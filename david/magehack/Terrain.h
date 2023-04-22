#ifndef __Terrain_H__
#define __Terrain_H__

#include "OpenGL.h"
#include "SmartPtr.h"

#include <vector>

namespace GL {
	class Texture;
};

class HeightMap;

/**
 * This class handles the terrain. As a first step, we just display a flat
 * square.
 */

class Terrain
	: public ReferenceCounted
{
public:

	Terrain(RefCountedPtr<const HeightMap> hMap);
	virtual ~Terrain();

	void initialise();
	void draw() const;
	float heightAt(float x, float y) const;
	GL::glVertex3D<GLfloat> normalAt(const GL::glVertex3D<GLfloat>& position) const;
	GL::glVertex3D<GLfloat> normalAtMap(int x, int y) const;
	float heightAt(const GL::glVertex3D<GLfloat>& point) { return heightAt(point.x(), point.z()); }

	std::vector< GL::glVertex3D<GLfloat> > intersectLine( const GL::glLine3D<GLfloat>& with );

	GL::glVertex2D<int> origin() const;
	GL::glVertex2D<int> size() const;

private:
	static const int theScale;
	static float scaleHeight(float height);
	float lookupHeightMap(int x, int y) const;
	void drawVertex(int x, int y) const;
	GL::glVertex3D<GLfloat> calcMapVertex(int x, int y) const;
	GL::glVertex3D<GLfloat> calcVertex(float x, float y) const;


	GLuint theTerrainList;
	RefCountedPtr<GL::Texture> theGras;
	RefCountedPtr<GL::Texture> theStones;
	RefCountedPtr<const HeightMap> theHeightMap;

};


#endif /* __Terrain_H__ */
