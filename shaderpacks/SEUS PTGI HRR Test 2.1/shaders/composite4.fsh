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


const bool colortex6MipmapEnabled = false;


in vec4 texcoord;

in vec3 lightVector;
in vec3 worldLightVector;
in vec3 worldSunVector;

in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorSkyUp;
in vec3 colorTorchlight;

in vec4 skySHR;
in vec4 skySHG;
in vec4 skySHB;

#include "lib/GBufferData.inc"


// vec4 GetViewPosition(in vec2 coord, in float depth) 
// {	
// 	vec4 tcoord = vec4(coord.xy, 0.0, 0.0);

// 	vec4 fragposition = gbufferProjectionInverse * vec4(tcoord.s * 2.0f - 1.0f, tcoord.t * 2.0f - 1.0f, 2.0f * depth - 1.0f, 1.0f);
// 		 fragposition /= fragposition.w;

	
// 	return fragposition;
// }





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
 vec2 e(vec3 v)
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
   ivec2 s=ivec2(i.x*m.x,i.y*m.y);
   float z=float(s.y/y),f=float(int(s.x+mod(m.x*z,y))/y);
   f+=floor(m.x*z/y);
   vec3 r=vec3(0.,0.,f);
   r.x=mod(s.x+mod(m.x*z,y),y);
   r.y=mod(s.y,y);
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
   float s=i.x+x*y;
   r.y=i.y+floor(s/m.x)*y;
   r+=.5;
   r/=m;
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
   int m=t();
   v=v-vec3(.5);
   v*=m;
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
 vec3 s(vec3 v)
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
 vec3 d(vec3 v,vec3 m,vec2 i,vec2 r,vec4 s,vec4 d,inout float x,out vec2 y)
 {
   bool f=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   f=!f;
   if(d.x==8||d.x==9||d.x==79||d.x<1.||!f||d.x==20.||d.x==171.||min(abs(m.x),abs(m.z))>.2)
     x=1.;
   if(d.x==50.||d.x==52.||d.x==76.)
     {
       x=0.;
       if(m.y<.5)
         x=1.;
     }
   if(d.x==51||d.x==53)
     x=0.;
   if(d.x>255)
     x=0.;
   vec3 z,c;
   if(m.x>.5)
     z=vec3(0.,0.,-1.),c=vec3(0.,-1.,0.);
   else
      if(m.x<-.5)
       z=vec3(0.,0.,1.),c=vec3(0.,-1.,0.);
     else
        if(m.y>.5)
         z=vec3(1.,0.,0.),c=vec3(0.,0.,1.);
       else
          if(m.y<-.5)
           z=vec3(1.,0.,0.),c=vec3(0.,0.,-1.);
         else
            if(m.z>.5)
             z=vec3(1.,0.,0.),c=vec3(0.,-1.,0.);
           else
              if(m.z<-.5)
               z=vec3(-1.,0.,0.),c=vec3(0.,-1.,0.);
   y=clamp((i.xy-r.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(d.x==10.||d.x==11.)
     {
       if(abs(m.y)<.01&&f||m.y>.99)
         h=.1,e=.1,x=0.;
       else
          x=1.;
     }
   if(d.x==51||d.x==53)
     h=.5,e=.1;
   if(d.x==76)
     h=.2,e=.2;
   if(d.x-255.+39.>=103.&&d.x-255.+39.<=113.)
     e=.025,h=.025;
   z=normalize(s.xyz);
   c=normalize(cross(z,m.xyz)*sign(s.w));
   vec3 n=v.xyz+mix(z*h,-z*h,vec3(y.x));
   n.xyz+=mix(c*h,-c*h,vec3(y.y));
   n.xyz-=m.xyz*e;
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
 void w(inout SPcacsgCKo v)
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
 vec3 d(const vec3 v,const vec3 y,vec3 m)
 {
   const float x=1e-05;
   vec3 z=(y+v)*.5,i=(y-v)*.5,s=m-z,f=vec3(0.);
   f+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-i.x),x);
   f+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-i.y),x);
   f+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-i.z),x);
   return normalize(f);
 }
 bool e(const vec3 v,const vec3 y,Ray m,out vec2 i)
 {
   vec3 x=m.inv_direction*(v-m.origin),s=m.inv_direction*(y-m.origin),d=min(s,x),f=max(s,x);
   vec2 r=max(d.xx,d.yz);
   float z=max(r.x,r.y);
   r=min(f.xx,f.yz);
   float h=min(r.x,r.y);
   i.x=z;
   i.y=h;
   return h>max(z,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(i+1e-05-m.origin),f=min(s,z),r=max(s,z);
   vec2 c=max(f.xx,f.yz);
   float h=max(c.x,c.y);
   c=min(r.xx,r.yz);
   float n=min(c.x,c.y);
   bool t=n>max(h,0.)&&max(h,0.)<x;
   if(t)
     y=d(v-1e-05,i+1e-05,m.origin+m.direction*h),x=h;
   return t;
 }
 vec3 e(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 s=m(v);
   float h=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*h),2).x;
   f*=saturate(dot(i,y));
   {
     vec4 d=texture2DLod(shadowcolor1,s.xy-vec2(0.,.5),4);
     float c=abs(d.x*256.-(v.y+cameraPosition.y)),r=GetCausticsComposite(v,i,c),t=shadow2DLod(shadowtex0,vec3(s.xy-vec2(0.,.5),s.z+1e-06),4).x;
     f=mix(f,f*r,1.-t);
   }
   f=TintUnderwaterDepth(f);
   return f*(1.-rainStrength);
 }
 vec3 f(vec3 y,vec3 s,vec3 x,vec3 z,int f)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=v(y);
   i+=1.;
   i-=Fract01(cameraPosition+.5);
   vec3 d=m(i+x*.99);
   float h=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(d.xy,d.z-.0006*h),3).x;
   r*=saturate(dot(s,x));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(d.xy-vec2(.5,0.),d.z-.0006*h),3).x;
   vec3 n=texture2DLod(shadowcolor,vec2(d.xy-vec2(.5,0.)),3).xyz;
   n*=n;
   r=mix(r,r*n,vec3(1.-t));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 s,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 i=m(v);
   float h=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(i.xy,i.z-.0006*h),2).x;
   f*=saturate(dot(s,y));
   f=TintUnderwaterDepth(f);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float r=shadow2DLod(shadowtex0,vec3(i.xy-vec2(.5,0.),i.z-.0006*h),3).x;
   vec3 n=texture2DLod(shadowcolor,vec2(i.xy-vec2(.5,0.)),3).xyz;
   n*=n;
   f=mix(f,f*n,vec3(1.-r));
   #endif
   return f*(1.-rainStrength);
 }struct CPrmwMXxJc{float pzBOsrqcFy;float ivaOqoXyFu;float OxTKjfMYEH;float avjkUoKnfB;vec3 PVAMAgODVh;};
 vec4 p(CPrmwMXxJc v)
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
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),s=UnpackTwo16BitFrom32Bit(v.z),f=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=m.y;
   i.avjkUoKnfB=s.y;
   i.ivaOqoXyFu=f.y*255.;
   i.PVAMAgODVh=pow(vec3(m.x,s.x,f.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc i(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return h(texture2DLod(colortex5,v,0));
 }
 float h(float v,float y)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+y,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool d(vec3 v,float y,Ray x,bool s,inout float i,inout vec3 f)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(s)
     return false;
   if(y>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),x,i,f);
   r=m;
   #else
   if(y<40.)
     return m=d(v,v+vec3(1.,1.,1.),x,i,f),m;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float z=.5;
       if(y==41.)
         z=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,z,1.),x,i,f);
       r=r||m;
     }
   if(y==42.||y>=55.&&y<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),x,i,f),r=r||m;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float z=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         z=0.;
       m=d(v+vec3(0.,z,0.),v+vec3(.5,.5+z,.5),x,i,f);
       r=r||m;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float z=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         z=0.;
       m=d(v+vec3(.5,z,0.),v+vec3(1.,.5+z,.5),x,i,f);
       r=r||m;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float z=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         z=0.;
       m=d(v+vec3(.5,z,.5),v+vec3(1.,.5+z,1.),x,i,f);
       r=r||m;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float z=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         z=0.;
       m=d(v+vec3(0.,z,.5),v+vec3(.5,.5+z,1.),x,i,f);
       r=r||m;
     }
   if(y>=67.&&y<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,x,i,f),r=r||m;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float z=8.,c=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         z=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         c=16.;
       m=d(v+vec3(z,6.,7.)/16.,v+vec3(c,9.,9.)/16.,x,i,f);
       r=r||m;
       m=d(v+vec3(z,12.,7.)/16.,v+vec3(c,15.,9.)/16.,x,i,f);
       r=r||m;
     }
   if(y>=71.&&y<=82.)
     {
       float z=8.,h=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         h=16.;
       if(y>=75.&&y<=82.)
         z=0.;
       m=d(v+vec3(7.,6.,z)/16.,v+vec3(9.,9.,h)/16.,x,i,f);
       r=r||m;
       m=d(v+vec3(7.,12.,z)/16.,v+vec3(9.,15.,h)/16.,x,i,f);
       r=r||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 z=vec3(0),c=vec3(0);
       if(y==83.)
         z=vec3(0,0,0),c=vec3(16,16,3);
       if(y==84.)
         z=vec3(0,0,13),c=vec3(16,16,16);
       if(y==86.)
         z=vec3(0,0,0),c=vec3(3,16,16);
       if(y==85.)
         z=vec3(13,0,0),c=vec3(16,16,16);
       m=d(v+z/16.,v+c/16.,x,i,f);
       r=r||m;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 z=vec3(0.),c=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float h=0.;
           if(y>=91.&&y<=94.)
             h=13.;
           z=vec3(0.,h,0.)/16.;
           c=vec3(16.,h+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float h=13.;
           if(y==97.||y==98.)
             h=0.;
           z=vec3(0.,0.,h)/16.;
           c=vec3(16.,16.,h+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float h=13.;
           if(y==99.||y==100.)
             h=0.;
           z=vec3(h,0.,0.)/16.;
           c=vec3(h+3.,16.,16.)/16.;
         }
       m=d(v+z,v+c,x,i,f);
       r=r||m;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 z=vec3(0.),c=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float h=float(y)-float(103.)+1.;
           c.y=h*2./16.;
         }
       if(y==111.)
         c.y=.0625;
       if(y==112.)
         z=vec3(1.,0.,1.)/16.,c=vec3(15.,1.,15.)/16.;
       if(y==113.)
         z=vec3(1.,0.,1.)/16.,c=vec3(15.,.5,15.)/16.;
       m=d(v+z,v+c,x,i,f);
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
   vec3 r=texture2D(noisetex,y).xyz,x=vec3(sqrt(.2),sqrt(2.),1.61803);
   r=mod(r+float(frameCounter%64)*x,vec3(1.));
   return r;
 }
 float G(float v,float y)
 {
   return 1./(v*(1.-y)+y);
 }
 void G(inout vec3 v,in vec3 y,in vec3 x,vec3 z,float f)
 {
   float i=length(y);
   i*=pow(eyeBrightnessSmooth.y/240.f,6.f);
   i*=rainStrength;
   float s=pow(exp(-i*3e-06),4.);
   vec3 r=vec3(dot(colorSkyUp,vec3(1.)));
   v=mix(r,v,vec3(s));
 }
 vec4 c(vec2 v)
 {
   vec2 y=vec2(v.x,(v.y-floor(mod(FRAME_TIME*60.f,60.f)))/60.f);
   return texture2DLod(colortex4,y.xy,0);
 }
 float c(vec3 v,float y)
 {
   vec3 i=v.xyz+cameraPosition.xyz,m=refract(worldLightVector,vec3(0.,1.,0.),.750188);
   i+=m*((v.y+cameraPosition.y)/m.y);
   vec4 s=c(mod(i.xz/4.,vec2(1.)))*13.;
   float x=pow(y/2.,.5),f=pow(s.x,saturate(x*.5+.5));
   f=mix(f,s.y,saturate(x-1.));
   f=mix(f,s.z,saturate(x-2.));
   f=mix(f,s.w,saturate(x-3.));
   return f;
 }
 float i(float v,float y)
 {
   return exp(-pow(v/(.9*y),2.));
 }
 float m(vec3 v,vec3 y)
 {
   return dot(abs(v-y),vec3(.3333));
 }
 vec3 a(vec2 v)
 {
   vec2 y=vec2(v.xy*ScreenSize)/64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   y=(floor(y*64.)+.5)/64.;
   vec3 r=texture2D(noisetex,y).xyz,f=vec3(sqrt(.2),sqrt(2.),1.61803);
   r=mod(r+vec3(f)*mod(frameCounter,64.f),vec3(1.));
   return r;
 }
 vec3 G(float v,float m,float x,vec3 y)
 {
   vec3 i;
   i.x=x*cos(v);
   i.y=x*sin(v);
   i.z=m;
   vec3 z=abs(y.y)<.999?vec3(0,0,1):vec3(1,0,0),f=normalize(cross(y,vec3(0.,1.,1.))),c=cross(f,y);
   return f*i.x+c*i.y+y*i.z;
 }
 vec3 G(vec2 v,float y,vec3 f)
 {
   float x=2*3.14159*v.x,z=sqrt((1-v.y)/(1+(y*y-1)*v.y)),i=sqrt(1-z*z);
   return G(x,z,i,f);
 }
 float g(float v)
 {
   return 2./(v*v+1e-07)-2.;
 }
 vec3 a(in vec2 v,in float y,in vec3 f)
 {
   float i=g(y),x=2*3.14159*v.x,z=pow(v.y,1.f/(i+1.f)),s=sqrt(1-z*z);
   return G(x,z,s,f);
 }
 float l(vec2 v)
 {
   return texture2DLod(colortex1,v+HalfScreen,0).w;
 }
 float a(float v,float y)
 {
   return v/(y*20.01+1.);
 }
 vec2 g(vec2 v,float y)
 {
   vec2 x=v;
   mat2 m=mat2(cos(y),-sin(y),sin(y),cos(y));
   v=m*v;
   return v;
 }
 vec4 G(sampler2D v,float x,bool y,float i,float z,float f,float s)
 {
   GBufferData m=GetGBufferData(texcoord.xy);
   GBufferDataTransparent r=GetGBufferDataTransparent(texcoord.xy);
   bool c=r.depth<m.depth;
   if(c)
     m.normal=r.normal,m.smoothness=r.smoothness,m.metalness=0.,m.mcLightmap=r.mcLightmap,m.depth=r.depth;
   vec4 d=GetViewPosition(texcoord.xy,m.depth),e=gbufferModelViewInverse*vec4(d.xyz,1.),n=gbufferModelViewInverse*vec4(d.xyz,0.);
   vec3 t=normalize(d.xyz),o=normalize(n.xyz),w=normalize((gbufferModelViewInverse*vec4(m.normal,0.)).xyz);
   float G=GetDepthLinear(texcoord.xy),l=dot(-t,m.normal.xyz),p=1.-m.smoothness,R=p*p,F=h(m.smoothness,m.metalness);
   vec4 j=texture2DLod(v,texcoord.xy+HalfScreen,0);
   float S=Luminance(j.xyz);
   if(F<.001)
     return j;
   float P=x*.9;
   P*=min(R*20.,1.1);
   P*=mix(j.w,1.,.2);
   vec2 H=vec2(0.);
   if(y)
     {
       vec2 T=BlueNoiseTemporal(texcoord.xy).xy*.99+.005;
       H=T-.5;
     }
   float T=BlueNoiseTemporal(texcoord.xy).x,b=1.1,L=a(i,m.totalTexGrad)/(R+.0001),Y=a(z*.5,m.totalTexGrad);
   vec4 C=vec4(0.),X=vec4(0.);
   float B=0.;
   vec4 O=vec4(vec3(f),1.);
   O.xyz=vec3(.25);
   O.xyz*=j.w*.95+.05;
   float J=m.smoothness;
   vec2 D=normalize(cross(m.normal,t).xy),u=g(D,1.5708);
   float A=1.-pow(1.-saturate(l),1.);
   D*=mix(.1075,.5,A);
   u*=mix(mix(.7,.7,R),.5,A);
   vec3 U=reflect(-t,m.normal);
   int M=0;
   for(int V=-1;V<=1;V++)
     {
       for(int I=-1;I<=1;I++)
         {
           vec2 E=vec2(V,I)+H;
           E=E.x*D+E.y*u;
           E*=P*1.5*ScreenTexel;
           vec2 k=texcoord.xy+E.xy;
           float W=length(E*ScreenSize);
           k=clamp(k,4.*ScreenTexel,1.-4.*ScreenTexel);
           vec4 q=texture2DLod(v,k+HalfScreen,0);
           vec3 N=GetNormals(k);
           float K=GetDepthLinear(k),Q=pow(saturate(dot(U,reflect(-t,N))),115./R),Z=exp(-(abs(K-G)*b)),ab=Q*Z;
           C+=vec4(pow(length(q.xyz),O.x)*normalize(q.xyz+1e-10),q.w)*ab;
           B+=ab;
           X+=q;
           M++;
         }
     }
   C/=B+.0001;
   C.xyz=pow(length(C.xyz),1./O.x)*normalize(C.xyz+1e-06);
   vec4 k=C;
   if(B<.001)
     k=j;
   return k;
 }
 void main()
 {
   GBufferData v=GetGBufferData(texcoord.xy);
   GBufferDataTransparent y=GetGBufferDataTransparent(texcoord.xy);
   MaterialMask x=CalculateMasks(v.materialID,texcoord.xy),i=CalculateMasks(y.materialID,texcoord.xy);
   bool z=y.depth<v.depth;
   if(z)
     v.normal=y.normal,v.smoothness=y.smoothness,v.metalness=0.,v.mcLightmap=y.mcLightmap,v.depth=y.depth,i.sky=0.;
   vec4 m=GetViewPosition(texcoord.xy,v.depth),f=gbufferModelViewInverse*vec4(m.xyz,1.),s=gbufferModelViewInverse*vec4(m.xyz,0.);
   vec3 r=normalize(m.xyz),c=normalize(s.xyz),n=normalize((gbufferModelViewInverse*vec4(v.normal,0.)).xyz);
   float t=ExpToLinearDepth(v.depth),e=1.-v.smoothness,d=e*e,o=h(v.smoothness,v.metalness);
   int R=0;
   vec4 p=texture2DLod(colortex7,texcoord.xy+HalfScreen,R),j=p;
   float a=1.-v.smoothness,l=a*a;
   vec3 w=n,k=-c,H=normalize(reflect(-k,w)+w*l),A=normalize(k+H);
   float P=saturate(dot(w,H)),F=saturate(dot(w,k)),L=saturate(dot(w,A)),D=saturate(dot(H,A)),B=v.metalness*.98+.02,S=pow(1.-D,5.),b=B+(1.-B)*S,Y=l/2.,u=G(P,Y)*G(F+.8,Y),C=P*b*u;
   j.xyz*=mix(vec3(1.),v.albedo.xyz,vec3(v.metalness));
   C=mix(C,1.,v.metalness);
   if(v.depth>.99999)
     C=0.;
   if(i.water>.5&&isEyeInWater>0)
     {
       if(length(refract(k,w,1.3333))<.5)
         C=1.;
       else
          C=0.;
     }
   C*=h(v.smoothness,v.metalness);
   if(i.water>.5&&isEyeInWater==0)
     C=mix(.02,C,.7);
   vec4 O=texture2DLod(colortex1,texcoord.xy+HalfScreen,0);
   vec3 T=pow(O.xyz,vec3(2.2)),E=T;
   E*=120.;
   if(isEyeInWater>0)
     UnderwaterFog(E,length(s.xyz),c,colorSkyUp,colorSunlight);
   vec3 g=E;
   E=mix(E,j.xyz*12.,vec3(saturate(C)));
   E+=g*v.metalness;
   {
     #ifdef GODRAYS
     #else
     if(isEyeInWater>0)
       #endif
     {
       float J=BlueNoiseTemporal(texcoord.xy).x,q=120.;
       if(isEyeInWater>0)
         q=20.;
       vec3 V=vec3(0.),X=(gbufferModelViewInverse*vec4(0.,0.,0.,1.)).xyz;
       for(int I=0;I<10;I++)
         {
           float M=float(I+J)/float(10);
           vec3 U=c.xyz*q*M+X;
           if(length(s.xyz)<length(U-X))
             {
               break;
             }
           float N,Z;
           vec3 K=WorldPosToShadowProjPos(U.xyz,N,Z),Q=shadow2DLod(shadowtex0,vec3(K.xy,K.z+1e-06),3).xxx;
           #ifdef GODRAYS_STAINED_GLASS_TINT
           float W=shadow2DLod(shadowtex0,vec3(K.xy-vec2(.5,0.),K.z-1e-06),3).x;
           vec3 ac=texture2DLod(shadowcolor,vec2(K.xy-vec2(.5,0.)),3).xyz;
           ac*=ac;
           Q=mix(Q,Q*ac,vec3(1.-W));
           #endif
           if(isEyeInWater>0)
             {
               float ad=abs(texture2DLod(shadowcolor1,K.xy-vec2(0.,.5),4).x*256.-(U.y+cameraPosition.y)),ae=GetCausticsComposite(U,worldLightVector,ad),af=shadow2DLod(shadowtex0,vec3(K.xy-vec2(0.,.5),K.z+1e-06),4).x;
               Q=mix(Q,Q*ae,vec3(1.-af));
               V+=Q*exp(-GetWaterAbsorption()*(q*M))*exp(-GetWaterAbsorption()*ad);
             }
           else
              V+=Q*colorSunlight*.1;
         }
       float Q=dot(worldLightVector,c.xyz),K=1.;
       if(isEyeInWater>0)
         Q=dot(refract(worldLightVector,vec3(0.,-1.,0.),.750019),c.xyz);
       else
          K=.5/(max(0.,pow(worldLightVector.y,2.)*2.)+.4);
       float I=Q*Q,Z=PhaseMie(.8,Q,I);
       E+=TintUnderwaterDepth(V*colorSunlight*GetWaterFogColor()*.115*Z*K*(1.-wetness));
     }
   }
   if(i.sky<.5&&isEyeInWater<1)
     LandAtmosphericScattering(E,m.xyz,r.xyz,c.xyz,worldSunVector.xyz,1.);
   E/=120.;
   E*=exp(-t*blindness);
   E=pow(E.xyz,vec3(.454545));
   gl_FragData[0]=vec4(E,Luminance(E));
 };





/* DRAWBUFFERS:1 */
