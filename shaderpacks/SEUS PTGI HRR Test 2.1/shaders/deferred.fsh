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
 vec3 v(vec2 v)
 {
   ivec2 s=ivec2(viewWidth,viewHeight);
   int x=s.x*s.y,y=f();
   ivec2 n=ivec2(v.x*s.x,v.y*s.y);
   float z=float(n.y/y),i=float(int(n.x+mod(s.x*z,y))/y);
   i+=floor(s.x*z/y);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(n.x+mod(s.x*z,y),y);
   m.y=mod(n.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 s(vec3 v)
 {
   ivec2 y=ivec2(viewWidth,viewHeight);
   int x=f();
   vec3 i=v.xzy*x;
   i=floor(i+1e-05);
   float z=i.z;
   vec2 n;
   n.x=mod(i.x+z*x,y.x);
   float s=i.x+z*x;
   n.y=i.y+floor(s/y.x)*x;
   n+=.5;
   n/=y;
   return n;
 }
 vec3 d(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 s=ivec2(2048,2048);
   int x=s.x*s.y,y=t();
   ivec2 n=ivec2(i.x*s.x,i.y*s.y);
   float z=float(n.y/y),f=float(int(n.x+mod(s.x*z,y))/y);
   f+=floor(s.x*z/y);
   vec3 m=vec3(0.,0.,f);
   m.x=mod(n.x+mod(s.x*z,y),y);
   m.y=mod(n.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 d(vec3 v,int y)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 n;
   n.x=mod(i.x+x*y,m.x);
   float s=i.x+x*y;
   n.y=i.y+floor(s/m.x)*y;
   n+=.5;
   n/=m;
   n.xy*=.5;
   return n;
 }
 vec3 f(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 s(vec3 v,int y)
 {
   return v*=1./y,v=v+vec3(.5),v;
 }
 vec3 m(vec3 v)
 {
   int m=t();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 x(vec3 v)
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
   vec3 v=cameraPosition.xyz+.5,y=previousCameraPosition.xyz+.5,x=floor(v-.0001),z=floor(y-.0001);
   return x-z;
 }
 vec3 n(vec3 v)
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
 vec3 d(vec3 v,vec3 i,vec2 n,vec2 y,vec4 s,vec4 m,inout float x,out vec2 f)
 {
   bool z=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   z=!z;
   if(m.x==8||m.x==9||m.x==79||m.x<1.||!z||m.x==20.||m.x==171.||min(abs(i.x),abs(i.z))>.2)
     x=1.;
   if(m.x==50.||m.x==52.||m.x==76.)
     {
       x=0.;
       if(i.y<.5)
         x=1.;
     }
   if(m.x==51||m.x==53)
     x=0.;
   if(m.x>255)
     x=0.;
   vec3 r,c;
   if(i.x>.5)
     r=vec3(0.,0.,-1.),c=vec3(0.,-1.,0.);
   else
      if(i.x<-.5)
       r=vec3(0.,0.,1.),c=vec3(0.,-1.,0.);
     else
        if(i.y>.5)
         r=vec3(1.,0.,0.),c=vec3(0.,0.,1.);
       else
          if(i.y<-.5)
           r=vec3(1.,0.,0.),c=vec3(0.,0.,-1.);
         else
            if(i.z>.5)
             r=vec3(1.,0.,0.),c=vec3(0.,-1.,0.);
           else
              if(i.z<-.5)
               r=vec3(-1.,0.,0.),c=vec3(0.,-1.,0.);
   f=clamp((n.xy-y.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(m.x==10.||m.x==11.)
     {
       if(abs(i.y)<.01&&z||i.y>.99)
         h=.1,e=.1,x=0.;
       else
          x=1.;
     }
   if(m.x==51||m.x==53)
     h=.5,e=.1;
   if(m.x==76)
     h=.2,e=.2;
   if(m.x-255.+39.>=103.&&m.x-255.+39.<=113.)
     e=.025,h=.025;
   r=normalize(s.xyz);
   c=normalize(cross(r,i.xyz)*sign(s.w));
   vec3 G=v.xyz+mix(r*h,-r*h,vec3(f.x));
   G.xyz+=mix(c*h,-c*h,vec3(f.y));
   G.xyz-=i.xyz*e;
   return G;
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
 void i(inout SPcacsgCKo v)
 {
   v.OmcxSfXfkJ=step(v.UekatYTTmj.xyz,v.UekatYTTmj.yzx)*step(v.UekatYTTmj.xyz,v.UekatYTTmj.zxy),v.UekatYTTmj+=v.OmcxSfXfkJ*v.vAdYwconYe,v.GadGLQcpqX+=v.OmcxSfXfkJ*v.AZVxALDdtL;
 }
 void d(in Ray v,in vec3 i[2],out float x,out float y)
 {
   float z,f,r,n;
   x=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   z=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   f=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   n=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   x=max(max(x,z),r);
   y=min(min(y,f),n);
 }
 vec3 d(const vec3 v,const vec3 i,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(i+v)*.5,n=(i-v)*.5,m=y-z,f=vec3(0.);
   f+=vec3(sign(m.x),0.,0.)*step(abs(abs(m.x)-n.x),x);
   f+=vec3(0.,sign(m.y),0.)*step(abs(abs(m.y)-n.y),x);
   f+=vec3(0.,0.,sign(m.z))*step(abs(abs(m.z)-n.z),x);
   return normalize(f);
 }
 bool e(const vec3 v,const vec3 i,Ray m,out vec2 y)
 {
   vec3 x=m.inv_direction*(v-m.origin),z=m.inv_direction*(i-m.origin),n=min(z,x),s=max(z,x);
   vec2 f=max(n.xx,n.yz);
   float c=max(f.x,f.y);
   f=min(s.xx,s.yz);
   float h=min(f.x,f.y);
   y.x=c;
   y.y=h;
   return h>max(c,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),c=m.inv_direction*(i+1e-05-m.origin),n=min(c,z),s=max(c,z);
   vec2 f=max(n.xx,n.yz);
   float h=max(f.x,f.y);
   f=min(s.xx,s.yz);
   float G=min(f.x,f.y);
   bool e=G>max(h,0.)&&max(h,0.)<x;
   if(e)
     y=d(v-1e-05,i+1e-05,m.origin+m.direction*h),x=h;
   return e;
 }
 vec3 e(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 m=n(v);
   float f=.5;
   vec3 t=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*f),2).x;
   t*=saturate(dot(i,y));
   {
     vec4 s=texture2DLod(shadowcolor1,m.xy-vec2(0.,.5),4);
     float c=abs(s.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,i,c),r=shadow2DLod(shadowtex0,vec3(m.xy-vec2(0.,.5),m.z+1e-06),4).x;
     t=mix(t,t*h,1.-r);
   }
   t=TintUnderwaterDepth(t);
   return t*(1.-rainStrength);
 }
 vec3 f(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 f=m(v);
   f+=1.;
   f-=Fract01(cameraPosition+.5);
   vec3 s=n(f+y*.99);
   float h=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*h),3).x;
   r*=saturate(dot(i,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*h),3).x;
   vec3 c=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   c*=c;
   r=mix(r,r*c,vec3(1.-t));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 i(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 m=n(v);
   float h=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*h),2).x;
   f*=saturate(dot(i,y));
   f=TintUnderwaterDepth(f);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float r=shadow2DLod(shadowtex0,vec3(m.xy-vec2(.5,0.),m.z-.0006*h),3).x;
   vec3 s=texture2DLod(shadowcolor,vec2(m.xy-vec2(.5,0.)),3).xyz;
   s*=s;
   f=mix(f,f*s,vec3(1.-r));
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
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),s=UnpackTwo16BitFrom32Bit(v.z),n=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=m.y;
   i.avjkUoKnfB=s.y;
   i.ivaOqoXyFu=n.y*255.;
   i.PVAMAgODVh=pow(vec3(m.x,s.x,n.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc G(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return h(texture2DLod(colortex5,v,0));
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
 bool G(vec3 v,float y,Ray i,bool z,inout float x,inout vec3 f)
 {
   bool m=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(z)
     return false;
   if(y>=67.)
     return false;
   r=d(v,v+vec3(1.,1.,1.),i,x,f);
   m=r;
   #else
   if(y<40.)
     return r=d(v,v+vec3(1.,1.,1.),i,x,f),r;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float h=.5;
       if(y==41.)
         h=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,h,1.),i,x,f);
       m=m||r;
     }
   if(y==42.||y>=55.&&y<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,x,f),m=m||r;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float h=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         h=0.;
       r=d(v+vec3(0.,h,0.),v+vec3(.5,.5+h,.5),i,x,f);
       m=m||r;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float h=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         h=0.;
       r=d(v+vec3(.5,h,0.),v+vec3(1.,.5+h,.5),i,x,f);
       m=m||r;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float h=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         h=0.;
       r=d(v+vec3(.5,h,.5),v+vec3(1.,.5+h,1.),i,x,f);
       m=m||r;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float h=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         h=0.;
       r=d(v+vec3(0.,h,.5),v+vec3(.5,.5+h,1.),i,x,f);
       m=m||r;
     }
   if(y>=67.&&y<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,x,f),m=m||r;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float h=8.,s=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         h=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         s=16.;
       r=d(v+vec3(h,6.,7.)/16.,v+vec3(s,9.,9.)/16.,i,x,f);
       m=m||r;
       r=d(v+vec3(h,12.,7.)/16.,v+vec3(s,15.,9.)/16.,i,x,f);
       m=m||r;
     }
   if(y>=71.&&y<=82.)
     {
       float h=8.,n=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         n=16.;
       if(y>=75.&&y<=82.)
         h=0.;
       r=d(v+vec3(7.,6.,h)/16.,v+vec3(9.,9.,n)/16.,i,x,f);
       m=m||r;
       r=d(v+vec3(7.,12.,h)/16.,v+vec3(9.,15.,n)/16.,i,x,f);
       m=m||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 h=vec3(0),s=vec3(0);
       if(y==83.)
         h=vec3(0,0,0),s=vec3(16,16,3);
       if(y==84.)
         h=vec3(0,0,13),s=vec3(16,16,16);
       if(y==86.)
         h=vec3(0,0,0),s=vec3(3,16,16);
       if(y==85.)
         h=vec3(13,0,0),s=vec3(16,16,16);
       r=d(v+h/16.,v+s/16.,i,x,f);
       m=m||r;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 h=vec3(0.),s=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float n=0.;
           if(y>=91.&&y<=94.)
             n=13.;
           h=vec3(0.,n,0.)/16.;
           s=vec3(16.,n+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float n=13.;
           if(y==97.||y==98.)
             n=0.;
           h=vec3(0.,0.,n)/16.;
           s=vec3(16.,16.,n+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float n=13.;
           if(y==99.||y==100.)
             n=0.;
           h=vec3(n,0.,0.)/16.;
           s=vec3(n+3.,16.,16.)/16.;
         }
       r=d(v+h,v+s,i,x,f);
       m=m||r;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 h=vec3(0.),n=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float s=float(y)-float(103.)+1.;
           n.y=s*2./16.;
         }
       if(y==111.)
         n.y=.0625;
       if(y==112.)
         h=vec3(1.,0.,1.)/16.,n=vec3(15.,1.,15.)/16.;
       if(y==113.)
         h=vec3(1.,0.,1.)/16.,n=vec3(15.,.5,15.)/16.;
       r=d(v+h,v+n,i,x,f);
       m=m||r;
     }
   #endif
   #endif
   return m;
 }
 vec3 c(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight));
   y*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   y=(floor(y*64.)+.5)/64.;
   vec3 f=texture2D(noisetex,y).xyz,x=vec3(sqrt(.2),sqrt(2.),1.61803);
   f=mod(f+float(frameCounter%64)*x,vec3(1.));
   return f;
 }
 vec2 y;
 vec3 c(vec3 v,vec2 y)
 {
   y=y*.999+.001;
   float x=6.28319*y.x,s=sqrt(y.y);
   vec3 f=normalize(cross(v,vec3(0.,1.,1.))),h=cross(v,f),i=f*cos(x)*s+h*sin(x)*s+v.xyz*sqrt(1.-y.y);
   return i;
 }
 vec3 e(vec3 v,vec3 y)
 {
   vec2 f=s(x(m(v)+y+1.+d()));
   vec3 h=G(f).PVAMAgODVh;
   return h;
 }
 vec3 G()
 {
   vec2 x=s(v(y.xy)+d()/f());
   vec3 h=G(x).PVAMAgODVh;
   return h;
 }
 vec3 G(vec3 v,vec3 m,vec3 x,vec3 h,vec3 z,MaterialMask n,float s,vec2 p,float a,out float S,out vec3 g,float w)
 {
   float C=fract(frameCounter*.0123456),o=1.;
   #ifdef SUNLIGHT_LEAK_FIX
   if(isEyeInWater<1)
     o=saturate(s*100.);
   #endif
   float J=1.;
   #ifdef CAVE_GI_LEAK_FIX
   if(isEyeInWater<1)
     J=saturate(s*10.);
   #endif
   vec3 R=c(y.xy+vec2(0.,0.)).xyz;
   g=c(x,R.xy);
   S=10000.;
   vec3 l=g;
   #ifdef GI_SCREEN_SPACE_TRACING
   bool b=false;
   {
     const int Y=5;
     float F=.25*-m.z;
     F=mix(F,.8,.5)*.5;
     float D=.07*-m.z;
     D=mix(D,1.,.5);
     D=.6;
     vec2 j=y.xy;
     vec3 O=m.xyz,H=normalize((gbufferModelView*vec4(g.xyz,0.)).xyz);
     for(int B=0;B<Y;B++)
       {
         float X=float(B),L=(X+.5+R.z)/float(Y),u=F*L*L;
         vec3 A=m.xyz+H*u,T=ProjectBack(A),P=GetViewPositionNoJitter(T.xy,GetDepth(DownscaleTexcoord(T.xy))).xyz;
         float U=length(A)-length(P)-.02;
         if(U>0.&&U<D)
           {
             b=true;
             j=T.xy;
             O=P.xyz;
             break;
           }
       }
     vec3 B=(gbufferModelViewInverse*vec4(O,1.)).xyz;
     B+=Fract01(cameraPosition.xyz+.5)+.5;
     if(b)
       {
         vec3 A=pow(texture2DLod(colortex6,j.xy-p*.5,0).xyz,vec3(2.2));
         A*=1.-saturate(a*1.1);
         return A*100.;
       }
   }
   #endif
   const float F=2.4,L=F;
   int A=t();
   float O=1./float(A);
   vec3 B=v+x*(.0002*length(v))-z*(w*.2/(saturate(dot(h,-z))+1e-06)+.005);
   B+=Fract01(cameraPosition.xyz+.5);
   Ray T=MakeRay(f(B,A)*A-vec3(1.,1.,1.),g);
   SPcacsgCKo P=r(T);
   vec3 D=vec3(1.),Y=vec3(0.);
   float U=0.,j=1.;
   {
     vec4 X=vec4(0.);
     vec3 u=vec3(0.);
     float H=.5;
     for(int M=0;M<DIFFUSE_TRACE_LENGTH;M++)
       {
         u=P.GadGLQcpqX/float(A);
         vec2 I=d(u,A);
         X=texture2DLod(shadowcolor,I,0);
         U=X.w*255.;
         float V=1.-step(.5,abs(U-241.));
         vec3 E=X.xyz*GI_LIGHT_TORCH_INTENSITY;
         Y+=E*V*H*.5;
         #ifdef GI_LEAF_TRANSPARENCY
         if(abs(U-36.)<.1)
           {
             if(R.z<pow(.5,j))
               {
                 i(P);
                 H=1.;
                 j+=10.;
                 D*=pow(X.xyz,vec3(.25));
                 continue;
               }
           }
         #endif
         if(U<240.)
           {
             if(G(P.GadGLQcpqX,U,T,M==0,S,l))
               {
                 break;
               }
           }
         i(P);
         H=1.;
       }
     float M=0.;
     if(U<1.f||U>254.f)
       {
         vec3 I=T.direction;
         if(isEyeInWater>0)
           I=refract(I,vec3(0.,-1.,0.),1.3333);
         vec3 E=SkyShading(I,worldSunVector,rainStrength);
         E*=saturate(I.y*10.+1.);
         E=DoNightEyeAtNight(E*12.,timeMidnight)*.083333;
         if(length(I)<.1)
           M=300.;
         vec3 V=E*J*D,k=V;
         #ifdef CLOUDS_IN_GI
         CloudPlane(k,-T.direction,worldLightVector,worldSunVector,colorSunlight,colorSkyUp,V,timeMidnight,false);
         V=mix(V,k,vec3(o*J));
         #endif
         V=TintUnderwaterDepth(V);
         V*=saturate(I.y*5.);
         Y+=V*.1;
       }
     else
       {
         if(abs(U-31.)<.1)
           Y+=.09*D*X.xyz*GI_LIGHT_BLOCK_INTENSITY;
         if(U>=32.&&U<=35.)
           {
             float V=0.;
             if(abs(U-32.)<.1)
               V=max(-l.z,0.);
             if(abs(U-33.)<.1)
               V=max(l.x,0.);
             if(abs(U-34.)<.1)
               V=max(l.z,0.);
             if(abs(U-35.)<.1)
               V=max(-l.x,0.);
             Y+=.02*D*V*vec3(2.,.35,.025)*GI_LIGHT_BLOCK_INTENSITY;
           }
         if(U<240.)
           {
             vec3 V=saturate(X.xyz);
             D*=V;
             Y+=e(u,l)*D*L;
             vec3 I=i(B+T.direction*S-1.,worldLightVector,l,g,A),E=DoNightEyeAtNight(I*D*F*colorSunlight*o*J*12.,timeMidnight)/12.;
             Y+=E;
             M=S;
           }
       }
     if(isEyeInWater>0)
       UnderwaterFog(Y,M,g,colorSkyUp,colorSunlight);
   }
   return Y;
 }
 void main()
 {
   vec4 v=texture2DLod(colortex2,texcoord.xy,0),i=texture2DLod(colortex7,texcoord.xy,0);
   y=texcoord.xy;
   if(y.x<HalfScreen.x&&y.y>HalfScreen.y)
     {
       y-=vec2(0.,HalfScreen.y);
       GBufferData m=GetGBufferData(y.xy);
       MaterialMask x=CalculateMasks(m.materialID,y.xy);
       vec4 s=GetViewPosition(y.xy,m.depth),n=gbufferModelViewInverse*vec4(s.xyz,1.),f=gbufferModelViewInverse*vec4(s.xyz,0.);
       vec3 h=normalize(s.xyz),r=normalize(f.xyz),c=normalize((gbufferModelViewInverse*vec4(m.normal,0.)).xyz),z=normalize((gbufferModelViewInverse*vec4(m.geoNormal,0.)).xyz);
       float V=length(s.xyz),t=dot(m.mcLightmap.xy,vec2(.5));
       if(x.grass>.5)
         c=vec3(0.,1.,0.),z=vec3(0.,1.,0.);
       float e;
       vec3 a,U=G(n.xyz,s.xyz,c.xyz,z,r.xyz,x,m.mcLightmap.y,vec2(0.),0.,e,a,m.parallaxOffset);
       v=vec4(a*.5+.5,1.);
       i=vec4(U,saturate(e*.1));
     }
   gl_FragData[0]=texture2DLod(colortex1,texcoord.xy,0);
   gl_FragData[1]=vec4(v);
   gl_FragData[2]=vec4(i);
 };




/* DRAWBUFFERS:127 */
