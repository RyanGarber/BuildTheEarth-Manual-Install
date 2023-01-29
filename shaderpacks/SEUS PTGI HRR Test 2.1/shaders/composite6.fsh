#version 330 compatibility

/*
 _______ _________ _______  _______  _
(  ____ \\__   __/(  ___  )(  ____ )( )
| (    \/   ) (   | (   ) || (    )|| |
| (_____    | |   | |   | || (____)|| |
(_____  )   | |   | |   | ||  _____)| |
      ) |   | |   | |   | || (      (_)
/\____) |   | |   | (___) || )       _
\_______)   )_(   (_______)|/       (_)

Do not modify this code until you have read the LICENSE.txt contained in the root directory of this shaderpack!

*/


#include "lib/Uniforms.inc"
#include "lib/Common.inc"
#include "lib/Materials.inc"


/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//fgdhghdf

/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////


const bool colortex2MipmapEnabled = true;
const bool colortex4MipmapEnabled = true;


in vec4 texcoord;
in vec3 lightVector;


in float timeSunriseSunset;
in float timeNoon;
in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;

in mat4 gbufferPreviousModelViewInverse;






#define CURR_COLOR_TEX colortex1
#define PREV_COLOR_TEX colortex3
#define TEMPORAL_DATA_TEX colortex2
#define DEPTHTEX depthtex0


 int f(int v)
 {
   return v-FloorToInt(mod(float(v),2.))-0;
 }
 int d(int v)
 {
   return v-FloorToInt(mod(float(v),2.))-1;
 }
 int d()
 {
   ivec2 v=ivec2(viewWidth,viewHeight);
   int y=v.x*v.y;
   return f(FloorToInt(floor(pow(float(y),.333333))));
 }
 int f()
 {
   ivec2 v=ivec2(2048,2048);
   int y=v.x*v.y;
   return d(FloorToInt(floor(pow(float(y),.333333))));
 }
 vec3 t(vec2 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=m.x*m.y,y=d();
   ivec2 f=ivec2(v.x*m.x,v.y*m.y);
   float z=float(f.y/y),i=float(int(f.x+mod(m.x*z,y))/y);
   i+=floor(m.x*z/y);
   vec3 c=vec3(0.,0.,i);
   c.x=mod(f.x+mod(m.x*z,y),y);
   c.y=mod(f.y,y);
   c.xyz=floor(c.xyz);
   c/=y;
   c.xyz=c.xzy;
   return c;
 }
 vec2 x(vec3 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=d();
   vec3 f=v.xzy*x;
   f=floor(f+1e-05);
   float y=f.z;
   vec2 i;
   i.x=mod(f.x+y*x,m.x);
   float c=f.x+y*x;
   i.y=f.y+floor(c/m.x)*x;
   i+=.5;
   i/=m;
   return i;
 }
 vec3 r(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,y=f();
   ivec2 c=ivec2(i.x*m.x,i.y*m.y);
   float z=float(c.y/y),r=float(int(c.x+mod(m.x*z,y))/y);
   r+=floor(m.x*z/y);
   vec3 n=vec3(0.,0.,r);
   n.x=mod(c.x+mod(m.x*z,y),y);
   n.y=mod(c.y,y);
   n.xyz=floor(n.xyz);
   n/=y;
   n.xyz=n.xzy;
   return n;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 f=v.xzy*y;
   f=floor(f+1e-05);
   float x=f.z;
   vec2 i;
   i.x=mod(f.x+x*y,m.x);
   float c=f.x+x*y;
   i.y=f.y+floor(c/m.x)*y;
   i+=.5;
   i/=m;
   i.xy*=.5;
   return i;
 }
 vec3 f(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 r(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v;
 }
 vec3 v(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 n(vec3 v)
 {
   int x=d();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 s(vec3 v)
 {
   int m=d();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 n()
 {
   vec3 v=cameraPosition.xyz+.5,y=previousCameraPosition.xyz+.5,x=floor(v-.0001),z=floor(y-.0001);
   return x-z;
 }
 vec3 m(vec3 v)
 {
   vec4 f=vec4(v,1.);
   f=shadowModelView*f;
   f=shadowProjection*f;
   f/=f.w;
   float x=sqrt(f.x*f.x+f.y*f.y),y=1.f-SHADOW_MAP_BIAS+x*SHADOW_MAP_BIAS;
   f.xy*=.95f/y;
   f.z=mix(f.z,.5,.8);
   f=f*.5f+.5f;
   f.xy*=.5;
   f.xy+=.5;
   return f.xyz;
 }
 vec3 d(vec3 v,vec3 f,vec2 m,vec2 n,vec4 c,vec4 i,inout float x,out vec2 y)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(i.x==8||i.x==9||i.x==79||i.x<1.||!r||i.x==20.||i.x==171.||min(abs(f.x),abs(f.z))>.2)
     x=1.;
   if(i.x==50.||i.x==52.||i.x==76.)
     {
       x=0.;
       if(f.y<.5)
         x=1.;
     }
   if(i.x==51||i.x==53)
     x=0.;
   if(i.x>255)
     x=0.;
   vec3 z,s;
   if(f.x>.5)
     z=vec3(0.,0.,-1.),s=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       z=vec3(0.,0.,1.),s=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         z=vec3(1.,0.,0.),s=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           z=vec3(1.,0.,0.),s=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             z=vec3(1.,0.,0.),s=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               z=vec3(-1.,0.,0.),s=vec3(0.,-1.,0.);
   y=clamp((m.xy-n.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,D=.15;
   if(i.x==10.||i.x==11.)
     {
       if(abs(f.y)<.01&&r||f.y>.99)
         h=.1,D=.1,x=0.;
       else
          x=1.;
     }
   if(i.x==51||i.x==53)
     h=.5,D=.1;
   if(i.x==76)
     h=.2,D=.2;
   if(i.x-255.+39.>=103.&&i.x-255.+39.<=113.)
     D=.025,h=.025;
   z=normalize(c.xyz);
   s=normalize(cross(z,f.xyz)*sign(c.w));
   vec3 e=v.xyz+mix(z*h,-z*h,vec3(y.x));
   e.xyz+=mix(s*h,-s*h,vec3(y.y));
   e.xyz-=f.xyz*D;
   return e;
 }struct SPcacsgCKo{vec3 GadGLQcpqX;vec3 GadGLQcpqXOrigin;vec3 vAdYwconYe;vec3 AZVxALDdtL;vec3 UekatYTTmj;vec3 OmcxSfXfkJ;};
 SPcacsgCKo p(Ray v)
 {
   SPcacsgCKo f;
   f.GadGLQcpqX=floor(v.origin);
   f.GadGLQcpqXOrigin=f.GadGLQcpqX;
   f.vAdYwconYe=abs(vec3(length(v.direction))/(v.direction+1e-07));
   f.AZVxALDdtL=sign(v.direction);
   f.UekatYTTmj=(sign(v.direction)*(f.GadGLQcpqX-v.origin)+sign(v.direction)*.5+.5)*f.vAdYwconYe;
   f.OmcxSfXfkJ=vec3(0.);
   return f;
 }
 void e(inout SPcacsgCKo v)
 {
   v.OmcxSfXfkJ=step(v.UekatYTTmj.xyz,v.UekatYTTmj.yzx)*step(v.UekatYTTmj.xyz,v.UekatYTTmj.zxy),v.UekatYTTmj+=v.OmcxSfXfkJ*v.vAdYwconYe,v.GadGLQcpqX+=v.OmcxSfXfkJ*v.AZVxALDdtL;
 }
 void d(in Ray v,in vec3 f[2],out float i,out float y)
 {
   float x,z,r,s;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   s=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,x),r);
   y=min(min(y,z),s);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(f+v)*.5,i=(f-v)*.5,c=y-z,r=vec3(0.);
   r+=vec3(sign(c.x),0.,0.)*step(abs(abs(c.x)-i.x),x);
   r+=vec3(0.,sign(c.y),0.)*step(abs(abs(c.y)-i.y),x);
   r+=vec3(0.,0.,sign(c.z))*step(abs(abs(c.z)-i.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),c=min(x,y),s=max(x,y);
   vec2 r=max(c.xx,c.yz);
   float z=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float n=min(r.x,r.y);
   i.x=z;
   i.y=n;
   return n>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),i=m.inv_direction*(f+1e-05-m.origin),c=min(i,z),s=max(i,z);
   vec2 r=max(c.xx,c.yz);
   float n=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float h=min(r.x,r.y);
   bool t=h>max(n,0.)&&max(n,0.)<x;
   if(t)
     y=d(v-1e-05,f+1e-05,m.origin+m.direction*n),x=n;
   return t;
 }
 vec3 e(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float n=.5;
   vec3 s=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*n),2).x;
   s*=saturate(dot(f,y));
   {
     vec4 c=texture2DLod(shadowcolor1,i.xy-vec2(0.,.5),4);
     float r=abs(c.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,f,r),D=shadow2DLod(shadowtex0,vec3(i.xy-vec2(0.,.5),i.z+1e-06),4).x;
     s=mix(s,s*h,1.-D);
   }
   s=TintUnderwaterDepth(s);
   return s*(1.-rainStrength);
 }
 vec3 f(vec3 y,vec3 f,vec3 x,vec3 z,int n)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=v(y);
   i+=1.;
   i-=Fract01(cameraPosition+.5);
   vec3 c=m(i+x*.99);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(c.xy,c.z-.0006*s),3).x;
   r*=saturate(dot(f,x));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float h=shadow2DLod(shadowtex0,vec3(c.xy-vec2(.5,0.),c.z-.0006*s),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(c.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-h));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*s),2).x;
   r*=saturate(dot(f,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*s),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-n));
   #endif
   return r*(1.-rainStrength);
 }struct CPrmwMXxJc{float pzBOsrqcFy;float ivaOqoXyFu;float OxTKjfMYEH;float avjkUoKnfB;vec3 PVAMAgODVh;};
 vec4 i(CPrmwMXxJc v)
 {
   vec4 i;
   v.PVAMAgODVh=max(vec3(0.),v.PVAMAgODVh);
   i.x=v.pzBOsrqcFy;
   v.PVAMAgODVh=pow(v.PVAMAgODVh,vec3(.125));
   i.y=PackTwo16BitTo32Bit(v.PVAMAgODVh.x,v.OxTKjfMYEH);
   i.z=PackTwo16BitTo32Bit(v.PVAMAgODVh.y,v.avjkUoKnfB);
   i.w=PackTwo16BitTo32Bit(v.PVAMAgODVh.z,v.ivaOqoXyFu/255.);
   return i;
 }
 CPrmwMXxJc h(vec4 v)
 {
   CPrmwMXxJc i;
   vec2 f=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),c=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=f.y;
   i.avjkUoKnfB=m.y;
   i.ivaOqoXyFu=c.y*255.;
   i.PVAMAgODVh=pow(vec3(f.x,m.x,c.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc c(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return h(texture2DLod(colortex5,v,0));
 }
 float c(float v,float y)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+y,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool c(vec3 v,float y,Ray x,bool f,inout float i,inout vec3 z)
 {
   bool m=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(f)
     return false;
   if(y>=67.)
     return false;
   r=d(v,v+vec3(1.,1.,1.),x,i,z);
   m=r;
   #else
   if(y<40.)
     return r=d(v,v+vec3(1.,1.,1.),x,i,z),r;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float s=.5;
       if(y==41.)
         s=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),x,i,z);
       m=m||r;
     }
   if(y==42.||y>=55.&&y<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),x,i,z),m=m||r;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float s=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         s=0.;
       r=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),x,i,z);
       m=m||r;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float s=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         s=0.;
       r=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),x,i,z);
       m=m||r;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float s=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         s=0.;
       r=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),x,i,z);
       m=m||r;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float s=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         s=0.;
       r=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),x,i,z);
       m=m||r;
     }
   if(y>=67.&&y<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,x,i,z),m=m||r;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float s=8.,c=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         s=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         c=16.;
       r=d(v+vec3(s,6.,7.)/16.,v+vec3(c,9.,9.)/16.,x,i,z);
       m=m||r;
       r=d(v+vec3(s,12.,7.)/16.,v+vec3(c,15.,9.)/16.,x,i,z);
       m=m||r;
     }
   if(y>=71.&&y<=82.)
     {
       float s=8.,c=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         c=16.;
       if(y>=75.&&y<=82.)
         s=0.;
       r=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,c)/16.,x,i,z);
       m=m||r;
       r=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,c)/16.,x,i,z);
       m=m||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 s=vec3(0),c=vec3(0);
       if(y==83.)
         s=vec3(0,0,0),c=vec3(16,16,3);
       if(y==84.)
         s=vec3(0,0,13),c=vec3(16,16,16);
       if(y==86.)
         s=vec3(0,0,0),c=vec3(3,16,16);
       if(y==85.)
         s=vec3(13,0,0),c=vec3(16,16,16);
       r=d(v+s/16.,v+c/16.,x,i,z);
       m=m||r;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 s=vec3(0.),c=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float h=0.;
           if(y>=91.&&y<=94.)
             h=13.;
           s=vec3(0.,h,0.)/16.;
           c=vec3(16.,h+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float n=13.;
           if(y==97.||y==98.)
             n=0.;
           s=vec3(0.,0.,n)/16.;
           c=vec3(16.,16.,n+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float n=13.;
           if(y==99.||y==100.)
             n=0.;
           s=vec3(n,0.,0.)/16.;
           c=vec3(n+3.,16.,16.)/16.;
         }
       r=d(v+s,v+c,x,i,z);
       m=m||r;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 s=vec3(0.),c=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float n=float(y)-float(103.)+1.;
           c.y=n*2./16.;
         }
       if(y==111.)
         c.y=.0625;
       if(y==112.)
         s=vec3(1.,0.,1.)/16.,c=vec3(15.,1.,15.)/16.;
       if(y==113.)
         s=vec3(1.,0.,1.)/16.,c=vec3(15.,.5,15.)/16.;
       r=d(v+s,v+c,x,i,z);
       m=m||r;
     }
   #endif
   #endif
   return m;
 }
 vec3 w(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight));
   y*=1./64.;
   const vec2 f[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   y=(floor(y*64.)+.5)/64.;
   vec3 i=texture2D(noisetex,y).xyz,x=vec3(sqrt(.2),sqrt(2.),1.61803);
   i=mod(i+float(frameCounter%64)*x,vec3(1.));
   return i;
 }
 vec2 c(vec2 v,float m,float x,out float y)
 {
   vec2 s=v;
   y=m;
   vec2 r=x*ScreenTexel;
   for(int i=-1;i<=1;i+=2)
     {
       for(int z=-1;z<=1;z+=2)
         {
           vec2 f=v+vec2(i,z)*r;
           float c=texture2DLod(DEPTHTEX,f,0).x;
           if(c<y)
             y=c,s=f;
         }
     }
   return s;
 }
 vec3 D(vec3 y)
 {
   mat3 v=mat3(.2126,.7152,.0722,-.09991,-.33609,.436,.615,-.55861,-.05639);
   return y*v;
 }
 vec3 g(vec3 y)
 {
   mat3 v=mat3(1.,0.,1.28033,1.,-.21482,-.38059,1.,2.12798,0.);
   return y*v;
 }
 vec3 D(vec3 v,vec3 y,vec3 x,vec3 m)
 {
   vec3 z=.5*(y+v),s=.5*(y-v),c=m-z,i=c/s,f=abs(i);
   float r=max(f.x,max(f.y,f.z));
   if(r>1.)
     return z+c/r;
   else
      return m;
 }
 vec4 a(vec2 v)
 {
   return pow(texture2DLod(PREV_COLOR_TEX,v,0),vec4(vec3(1./2.2),1.));
 }
 vec4 G(vec2 v)
 {
   vec2 y=ScreenSize,m=ScreenTexel,f=v*y,x=floor(f-.5)+.5,s=f-x,z=s*s,i=s*z;
   float r=.25;
   vec2 c=-r*i+2.*r*z-r*s,n=(2.-r)*i-(3.-r)*z+1.,h=-(2.-r)*i+(3.-2.*r)*z+r*s,D=r*i-r*z,t=n+h,d=m*(x+h/t);
   vec4 e=a(vec2(d.x,d.y));
   vec2 o=m*(x-1.),H=m*(x+2.);
   vec4 G=vec4(a(vec2(d.x,o.y)).xyz,1.)*(t.x*c.y)+vec4(a(vec2(o.x,d.y)).xyz,1.)*(c.x*t.y)+vec4(e.xyz,1.)*(t.x*t.y)+vec4(a(vec2(H.x,d.y)).xyz,1.)*(D.x*t.y)+vec4(a(vec2(d.x,H.y)).xyz,1.)*(t.x*D.y);
   return pow(vec4(max(vec3(0.),G.xyz*(1./G.w)),e.w),vec4(vec3(2.2),1.));
 }
 void D(vec2 v,float x,out vec3 y,out vec3 i,out vec4 m)
 {
   vec4 f=vec4(v.xy*2.-1.,x*2.-1.,1.),c=gbufferProjectionInverse*f;
   c.xyz/=c.w;
   m=gbufferModelViewInverse*vec4(c.xyz,1.);
   vec4 r=m;
   r.xyz+=cameraPosition-previousCameraPosition;
   vec4 s=gbufferPreviousModelView*vec4(r.xyz,1.),z=gbufferPreviousProjection*vec4(s.xyz,1.);
   z.xyz/=z.w;
   y=f.xyz-z.xyz;
   vec4 n=gbufferModelView*vec4(r.xyz,1.),e=gbufferProjection*vec4(n.xyz,1.);
   e.xyz/=e.w;
   i=f.xyz-e.xyz;
 }
 vec3 D(vec2 v,float y)
 {
   vec4 f=GetViewPosition(v,y);
   return(gbufferModelViewInverse*vec4(f.xyz,1.)).xyz;
 }
 vec4 F(vec2 v)
 {
   return texture2DLod(CURR_COLOR_TEX,v+HalfScreen,0);
 }
 float F(vec3 v,vec3 y)
 {
   return max(max(abs(v.x-y.x),abs(v.y-y.y)),abs(v.z-y.z));
 }
 void main()
 {
   vec3 y=vec3(0.);
   vec2 v=DownscaleTexcoord(texcoord.xy),s=JitterSampleOffset(0),x=s*ScreenTexel;
   ivec2 m=ivec2(floor(texcoord.xy*ScreenSize+floor(s)));
   float f=m%DOWNSCALE_FACTOR_MULT==ivec2(0)?1.:0.,r=f;
   vec4 n=F(LockRenderPixelCoord(v));
   vec3 z=n.xyz,h=z;
   int t=FloorToInt(n.w*255.+.1);
   float a,e=texture2DLod(DEPTHTEX,v,0).x,o=texture2DLod(depthtex1,v,0).x;
   vec2 d=c(v,e,1.,a);
   vec3 H,l;
   vec4 w;
   D(d*2.,a,H,l,w);
   float p=length(H.xy)*.2;
   if(e<.7)
     H*=0.;
   vec2 R=texcoord.xy-H.xy*.5,X=cos((fract(abs(texcoord.xy-R.xy)*ScreenSize)*2.-1.)*3.14159)*.5+.5,u=pow(X,vec2(.5));
   vec4 S=G(R.xy);
   float J=texture2D(PREV_COLOR_TEX,R.xy).w;
   const int O=4;
   vec3 C=vec3(0.),b=vec3(0.),Y=vec3(0.);
   const float T=.7;
   for(int P=-1;P<=1;P+=2)
     {
       for(int B=-1;B<=1;B+=2)
         {
           vec3 L=texture2DLod(CURR_COLOR_TEX,v.xy+vec2(P,B)*T*ScreenTexel+HalfScreen,0).xyz;
           C+=L;
           L=D(L);
           b+=L;
           Y+=L*L;
         }
     }
   b*=.25;
   Y*=.25;
   C*=.25;
   CPrmwMXxJc L=c(texcoord.xy);
   L.ivaOqoXyFu+=1.;
   float P=20.,B=1.;
   P=mix(10.,2.5,saturate(p*110.));
   #ifdef GREEDY_TAA
   #endif
   float A=0.,j=0.;
   vec3 E=vec3(0.);
   {
     {
       vec2 U=texcoord.xy;
       U+=JitterSampleOffset(0)*ScreenTexel;
       float M=0.;
       for(int V=1;V<=2;V++)
         {
           vec2 I=ScreenTexel*exp2(float(V))*.5;
           vec4 q=(texture2DLod(colortex2,DownscaleTexcoord(U.xy)+vec2(0.,HalfScreen.y)+I.xy*vec2(1.,1.),V)+texture2DLod(colortex2,DownscaleTexcoord(U.xy)+vec2(0.,HalfScreen.y)+I.xy*vec2(1.,-1.),V)+texture2DLod(colortex2,DownscaleTexcoord(U.xy)+vec2(0.,HalfScreen.y)+I.xy*vec2(-1.,1.),V)+texture2DLod(colortex2,DownscaleTexcoord(U.xy)+vec2(0.,HalfScreen.y)+I.xy*vec2(-1.,-1.),V))*.25;
           vec3 k=q.xyz;
           float W=pow(q.w,1.);
           vec3 N=(texture2DLod(colortex2,DownscaleTexcoord(R.xy)+HalfScreen+I.xy*vec2(1.,1.),V).xyz+texture2DLod(colortex2,DownscaleTexcoord(R.xy)+HalfScreen+I.xy*vec2(1.,-1.),V).xyz+texture2DLod(colortex2,DownscaleTexcoord(R.xy)+HalfScreen+I.xy*vec2(-1.,1.),V).xyz+texture2DLod(colortex2,DownscaleTexcoord(R.xy)+HalfScreen+I.xy*vec2(-1.,-1.),V).xyz)*.25;
           float K=1./(W+1e-09),Q=F(k,N)*K;
           E=vec3(W);
           Q*=200.;
           Q*=exp2(float(V));
           M+=Q;
         }
       A=M*mix(.01,.02,saturate(p*50.))*.011*6.;
       if(t==MAT_ID_DYNAMIC_ENTITY||t==MAT_ID_HAND)
         A*=6.;
       else
          if(e<o)
           A*=4.;
     }
     j=0.;
     {
       vec4 U=gbufferProjectionInverse*vec4(R.xy*2.-1.,J*2.-1.,1.);
       U/=U.w;
       vec3 V=(gbufferPreviousModelViewInverse*vec4(U.xyz,1.)).xyz;
       V+=previousCameraPosition;
       V-=cameraPosition;
       float Q=length(w.xyz-V)/(length(w.xyz)+.001);
       Q=max(0.,Q-.05);
       A*=mix(1.,mix(3.,110.,saturate(p*1800.)),saturate(Q*2.));
       j=saturate(Q*15.);
     }
     float V=exp(-A);
     f=mix(1.,f,V);
     B=mix(1.,B,V);
     if(V<.95)
       z=mix(F(v-HalfScreen+JitterSampleOffset(0)*ScreenTexel*.5).xyz,z,vec3(V));
     L.ivaOqoXyFu*=exp(-A*.1);
   }
   L.ivaOqoXyFu=min(L.ivaOqoXyFu,128.);
   if(R.x<0.||R.x>1.||R.y<0.||R.y>1.)
     B=1.,f=1.,L.ivaOqoXyFu=0.;
   if(ExpToLinearDepth(e)-ExpToLinearDepth(a)>.9)
     P*=exp(-(length(l.xy)*length(z.xyz-S.xyz)/(length(z)+1e-07))*400.);
   vec3 V=sqrt(max(vec3(0.),Y-b*b)),U=b-P*V,Q=b+P*V;
   S.xyz=g(D(U,Q,z.xyz,D(S.xyz)));
   #ifdef SKIP_AA
   f=1.;
   B=1.;
   #endif
   vec3 W=mix(S.xyz,z,vec3(B*f));
   W=max(vec3(0.),W);
   gl_FragData[0]=vec4(E,j);
   gl_FragData[1]=vec4(W,a);
   gl_FragData[2]=i(L);
   gl_FragData[3]=vec4(R.xy,0.,1.);
 };




/* DRAWBUFFERS:2357 */
