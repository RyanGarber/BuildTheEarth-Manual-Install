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





in vec4 texcoord;
in vec3 lightVector;

in float timeSunriseSunset;
in float timeNoon;
in float timeMidnight;
in float timeSkyDark;

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorSunglow;
in vec3 colorBouncedSunlight;
in vec3 colorScatteredSunlight;
in vec3 colorTorchlight;
in vec3 colorWaterMurk;
in vec3 colorWaterBlue;
in vec3 colorSkyTint;



in vec3 upVector;



#include "lib/GBufferData.inc"


 int f(int v)
 {
   return v-FloorToInt(mod(float(v),2.))-0;
 }
 int t(int v)
 {
   return v-FloorToInt(mod(float(v),2.))-1;
 }
 int f()
 {
   ivec2 v=ivec2(viewWidth,viewHeight);
   int y=v.x*v.y;
   return f(FloorToInt(floor(pow(float(y),.333333))));
 }
 int t()
 {
   ivec2 v=ivec2(2048,2048);
   int y=v.x*v.y;
   return t(FloorToInt(floor(pow(float(y),.333333))));
 }
 vec3 d(vec2 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=m.x*m.y,y=f();
   ivec2 d=ivec2(v.x*m.x,v.y*m.y);
   float z=float(d.y/y),i=float(int(d.x+mod(m.x*z,y))/y);
   i+=floor(m.x*z/y);
   vec3 s=vec3(0.,0.,i);
   s.x=mod(d.x+mod(m.x*z,y),y);
   s.y=mod(d.y,y);
   s.xyz=floor(s.xyz);
   s/=y;
   s.xyz=s.xzy;
   return s;
 }
 vec2 n(vec3 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=f();
   vec3 i=v.xzy*x;
   i=floor(i+1e-05);
   float y=i.z;
   vec2 r;
   r.x=mod(i.x+y*x,m.x);
   float s=i.x+y*x;
   r.y=i.y+floor(s/m.x)*x;
   r+=.5;
   r/=m;
   return r;
 }
 vec3 x(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,y=t();
   ivec2 d=ivec2(i.x*m.x,i.y*m.y);
   float z=float(d.y/y),f=float(int(d.x+mod(m.x*z,y))/y);
   f+=floor(m.x*z/y);
   vec3 s=vec3(0.,0.,f);
   s.x=mod(d.x+mod(m.x*z,y),y);
   s.y=mod(d.y,y);
   s.xyz=floor(s.xyz);
   s/=y;
   s.xyz=s.xzy;
   return s;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 f;
   f.x=mod(i.x+x*y,m.x);
   float s=i.x+x*y;
   f.y=i.y+floor(s/m.x)*y;
   f+=.5;
   f/=m;
   f.xy*=.5;
   return f;
 }
 vec3 f(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 n(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v;
 }
 vec3 v(vec3 v)
 {
   int m=t();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 s(vec3 v)
 {
   int y=f();
   v*=1./y;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 e(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 d()
 {
   vec3 v=cameraPosition.xyz+.5,i=previousCameraPosition.xyz+.5,y=floor(v-.0001),x=floor(i-.0001);
   return y-x;
 }
 vec3 m(vec3 v)
 {
   vec4 i=vec4(v,1.);
   i=shadowModelView*i;
   i=shadowProjection*i;
   i/=i.w;
   float x=sqrt(i.x*i.x+i.y*i.y),y=1.f-SHADOW_MAP_BIAS+x*SHADOW_MAP_BIAS;
   i.xy*=.95f/y;
   i.z=mix(i.z,.5,.8);
   i=i*.5f+.5f;
   i.xy*=.5;
   i.xy+=.5;
   return i.xyz;
 }
 vec3 d(vec3 v,vec3 i,vec2 s,vec2 d,vec4 m,vec4 f,inout float x,out vec2 y)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(f.x==8||f.x==9||f.x==79||f.x<1.||!r||f.x==20.||f.x==171.||min(abs(i.x),abs(i.z))>.2)
     x=1.;
   if(f.x==50.||f.x==52.||f.x==76.)
     {
       x=0.;
       if(i.y<.5)
         x=1.;
     }
   if(f.x==51||f.x==53)
     x=0.;
   if(f.x>255)
     x=0.;
   vec3 z,c;
   if(i.x>.5)
     z=vec3(0.,0.,-1.),c=vec3(0.,-1.,0.);
   else
      if(i.x<-.5)
       z=vec3(0.,0.,1.),c=vec3(0.,-1.,0.);
     else
        if(i.y>.5)
         z=vec3(1.,0.,0.),c=vec3(0.,0.,1.);
       else
          if(i.y<-.5)
           z=vec3(1.,0.,0.),c=vec3(0.,0.,-1.);
         else
            if(i.z>.5)
             z=vec3(1.,0.,0.),c=vec3(0.,-1.,0.);
           else
              if(i.z<-.5)
               z=vec3(-1.,0.,0.),c=vec3(0.,-1.,0.);
   y=clamp((s.xy-d.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,S=.15;
   if(f.x==10.||f.x==11.)
     {
       if(abs(i.y)<.01&&r||i.y>.99)
         h=.1,S=.1,x=0.;
       else
          x=1.;
     }
   if(f.x==51||f.x==53)
     h=.5,S=.1;
   if(f.x==76)
     h=.2,S=.2;
   if(f.x-255.+39.>=103.&&f.x-255.+39.<=113.)
     S=.025,h=.025;
   z=normalize(m.xyz);
   c=normalize(cross(z,i.xyz)*sign(m.w));
   vec3 n=v.xyz+mix(z*h,-z*h,vec3(y.x));
   n.xyz+=mix(c*h,-c*h,vec3(y.y));
   n.xyz-=i.xyz*S;
   return n;
 }struct SPcacsgCKo{vec3 GadGLQcpqX;vec3 GadGLQcpqXOrigin;vec3 vAdYwconYe;vec3 AZVxALDdtL;vec3 UekatYTTmj;vec3 OmcxSfXfkJ;};
 SPcacsgCKo r(Ray v)
 {
   SPcacsgCKo i;
   i.GadGLQcpqX=floor(v.origin);
   i.GadGLQcpqXOrigin=i.GadGLQcpqX;
   i.vAdYwconYe=abs(vec3(length(v.direction))/(v.direction+1e-07));
   i.AZVxALDdtL=sign(v.direction);
   i.UekatYTTmj=(sign(v.direction)*(i.GadGLQcpqX-v.origin)+sign(v.direction)*.5+.5)*i.vAdYwconYe;
   i.OmcxSfXfkJ=vec3(0.);
   return i;
 }
 void p(inout SPcacsgCKo v)
 {
   v.OmcxSfXfkJ=step(v.UekatYTTmj.xyz,v.UekatYTTmj.yzx)*step(v.UekatYTTmj.xyz,v.UekatYTTmj.zxy),v.UekatYTTmj+=v.OmcxSfXfkJ*v.vAdYwconYe,v.GadGLQcpqX+=v.OmcxSfXfkJ*v.AZVxALDdtL;
 }
 void d(in Ray v,in vec3 i[2],out float f,out float y)
 {
   float x,z,r,s;
   f=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   s=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   f=max(max(f,x),r);
   y=min(min(y,z),s);
 }
 vec3 d(const vec3 v,const vec3 i,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(i+v)*.5,f=(i-v)*.5,s=y-z,r=vec3(0.);
   r+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-f.x),x);
   r+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-f.y),x);
   r+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-f.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 i,Ray m,out vec2 f)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(i-m.origin),s=min(x,y),d=max(x,y);
   vec2 r=max(s.xx,s.yz);
   float z=max(r.x,r.y);
   r=min(d.xx,d.yz);
   float c=min(r.x,r.y);
   f.x=z;
   f.y=c;
   return c>max(z,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(i+1e-05-m.origin),f=min(s,z),c=max(s,z);
   vec2 r=max(f.xx,f.yz);
   float n=max(r.x,r.y);
   r=min(c.xx,c.yz);
   float h=min(r.x,r.y);
   bool t=h>max(n,0.)&&max(n,0.)<x;
   if(t)
     y=d(v-1e-05,i+1e-05,m.origin+m.direction*n),x=n;
   return t;
 }
 vec3 e(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 f=m(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(f.xy,f.z-.0006*s),2).x;
   r*=saturate(dot(i,y));
   {
     vec4 d=texture2DLod(shadowcolor1,f.xy-vec2(0.,.5),4);
     float c=abs(d.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,i,c),t=shadow2DLod(shadowtex0,vec3(f.xy-vec2(0.,.5),f.z+1e-06),4).x;
     r=mix(r,r*h,1.-t);
   }
   r=TintUnderwaterDepth(r);
   return r*(1.-rainStrength);
 }
 vec3 f(vec3 y,vec3 i,vec3 x,vec3 z,int f)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 r=v(y);
   r+=1.;
   r-=Fract01(cameraPosition+.5);
   vec3 s=m(r+x*.99);
   float h=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*h),3).x;
   c*=saturate(dot(i,x));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*h),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   c=mix(c,c*e,vec3(1.-n));
   #endif
   return c*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 f=m(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(f.xy,f.z-.0006*s),2).x;
   r*=saturate(dot(i,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(f.xy-vec2(.5,0.),f.z-.0006*s),3).x;
   vec3 c=texture2DLod(shadowcolor,vec2(f.xy-vec2(.5,0.)),3).xyz;
   c*=c;
   r=mix(r,r*c,vec3(1.-n));
   #endif
   return r*(1.-rainStrength);
 }struct CPrmwMXxJc{float pzBOsrqcFy;float ivaOqoXyFu;float OxTKjfMYEH;float avjkUoKnfB;vec3 PVAMAgODVh;};
 vec4 w(CPrmwMXxJc v)
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
   vec2 f=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),s=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=f.y;
   i.avjkUoKnfB=m.y;
   i.ivaOqoXyFu=s.y*255.;
   i.PVAMAgODVh=pow(vec3(f.x,m.x,s.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc i(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return h(texture2DLod(colortex5,v,0));
 }
 float e(float v,float y)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+y,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool d(vec3 v,float y,Ray i,bool x,inout float f,inout vec3 z)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(x)
     return false;
   if(y>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),i,f,z);
   r=m;
   #else
   if(y<40.)
     return m=d(v,v+vec3(1.,1.,1.),i,f,z),m;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float s=.5;
       if(y==41.)
         s=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),i,f,z);
       r=r||m;
     }
   if(y==42.||y>=55.&&y<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,f,z),r=r||m;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float s=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         s=0.;
       m=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),i,f,z);
       r=r||m;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float s=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         s=0.;
       m=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),i,f,z);
       r=r||m;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float s=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         s=0.;
       m=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),i,f,z);
       r=r||m;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float s=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         s=0.;
       m=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),i,f,z);
       r=r||m;
     }
   if(y>=67.&&y<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,f,z),r=r||m;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float s=8.,c=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         s=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         c=16.;
       m=d(v+vec3(s,6.,7.)/16.,v+vec3(c,9.,9.)/16.,i,f,z);
       r=r||m;
       m=d(v+vec3(s,12.,7.)/16.,v+vec3(c,15.,9.)/16.,i,f,z);
       r=r||m;
     }
   if(y>=71.&&y<=82.)
     {
       float s=8.,c=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         c=16.;
       if(y>=75.&&y<=82.)
         s=0.;
       m=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,c)/16.,i,f,z);
       r=r||m;
       m=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,c)/16.,i,f,z);
       r=r||m;
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
       m=d(v+s/16.,v+c/16.,i,f,z);
       r=r||m;
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
           float h=13.;
           if(y==97.||y==98.)
             h=0.;
           s=vec3(0.,0.,h)/16.;
           c=vec3(16.,16.,h+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float h=13.;
           if(y==99.||y==100.)
             h=0.;
           s=vec3(h,0.,0.)/16.;
           c=vec3(h+3.,16.,16.)/16.;
         }
       m=d(v+s,v+c,i,f,z);
       r=r||m;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 s=vec3(0.),c=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float h=float(y)-float(103.)+1.;
           c.y=h*2./16.;
         }
       if(y==111.)
         c.y=.0625;
       if(y==112.)
         s=vec3(1.,0.,1.)/16.,c=vec3(15.,1.,15.)/16.;
       if(y==113.)
         s=vec3(1.,0.,1.)/16.,c=vec3(15.,.5,15.)/16.;
       m=d(v+s,v+c,i,f,z);
       r=r||m;
     }
   #endif
   #endif
   return r;
 }
 vec3 G(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight));
   y*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   y=(floor(y*64.)+.5)/64.;
   vec3 r=texture2D(noisetex,y).xyz,s=vec3(sqrt(.2),sqrt(2.),1.61803);
   r=mod(r+float(frameCounter%64)*s,vec3(1.));
   return r;
 }
 float G(float v,float y)
 {
   return exp(-pow(v/(.9*y),2.));
 }
 float h(vec3 v,vec3 y)
 {
   return dot(abs(v-y),vec3(.3333));
 }
 vec3 R(vec2 v)
 {
   vec2 y=vec2(v.xy*ScreenSize)/64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   y=(floor(y*64.)+.5)/64.;
   vec3 r=texture2D(noisetex,y).xyz,s=vec3(sqrt(.2),sqrt(2.),1.61803);
   r=mod(r+vec3(s)*mod(frameCounter,64.f),vec3(1.));
   return r;
 }
 vec3 G(float v,float m,float i,vec3 y)
 {
   vec3 f;
   f.x=i*cos(v);
   f.y=i*sin(v);
   f.z=m;
   vec3 s=abs(y.y)<.999?vec3(0,0,1):vec3(1,0,0),x=normalize(cross(y,vec3(0.,1.,1.))),c=cross(x,y);
   return x*f.x+c*f.y+y*f.z;
 }
 vec3 G(vec2 v,float y,vec3 z)
 {
   float s=2*3.14159*v.x,x=sqrt((1-v.y)/(1+(y*y-1)*v.y)),i=sqrt(1-x*x);
   return G(s,x,i,z);
 }
 float c(float v)
 {
   return 2./(v*v+1e-07)-2.;
 }
 vec3 R(in vec2 v,in float y,in vec3 z)
 {
   float s=c(y),i=2*3.14159*v.x,x=pow(v.y,1.f/(s+1.f)),f=sqrt(1-x*x);
   return G(i,x,f,z);
 }
 float a(vec2 v)
 {
   return texture2DLod(colortex1,v+HalfScreen,0).w;
 }
 float R(float v,float y)
 {
   return v/(y*20.01+1.);
 }
 vec2 a(vec2 v,float y)
 {
   vec2 s=v;
   mat2 x=mat2(cos(y),-sin(y),sin(y),cos(y));
   v=x*v;
   return v;
 }
 vec4 G(sampler2D v,float i,bool y,float s,float x,float z,float f)
 {
   GBufferData m=GetGBufferData(texcoord.xy);
   GBufferDataTransparent r=GetGBufferDataTransparent(texcoord.xy);
   bool c=r.depth<m.depth;
   if(c)
     m.normal=r.normal,m.smoothness=r.smoothness,m.metalness=0.,m.mcLightmap=r.mcLightmap,m.depth=r.depth;
   vec4 d=GetViewPosition(texcoord.xy,m.depth),h=gbufferModelViewInverse*vec4(d.xyz,1.),n=gbufferModelViewInverse*vec4(d.xyz,0.);
   vec3 t=normalize(d.xyz),S=normalize(n.xyz),o=normalize((gbufferModelViewInverse*vec4(m.normal,0.)).xyz);
   float p=GetDepthLinear(texcoord.xy),l=dot(-t,m.normal.xyz),G=1.-m.smoothness,w=G*G,b=e(m.smoothness,m.metalness);
   vec4 F=texture2DLod(v,texcoord.xy+HalfScreen,0);
   float O=Luminance(F.xyz);
   if(b<.001)
     return F;
   float P=i*.9;
   P*=min(w*20.,1.1);
   P*=mix(F.w,1.,.2);
   vec2 H=vec2(0.);
   if(y)
     {
       vec2 U=BlueNoiseTemporal(texcoord.xy).xy*.99+.005;
       H=U-.5;
     }
   float U=BlueNoiseTemporal(texcoord.xy).x,B=1.1,Y=R(s,m.totalTexGrad)/(w+.0001),J=R(x*.5,m.totalTexGrad);
   vec4 j=vec4(0.),X=vec4(0.);
   float g=0.;
   vec4 u=vec4(vec3(z),1.);
   u.xyz=vec3(.25);
   u.xyz*=F.w*.95+.05;
   float A=m.smoothness;
   vec2 C=normalize(cross(m.normal,t).xy),L=a(C,1.5708);
   float T=1.-pow(1.-saturate(l),1.);
   C*=mix(.1075,.5,T);
   L*=mix(mix(.7,.7,w),.5,T);
   vec3 D=reflect(-t,m.normal);
   int V=0;
   for(int M=-1;M<=1;M++)
     {
       for(int q=-1;q<=1;q++)
         {
           vec2 k=vec2(M,q)+H;
           k=k.x*C+k.y*L;
           k*=P*1.5*ScreenTexel;
           vec2 I=texcoord.xy+k.xy;
           float E=length(k*ScreenSize);
           I=clamp(I,4.*ScreenTexel,1.-4.*ScreenTexel);
           vec4 W=texture2DLod(v,I+HalfScreen,0);
           vec3 N=GetNormals(I);
           float K=GetDepthLinear(I),Q=pow(saturate(dot(D,reflect(-t,N))),115./w),Z=exp(-(abs(K-p)*B)),ab=Q*Z;
           j+=vec4(pow(length(W.xyz),u.x)*normalize(W.xyz+1e-10),W.w)*ab;
           g+=ab;
           X+=W;
           V++;
         }
     }
   j/=g+.0001;
   j.xyz=pow(length(j.xyz),1./u.x)*normalize(j.xyz+1e-06);
   vec4 k=j;
   if(g<.001)
     k=F;
   return k;
 }
 void main()
 {
   vec4 v=texture2DLod(colortex7,texcoord.xy+HalfScreen,4);
   vec3 y=pow(texture2DLod(colortex1,texcoord.xy+HalfScreen,2).xyz,vec3(2.2)),s=GetViewPosition(texcoord.xy,GetDepth(texcoord.xy)).xyz,z=GetNormals(texcoord.xy);
   float m=pow(1.-saturate(dot(-normalize(s),z)),5.);
   v.xyz*=m;
   float x=dot(max(vec3(0.),vec3(v.xyz-y.xyz*20.)),vec3(240.));
   vec4 i=texture2DLod(colortex7,texcoord.xy+HalfScreen,0);
   i=G(colortex7,15.,true,180.,40.,.1,0.);
   gl_FragData[0]=vec4(i);
 };




/* DRAWBUFFERS:7 */
