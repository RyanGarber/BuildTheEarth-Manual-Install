#version 330 compatibility



#define GLOWING_REDSTONE_BLOCK // If enabled, redstone blocks are treated as light sources for GI
#define GLOWING_LAPIS_LAZULI_BLOCK // If enabled, lapis lazuli blocks are treated as light sources for GI


#define GENERAL_GRASS_FIX

#include "lib/Uniforms.inc"
#include "lib/Common.inc"


attribute vec4 mc_Entity;
attribute vec4 at_tangent;
attribute vec4 mc_midTexCoord;



out vec4 color;
out vec4 texcoord;
out vec4 lmcoord;
out vec3 worldPosition;
out vec3 viewPos;
out vec4 preDownscaleProjPos;
out vec4 glPosition;

out vec3 worldNormal;

out vec2 blockLight;

out float materialIDs;

out mat3 tbnMatrix;
out vec3 tangent;
out vec3 binormal;
out vec3 normal;


#include "lib/Materials.inc"

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
   int x=v.x*v.y;
   return f(FloorToInt(floor(pow(float(x),.333333))));
 }
 int t()
 {
   ivec2 v=ivec2(2048,2048);
   int x=v.x*v.y;
   return t(FloorToInt(floor(pow(float(x),.333333))));
 }
 vec3 s(vec2 v)
 {
   ivec2 x=ivec2(viewWidth,viewHeight);
   int s=x.x*x.y,y=f();
   ivec2 l=ivec2(v.x*x.x,v.y*x.y);
   float z=float(l.y/y),i=float(int(l.x+mod(x.x*z,y))/y);
   i+=floor(x.x*z/y);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(l.x+mod(x.x*z,y),y);
   m.y=mod(l.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 d(vec3 v)
 {
   ivec2 x=ivec2(viewWidth,viewHeight);
   int y=f();
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float s=i.z;
   vec2 r;
   r.x=mod(i.x+s*y,x.x);
   float m=i.x+s*y;
   r.y=i.y+floor(m/x.x)*y;
   r+=.5;
   r/=x;
   return r;
 }
 vec3 e(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 x=ivec2(2048,2048);
   int s=x.x*x.y,y=t();
   ivec2 l=ivec2(i.x*x.x,i.y*x.y);
   float z=float(l.y/y),f=float(int(l.x+mod(x.x*z,y))/y);
   f+=floor(x.x*z/y);
   vec3 m=vec3(0.,0.,f);
   m.x=mod(l.x+mod(x.x*z,y),y);
   m.y=mod(l.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 x=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float s=i.z;
   vec2 r;
   r.x=mod(i.x+s*y,x.x);
   float m=i.x+s*y;
   r.y=i.y+floor(m/x.x)*y;
   r+=.5;
   r/=x;
   r.xy*=.5;
   return r;
 }
 vec3 e(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 f(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v;
 }
 vec3 v(vec3 v)
 {
   int x=t();
   v=v-vec3(.5);
   v*=x;
   return v;
 }
 vec3 n(vec3 v)
 {
   int x=f();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 x(vec3 v)
 {
   int x=f();
   v=v-vec3(.5);
   v*=x;
   return v;
 }
 vec3 d()
 {
   vec3 v=cameraPosition.xyz+.5,x=previousCameraPosition.xyz+.5,y=floor(v-.0001),s=floor(x-.0001);
   return y-s;
 }
 vec3 m(vec3 v)
 {
   vec4 x=vec4(v,1.);
   x=shadowModelView*x;
   x=shadowProjection*x;
   x/=x.w;
   float s=sqrt(x.x*x.x+x.y*x.y),y=1.f-SHADOW_MAP_BIAS+s*SHADOW_MAP_BIAS;
   x.xy*=.95f/y;
   x.z=mix(x.z,.5,.8);
   x=x*.5f+.5f;
   x.xy*=.5;
   x.xy+=.5;
   return x.xyz;
 }
 vec3 d(vec3 v,vec3 m,vec2 x,vec2 y,vec4 l,vec4 i,inout float f,out vec2 r)
 {
   bool s=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   s=!s;
   if(i.x==8||i.x==9||i.x==79||i.x<1.||!s||i.x==20.||i.x==171.||min(abs(m.x),abs(m.z))>.2)
     f=1.;
   if(i.x==50.||i.x==52.||i.x==76.)
     {
       f=0.;
       if(m.y<.5)
         f=1.;
     }
   if(i.x==51||i.x==53)
     f=0.;
   if(i.x>255)
     f=0.;
   vec3 g,z;
   if(m.x>.5)
     g=vec3(0.,0.,-1.),z=vec3(0.,-1.,0.);
   else
      if(m.x<-.5)
       g=vec3(0.,0.,1.),z=vec3(0.,-1.,0.);
     else
        if(m.y>.5)
         g=vec3(1.,0.,0.),z=vec3(0.,0.,1.);
       else
          if(m.y<-.5)
           g=vec3(1.,0.,0.),z=vec3(0.,0.,-1.);
         else
            if(m.z>.5)
             g=vec3(1.,0.,0.),z=vec3(0.,-1.,0.);
           else
              if(m.z<-.5)
               g=vec3(-1.,0.,0.),z=vec3(0.,-1.,0.);
   r=clamp((x.xy-y.xy)*100000.,vec2(0.),vec2(1.));
   float t=.15,b=.15;
   if(i.x==10.||i.x==11.)
     {
       if(abs(m.y)<.01&&s||m.y>.99)
         t=.1,b=.1,f=0.;
       else
          f=1.;
     }
   if(i.x==51||i.x==53)
     t=.5,b=.1;
   if(i.x==76)
     t=.2,b=.2;
   if(i.x-255.+39.>=103.&&i.x-255.+39.<=113.)
     b=.025,t=.025;
   g=normalize(l.xyz);
   z=normalize(cross(g,m.xyz)*sign(l.w));
   vec3 n=v.xyz+mix(g*t,-g*t,vec3(r.x));
   n.xyz+=mix(z*t,-z*t,vec3(r.y));
   n.xyz-=m.xyz*b;
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
 void d(in Ray v,in vec3 m[2],out float x,out float i)
 {
   float y,z,f,r;
   x=(m[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   i=(m[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(m[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(m[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   f=(m[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   r=(m[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   x=max(max(x,y),f);
   i=min(min(i,z),r);
 }
 vec3 d(const vec3 v,const vec3 x,vec3 y)
 {
   const float z=1e-05;
   vec3 s=(x+v)*.5,i=(x-v)*.5,m=y-s,f=vec3(0.);
   f+=vec3(sign(m.x),0.,0.)*step(abs(abs(m.x)-i.x),z);
   f+=vec3(0.,sign(m.y),0.)*step(abs(abs(m.y)-i.y),z);
   f+=vec3(0.,0.,sign(m.z))*step(abs(abs(m.z)-i.z),z);
   return normalize(f);
 }
 bool e(const vec3 v,const vec3 x,Ray i,out vec2 y)
 {
   vec3 z=i.inv_direction*(v-i.origin),m=i.inv_direction*(x-i.origin),l=min(m,z),s=max(m,z);
   vec2 f=max(l.xx,l.yz);
   float g=max(f.x,f.y);
   f=min(s.xx,s.yz);
   float n=min(f.x,f.y);
   y.x=g;
   y.y=n;
   return n>max(g,0.);
 }
 bool d(const vec3 v,const vec3 x,Ray i,inout float y,inout vec3 z)
 {
   vec3 f=i.inv_direction*(v-1e-05-i.origin),m=i.inv_direction*(x+1e-05-i.origin),l=min(m,f),s=max(m,f);
   vec2 r=max(l.xx,l.yz);
   float g=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float n=min(r.x,r.y);
   bool t=n>max(g,0.)&&max(g,0.)<y;
   if(t)
     z=d(v-1e-05,x+1e-05,i.origin+i.direction*g),y=g;
   return t;
 }
 vec3 e(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 l=m(v);
   float s=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(l.xy,l.z-.0006*s),2).x;
   f*=saturate(dot(i,y));
   {
     vec4 r=texture2DLod(shadowcolor1,l.xy-vec2(0.,.5),4);
     float t=abs(r.x*256.-(v.y+cameraPosition.y)),g=GetCausticsComposite(v,i,t),n=shadow2DLod(shadowtex0,vec3(l.xy-vec2(0.,.5),l.z+1e-06),4).x;
     f=mix(f,f*g,1.-n);
   }
   f=TintUnderwaterDepth(f);
   return f*(1.-rainStrength);
 }
 vec3 f(vec3 x,vec3 i,vec3 y,vec3 f,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 r=v(x);
   r+=1.;
   r-=Fract01(cameraPosition+.5);
   vec3 l=m(r+y*.99);
   float s=.5;
   vec3 g=vec3(1.)*shadow2DLod(shadowtex0,vec3(l.xy,l.z-.0006*s),3).x;
   g*=saturate(dot(i,y));
   g=TintUnderwaterDepth(g);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(l.xy-vec2(.5,0.),l.z-.0006*s),3).x;
   vec3 n=texture2DLod(shadowcolor,vec2(l.xy-vec2(.5,0.)),3).xyz;
   n*=n;
   g=mix(g,g*n,vec3(1.-t));
   #endif
   return g*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 x,vec3 y,vec3 i,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 l=m(v);
   float s=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(l.xy,l.z-.0006*s),2).x;
   f*=saturate(dot(x,y));
   f=TintUnderwaterDepth(f);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(l.xy-vec2(.5,0.),l.z-.0006*s),3).x;
   vec3 r=texture2DLod(shadowcolor,vec2(l.xy-vec2(.5,0.)),3).xyz;
   r*=r;
   f=mix(f,f*r,vec3(1.-t));
   #endif
   return f*(1.-rainStrength);
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
 CPrmwMXxJc G(vec4 v)
 {
   CPrmwMXxJc i;
   vec2 x=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),l=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=x.y;
   i.avjkUoKnfB=m.y;
   i.ivaOqoXyFu=l.y*255.;
   i.PVAMAgODVh=pow(vec3(x.x,m.x,l.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc w(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return G(texture2DLod(colortex5,v,0));
 }
 float G(float v,float y)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+y,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool G(vec3 v,float x,Ray i,bool y,inout float f,inout vec3 z)
 {
   bool m=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(y)
     return false;
   if(x>=67.)
     return false;
   r=d(v,v+vec3(1.,1.,1.),i,f,z);
   m=r;
   #else
   if(x<40.)
     return r=d(v,v+vec3(1.,1.,1.),i,f,z),r;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float s=.5;
       if(x==41.)
         s=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),i,f,z);
       m=m||r;
     }
   if(x==42.||x>=55.&&x<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,f,z),m=m||r;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float s=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         s=0.;
       r=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),i,f,z);
       m=m||r;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float s=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         s=0.;
       r=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),i,f,z);
       m=m||r;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float s=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         s=0.;
       r=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),i,f,z);
       m=m||r;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float s=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         s=0.;
       r=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),i,f,z);
       m=m||r;
     }
   if(x>=67.&&x<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,f,z),m=m||r;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float s=8.,g=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         s=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         g=16.;
       r=d(v+vec3(s,6.,7.)/16.,v+vec3(g,9.,9.)/16.,i,f,z);
       m=m||r;
       r=d(v+vec3(s,12.,7.)/16.,v+vec3(g,15.,9.)/16.,i,f,z);
       m=m||r;
     }
   if(x>=71.&&x<=82.)
     {
       float s=8.,t=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         t=16.;
       if(x>=75.&&x<=82.)
         s=0.;
       r=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,t)/16.,i,f,z);
       m=m||r;
       r=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,t)/16.,i,f,z);
       m=m||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(x>=83.&&x<=86.)
     {
       vec3 s=vec3(0),l=vec3(0);
       if(x==83.)
         s=vec3(0,0,0),l=vec3(16,16,3);
       if(x==84.)
         s=vec3(0,0,13),l=vec3(16,16,16);
       if(x==86.)
         s=vec3(0,0,0),l=vec3(3,16,16);
       if(x==85.)
         s=vec3(13,0,0),l=vec3(16,16,16);
       r=d(v+s/16.,v+l/16.,i,f,z);
       m=m||r;
     }
   if(x>=87.&&x<=102.)
     {
       vec3 s=vec3(0.),l=vec3(1.);
       if(x>=87.&&x<=94.)
         {
           float t=0.;
           if(x>=91.&&x<=94.)
             t=13.;
           s=vec3(0.,t,0.)/16.;
           l=vec3(16.,t+3.,16.)/16.;
         }
       if(x>=95.&&x<=98.)
         {
           float t=13.;
           if(x==97.||x==98.)
             t=0.;
           s=vec3(0.,0.,t)/16.;
           l=vec3(16.,16.,t+3.)/16.;
         }
       if(x>=99.&&x<=102.)
         {
           float g=13.;
           if(x==99.||x==100.)
             g=0.;
           s=vec3(g,0.,0.)/16.;
           l=vec3(g+3.,16.,16.)/16.;
         }
       r=d(v+s,v+l,i,f,z);
       m=m||r;
     }
   if(x>=103.&&x<=113.)
     {
       vec3 s=vec3(0.),l=vec3(1.);
       if(x>=103.&&x<=110.)
         {
           float n=float(x)-float(103.)+1.;
           l.y=n*2./16.;
         }
       if(x==111.)
         l.y=.0625;
       if(x==112.)
         s=vec3(1.,0.,1.)/16.,l=vec3(15.,1.,15.)/16.;
       if(x==113.)
         s=vec3(1.,0.,1.)/16.,l=vec3(15.,.5,15.)/16.;
       r=d(v+s,v+l,i,f,z);
       m=m||r;
     }
   #endif
   #endif
   return m;
 }
 vec3 h(vec2 x)
 {
   vec2 v=vec2(x.xy*vec2(viewWidth,viewHeight));
   v*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(x.x<2./viewWidth||x.x>1.-2./viewWidth||x.y<2./viewHeight||x.y>1.-2./viewHeight)
     ;
   v=(floor(v*64.)+.5)/64.;
   vec3 r=texture2D(noisetex,v).xyz,s=vec3(sqrt(.2),sqrt(2.),1.61803);
   r=mod(r+float(frameCounter%64)*s,vec3(1.));
   return r;
 }
 void main()
 {
   color=gl_Color;
   texcoord=gl_MultiTexCoord0;
   lmcoord=gl_TextureMatrix[1]*gl_MultiTexCoord1;
   blockLight.x=clamp(lmcoord.x*33.05f/32.f-.0328125f,0.f,1.f);
   blockLight.y=clamp(lmcoord.y*33.75f/32.f-.0328125f,0.f,1.f);
   worldNormal=gl_Normal;
   vec4 x=gbufferModelViewInverse*gl_ModelViewMatrix*gl_Vertex;
   worldPosition=x.xyz+cameraPosition.xyz;
   viewPos=(gl_ModelViewMatrix*gl_Vertex).xyz;
   materialIDs=MAT_ID_OPAQUE;
   float v=0.f,s=abs(normalize(gl_Normal.xz).x),f=abs(gl_Normal.y);
   if(mc_Entity.x==31.||mc_Entity.x==38.f||mc_Entity.x==37.f||mc_Entity.x==1925.f||mc_Entity.x==1920.f||mc_Entity.x==1921.f||mc_Entity.x==2.&&gl_Normal.y<.5&&s>.01&&s<.99&&f<.9)
     materialIDs=MAT_ID_GRASS,v=1.f;
   #ifdef GENERAL_GRASS_FIX
   if(abs(worldNormal.x)>.01&&abs(worldNormal.x)<.99||abs(worldNormal.y)>.01&&abs(worldNormal.y)<.99||abs(worldNormal.z)>.01&&abs(worldNormal.z)<.99)
     materialIDs=MAT_ID_GRASS;
   #endif
   if(mc_Entity.x==175.f)
     materialIDs=MAT_ID_GRASS;
   if(mc_Entity.x==59.)
     materialIDs=MAT_ID_GRASS,v=1.f;
   if(mc_Entity.x==18.||mc_Entity.x==161.f)
     {
       if(color.x>.999&&color.y>.999&&color.z>.999)
         ;
       else
          materialIDs=MAT_ID_LEAVES;
       if(abs(color.x-color.y)>.001||abs(color.x-color.z)>.001||abs(color.y-color.z)>.001)
         materialIDs=MAT_ID_LEAVES;
     }
   if(mc_Entity.x==50||mc_Entity.x==52)
     materialIDs=MAT_ID_TORCH;
   if(mc_Entity.x==10||mc_Entity.x==11)
     materialIDs=MAT_ID_LAVA;
   if(mc_Entity.x==89||mc_Entity.x==124||mc_Entity.x==169||mc_Entity.x==91)
     materialIDs=MAT_ID_GLOWSTONE;
   #ifdef GLOWING_REDSTONE_BLOCK
   if(mc_Entity.x==152)
     materialIDs=MAT_ID_GLOWSTONE;
   #endif
   #ifdef GLOWING_LAPIS_LAZULI_BLOCK
   if(mc_Entity.x==22)
     materialIDs=MAT_ID_GLOWSTONE;
   #endif
   #ifdef GLOWING_EMERALD_BLOCK
   if(mc_Entity.x==133)
     materialIDs=MAT_ID_GLOWSTONE;
   #endif
   if(mc_Entity.x==51||mc_Entity.x==53)
     materialIDs=MAT_ID_FIRE;
   if(mc_Entity.x==188||mc_Entity.x==189||mc_Entity.x==190||mc_Entity.x==191)
     materialIDs=MAT_ID_LIT_FURNACE;
   float m=1.;
   if(color.x==1.&&color.y==1.&&color.z==1.)
     m=0.;
   normal=normalize(gl_NormalMatrix*gl_Normal);
   float i=-1.;
   if(gl_Normal.x>.5)
     tangent=normalize(gl_NormalMatrix*vec3(0.,0.,i)),binormal=normalize(gl_NormalMatrix*vec3(0.,-1.,0.));
   else
      if(gl_Normal.x<-.5)
       tangent=normalize(gl_NormalMatrix*vec3(0.,0.,1.)),binormal=normalize(gl_NormalMatrix*vec3(0.,-1.,0.));
     else
        if(gl_Normal.y>.5)
         tangent=normalize(gl_NormalMatrix*vec3(1.,0.,0.)),binormal=normalize(gl_NormalMatrix*vec3(0.,0.,1.));
       else
          if(gl_Normal.y<-.5)
           tangent=normalize(gl_NormalMatrix*vec3(1.,0.,0.)),binormal=normalize(gl_NormalMatrix*vec3(0.,0.,-1.));
         else
            if(gl_Normal.z>.5)
             tangent=normalize(gl_NormalMatrix*vec3(1.,0.,0.)),binormal=normalize(gl_NormalMatrix*vec3(0.,-1.,0.));
           else
              if(gl_Normal.z<-.5)
               tangent=normalize(gl_NormalMatrix*vec3(i,0.,0.)),binormal=normalize(gl_NormalMatrix*vec3(0.,-1.,0.));
   tbnMatrix=mat3(tangent.x,binormal.x,normal.x,tangent.y,binormal.y,normal.y,tangent.z,binormal.z,normal.z);
   gl_Position=gl_ProjectionMatrix*gbufferModelView*x;
   FinalVertexTransformTAA(gl_Position,preDownscaleProjPos);
   glPosition=gl_Position;
 };



