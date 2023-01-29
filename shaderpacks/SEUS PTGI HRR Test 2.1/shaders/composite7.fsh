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


/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//fgdhghdf

/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////




const bool colortex3MipmapEnabled = true;

in vec4 texcoord;
in vec3 lightVector;


in float timeSunriseSunset;
in float timeNoon;
in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;





#define COLORPOW 1.0

#define CURR_COLOR_TEX colortex3
#define PREV_COLOR_TEX colortex6
#define DEPTHTEX depthtex0


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
   ivec2 n=ivec2(v.x*m.x,v.y*m.y);
   float z=float(n.y/y),i=float(int(n.x+mod(m.x*z,y))/y);
   i+=floor(m.x*z/y);
   vec3 r=vec3(0.,0.,i);
   r.x=mod(n.x+mod(m.x*z,y),y);
   r.y=mod(n.y,y);
   r.xyz=floor(r.xyz);
   r/=y;
   r.xyz=r.xzy;
   return r;
 }
 vec2 x(vec3 v)
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
 vec3 n(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,y=t();
   ivec2 n=ivec2(i.x*m.x,i.y*m.y);
   float z=float(n.y/y),f=float(int(n.x+mod(m.x*z,y))/y);
   f+=floor(m.x*z/y);
   vec3 r=vec3(0.,0.,f);
   r.x=mod(n.x+mod(m.x*z,y),y);
   r.y=mod(n.y,y);
   r.xyz=floor(r.xyz);
   r/=y;
   r.xyz=r.xzy;
   return r;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 r;
   r.x=mod(i.x+x*y,m.x);
   float f=i.x+x*y;
   r.y=i.y+floor(f/m.x)*y;
   r+=.5;
   r/=m;
   r.xy*=.5;
   return r;
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
 vec3 r(vec3 v)
 {
   int x=f();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 p(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 d()
 {
   vec3 v=cameraPosition.xyz+.5,y=previousCameraPosition.xyz+.5,x=floor(v-.0001),i=floor(y-.0001);
   return x-i;
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
 vec3 d(vec3 v,vec3 m,vec2 i,vec2 r,vec4 n,vec4 f,inout float x,out vec2 y)
 {
   bool z=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   z=!z;
   if(f.x==8||f.x==9||f.x==79||f.x<1.||!z||f.x==20.||f.x==171.||min(abs(m.x),abs(m.z))>.2)
     x=1.;
   if(f.x==50.||f.x==52.||f.x==76.)
     {
       x=0.;
       if(m.y<.5)
         x=1.;
     }
   if(f.x==51||f.x==53)
     x=0.;
   if(f.x>255)
     x=0.;
   vec3 s,e;
   if(m.x>.5)
     s=vec3(0.,0.,-1.),e=vec3(0.,-1.,0.);
   else
      if(m.x<-.5)
       s=vec3(0.,0.,1.),e=vec3(0.,-1.,0.);
     else
        if(m.y>.5)
         s=vec3(1.,0.,0.),e=vec3(0.,0.,1.);
       else
          if(m.y<-.5)
           s=vec3(1.,0.,0.),e=vec3(0.,0.,-1.);
         else
            if(m.z>.5)
             s=vec3(1.,0.,0.),e=vec3(0.,-1.,0.);
           else
              if(m.z<-.5)
               s=vec3(-1.,0.,0.),e=vec3(0.,-1.,0.);
   y=clamp((i.xy-r.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,o=.15;
   if(f.x==10.||f.x==11.)
     {
       if(abs(m.y)<.01&&z||m.y>.99)
         h=.1,o=.1,x=0.;
       else
          x=1.;
     }
   if(f.x==51||f.x==53)
     h=.5,o=.1;
   if(f.x==76)
     h=.2,o=.2;
   if(f.x-255.+39.>=103.&&f.x-255.+39.<=113.)
     o=.025,h=.025;
   s=normalize(n.xyz);
   e=normalize(cross(s,m.xyz)*sign(n.w));
   vec3 d=v.xyz+mix(s*h,-s*h,vec3(y.x));
   d.xyz+=mix(e*h,-e*h,vec3(y.y));
   d.xyz-=m.xyz*o;
   return d;
 }struct SPcacsgCKo{vec3 GadGLQcpqX;vec3 GadGLQcpqXOrigin;vec3 vAdYwconYe;vec3 AZVxALDdtL;vec3 UekatYTTmj;vec3 OmcxSfXfkJ;};
 SPcacsgCKo s(Ray v)
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
 void w(inout SPcacsgCKo v)
 {
   v.OmcxSfXfkJ=step(v.UekatYTTmj.xyz,v.UekatYTTmj.yzx)*step(v.UekatYTTmj.xyz,v.UekatYTTmj.zxy),v.UekatYTTmj+=v.OmcxSfXfkJ*v.vAdYwconYe,v.GadGLQcpqX+=v.OmcxSfXfkJ*v.AZVxALDdtL;
 }
 void d(in Ray v,in vec3 f[2],out float i,out float y)
 {
   float x,z,r,e;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   e=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,x),r);
   y=min(min(y,z),e);
 }
 vec3 d(const vec3 v,const vec3 x,vec3 y)
 {
   const float i=1e-05;
   vec3 z=(x+v)*.5,m=(x-v)*.5,f=y-z,r=vec3(0.);
   r+=vec3(sign(f.x),0.,0.)*step(abs(abs(f.x)-m.x),i);
   r+=vec3(0.,sign(f.y),0.)*step(abs(abs(f.y)-m.y),i);
   r+=vec3(0.,0.,sign(f.z))*step(abs(abs(f.z)-m.z),i);
   return normalize(r);
 }
 bool f(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),n=min(x,y),r=max(x,y);
   vec2 s=max(n.xx,n.yz);
   float z=max(s.x,s.y);
   s=min(r.xx,r.yz);
   float e=min(s.x,s.y);
   i.x=z;
   i.y=e;
   return e>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float x,inout vec3 y)
 {
   vec3 i=m.inv_direction*(v-1e-05-m.origin),z=m.inv_direction*(f+1e-05-m.origin),n=min(z,i),s=max(z,i);
   vec2 r=max(n.xx,n.yz);
   float h=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float e=min(r.x,r.y);
   bool t=e>max(h,0.)&&max(h,0.)<x;
   if(t)
     y=d(v-1e-05,f+1e-05,m.origin+m.direction*h),x=h;
   return t;
 }
 vec3 f(vec3 v,vec3 f,vec3 y,vec3 x,int i)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 r=m(v);
   float z=.5;
   vec3 t=vec3(1.)*shadow2DLod(shadowtex0,vec3(r.xy,r.z-.0006*z),2).x;
   t*=saturate(dot(f,y));
   {
     vec4 n=texture2DLod(shadowcolor1,r.xy-vec2(0.,.5),4);
     float e=abs(n.x*256.-(v.y+cameraPosition.y)),s=GetCausticsComposite(v,f,e),o=shadow2DLod(shadowtex0,vec3(r.xy-vec2(0.,.5),r.z+1e-06),4).x;
     t=mix(t,t*s,1.-o);
   }
   t=TintUnderwaterDepth(t);
   return t*(1.-rainStrength);
 }
 vec3 m(vec3 y,vec3 f,vec3 x,vec3 z,int i)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 r=v(y);
   r+=1.;
   r-=Fract01(cameraPosition+.5);
   vec3 n=m(r+x*.99);
   float s=.5;
   vec3 e=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*s),3).x;
   e*=saturate(dot(f,x));
   e=TintUnderwaterDepth(e);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*s),3).x;
   vec3 h=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   h*=h;
   e=mix(e,e*h,vec3(1.-t));
   #endif
   return e*(1.-rainStrength);
 }
 vec3 n(vec3 v,vec3 f,vec3 y,vec3 x,int i)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 r=m(v);
   float z=.5;
   vec3 e=vec3(1.)*shadow2DLod(shadowtex0,vec3(r.xy,r.z-.0006*z),2).x;
   e*=saturate(dot(f,y));
   e=TintUnderwaterDepth(e);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(r.xy-vec2(.5,0.),r.z-.0006*z),3).x;
   vec3 s=texture2DLod(shadowcolor,vec2(r.xy-vec2(.5,0.)),3).xyz;
   s*=s;
   e=mix(e,e*s,vec3(1.-t));
   #endif
   return e*(1.-rainStrength);
 }struct CPrmwMXxJc{float pzBOsrqcFy;float ivaOqoXyFu;float OxTKjfMYEH;float avjkUoKnfB;vec3 PVAMAgODVh;};
 vec4 e(CPrmwMXxJc v)
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
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),f=UnpackTwo16BitFrom32Bit(v.z),r=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=m.y;
   i.avjkUoKnfB=f.y;
   i.ivaOqoXyFu=r.y*255.;
   i.PVAMAgODVh=pow(vec3(m.x,f.x,r.x),vec3(8.));
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
 bool d(vec3 v,float y,Ray x,bool f,inout float i,inout vec3 z)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(f)
     return false;
   if(y>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),x,i,z);
   r=m;
   #else
   if(y<40.)
     return m=d(v,v+vec3(1.,1.,1.),x,i,z),m;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float e=.5;
       if(y==41.)
         e=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,e,1.),x,i,z);
       r=r||m;
     }
   if(y==42.||y>=55.&&y<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),x,i,z),r=r||m;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float e=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         e=0.;
       m=d(v+vec3(0.,e,0.),v+vec3(.5,.5+e,.5),x,i,z);
       r=r||m;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float e=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         e=0.;
       m=d(v+vec3(.5,e,0.),v+vec3(1.,.5+e,.5),x,i,z);
       r=r||m;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float e=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         e=0.;
       m=d(v+vec3(.5,e,.5),v+vec3(1.,.5+e,1.),x,i,z);
       r=r||m;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float e=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         e=0.;
       m=d(v+vec3(0.,e,.5),v+vec3(.5,.5+e,1.),x,i,z);
       r=r||m;
     }
   if(y>=67.&&y<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,x,i,z),r=r||m;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float e=8.,s=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         e=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         s=16.;
       m=d(v+vec3(e,6.,7.)/16.,v+vec3(s,9.,9.)/16.,x,i,z);
       r=r||m;
       m=d(v+vec3(e,12.,7.)/16.,v+vec3(s,15.,9.)/16.,x,i,z);
       r=r||m;
     }
   if(y>=71.&&y<=82.)
     {
       float e=8.,s=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         s=16.;
       if(y>=75.&&y<=82.)
         e=0.;
       m=d(v+vec3(7.,6.,e)/16.,v+vec3(9.,9.,s)/16.,x,i,z);
       r=r||m;
       m=d(v+vec3(7.,12.,e)/16.,v+vec3(9.,15.,s)/16.,x,i,z);
       r=r||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 e=vec3(0),s=vec3(0);
       if(y==83.)
         e=vec3(0,0,0),s=vec3(16,16,3);
       if(y==84.)
         e=vec3(0,0,13),s=vec3(16,16,16);
       if(y==86.)
         e=vec3(0,0,0),s=vec3(3,16,16);
       if(y==85.)
         e=vec3(13,0,0),s=vec3(16,16,16);
       m=d(v+e/16.,v+s/16.,x,i,z);
       r=r||m;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 e=vec3(0.),s=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float h=0.;
           if(y>=91.&&y<=94.)
             h=13.;
           e=vec3(0.,h,0.)/16.;
           s=vec3(16.,h+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float n=13.;
           if(y==97.||y==98.)
             n=0.;
           e=vec3(0.,0.,n)/16.;
           s=vec3(16.,16.,n+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float h=13.;
           if(y==99.||y==100.)
             h=0.;
           e=vec3(h,0.,0.)/16.;
           s=vec3(h+3.,16.,16.)/16.;
         }
       m=d(v+e,v+s,x,i,z);
       r=r||m;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 e=vec3(0.),s=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float t=float(y)-float(103.)+1.;
           s.y=t*2./16.;
         }
       if(y==111.)
         s.y=.0625;
       if(y==112.)
         e=vec3(1.,0.,1.)/16.,s=vec3(15.,1.,15.)/16.;
       if(y==113.)
         e=vec3(1.,0.,1.)/16.,s=vec3(15.,.5,15.)/16.;
       m=d(v+e,v+s,x,i,z);
       r=r||m;
     }
   #endif
   #endif
   return r;
 }
 vec3 D(vec2 v)
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
 vec2 D(vec2 v,float m,float x,out float y)
 {
   vec2 i=v;
   y=m;
   vec2 e=x*ScreenTexel;
   for(int r=-1;r<=1;r+=2)
     {
       for(int z=-1;z<=1;z+=2)
         {
           vec2 s=v+vec2(r,z)*e;
           float f=texture2DLod(DEPTHTEX,s,0).x;
           if(f<y)
             y=f,i=s;
         }
     }
   return i;
 }
 vec3 c(vec3 y)
 {
   mat3 v=mat3(.2126,.7152,.0722,-.09991,-.33609,.436,.615,-.55861,-.05639);
   return y*v;
 }
 vec3 g(vec3 y)
 {
   mat3 v=mat3(1.,0.,1.28033,1.,-.21482,-.38059,1.,2.12798,0.);
   return y*v;
 }
 vec3 c(vec3 v,vec3 y,vec3 x,vec3 m)
 {
   vec3 e=.5*(y+v),i=.5*(y-v),s=m-e,z=s/i,r=abs(z);
   float f=max(r.x,max(r.y,r.z));
   if(f>1.)
     return e+s/f;
   else
      return m;
 }
 vec4 D(sampler2D v,vec2 y)
 {
   return pow(texture2DLod(v,y,0),vec4(vec3(1./2.2),1.));
 }
 vec4 c(sampler2D v,vec2 y)
 {
   vec2 x=vec2(viewWidth,viewHeight),m=1./x,i=y*x,e=floor(i-.5)+.5,s=i-e,z=s*s,r=s*z;
   float f=.5;
   vec2 n=-f*r+2.*f*z-f*s,t=(2.-f)*r-(3.-f)*z+1.,h=-(2.-f)*r+(3.-2.*f)*z+f*s,o=f*r-f*z,d=t+h,c=m*(e+h/d);
   vec4 a=D(v,vec2(c.x,c.y));
   vec2 C=m*(e-1.),l=m*(e+2.);
   vec4 R=vec4(D(v,vec2(c.x,C.y)).xyz,1.)*(d.x*n.y)+vec4(D(v,vec2(C.x,c.y)).xyz,1.)*(n.x*d.y)+vec4(a.xyz,1.)*(d.x*d.y)+vec4(D(v,vec2(l.x,c.y)).xyz,1.)*(o.x*d.y)+vec4(D(v,vec2(c.x,l.y)).xyz,1.)*(d.x*o.y);
   return pow(vec4(max(vec3(0.),R.xyz*(1./R.w)),a.w),vec4(vec3(2.2),1.));
 }
 float D()
 {
   float v=int(log2(min(viewWidth,viewHeight)));
   return min(.0035,pow(dot(texture2DLod(CURR_COLOR_TEX,vec2(.65,.65),v+1).xyz,vec3(.33333)),2.));
 }
 void D(vec2 v,float x,out vec3 y,out vec3 i,out vec4 r)
 {
   vec4 m=vec4(v.xy*2.-1.,x*2.-1.,1.),f=gbufferProjectionInverse*m;
   f.xyz/=f.w;
   r=gbufferModelViewInverse*vec4(f.xyz,1.);
   vec4 e=r;
   e.xyz+=cameraPosition-previousCameraPosition;
   vec4 n=gbufferPreviousModelView*vec4(e.xyz,1.),s=gbufferPreviousProjection*vec4(n.xyz,1.);
   s.xyz/=s.w;
   y=m.xyz-s.xyz;
   vec4 z=gbufferModelView*vec4(e.xyz,1.),t=gbufferProjection*vec4(z.xyz,1.);
   t.xyz/=t.w;
   i=m.xyz-t.xyz;
 }
 vec3 g(vec2 v,float y)
 {
   vec4 i=GetViewPosition(v,y);
   return(gbufferModelViewInverse*vec4(i.xyz,1.)).xyz;
 }
 void main()
 {
   float v=texture2D(depthtex0,texcoord.xy).x;
   vec2 y=texcoord.xy;
   if(v>.7)
     ;
   vec4 m=texture2DLod(CURR_COLOR_TEX,y,0);
   vec3 r=pow(m.xyz,vec3(COLORPOW)),x=r;
   float z;
   vec2 e=D(texcoord.xy,v,1.,z);
   float s=z,f=texture2D(DEPTHTEX,DownscaleTexcoord(texcoord.xy)).x,t;
   vec2 h=D(DownscaleTexcoord(texcoord.xy),f,1.,t);
   float n=t;
   vec3 d,o;
   vec4 w;
   D(e,n,d,o,w);
   float a=length(d.xy)*.25;
   if(f<.7)
     d*=0.;
   vec2 C=texcoord.xy-d.xy*.5,l=cos((fract(abs(texcoord.xy-C.xy)*ScreenSize)*2.-1.)*3.14159)*.5+.5,R=pow(l,vec2(.5));
   vec4 p=pow(c(PREV_COLOR_TEX,C.xy),vec4(COLORPOW,COLORPOW,COLORPOW,1.));
   float S=0.;
   vec3 G=vec3(0.);
   #if AA_STYLE==0
   S=mix(1.2,1.2,saturate(a*110.));
   G=vec3(frameTime*mix(.4,.7,saturate(a*200.)));
   #else
   CPrmwMXxJc j=i(texcoord.xy);
   S=1.4;
   G=vec3(1.)/(j.ivaOqoXyFu+1.);
   #endif
   if(ExpToLinearDepth(f)-ExpToLinearDepth(t)>.9)
     S*=exp(-(length(o.xy)*length(r.xyz-p.xyz)/(length(r)+1e-07))*400.);
   if(f<.7)
     S=.8;
   if(C.x<0.||C.x>1.||C.y<0.||C.y>1.)
     G=vec3(1.);
   vec3 X=vec3(1e+06,1e+06,1e+06),W=vec3(0.,0.,0.),b=vec3(0.,0.,0.),u=vec3(0.),E=vec3(0.);
   int P=0;
   vec3 U=vec3(0.),Y=vec3(0.);
   for(int F=-1;F<=1;F++)
     {
       for(int O=-1;O<=1;O++)
         {
           vec2 A=vec2(float(F),float(O))/vec2(viewWidth,viewHeight);
           vec3 J=pow(texture2D(CURR_COLOR_TEX,y.xy+A).xyz,vec3(COLORPOW));
           X=min(X,J);
           W=max(W,J);
           b+=J;
           if(O==0)
             u+=J;
           if(F==0)
             E+=J;
           J=c(J);
           U+=J;
           Y+=J*J;
           P++;
         }
     }
   b/=P;
   u/=3.;
   E/=3.;
   vec3 J=U/P,L=sqrt(max(vec3(0.),Y/P-J*J)),F=J-S*L,O=J+S*L;
   #ifdef SKIP_AA
   G=vec3(1.);
   #endif
   vec3 A=(vec3(1.)-exp(-(r-b)*5.))*.12,T=(vec3(1.)-exp(-(r-u)*5.))*.12,H=(vec3(1.)-exp(-(r-E)*5.))*.12;
   r+=T*(.15/G)*R.x;
   r+=H*(.15/G)*R.y;
   p.xyz=g(c(F,O,r.xyz,c(p.xyz)));
   vec3 B=mix(p.xyz,r,G);
   B=pow(B,vec3(1./COLORPOW));
   vec2 V=texcoord.xy*ScreenSize;
   if(distance(V,vec2(0.,0.))<1.)
     {
       float M=D()*100.,I=texture2DLod(PREV_COLOR_TEX,texcoord.xy,0).w;
       M=mix(I,M,saturate(M>I?1.5*frameTime:6.*frameTime));
       v=M;
     }
   B=max(vec3(0.),B);
   vec2 M=normalize(d.xy+1e-07)*min(1.,length(d.xy));
   if(f<.7)
     M=vec2(0.);
   gl_FragData[0]=vec4(M.xy*.5+.5,0.,1.);
   gl_FragData[1]=vec4(B,v);
 };




/* DRAWBUFFERS:26 */
