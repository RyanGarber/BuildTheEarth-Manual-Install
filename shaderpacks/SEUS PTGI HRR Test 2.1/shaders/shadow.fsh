#version 330 compatibility
#extension GL_ARB_shading_language_packing : enable
#extension GL_ARB_shader_bit_encoding : enable


#include "lib/Uniforms.inc"
#include "lib/Common.inc"
#include "lib/GBuffersCommon.inc"


in vec4 texcoord;
in vec4 color;
// in vec4 lmcoord;

// in vec3 normal;
in vec4 viewPos;
in vec3 zrEuGoMOCd;

in float materialIDs;
in float mcEntity;
in float isWater;
in float isStainedGlass;


in float invalidForVolume;
in float aGBCSUeTQs;
in float fragDepth;

in vec2 sbxhonUINy;


 int f(int f)
 {
   return f-FloorToInt(mod(float(f),2.))-0;
 }
 int t(int f)
 {
   return f-FloorToInt(mod(float(f),2.))-1;
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
   int f=v.x*v.y;
   return t(FloorToInt(floor(pow(float(f),.333333))));
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
 vec2 s(vec3 v)
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
   int x=m.x*m.y,f=t();
   ivec2 n=ivec2(i.x*m.x,i.y*m.y);
   float z=float(n.y/f),y=float(int(n.x+mod(m.x*z,f))/f);
   y+=floor(m.x*z/f);
   vec3 r=vec3(0.,0.,y);
   r.x=mod(n.x+mod(m.x*z,f),f);
   r.y=mod(n.y,f);
   r.xyz=floor(r.xyz);
   r/=f;
   r.xyz=r.xzy;
   return r;
 }
 vec2 d(vec3 v,int f)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 i=v.xzy*f;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 r;
   r.x=mod(i.x+x*f,m.x);
   float n=i.x+x*f;
   r.y=i.y+floor(n/m.x)*f;
   r+=.5;
   r/=m;
   r.xy*=.5;
   return r;
 }
 vec3 f(vec3 v,int f)
 {
   return v*=1./f,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 n(vec3 v,int f)
 {
   return v*=1./f,v=v+vec3(.5),v;
 }
 vec3 v(vec3 v)
 {
   int f=t();
   v=v-vec3(.5);
   v*=f;
   return v;
 }
 vec3 x(vec3 v)
 {
   int x=f();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 r(vec3 v)
 {
   int x=f();
   v=v-vec3(.5);
   v*=x;
   return v;
 }
 vec3 d()
 {
   vec3 v=cameraPosition.xyz+.5,x=previousCameraPosition.xyz+.5,f=floor(v-.0001),y=floor(x-.0001);
   return f-y;
 }
 vec3 m(vec3 f)
 {
   vec4 v=vec4(f,1.);
   v=shadowModelView*v;
   v=shadowProjection*v;
   v/=v.w;
   float x=sqrt(v.x*v.x+v.y*v.y),y=1.f-SHADOW_MAP_BIAS+x*SHADOW_MAP_BIAS;
   v.xy*=.95f/y;
   v.z=mix(v.z,.5,.8);
   v=v*.5f+.5f;
   v.xy*=.5;
   v.xy+=.5;
   return v.xyz;
 }
 vec3 d(vec3 v,vec3 f,vec2 n,vec2 r,vec4 m,vec4 i,inout float x,out vec2 y)
 {
   bool z=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   z=!z;
   if(i.x==8||i.x==9||i.x==79||i.x<1.||!z||i.x==20.||i.x==171.||min(abs(f.x),abs(f.z))>.2)
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
   vec3 s,c;
   if(f.x>.5)
     s=vec3(0.,0.,-1.),c=vec3(0.,-1.,0.);
   else
      if(f.x<-.5)
       s=vec3(0.,0.,1.),c=vec3(0.,-1.,0.);
     else
        if(f.y>.5)
         s=vec3(1.,0.,0.),c=vec3(0.,0.,1.);
       else
          if(f.y<-.5)
           s=vec3(1.,0.,0.),c=vec3(0.,0.,-1.);
         else
            if(f.z>.5)
             s=vec3(1.,0.,0.),c=vec3(0.,-1.,0.);
           else
              if(f.z<-.5)
               s=vec3(-1.,0.,0.),c=vec3(0.,-1.,0.);
   y=clamp((n.xy-r.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(i.x==10.||i.x==11.)
     {
       if(abs(f.y)<.01&&z||f.y>.99)
         h=.1,e=.1,x=0.;
       else
          x=1.;
     }
   if(i.x==51||i.x==53)
     h=.5,e=.1;
   if(i.x==76)
     h=.2,e=.2;
   if(i.x-255.+39.>=103.&&i.x-255.+39.<=113.)
     e=.025,h=.025;
   s=normalize(m.xyz);
   c=normalize(cross(s,f.xyz)*sign(m.w));
   vec3 j=v.xyz+mix(s*h,-s*h,vec3(y.x));
   j.xyz+=mix(c*h,-c*h,vec3(y.y));
   j.xyz-=f.xyz*e;
   return j;
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
 void d(in Ray v,in vec3 f[2],out float i,out float x)
 {
   float y,r,z,e;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   e=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,y),z);
   x=min(min(x,r),e);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(f+v)*.5,i=(f-v)*.5,n=y-z,r=vec3(0.);
   r+=vec3(sign(n.x),0.,0.)*step(abs(abs(n.x)-i.x),x);
   r+=vec3(0.,sign(n.y),0.)*step(abs(abs(n.y)-i.y),x);
   r+=vec3(0.,0.,sign(n.z))*step(abs(abs(n.z)-i.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 f,Ray i,out vec2 r)
 {
   vec3 x=i.inv_direction*(v-i.origin),y=i.inv_direction*(f-i.origin),n=min(y,x),m=max(y,x);
   vec2 s=max(n.xx,n.yz);
   float z=max(s.x,s.y);
   s=min(m.xx,m.yz);
   float c=min(s.x,s.y);
   r.x=z;
   r.y=c;
   return c>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray i,inout float x,inout vec3 y)
 {
   vec3 z=i.inv_direction*(v-1e-05-i.origin),s=i.inv_direction*(f+1e-05-i.origin),n=min(s,z),m=max(s,z);
   vec2 r=max(n.xx,n.yz);
   float c=max(r.x,r.y);
   r=min(m.xx,m.yz);
   float h=min(r.x,r.y);
   bool e=h>max(c,0.)&&max(c,0.)<x;
   if(e)
     y=d(v-1e-05,f+1e-05,i.origin+i.direction*c),x=c;
   return e;
 }
 vec3 e(vec3 v,vec3 f,vec3 x,vec3 z,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*s),2).x;
   r*=saturate(dot(f,x));
   {
     vec4 n=texture2DLod(shadowcolor1,i.xy-vec2(0.,.5),4);
     float c=abs(n.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,f,c),e=shadow2DLod(shadowtex0,vec3(i.xy-vec2(0.,.5),i.z+1e-06),4).x;
     r=mix(r,r*h,1.-e);
   }
   r=TintUnderwaterDepth(r);
   return r*(1.-rainStrength);
 }
 vec3 f(vec3 f,vec3 i,vec3 x,vec3 z,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 r=v(f);
   r+=1.;
   r-=Fract01(cameraPosition+.5);
   vec3 n=m(r+x*.99);
   float s=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*s),3).x;
   c*=saturate(dot(i,x));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float h=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*s),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   c=mix(c,c*e,vec3(1.-h));
   #endif
   return c*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 f,vec3 x,vec3 z,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*s),2).x;
   r*=saturate(dot(f,x));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*s),3).x;
   vec3 c=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   c*=c;
   r=mix(r,r*c,vec3(1.-n));
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
 CPrmwMXxJc w(vec4 v)
 {
   CPrmwMXxJc i;
   vec2 f=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),n=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=f.y;
   i.avjkUoKnfB=m.y;
   i.ivaOqoXyFu=n.y*255.;
   i.PVAMAgODVh=pow(vec3(f.x,m.x,n.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc h(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return w(texture2DLod(colortex5,v,0));
 }
 float e(float v,float f)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+f,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool d(vec3 v,float f,Ray x,bool y,inout float i,inout vec3 z)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(y)
     return false;
   if(f>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),x,i,z);
   r=m;
   #else
   if(f<40.)
     return m=d(v,v+vec3(1.,1.,1.),x,i,z),m;
   if(f==40.||f==41.||f>=43.&&f<=54.)
     {
       float s=.5;
       if(f==41.)
         s=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),x,i,z);
       r=r||m;
     }
   if(f==42.||f>=55.&&f<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),x,i,z),r=r||m;
   if(f==43.||f==46.||f==47.||f==52.||f==53.||f==54.||f==55.||f==58.||f==59.||f==64.||f==65.||f==66.)
     {
       float s=.5;
       if(f==55.||f==58.||f==59.||f==64.||f==65.||f==66.)
         s=0.;
       m=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),x,i,z);
       r=r||m;
     }
   if(f==43.||f==45.||f==48.||f==51.||f==53.||f==54.||f==55.||f==57.||f==60.||f==63.||f==65.||f==66.)
     {
       float s=.5;
       if(f==55.||f==57.||f==60.||f==63.||f==65.||f==66.)
         s=0.;
       m=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),x,i,z);
       r=r||m;
     }
   if(f==44.||f==45.||f==49.||f==51.||f==52.||f==54.||f==56.||f==57.||f==61.||f==63.||f==64.||f==66.)
     {
       float s=.5;
       if(f==56.||f==57.||f==61.||f==63.||f==64.||f==66.)
         s=0.;
       m=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),x,i,z);
       r=r||m;
     }
   if(f==44.||f==46.||f==50.||f==51.||f==52.||f==53.||f==56.||f==58.||f==62.||f==63.||f==64.||f==65.)
     {
       float s=.5;
       if(f==56.||f==58.||f==62.||f==63.||f==64.||f==65.)
         s=0.;
       m=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),x,i,z);
       r=r||m;
     }
   if(f>=67.&&f<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,x,i,z),r=r||m;
   if(f==68.||f==69.||f==70.||f==72.||f==73.||f==74.||f==76.||f==77.||f==78.||f==80.||f==81.||f==82.)
     {
       float s=8.,n=8.;
       if(f==68.||f==70.||f==72.||f==74.||f==76.||f==78.||f==80.||f==82.)
         s=0.;
       if(f==69.||f==70.||f==73.||f==74.||f==77.||f==78.||f==81.||f==82.)
         n=16.;
       m=d(v+vec3(s,6.,7.)/16.,v+vec3(n,9.,9.)/16.,x,i,z);
       r=r||m;
       m=d(v+vec3(s,12.,7.)/16.,v+vec3(n,15.,9.)/16.,x,i,z);
       r=r||m;
     }
   if(f>=71.&&f<=82.)
     {
       float s=8.,n=8.;
       if(f>=71.&&f<=74.||f>=79.&&f<=82.)
         n=16.;
       if(f>=75.&&f<=82.)
         s=0.;
       m=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,n)/16.,x,i,z);
       r=r||m;
       m=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,n)/16.,x,i,z);
       r=r||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(f>=83.&&f<=86.)
     {
       vec3 s=vec3(0),n=vec3(0);
       if(f==83.)
         s=vec3(0,0,0),n=vec3(16,16,3);
       if(f==84.)
         s=vec3(0,0,13),n=vec3(16,16,16);
       if(f==86.)
         s=vec3(0,0,0),n=vec3(3,16,16);
       if(f==85.)
         s=vec3(13,0,0),n=vec3(16,16,16);
       m=d(v+s/16.,v+n/16.,x,i,z);
       r=r||m;
     }
   if(f>=87.&&f<=102.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(f>=87.&&f<=94.)
         {
           float c=0.;
           if(f>=91.&&f<=94.)
             c=13.;
           s=vec3(0.,c,0.)/16.;
           n=vec3(16.,c+3.,16.)/16.;
         }
       if(f>=95.&&f<=98.)
         {
           float c=13.;
           if(f==97.||f==98.)
             c=0.;
           s=vec3(0.,0.,c)/16.;
           n=vec3(16.,16.,c+3.)/16.;
         }
       if(f>=99.&&f<=102.)
         {
           float c=13.;
           if(f==99.||f==100.)
             c=0.;
           s=vec3(c,0.,0.)/16.;
           n=vec3(c+3.,16.,16.)/16.;
         }
       m=d(v+s,v+n,x,i,z);
       r=r||m;
     }
   if(f>=103.&&f<=113.)
     {
       vec3 s=vec3(0.),n=vec3(1.);
       if(f>=103.&&f<=110.)
         {
           float c=float(f)-float(103.)+1.;
           n.y=c*2./16.;
         }
       if(f==111.)
         n.y=.0625;
       if(f==112.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,1.,15.)/16.;
       if(f==113.)
         s=vec3(1.,0.,1.)/16.,n=vec3(15.,.5,15.)/16.;
       m=d(v+s,v+n,x,i,z);
       r=r||m;
     }
   #endif
   #endif
   return r;
 }
 vec3 G(vec2 f)
 {
   vec2 v=vec2(f.xy*vec2(viewWidth,viewHeight));
   v*=1./64.;
   const vec2 x[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(f.x<2./viewWidth||f.x>1.-2./viewWidth||f.y<2./viewHeight||f.y>1.-2./viewHeight)
     ;
   v=(floor(v*64.)+.5)/64.;
   vec3 r=texture2D(noisetex,v).xyz,s=vec3(sqrt(.2),sqrt(2.),1.61803);
   r=mod(r+float(frameCounter%64)*s,vec3(1.));
   return r;
 }
 vec4 G(in sampler2D v,in vec2 f)
 {
   vec2 x=vec2(64.f,64.f);
   f*=x;
   f+=.5f;
   vec2 r=floor(f),i=fract(f);
   i.x=i.x*i.x*(3.f-2.f*i.x);
   i.y=i.y*i.y*(3.f-2.f*i.y);
   f=r+i;
   f-=.5f;
   f/=x;
   return texture2D(v,f);
 }
 float G(in float v,in float f,in float x)
 {
   if(v>f)
     return v;
   float s=2.f*x-f,z=2.f*f-3.f*x,i=v/f;
   return(s*i+z)*i*i+x;
 }
 float D(vec3 v)
 {
   float f=.5f;
   vec2 i=v.xz/20.f;
   i.xy-=v.y/20.f;
   i.x=-i.x;
   i.x+=FRAME_TIME/40.f*f;
   i.y-=FRAME_TIME/40.f*f;
   float r=1.f,x=r,s=0.f,m=G(noisetex,i*vec2(2.f,1.2f)+vec2(0.f,i.x*2.1f)).x;
   i/=2.1f;
   i.y-=FRAME_TIME/20.f*f;
   i.x-=FRAME_TIME/30.f*f;
   s+=m*.5;
   r=2.1f;
   x+=r;
   m=G(noisetex,i*vec2(2.f,1.4f)+vec2(0.f,-i.x*2.1f)).x;
   i/=1.5f;
   i.x+=FRAME_TIME/20.f*f;
   m*=r;
   s+=m;
   r=17.25f;
   x+=r;
   m=G(noisetex,i*vec2(1.f,.75f)+vec2(0.f,i.x*1.1f)).x;
   i/=1.5f;
   i.x-=FRAME_TIME/55.f*f;
   m*=r;
   s+=m;
   r=15.25f;
   x+=r;
   m=G(noisetex,i*vec2(1.f,.75f)+vec2(0.f,-i.x*1.7f)).x;
   i/=1.9f;
   i.x+=FRAME_TIME/155.f*f;
   m*=r;
   s+=m;
   r=29.25f;
   x+=r;
   m=abs(G(noisetex,i*vec2(1.f,.8f)+vec2(0.f,-i.x*1.7f)).x*2.f-1.f);
   i/=2.f;
   i.x+=FRAME_TIME/155.f*f;
   m=1.f-G(m,.2f,.1f);
   m*=r;
   s+=m;
   r=15.25f;
   x+=r;
   m=abs(G(noisetex,i*vec2(1.f,.8f)+vec2(0.f,i.x*1.7f)).x*2.f-1.f);
   m=1.f-G(m,.2f,.1f);
   m*=r;
   s+=m;
   s/=x;
   return s;
 }
 void main()
 {
   vec4 v=texture2D(texture,texcoord.xy,0);
   vec3 f=v.xyz*color.xyz;
   float x=1.;
   if(aGBCSUeTQs<.5)
     {
       x=min(v.w*7.,1.);
       vec3 i=(shadowModelViewInverse*vec4(viewPos.xyz,1.)).xyz;
       i+=cameraPosition.xyz;
       gl_FragData[0]=vec4(f.xyz,x);
       gl_FragData[1]=vec4(i.y/256.,1.-isWater,0.,x);
     }
   else
     {
       if(invalidForVolume>.0001)
         {
           discard;
         }
       vec3 s=zrEuGoMOCd+cameraPosition.xyz;
       f=pow(f,vec3(2.2));
       if(abs(mcEntity-50.)<.1)
         {
           vec3 i=hash33(s);
           f.xyz=KelvinToRGB(float(TORCHLIGHT_COLOR_TEMPERATURE*mix(.85,1.,i.x)))*mix(.1,.8,i.y);
         }
       if(abs(mcEntity-76.)<.1)
         f.xyz=vec3(1.,.02,.01)*.05;
       if(abs(mcEntity-51.)<.1)
         f.xyz=vec3(2.,.35,.025);
       if(abs(mcEntity-52.5)<1.5)
         f.xyz=vec3(0.,.9,1.);
       float i=clamp((abs(color.x-color.y)+abs(color.x-color.z)+abs(color.y-color.z))*500.,0.,1.);
       f.xyz=normalize(f.xyz+1e-05)*min(length(f.xyz),.95);
       gl_FragData[0]=vec4(f.xyz,(materialIDs+.1)/255.*x);
       gl_FragData[1]=vec4(sbxhonUINy.xy,i,dot(v.xyz,vec3(.33333)));
     }
 };



