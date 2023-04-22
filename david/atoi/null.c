#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#if (OPTIM == 1)
#define ATOI atoi_C
const int d9[]= { 0000000000, 1000000000, 2000000000, 2000000000, 2000000000, 2000000000, 2000000000, 2000000000, 2000000000, 2000000000, };
const int d8[]= { 000000000, 100000000, 200000000, 300000000, 400000000, 500000000, 600000000, 700000000, 800000000, 900000000, };
const int d7[]= { 00000000, 10000000, 20000000, 30000000, 40000000, 50000000, 60000000, 70000000, 80000000, 90000000, };
const int d6[]= { 0000000, 1000000, 2000000, 3000000, 4000000, 5000000, 6000000, 7000000, 8000000, 9000000, };
const int d5[]= { 000000, 100000, 200000, 300000, 400000, 500000, 600000, 700000, 800000, 900000, };
const int d4[]= { 00000, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, };
const int d3[]= { 0000, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, };
const int d2[]= { 000, 100, 200, 300, 400, 500, 600, 700, 800, 900, };
const int d1[]= { 00, 10, 20, 30, 40, 50, 60, 70, 80, 90, };

static int atoi_C(const char *a)
{
   int i=0, m=0;
   while (*a==' '||*a=='\t')  ++a;
   if (*a=='-'&&(m=1,1)||*a=='+')  ++a;
   while (*a=='0')  ++a;

   if (a[0]>'9'||a[0]<'0')  goto ADD0;
   if (a[1]>'9'||a[1]<'0')  {       goto ADD1; }
   if (a[2]>'9'||a[2]<'0')  { a+=1; goto ADD2; }
   if (a[3]>'9'||a[3]<'0')  { a+=2; goto ADD3; }
   if (a[4]>'9'||a[4]<'0')  { a+=3; goto ADD4; }
   if (a[5]>'9'||a[5]<'0')  { a+=4; goto ADD5; }
   if (a[6]>'9'||a[6]<'0')  { a+=5; goto ADD6; }
   if (a[7]>'9'||a[7]<'0')  { a+=6; goto ADD7; }
   if (a[8]>'9'||a[8]<'0')  { a+=7; goto ADD8; }
   if (a[9]>'9'||a[9]<'0')  { a+=8; goto ADD9; }
                              a+=9;
          i+= d9[a[-9]-'0'];
   ADD9:  i+= d8[a[-8]-'0'];
   ADD8:  i+= d7[a[-7]-'0'];
   ADD7:  i+= d6[a[-6]-'0'];
   ADD6:  i+= d5[a[-5]-'0'];
   ADD5:  i+= d4[a[-4]-'0'];
   ADD4:  i+= d3[a[-3]-'0'];
   ADD3:  i+= d2[a[-2]-'0'];
   ADD2:  i+= d1[a[-1]-'0'];
   ADD1:  i+=    a[ 0]-'0';
   ADD0:;
   return (m?-i:i);
}

#else 
#include <stdlib.h>
#define ATOI atoi
#endif

int main(int argc, char * argv) 
{
	char buf[4098];
	char * tmp;
	long result = 0;
	int fd = open("test.in", O_RDONLY);
	while ( read (fd, buf, sizeof( buf) ) > 0 )
	{
		tmp = buf + 4096;
		while(tmp != buf)
			if (*--tmp == ' ') result += *tmp;
	}
	printf("%d\n",result);
	exit (0);
}
