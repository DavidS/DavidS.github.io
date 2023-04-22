#include "Terrain.h"

#include "HeightMap.h"
#include "OpenGL.h"
#include "Texture.h"

#include <SDL.h>
#include <cmath>
#include <iostream>

using namespace GL;
using namespace std;

const int Terrain::theScale = 5;
static int ncount = 0;

glVertex2D<int> Terrain::origin() const
{
	return theHeightMap->origin() * theScale;
}

glVertex2D<int> Terrain::size() const
{
	return theHeightMap->size() * theScale;
}

vector< GL::glVertex3D<GLfloat> > Terrain::intersectLine( const glLine3D<GLfloat>& line )
{
	vector< GL::glVertex3D<GLfloat> > result;
	
	GLfloat stepSize = line.unityParameter() / 2.0f;

	glVertex3D<GLfloat> lastHitTest = line.position();
	GLfloat lastHitHeight = lastHitTest.y() - heightAt(lastHitTest);

	for (int steps = 1; steps < 1024; steps ++)
	{
		glVertex3D<GLfloat> hitTest = line.positionAt(stepSize*steps);
		GLfloat hitHeight = hitTest.y() - heightAt(hitTest);
		// if signs differ, the line has changed from below to above the terrain (or vice-versa)
		if ( ((hitHeight <= 0.0f) && (lastHitHeight > 0.0f))
			|| ((lastHitHeight <= 0.0f) && (hitHeight > 0.0f)) )
		{
			// get midpoint
			glVertex3D<GLfloat> hit(line.positionAt(stepSize*(float(steps)-0.5)));
			hit.y() = heightAt(hit);
			result.push_back(hit);
		}
		lastHitTest = hitTest;
		lastHitHeight = hitHeight;
	}
	
	return result;
}

float Terrain::lookupHeightMap(int x, int y) const
{
	float heightOffset = 0.0f;

	glVertex2D<GLint> origin = theHeightMap->origin();
	glVertex2D<GLint> originSize = origin + theHeightMap->size() ;

	if (x < origin.x()) 
	{
		x = origin.x();
		heightOffset += 30;
	}
	else if (x > originSize.x())
	{
		x = originSize.x();
		heightOffset += 30;
	}

	if (y < origin.y()) 
	{
		y = origin.y();
		heightOffset += 30;
	}
	else if (y > originSize.y())
	{
		y = originSize.y();
		heightOffset += 30;
	}

	return heightOffset + theHeightMap->heightAt(x,y);

	//return sin((float)x*y / 10);
	// return x*y / 1000.0;
}

glVertex3D<GLfloat> Terrain::normalAt(const glVertex3D<GLfloat>& pos) const
{
	// FIXME: interpolate correctly
	// return normalAtMap((int)floor(pos.x()), (int)floor(pos.y()));
	return makeVertex(0.0f, 1.0f, 0.0f);
}

glVertex3D<GLfloat> Terrain::normalAtMap(int x, int y) const
{
	glVertex3D<GLfloat> vertex = calcMapVertex(x,y);
	glVertex3D<GLfloat> neighbours[]
	= {
		calcMapVertex(x  ,y+1) - vertex,
		calcMapVertex(x-1,y  ) - vertex,
		calcMapVertex(x  ,y-1) - vertex,
		calcMapVertex(x+1,y  ) - vertex,
	};

	// average over the normals of all four adjacent faces
	glVertex3D<GLfloat> normal(0.0f, 0.0f, 0.0f);
	for (int i = 0; i < 4; ++i)
	{
		normal += neighbours[(i+1) % 4].cross(neighbours[i]);
	}
	normal.normalize();
	return normal;
}


float Terrain::heightAt(float x, float y) const
{
	// scale to Data-units.
	x /= theScale;
	y /= theScale;

	float floorX = floorf(x);
	float floorY = floorf(y);

	float offX = x - floorX;
	float offY = y - floorY;

	float ceilX = ceilf(x);
	float ceilY = ceilf(y);


	float result = 0.0f;
	if (offX + offY < 1.0f)
	{
		float avgLowerY = (1-offX)*lookupHeightMap((int)floorX, (int)floorY)
			+ offX*lookupHeightMap((int)ceilX , (int)floorY);
		float avgUpperY = (1-offX)*lookupHeightMap((int)floorX, (int)ceilY)
			+ offX*lookupHeightMap((int)ceilX , (int)floorY);

		float scale = offY / (1-offX);
		result =  ((1-scale)*avgLowerY + scale*avgUpperY);
	}
	else
	{
		float avgLowerY = (1-offX)*lookupHeightMap((int)floorX, (int) ceilY)
			+ offX*lookupHeightMap((int)ceilX , (int) floorY);
		float avgUpperY = (1-offX)*lookupHeightMap((int)floorX, (int) ceilY)
			+ offX*lookupHeightMap((int)ceilX , (int) ceilY);

		float scale = (1-offY) / offX;
		result =  (scale*avgLowerY + (1-scale)*avgUpperY);
	} 
	return scaleHeight(result);
}

float Terrain::scaleHeight(float height)
{
	return (height*theScale) / 10.0f;
}

glVertex3D<GLfloat> Terrain::calcVertex(float x, float y) const
{
	return glVertex3D<GLfloat>(x, heightAt(x,y), y);
}

glVertex3D<GLfloat> Terrain::calcMapVertex(int x, int y) const
{
	return glVertex3D<GLfloat>(x, scaleHeight(lookupHeightMap(x,y)), y);
}

glVertex3D<GLfloat> lightVector()
{
	static glVertex3D<GLfloat> light(1.0, 1.0, 1.0);
	static bool normalized = false;
	if (!normalized)
	{
		light.normalize();
		normalized = true;
	}
	return light;
}

void Terrain::drawVertex(int x, int y) const
{
	glVertex3D<GLfloat> vertex = calcMapVertex(x,y);
	glNormal(normalAtMap(x, y));
	
	vertex.x() *= theScale;
	vertex.z() *= theScale;

	glVertex(vertex);
}

Terrain::Terrain(RefCountedPtr<const HeightMap> hMap)
: theTerrainList(glGenLists(1)),
	theGras(Texture::loadTexture("textures/grassy.bmp")),
	theStones(Texture::loadTexture("textures/stony.bmp")),
	theHeightMap(hMap)
{
}

void Terrain::initialise()
{
	Uint32 startTime = SDL_GetTicks();
	glNewList(theTerrainList, GL_COMPILE);
	glColor3f(1,1,1);
	theGras->enable();
	for (int x = ( theHeightMap->origin().x() - 2 );
			x < ( theHeightMap->origin().x() + theHeightMap->size().x() + 2);
			x += 1 )
	{
		glBegin( GL_TRIANGLE_STRIP );
		// glBegin( GL_POINTS );
		for (int z = ( theHeightMap->origin().y() - 2);
				z < ( theHeightMap->origin().y() + theHeightMap->size().y() + 2);
				z += 1 )
		{
			glTexCoord(0, 0);
			drawVertex(x  , z  );
			glTexCoord(1, 0);
			drawVertex(x+1, z  );
			glTexCoord(0, 1);
			drawVertex(x  , z+1);
			glTexCoord(1, 1);
			drawVertex(x+1, z+1);
		}
		glEnd();
	}
	theGras->disable();
	glEndList();
	cout << "calculated " << ncount << " normals" << endl;
	cout << "took " << ( SDL_GetTicks() - startTime ) << " ms" << endl;
}

Terrain::~Terrain() 
{
	glDeleteLists(theTerrainList,1);
}

void Terrain::draw() const
{
	glCallList(theTerrainList);
}

