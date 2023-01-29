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

/////////ADJUSTABLE VARIABLES//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////ADJUSTABLE VARIABLES//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//#define HALF_RES_TRACE

/////////INTERNAL VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////INTERNAL VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Do not change the name of these variables or their type. The Shaders Mod reads these lines and determines values to send to the inner-workings
//of the shaders mod. The shaders mod only reads these lines and doesn't actually know the real value assigned to these variables in GLSL.
//Some of these variables are critical for proper operation. Change at your own risk.

//END OF INTERNAL VARIABLES//




in vec4 texcoord;

in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorSkyUp;
in vec3 colorTorchlight;

in vec4 skySHR;
in vec4 skySHG;
in vec4 skySHB;


in vec3 worldLightVector;
in vec3 worldSunVector;


in mat4 gbufferPreviousModelViewInverse;
in mat4 gbufferPreviousProjectionInverse;


#include "lib/Uniforms.inc"
#include "lib/Common.inc"

#include "lib/Materials.inc"


/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






// vec4 GetViewPosition(in vec2 coord, in float depth) 
// {	
// 	vec2 tcoord = coord;
// 	TemporalJitterProjPosInv01(tcoord);

// 	vec4 fragposition = gbufferProjectionInverse * vec4(tcoord.s * 2.0f - 1.0f, tcoord.t * 2.0f - 1.0f, 2.0f * depth - 1.0f, 1.0f);
// 		 fragposition /= fragposition.w;

	
// 	return fragposition;
// }













#include "lib/GBufferData.inc"
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
 vec3 v(vec2 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=m.x*m.y,y=d();
   ivec2 f=ivec2(v.x*m.x,v.y*m.y);
   float z=float(f.y/y),i=float(int(f.x+mod(m.x*z,y))/y);
   i+=floor(m.x*z/y);
   vec3 s=vec3(0.,0.,i);
   s.x=mod(f.x+mod(m.x*z,y),y);
   s.y=mod(f.y,y);
   s.xyz=floor(s.xyz);
   s/=y;
   s.xyz=s.xzy;
   return s;
 }
 vec2 t(vec3 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=d();
   vec3 f=v.xzy*x;
   f=floor(f+1e-05);
   float y=f.z;
   vec2 i;
   i.x=mod(f.x+y*x,m.x);
   float s=f.x+y*x;
   i.y=f.y+floor(s/m.x)*x;
   i+=.5;
   i/=m;
   return i;
 }
 vec3 x(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,y=f();
   ivec2 s=ivec2(i.x*m.x,i.y*m.y);
   float z=float(s.y/y),r=float(int(s.x+mod(m.x*z,y))/y);
   r+=floor(m.x*z/y);
   vec3 t=vec3(0.,0.,r);
   t.x=mod(s.x+mod(m.x*z,y),y);
   t.y=mod(s.y,y);
   t.xyz=floor(t.xyz);
   t/=y;
   t.xyz=t.xzy;
   return t;
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
   float s=f.x+x*y;
   i.y=f.y+floor(s/m.x)*y;
   i+=.5;
   i/=m;
   i.xy*=.5;
   return i;
 }
 vec3 f(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 t(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v;
 }
 vec3 s(vec3 v)
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
 vec3 m(vec3 v)
 {
   int m=d();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 m()
 {
   vec3 v=cameraPosition.xyz+.5,y=previousCameraPosition.xyz+.5,x=floor(v-.0001),z=floor(y-.0001);
   return x-z;
 }
 vec3 e(vec3 v)
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
 vec3 d(vec3 v,vec3 m,vec2 f,vec2 x,vec4 s,vec4 i,inout float y,out vec2 t)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(i.x==8||i.x==9||i.x==79||i.x<1.||!r||i.x==20.||i.x==171.||min(abs(m.x),abs(m.z))>.2)
     y=1.;
   if(i.x==50.||i.x==52.||i.x==76.)
     {
       y=0.;
       if(m.y<.5)
         y=1.;
     }
   if(i.x==51||i.x==53)
     y=0.;
   if(i.x>255)
     y=0.;
   vec3 z,e;
   if(m.x>.5)
     z=vec3(0.,0.,-1.),e=vec3(0.,-1.,0.);
   else
      if(m.x<-.5)
       z=vec3(0.,0.,1.),e=vec3(0.,-1.,0.);
     else
        if(m.y>.5)
         z=vec3(1.,0.,0.),e=vec3(0.,0.,1.);
       else
          if(m.y<-.5)
           z=vec3(1.,0.,0.),e=vec3(0.,0.,-1.);
         else
            if(m.z>.5)
             z=vec3(1.,0.,0.),e=vec3(0.,-1.,0.);
           else
              if(m.z<-.5)
               z=vec3(-1.,0.,0.),e=vec3(0.,-1.,0.);
   t=clamp((f.xy-x.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,w=.15;
   if(i.x==10.||i.x==11.)
     {
       if(abs(m.y)<.01&&r||m.y>.99)
         h=.1,w=.1,y=0.;
       else
          y=1.;
     }
   if(i.x==51||i.x==53)
     h=.5,w=.1;
   if(i.x==76)
     h=.2,w=.2;
   if(i.x-255.+39.>=103.&&i.x-255.+39.<=113.)
     w=.025,h=.025;
   z=normalize(s.xyz);
   e=normalize(cross(z,m.xyz)*sign(s.w));
   vec3 n=v.xyz+mix(z*h,-z*h,vec3(t.x));
   n.xyz+=mix(e*h,-e*h,vec3(t.y));
   n.xyz-=m.xyz*w;
   return n;
 }struct SPcacsgCKo{vec3 GadGLQcpqX;vec3 GadGLQcpqXOrigin;vec3 vAdYwconYe;vec3 AZVxALDdtL;vec3 UekatYTTmj;vec3 OmcxSfXfkJ;};
 SPcacsgCKo r(Ray v)
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
 void i(inout SPcacsgCKo v)
 {
   v.OmcxSfXfkJ=step(v.UekatYTTmj.xyz,v.UekatYTTmj.yzx)*step(v.UekatYTTmj.xyz,v.UekatYTTmj.zxy),v.UekatYTTmj+=v.OmcxSfXfkJ*v.vAdYwconYe,v.GadGLQcpqX+=v.OmcxSfXfkJ*v.AZVxALDdtL;
 }
 void d(in Ray v,in vec3 f[2],out float i,out float y)
 {
   float x,z,r,w;
   i=(f[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(f[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(f[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(f[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(f[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   w=(f[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   i=max(max(i,x),r);
   y=min(min(y,z),w);
 }
 vec3 d(const vec3 v,const vec3 f,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(f+v)*.5,i=(f-v)*.5,m=y-z,r=vec3(0.);
   r+=vec3(sign(m.x),0.,0.)*step(abs(abs(m.x)-i.x),x);
   r+=vec3(0.,sign(m.y),0.)*step(abs(abs(m.y)-i.y),x);
   r+=vec3(0.,0.,sign(m.z))*step(abs(abs(m.z)-i.z),x);
   return normalize(r);
 }
 bool e(const vec3 v,const vec3 f,Ray m,out vec2 i)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(f-m.origin),s=min(x,y),t=max(x,y);
   vec2 r=max(s.xx,s.yz);
   float z=max(r.x,r.y);
   r=min(t.xx,t.yz);
   float n=min(r.x,r.y);
   i.x=z;
   i.y=n;
   return n>max(z,0.);
 }
 bool d(const vec3 v,const vec3 f,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),i=m.inv_direction*(f+1e-05-m.origin),s=min(i,z),t=max(i,z);
   vec2 r=max(s.xx,s.yz);
   float n=max(r.x,r.y);
   r=min(t.xx,t.yz);
   float h=min(r.x,r.y);
   bool w=h>max(n,0.)&&max(n,0.)<x;
   if(w)
     y=d(v-1e-05,f+1e-05,m.origin+m.direction*n),x=n;
   return w;
 }
 vec3 e(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 m=e(v);
   float w=.5;
   vec3 i=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*w),2).x;
   i*=saturate(dot(f,y));
   {
     vec4 s=texture2DLod(shadowcolor1,m.xy-vec2(0.,.5),4);
     float t=abs(s.x*256.-(v.y+cameraPosition.y)),r=GetCausticsComposite(v,f,t),h=shadow2DLod(shadowtex0,vec3(m.xy-vec2(0.,.5),m.z+1e-06),4).x;
     i=mix(i,i*r,1.-h);
   }
   i=TintUnderwaterDepth(i);
   return i*(1.-rainStrength);
 }
 vec3 f(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 i=s(v);
   i+=1.;
   i-=Fract01(cameraPosition+.5);
   vec3 m=e(i+y*.99);
   float w=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*w),3).x;
   r*=saturate(dot(f,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(m.xy-vec2(.5,0.),m.z-.0006*w),3).x;
   vec3 n=texture2DLod(shadowcolor,vec2(m.xy-vec2(.5,0.)),3).xyz;
   n*=n;
   r=mix(r,r*n,vec3(1.-t));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 i(vec3 v,vec3 f,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 m=e(v);
   float w=.5;
   vec3 i=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*w),2).x;
   i*=saturate(dot(f,y));
   i=TintUnderwaterDepth(i);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(m.xy-vec2(.5,0.),m.z-.0006*w),3).x;
   vec3 r=texture2DLod(shadowcolor,vec2(m.xy-vec2(.5,0.)),3).xyz;
   r*=r;
   i=mix(i,i*r,vec3(1.-t));
   #endif
   return i*(1.-rainStrength);
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
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),f=UnpackTwo16BitFrom32Bit(v.z),t=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=m.y;
   i.avjkUoKnfB=f.y;
   i.ivaOqoXyFu=t.y*255.;
   i.PVAMAgODVh=pow(vec3(m.x,f.x,t.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc g(vec2 v)
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
       float h=.5;
       if(y==41.)
         h=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,h,1.),x,i,z);
       m=m||r;
     }
   if(y==42.||y>=55.&&y<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),x,i,z),m=m||r;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float h=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         h=0.;
       r=d(v+vec3(0.,h,0.),v+vec3(.5,.5+h,.5),x,i,z);
       m=m||r;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float h=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         h=0.;
       r=d(v+vec3(.5,h,0.),v+vec3(1.,.5+h,.5),x,i,z);
       m=m||r;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float h=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         h=0.;
       r=d(v+vec3(.5,h,.5),v+vec3(1.,.5+h,1.),x,i,z);
       m=m||r;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float h=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         h=0.;
       r=d(v+vec3(0.,h,.5),v+vec3(.5,.5+h,1.),x,i,z);
       m=m||r;
     }
   if(y>=67.&&y<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,x,i,z),m=m||r;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float h=8.,s=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         h=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         s=16.;
       r=d(v+vec3(h,6.,7.)/16.,v+vec3(s,9.,9.)/16.,x,i,z);
       m=m||r;
       r=d(v+vec3(h,12.,7.)/16.,v+vec3(s,15.,9.)/16.,x,i,z);
       m=m||r;
     }
   if(y>=71.&&y<=82.)
     {
       float h=8.,w=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         w=16.;
       if(y>=75.&&y<=82.)
         h=0.;
       r=d(v+vec3(7.,6.,h)/16.,v+vec3(9.,9.,w)/16.,x,i,z);
       m=m||r;
       r=d(v+vec3(7.,12.,h)/16.,v+vec3(9.,15.,w)/16.,x,i,z);
       m=m||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 h=vec3(0),w=vec3(0);
       if(y==83.)
         h=vec3(0,0,0),w=vec3(16,16,3);
       if(y==84.)
         h=vec3(0,0,13),w=vec3(16,16,16);
       if(y==86.)
         h=vec3(0,0,0),w=vec3(3,16,16);
       if(y==85.)
         h=vec3(13,0,0),w=vec3(16,16,16);
       r=d(v+h/16.,v+w/16.,x,i,z);
       m=m||r;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 h=vec3(0.),w=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float s=0.;
           if(y>=91.&&y<=94.)
             s=13.;
           h=vec3(0.,s,0.)/16.;
           w=vec3(16.,s+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float t=13.;
           if(y==97.||y==98.)
             t=0.;
           h=vec3(0.,0.,t)/16.;
           w=vec3(16.,16.,t+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float s=13.;
           if(y==99.||y==100.)
             s=0.;
           h=vec3(s,0.,0.)/16.;
           w=vec3(s+3.,16.,16.)/16.;
         }
       r=d(v+h,v+w,x,i,z);
       m=m||r;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 h=vec3(0.),s=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float t=float(y)-float(103.)+1.;
           s.y=t*2./16.;
         }
       if(y==111.)
         s.y=.0625;
       if(y==112.)
         h=vec3(1.,0.,1.)/16.,s=vec3(15.,1.,15.)/16.;
       if(y==113.)
         h=vec3(1.,0.,1.)/16.,s=vec3(15.,.5,15.)/16.;
       r=d(v+h,v+s,x,i,z);
       m=m||r;
     }
   #endif
   #endif
   return m;
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
 vec2 D(vec2 v,float y,out float i)
 {
   vec2 x=1./vec2(viewWidth,viewHeight);
   vec4 f;
   f.x=texture2D(depthtex1,v+x*vec2(1.,1.)).x;
   f.y=texture2D(depthtex1,v+x*vec2(1.,-1.)).x;
   f.z=texture2D(depthtex1,v+x*vec2(-1.,1.)).x;
   f.w=texture2D(depthtex1,v+x*vec2(-1.,-1.)).x;
   vec2 h=vec2(0.,0.);
   if(f.x<y)
     h=vec2(1.,1.);
   if(f.y<y)
     h=vec2(1.,-1.);
   if(f.z<y)
     h=vec2(-1.,1.);
   if(f.w<y)
     h=vec2(-1.,-1.);
   i=min(min(min(f.x,f.y),f.z),f.w);
   return v+x*h;
 }
 vec3 D(vec3 v,vec2 y)
 {
   y=y*.99+.005;
   float f=6.28319*y.x,x=sqrt(y.y);
   vec3 m=normalize(cross(v,vec3(0.,1.,1.))),h=cross(v,m),i=m*cos(f)*x+h*sin(f)*x+v.xyz*sqrt(1.-y.y);
   return i;
 }
 vec3 g(vec3 v,vec3 y)
 {
   vec2 f=t(n(s(v)+y+1.+m()));
   vec3 x=g(f).PVAMAgODVh;
   return x;
 }
 vec3 D()
 {
   vec2 y=t(v(texcoord.xy)+m()/d());
   vec3 x=g(y).PVAMAgODVh;
   return x;
 }
 vec3 e()
 {
   int y=f();
   vec3 x=v(texcoord.xy),s=m(x),h=f(s-vec3(1.,1.,0.),y);
   vec2 z=d(h,y);
   float w=1.;
   #ifdef CAVE_GI_LEAK_FIX
   if(isEyeInWater<1)
     w*=saturate(eyeBrightnessSmooth.y/240.*20.);
   #endif
   float t=1000.,e=1.;
   {
     vec3 n=f(s,y);
     float G=1./float(y);
     vec4 c=texture2DLod(shadowcolor,d(n+vec3(0.,0.,0.)*G,y),0),o=texture2DLod(shadowcolor,d(n+vec3(0.,0.,-1.)*G,y),0),j=texture2DLod(shadowcolor,d(n+vec3(1.,0.,0.)*G,y),0),H=texture2DLod(shadowcolor,d(n+vec3(0.,0.,1.)*G,y),0),B=texture2DLod(shadowcolor,d(n+vec3(-1.,0.,0.)*G,y),0),R=texture2DLod(shadowcolor,d(n+vec3(0.,1.,0.)*G,y),0),p=texture2DLod(shadowcolor,d(n+vec3(0.,-1.,0.)*G,y),0);
     e=c.w;
     t=min(t,o.w);
     t=min(t,j.w);
     t=min(t,H.w);
     t=min(t,B.w);
     t=min(t,R.w);
     t=min(t,p.w);
   }
   if(t*255.>240.||e*255.<240.)
     return vec3(0.);
   vec3 n=vec3(0.);
   const float G=2.4,o=G;
   for(int J=0;J<GI_SECONDARY_SAMPLES;J++)
     {
       float c=sin(frameTimeCounter*1.1)+s.x*.11+s.y*.12+s.z*.13+J*.1;
       vec3 p=normalize(rand(vec2(c))*2.-1.);
       p.x+=p.x==p.y||p.x==p.z?.01:0.;
       p.y+=p.y==p.z?.01:0.;
       vec3 a=s+vec3(1.,1.,1.);
       Ray R=MakeRay(f(a,y)*y-vec3(1.,1.,1.),p);
       SPcacsgCKo S=r(R);
       vec3 l=vec3(1.);
       float U=1000.;
       for(int C=0;C<1;C++)
         {
           vec4 j=vec4(0.);
           float B=0.;
           vec3 H=vec3(0.);
           float F=.2;
           for(int u=0;u<DIFFUSE_TRACE_LENGTH;u++)
             {
               H=S.GadGLQcpqX/float(y);
               vec2 D=d(H,y);
               j=texture2DLod(shadowcolor,D,0);
               B=j.w*255.;
               float O=1.-step(.5,abs(B-241.));
               vec3 T=j.xyz*GI_LIGHT_TORCH_INTENSITY;
               n+=T*F*O*(u==0?.5:1.);
               if(B<240.)
                 {
                   break;
                 }
               i(S);
               F=saturate(F*1.3);
             }
           U=distance(S.GadGLQcpqX.xyz,S.GadGLQcpqXOrigin.xyz);
           float u=0.;
           vec3 D=-S.OmcxSfXfkJ*S.AZVxALDdtL;
           float O=1.;
           if(abs(dot(S.GadGLQcpqX-S.GadGLQcpqXOrigin,D))<1.1)
             O=0.;
           if(B<1.f||B>254.f)
             {
               vec3 T=R.direction;
               if(isEyeInWater>0)
                 T=refract(T,vec3(0.,-1.,0.),1.3333);
               vec3 P=SkyShading(T,worldSunVector,rainStrength);
               P*=saturate(T.y*10.+1.);
               P=DoNightEyeAtNight(P*12.,timeMidnight)*.083333;
               if(isEyeInWater>0)
                 ;
               if(length(T)<.1)
                 u=300.;
               vec3 L=P*w*l,Y=L;
               #ifdef CLOUDS_IN_GI
               CloudPlane(Y,-R.direction,worldLightVector,worldSunVector,colorSunlight,colorSkyUp,L,timeMidnight,false);
               L=mix(L,Y,vec3(w));
               #endif
               L=TintUnderwaterDepth(L);
               n+=L*.1;
             }
           if(abs(B-31.)<.1)
             n+=.09*j.xyz*GI_LIGHT_BLOCK_INTENSITY;
           if(B>=32.&&B<=35.)
             {
               float T=0.;
               if(abs(B-32.)<.1)
                 T=max(-D.z,0.);
               if(abs(B-33.)<.1)
                 T=max(D.x,0.);
               if(abs(B-34.)<.1)
                 T=max(D.z,0.);
               if(abs(B-35.)<.1)
                 T=max(-D.x,0.);
               n+=.02*l*T*vec3(2.,.35,.025)*GI_LIGHT_BLOCK_INTENSITY;
             }
           if(B<240.)
             {
               vec3 T=saturate(j.xyz);
               l*=T;
               vec3 L=-(S.OmcxSfXfkJ*S.AZVxALDdtL),P=f(H,worldLightVector,L,p,y),Y=DoNightEyeAtNight(P*G*colorSunlight*l*O*w*12.,timeMidnight)/12.;
               n+=Y;
               n+=g(H,L)*o*.95*mix(vec3(1.),l,vec3(O));
               u=U;
             }
           {
             vec2 T=IntersectSphere(s,R.direction,vec3(0.,1.5,0.),.75);
             if(U>T.y&&T.y>-.5)
               ;
           }
           if(isEyeInWater>0)
             UnderwaterFog(n,u,p,colorSkyUp,colorSunlight);
         }
     }
   n/=float(GI_SECONDARY_SAMPLES);
   return saturate(n/o);
 }
 vec4 w(float v)
 {
   float y=v*v,m=y*v;
   vec4 i;
   i.x=-m+3*y-3*v+1;
   i.y=3*m-6*y+4;
   i.z=-3*m+3*y+3*v+1;
   i.w=m;
   return i/6.f;
 }
 bool h(vec3 v,vec3 y)
 {
   vec3 x=normalize(cross(dFdx(v),dFdy(v))),z=normalize(y-v),h=normalize(z);
   float i=.02+length(v)*.04;
   return distance(v,y)<i;
 }
 vec3 i(sampler2D v,vec2 y)
 {
   vec2 m=y*ScreenSize,x=floor(m-.5)+.5,h=m-x,z=h*h,i=h*z;
   float f=.5;
   vec2 s=-f*i+2.*f*z-f*h,t=(2.-f)*i-(3.-f)*z+1.,r=-(2.-f)*i+(3.-2.*f)*z+f*h,w=f*i-f*z,n=t+r,d=ScreenTexel*(x+r/n);
   vec3 T=texture2DLod(v,vec2(d.x,d.y),0).xyz;
   vec2 c=ScreenTexel*(x-1.),p=ScreenTexel*(x+2.);
   vec4 e=vec4(texture2DLod(v,vec2(d.x,c.y),0).xyz,1.)*(n.x*s.y)+vec4(texture2DLod(v,vec2(c.x,d.y),0).xyz,1.)*(s.x*n.y)+vec4(T,1.)*(n.x*n.y)+vec4(texture2DLod(v,vec2(p.x,d.y),0).xyz,1.)*(w.x*n.y)+vec4(texture2DLod(v,vec2(d.x,p.y),0).xyz,1.)*(n.x*w.y);
   return max(vec3(0.),e.xyz*(1./e.w));
 }
 vec4 e(vec2 v,float x,out vec3 y)
 {
   vec4 m=gbufferProjectionInverse*vec4(UndownscaleTexcoord(texcoord.xy)*2.-1.,x*2.-1.,1.);
   m/=m.w;
   vec3 f=(gbufferModelViewInverse*vec4(m.xyz,1.)).xyz;
   vec2 z=fract(v*ScreenSize)-.5,t[4]=vec2[4](vec2(0.,0.),vec2(1.,0.),vec2(0.,1.),vec2(1.,1.));
   vec4 i[4];
   for(int r=0;r<4;r++)
     {
       vec2 h=t[r]*ScreenTexel*sign(z),s=LockRenderPixelCoord(v+h);
       float w=texture2DLod(colortex4,s,0).w;
       vec3 n=texture2DLod(colortex4,s,0).xyz;
       vec4 d=gbufferPreviousProjectionInverse*vec4(UndownscaleTexcoord(s)*2.-1.,w*2.-1.,1.);
       d/=d.w;
       vec3 e=(gbufferPreviousModelViewInverse*vec4(d.xyz,1.)).xyz;
       e+=previousCameraPosition;
       e-=cameraPosition;
       float T=length(e.xyz-f.xyz)/(length(f.xyz)+.001),G=T>.1?0.:1.;
       i[r]=vec4(n*G,G);
     }
   vec2 s=abs(z);
   vec4 h=mix(i[0],i[1],vec4(s.x)),r=mix(i[2],i[3],vec4(s.x)),n=mix(h,r,vec4(s.y));
   n.xyz/=n.w+.0001;
   return vec4(n.xyz,n.w);
 }
 vec2 D(float v,vec2 m,out float y,out vec3 i,out vec4 f)
 {
   float z;
   vec2 x=D(texcoord.xy,v,z);
   y=texture2D(depthtex1,x).x;
   vec4 s=vec4(UndownscaleTexcoord(texcoord.xy)*2.-1.,y*2.-1.,1.),r=gbufferProjectionInverse*s;
   r.xyz/=r.w;
   vec4 h=gbufferModelViewInverse*vec4(r.xyz,1.);
   f=h;
   f.xyz+=cameraPosition-previousCameraPosition;
   vec4 t=gbufferPreviousModelView*vec4(f.xyz,1.),n=gbufferPreviousProjection*vec4(t.xyz,1.);
   n.xyz/=n.w;
   i=(s.xyz-n.xyz)*.5;
   vec2 w=m.xy-i.xy*.5;
   if(y<.7)
     w=texcoord.xy;
   return w;
 }
 void main()
 {
   vec4 y=vec4(0.);
   CPrmwMXxJc v;
   v.pzBOsrqcFy=.1;
   v.OxTKjfMYEH=.1;
   v.avjkUoKnfB=.1;
   v.PVAMAgODVh=vec3(0.);
   if(texcoord.x<HalfScreen.x&&texcoord.y<HalfScreen.y)
     {
       GBufferData m=GetGBufferData(texcoord.xy);
       MaterialMask f=CalculateMasks(m.materialID,texcoord.xy);
       vec4 i=GetViewPosition(texcoord.xy,m.depth),x=gbufferModelViewInverse*vec4(i.xyz,1.),s=gbufferModelViewInverse*vec4(i.xyz,0.);
       vec3 z=normalize(i.xyz),h=normalize(s.xyz),r=normalize((gbufferModelViewInverse*vec4(m.normal,0.)).xyz),w=normalize((gbufferModelViewInverse*vec4(m.geoNormal,0.)).xyz);
       float t=length(i.xyz),n=dot(m.mcLightmap.xy,vec2(.5));
       if(f.grass>.5)
         r=vec3(0.,1.,0.),w=vec3(0.,1.,0.);
       vec4 d=vec4(texcoord.xy,0.,0.);
       float G;
       vec3 S;
       vec4 o;
       vec2 c=D(m.depth,d.xy,G,S,o),B=c.xy;
       B-=(vec2(mod(frameCounter/2,2.f),mod(frameCounter,2.f))-.5)/vec2(viewWidth,viewHeight)*.125;
       vec3 L;
       vec4 T=e(B.xy,m.depth,L);
       CPrmwMXxJc a=g(c.xy);
       float U=1./(saturate(-dot(m.geoNormal,z))*100.+1.);
       vec4 R=vec4(c.xy,0.,0.);
       TemporalJitterProjPosPrevInv(R);
       vec4 j=gbufferPreviousProjectionInverse*vec4(UndownscaleTexcoord(c.xy)*2.-1.,texture2DLod(colortex4,R.xy,0).w*2.-1.,1.);
       j/=j.w;
       vec3 u=(gbufferPreviousModelViewInverse*vec4(j.xyz,1.)).xyz;
       a.pzBOsrqcFy+=1.;
       a.pzBOsrqcFy=min(a.pzBOsrqcFy,32.);
       vec2 H=1./vec2(viewWidth,viewHeight),Y=1.-H;
       float l=0.,P=1.-1./(a.pzBOsrqcFy+1.);
       if(T.w<.01||(c.x<H.x||c.x>Y.x||c.y<H.y||c.y>Y.y)||abs(U-a.OxTKjfMYEH)>.02)
         P=0.,l=.99,a.pzBOsrqcFy=0.;
       float O;
       vec3 C=texture2DLod(colortex7,texcoord.xy+vec2(0.,HalfScreen.y),0).xyz;
       C=mix(C,T.xyz,vec3(P));
       l=max(l,mix(l,.9,saturate(-S.z*520.)));
       a.OxTKjfMYEH=U;
       a.avjkUoKnfB=mix(l,a.avjkUoKnfB,mix(P*.25,0.,l));
       C=max(vec3(0.),C);
       y=vec4(C,m.depth);
       v=a;
     }
   v.PVAMAgODVh=mix(D(),e(),vec3(.025));
   gl_FragData[0]=vec4(y);
   {
     CPrmwMXxJc m=g(texcoord.xy);
     v.ivaOqoXyFu=m.ivaOqoXyFu;
     gl_FragData[1]=max(vec4(0.),p(v));
   }
 };




/* DRAWBUFFERS:45 */
