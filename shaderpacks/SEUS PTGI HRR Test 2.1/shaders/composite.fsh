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





in vec4 texcoord;

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorTorchlight;
in vec3 colorSkyUp;

in vec4 skySHR;
in vec4 skySHG;
in vec4 skySHB;

in vec3 worldLightVector;
in vec3 worldSunVector;

in float timeMidnight;

#include "lib/Uniforms.inc"
#include "lib/Common.inc"


vec2 Texcoord;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////








vec2 GetNearFragment(vec2 coord, float depth, out float minDepth)
{
	
	
	vec2 texel = 1.0 / vec2(viewWidth, viewHeight);
	vec4 depthSamples;
	depthSamples.x = texture2D(depthtex1, coord + texel * vec2(1.0, 1.0)).x;
	depthSamples.y = texture2D(depthtex1, coord + texel * vec2(1.0, -1.0)).x;
	depthSamples.z = texture2D(depthtex1, coord + texel * vec2(-1.0, 1.0)).x;
	depthSamples.w = texture2D(depthtex1, coord + texel * vec2(-1.0, -1.0)).x;

	vec2 targetFragment = vec2(0.0, 0.0);

	if (depthSamples.x < depth)
		targetFragment = vec2(1.0, 1.0);
	if (depthSamples.y < depth)
		targetFragment = vec2(1.0, -1.0);
	if (depthSamples.z < depth)
		targetFragment = vec2(-1.0, 1.0);
	if (depthSamples.w < depth)
		targetFragment = vec2(-1.0, -1.0);


	minDepth = min(min(min(depthSamples.x, depthSamples.y), depthSamples.z), depthSamples.w);

	return coord + texel * targetFragment;
}






#include "lib/Materials.inc"
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
   ivec2 d=ivec2(v.x*s.x,v.y*s.y);
   float z=float(d.y/y),i=float(int(d.x+mod(s.x*z,y))/y);
   i+=floor(s.x*z/y);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(d.x+mod(s.x*z,y),y);
   m.y=mod(d.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 s(vec3 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int z=f();
   vec3 i=v.xzy*z;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 r;
   r.x=mod(i.x+x*z,m.x);
   float c=i.x+x*z;
   r.y=i.y+floor(c/m.x)*z;
   r+=.5;
   r/=m;
   return r;
 }
 vec3 d(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 s=ivec2(2048,2048);
   int x=s.x*s.y,y=t();
   ivec2 d=ivec2(i.x*s.x,i.y*s.y);
   float z=float(d.y/y),f=float(int(d.x+mod(s.x*z,y))/y);
   f+=floor(s.x*z/y);
   vec3 m=vec3(0.,0.,f);
   m.x=mod(d.x+mod(s.x*z,y),y);
   m.y=mod(d.y,y);
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
   vec2 f;
   f.x=mod(i.x+x*y,m.x);
   float c=i.x+x*y;
   f.y=i.y+floor(c/m.x)*y;
   f+=.5;
   f/=m;
   f.xy*=.5;
   return f;
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
 vec3 e(vec3 v)
 {
   int y=f();
   v*=1./y;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 x(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 d()
 {
   vec3 v=cameraPosition.xyz+.5,i=previousCameraPosition.xyz+.5,y=floor(v-.0001),z=floor(i-.0001);
   return y-z;
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
 vec3 d(vec3 v,vec3 i,vec2 d,vec2 y,vec4 f,vec4 s,inout float x,out vec2 m)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(s.x==8||s.x==9||s.x==79||s.x<1.||!r||s.x==20.||s.x==171.||min(abs(i.x),abs(i.z))>.2)
     x=1.;
   if(s.x==50.||s.x==52.||s.x==76.)
     {
       x=0.;
       if(i.y<.5)
         x=1.;
     }
   if(s.x==51||s.x==53)
     x=0.;
   if(s.x>255)
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
   m=clamp((d.xy-y.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,w=.15;
   if(s.x==10.||s.x==11.)
     {
       if(abs(i.y)<.01&&r||i.y>.99)
         h=.1,w=.1,x=0.;
       else
          x=1.;
     }
   if(s.x==51||s.x==53)
     h=.5,w=.1;
   if(s.x==76)
     h=.2,w=.2;
   if(s.x-255.+39.>=103.&&s.x-255.+39.<=113.)
     w=.025,h=.025;
   z=normalize(f.xyz);
   c=normalize(cross(z,i.xyz)*sign(f.w));
   vec3 n=v.xyz+mix(z*h,-z*h,vec3(m.x));
   n.xyz+=mix(c*h,-c*h,vec3(m.y));
   n.xyz-=i.xyz*w;
   return n;
 }struct SPcacsgCKo{vec3 GadGLQcpqX;vec3 GadGLQcpqXOrigin;vec3 vAdYwconYe;vec3 AZVxALDdtL;vec3 UekatYTTmj;vec3 OmcxSfXfkJ;};
 SPcacsgCKo p(Ray v)
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
 void d(in Ray v,in vec3 i[2],out float f,out float y)
 {
   float z,x,r,c;
   f=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   z=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   x=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   c=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   f=max(max(f,z),r);
   y=min(min(y,x),c);
 }
 vec3 d(const vec3 v,const vec3 y,vec3 f)
 {
   const float x=1e-05;
   vec3 z=(y+v)*.5,i=(y-v)*.5,s=f-z,c=vec3(0.);
   c+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-i.x),x);
   c+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-i.y),x);
   c+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-i.z),x);
   return normalize(c);
 }
 bool e(const vec3 v,const vec3 i,Ray s,out vec2 f)
 {
   vec3 y=s.inv_direction*(v-s.origin),x=s.inv_direction*(i-s.origin),c=min(x,y),d=max(x,y);
   vec2 m=max(c.xx,c.yz);
   float z=max(m.x,m.y);
   m=min(d.xx,d.yz);
   float n=min(m.x,m.y);
   f.x=z;
   f.y=n;
   return n>max(z,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray s,inout float y,inout vec3 x)
 {
   vec3 z=s.inv_direction*(v-1e-05-s.origin),c=s.inv_direction*(i+1e-05-s.origin),m=min(c,z),f=max(c,z);
   vec2 r=max(m.xx,m.yz);
   float t=max(r.x,r.y);
   r=min(f.xx,f.yz);
   float n=min(r.x,r.y);
   bool h=n>max(t,0.)&&max(t,0.)<y;
   if(h)
     x=d(v-1e-05,i+1e-05,s.origin+s.direction*t),y=t;
   return h;
 }
 vec3 e(vec3 v,vec3 i,vec3 y,vec3 z,int x)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 s=n(v);
   float f=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*f),2).x;
   c*=saturate(dot(i,y));
   {
     vec4 d=texture2DLod(shadowcolor1,s.xy-vec2(0.,.5),4);
     float m=abs(d.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,i,m),w=shadow2DLod(shadowtex0,vec3(s.xy-vec2(0.,.5),s.z+1e-06),4).x;
     c=mix(c,c*h,1.-w);
   }
   c=TintUnderwaterDepth(c);
   return c*(1.-rainStrength);
 }
 vec3 f(vec3 v,vec3 i,vec3 y,vec3 z,int x)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 f=m(v);
   f+=1.;
   f-=Fract01(cameraPosition+.5);
   vec3 s=n(f+y*.99);
   float h=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*h),3).x;
   c*=saturate(dot(i,y));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*h),3).x;
   vec3 r=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   r*=r;
   c=mix(c,c*r,vec3(1.-t));
   #endif
   return c*(1.-rainStrength);
 }
 vec3 i(vec3 v,vec3 i,vec3 y,vec3 z,int x)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 s=n(v);
   float f=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*f),2).x;
   c*=saturate(dot(i,y));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float m=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*f),3).x;
   vec3 r=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   r*=r;
   c=mix(c,c*r,vec3(1.-m));
   #endif
   return c*(1.-rainStrength);
 }struct CPrmwMXxJc{float pzBOsrqcFy;float ivaOqoXyFu;float OxTKjfMYEH;float avjkUoKnfB;vec3 PVAMAgODVh;};
 vec4 h(CPrmwMXxJc v)
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
 CPrmwMXxJc r(vec4 v)
 {
   CPrmwMXxJc i;
   vec2 s=UnpackTwo16BitFrom32Bit(v.y),m=UnpackTwo16BitFrom32Bit(v.z),c=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=s.y;
   i.avjkUoKnfB=m.y;
   i.ivaOqoXyFu=c.y*255.;
   i.PVAMAgODVh=pow(vec3(s.x,m.x,c.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc w(vec2 v)
 {
   vec2 z=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*z;
   return r(texture2DLod(colortex5,v,0));
 }
 float e(float v,float y)
 {
   float z=1.;
   #ifdef FULL_RT_REFLECTIONS
   z=clamp(pow(v,.125)+y,0.,1.);
   #else
   z=clamp(v*10.-7.,0.,1.);
   #endif
   return z;
 }
 bool d(vec3 v,float y,Ray i,bool z,inout float f,inout vec3 x)
 {
   bool m=false,c=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(z)
     return false;
   if(y>=67.)
     return false;
   c=d(v,v+vec3(1.,1.,1.),i,f,x);
   m=c;
   #else
   if(y<40.)
     return c=d(v,v+vec3(1.,1.,1.),i,f,x),c;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float s=.5;
       if(y==41.)
         s=.9375;
       c=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),i,f,x);
       m=m||c;
     }
   if(y==42.||y>=55.&&y<=66.)
     c=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,f,x),m=m||c;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float s=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         s=0.;
       c=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),i,f,x);
       m=m||c;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float s=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         s=0.;
       c=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),i,f,x);
       m=m||c;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float s=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         s=0.;
       c=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),i,f,x);
       m=m||c;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float s=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         s=0.;
       c=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),i,f,x);
       m=m||c;
     }
   if(y>=67.&&y<=82.)
     c=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,f,x),m=m||c;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float s=8.,h=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         s=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         h=16.;
       c=d(v+vec3(s,6.,7.)/16.,v+vec3(h,9.,9.)/16.,i,f,x);
       m=m||c;
       c=d(v+vec3(s,12.,7.)/16.,v+vec3(h,15.,9.)/16.,i,f,x);
       m=m||c;
     }
   if(y>=71.&&y<=82.)
     {
       float s=8.,h=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         h=16.;
       if(y>=75.&&y<=82.)
         s=0.;
       c=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,h)/16.,i,f,x);
       m=m||c;
       c=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,h)/16.,i,f,x);
       m=m||c;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 s=vec3(0),h=vec3(0);
       if(y==83.)
         s=vec3(0,0,0),h=vec3(16,16,3);
       if(y==84.)
         s=vec3(0,0,13),h=vec3(16,16,16);
       if(y==86.)
         s=vec3(0,0,0),h=vec3(3,16,16);
       if(y==85.)
         s=vec3(13,0,0),h=vec3(16,16,16);
       c=d(v+s/16.,v+h/16.,i,f,x);
       m=m||c;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 s=vec3(0.),r=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float h=0.;
           if(y>=91.&&y<=94.)
             h=13.;
           s=vec3(0.,h,0.)/16.;
           r=vec3(16.,h+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float h=13.;
           if(y==97.||y==98.)
             h=0.;
           s=vec3(0.,0.,h)/16.;
           r=vec3(16.,16.,h+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float h=13.;
           if(y==99.||y==100.)
             h=0.;
           s=vec3(h,0.,0.)/16.;
           r=vec3(h+3.,16.,16.)/16.;
         }
       c=d(v+s,v+r,i,f,x);
       m=m||c;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 s=vec3(0.),r=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float n=float(y)-float(103.)+1.;
           r.y=n*2./16.;
         }
       if(y==111.)
         r.y=.0625;
       if(y==112.)
         s=vec3(1.,0.,1.)/16.,r=vec3(15.,1.,15.)/16.;
       if(y==113.)
         s=vec3(1.,0.,1.)/16.,r=vec3(15.,.5,15.)/16.;
       c=d(v+s,v+r,i,f,x);
       m=m||c;
     }
   #endif
   #endif
   return m;
 }
 vec3 g(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight));
   y*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   y=(floor(y*64.)+.5)/64.;
   vec3 c=texture2D(noisetex,y).xyz,s=vec3(sqrt(.2),sqrt(2.),1.61803);
   c=mod(c+float(frameCounter%64)*s,vec3(1.));
   return c;
 }
 vec2 S(inout float v)
 {
   return fract(sin(vec2(v+=.1,v+=.1))*vec2(43758.5,22578.1));
 }
 vec3 c(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight))/64.;
   const vec2 m[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   y+=m[int(mod(float(frameCounter),8.))]*.5;
   y=(floor(y*64.)+.5)/64.;
   vec3 c=texture2D(noisetex,y).xyz;
   return c;
 }
 vec3 S(vec3 v,inout float y,int x)
 {
   vec2 i=c(Texcoord.xy+vec2(y+=.1,y+=.1)).xy;
   i=fract(i+S(y)*.1);
   float s=6.28319*i.x,z=sqrt(i.y);
   vec3 m=normalize(cross(v,vec3(0.,1.,1.))),f=cross(v,m),h=m*cos(s)*z+f*sin(s)*z+v.xyz*sqrt(1.-i.y);
   return h;
 }
 vec3 S(vec3 v,vec3 y)
 {
   vec2 c=s(e(m(v)+y+1.));
   vec3 z=w(c).PVAMAgODVh;
   return z;
 }
 vec3 S()
 {
   vec2 y=s(v(Texcoord.xy)+d()/f());
   vec3 c=w(y).PVAMAgODVh;
   return c;
 }
 vec3 S(float v,float y,float f,vec3 i)
 {
   vec3 s;
   s.x=f*cos(v);
   s.y=f*sin(v);
   s.z=y;
   vec3 c=abs(i.y)<.999?vec3(0,0,1):vec3(1,0,0),x=normalize(cross(i,vec3(0.,1.,1.))),z=cross(x,i);
   return x*s.x+z*s.y+i*s.z;
 }
 vec3 c(vec2 v,float y,vec3 x)
 {
   float s=2*3.14159*v.x,z=sqrt((1-v.y)/(1+(y*y-1)*v.y)),i=sqrt(1-z*z);
   return S(s,z,i,x);
 }
 float G(float v)
 {
   return 2./(v*v+1e-07)-2.;
 }
 vec3 G(in vec2 v,in float y,in vec3 x)
 {
   float s=G(y),i=2*3.14159*v.x,z=pow(v.y,1.f/(s+1.f)),c=sqrt(1-z*z);
   return S(i,z,c,x);
 }
 float G(float v,float y)
 {
   return 1./(v*(1.-y)+y);
 }
 void c(inout vec3 v,in vec3 y)
 {
   vec3 x=normalize(y.xyz),i=v;
   float s=dot(i,x);
   i=normalize(v-x*saturate(s)*.5);
   v=i;
 }
 vec4 R(in vec2 v)
 {
   float y=GetDepth(v);
   vec4 i=gbufferProjectionInverse*vec4(v.x*2.f-1.f,v.y*2.f-1.f,2.f*y-1.f,1.f);
   i/=i.w;
   return i;
 }
 vec4 R(in vec2 v,in float y)
 {
   vec4 i=gbufferProjectionInverse*vec4(v.x*2.f-1.f,v.y*2.f-1.f,2.f*y-1.f,1.f);
   i/=i.w;
   return i;
 }
 void G(inout vec3 v,in vec3 y,in vec3 i,vec3 z,float x)
 {
   float c=length(y);
   c*=pow(eyeBrightnessSmooth.y/240.f,6.f);
   c*=rainStrength;
   float s=pow(exp(-c*1e-05),4.);
   s=max(s,.5);
   vec3 f=vec3(dot(colorSkyUp,vec3(1.)))*.05;
   v=mix(f,v,vec3(s));
 }
 vec4 G(float v,float y,vec3 s,vec3 m,vec3 x,vec3 z,vec3 h,float r,float n,float w,float a,bool T)
 {
   float l=1.;
   #ifdef SUNLIGHT_LEAK_FIX
   if(isEyeInWater<1)
     l=saturate(n*100.);
   #endif
   v=max(v-.05,0.);
   y=0.;
   float R=v*v,o=fract(frameCounter*.0123456);
   vec3 O=c(Texcoord.xy).xyz*.99+.005,U=c(Texcoord.xy+.1).xyz,g=reflect(h,c(c(Texcoord.xy).xy*vec2(1.,.8),R,x)),H=normalize((gbufferModelView*vec4(g.xyz,0.)).xyz);
   if(dot(g,x)<0.)
     g=reflect(g,x);
   #ifdef REFLECTION_SCREEN_SPACE_TRACING
   bool b=false;
   {
     const int k=16;
     vec2 F=Texcoord.xy;
     vec3 D=m.xyz;
     float C=0.;
     vec3 X=m.xyz;
     float P=.1/saturate(dot(-h,x)+.001),J=P*2.,L=1.,Y=0.;
     for(int N=0;N<k;N++)
       {
         float j=float(N),u=(j+.5)/float(k);
         vec3 E=H.xyz*P*(.1+length(X)*.1)*L;
         float A=J*(length(X)*.1);
         X+=E;
         vec2 M=ProjectBack(X).xy;
         vec3 B=GetViewPositionNoJitter(M.xy,GetDepth(DownscaleTexcoord(M.xy))).xyz;
         float I=length(X)-length(B)-.02;
         if(X.z>0.)
           {
             break;
           }
         if(I>0.&&I<A&&M.x>0.&&M.x<1.&&M.y>0.&&M.y<1.)
           {
             X-=E;
             L*=.5;
             Y+=1.;
             if(Y>2.)
               {
                 b=true;
                 F=M.xy;
                 D=B.xyz;
                 C=distance(X,m.xyz)*.4;
                 break;
               }
           }
       }
     vec3 N=(gbufferModelViewInverse*vec4(D,0.)).xyz;
     if(length(N)>far)
       b=false;
     if(b)
       {
         F.xy=floor(F.xy*vec2(viewWidth,viewHeight)+.5)/vec2(viewWidth,viewHeight);
         TemporalJitterProjPos01(F);
         vec2 M=F.xy*.5;
         M=clamp(M,vec2(0.)+ScreenTexel,HalfScreen)+HalfScreen;
         vec3 E=pow(texture2DLod(colortex1,M,0).xyz,vec3(2.2)),u=E*100.;
         LandAtmosphericScattering(u,D-m,H,g,worldSunVector,1.);
         G(u,D,normalize(m.xyz),normalize(s.xyz),1.);
         if(isEyeInWater>0)
           u*=1.2,UnderwaterFog(u,length(D),h,colorSkyUp,colorSunlight),u/=1.2;
         return vec4(u,saturate(C/4.));
       }
   }
   #endif
   const float P=2.4,u=P;
   int X=t(),D=f();
   vec3 M=s+x*(.01+r*.1)-h*(a*.2/(saturate(dot(z,-h))+1e-06)+.005)*(T?0.:1.);
   M+=Fract01(cameraPosition.xyz+.5);
   Ray F=MakeRay(f(M,X)*X-vec3(1.),g);
   vec3 L=vec3(1.),j=vec3(0.);
   float N=0.;
   SPcacsgCKo E=p(F);
   float C=far;
   vec3 B=vec3(1.);
   for(int Y=0;Y<1;Y++)
     {
       vec4 J=vec4(0.);
       vec3 A=vec3(0.);
       float I=.5;
       for(int k=0;k<REFLECTION_TRACE_LENGTH;k++)
         {
           A=E.GadGLQcpqX/float(X);
           vec2 V=d(A,X);
           J=texture2DLod(shadowcolor,V,0);
           N=J.w*255.;
           float q=1.-step(.5,abs(N-241.));
           vec3 W=J.xyz;
           float Q=dot(E.GadGLQcpqX+.5-F.origin,E.GadGLQcpqX+.5-F.origin),K=saturate(pow(saturate(dot(F.direction,normalize(E.GadGLQcpqX+.5-F.origin))),56.*Q)*5.-1.)*5.;
           j+=W*q*I*.5*K;
           if(N<240.)
             {
               if(d(E.GadGLQcpqX,N,F,k==0,C,B))
                 {
                   break;
                 }
             }
           i(E);
           I=1.;
         }
       if(J.w*255.<1.f||J.w*255.>254.f)
         {
           vec3 k=SkyShading(F.direction,worldSunVector,rainStrength);
           k=DoNightEyeAtNight(k*12.,timeMidnight)*.083333;
           vec3 V=k*L,K=V;
           #ifdef CLOUDS_IN_GI
           CloudPlane(K,-F.direction,worldLightVector,worldSunVector,colorSunlight,colorSkyUp,V,timeMidnight,false);
           V=mix(V,K,vec3(l));
           #endif
           V=TintUnderwaterDepth(V);
           j+=V*.1;
           C=1000.;
           break;
         }
       vec3 k=mod(F.origin+F.direction*C,vec3(1.))-.5;
       float V=log2(C*.4*v*TEXTURE_RESOLUTION);
       vec2 q=vec2(0.);
       q+=vec2(k.z*-B.x,-k.y)*abs(B.x);
       q+=vec2(k.x,k.z*B.y)*abs(B.y);
       q+=vec2(k.x*B.z,-k.y)*abs(B.z);
       vec3 W=(F.origin+F.direction*C)/float(X);
       vec2 Q=textureSize(colortex0,0);
       vec4 K=texture2DLod(shadowcolor1,d(A,X),0);
       vec2 Z=K.xy;
       Z=(floor(Z*Q/TEXTURE_RESOLUTION)+.5)/(Q/TEXTURE_RESOLUTION);
       vec2 ab=Z+q.xy*(TEXTURE_RESOLUTION/Q);
       vec3 ac=pow(texture2DLod(colortex0,ab,V).xyz,vec3(2.2));
       ac*=mix(vec3(1.),J.xyz/(K.w+1e-05),vec3(K.z));
       if(N<240.)
         {
           vec3 ad=saturate(J.xyz);
           L*=ac;
         }
       if(abs(N-31.)<.1)
         j+=.09*L*GI_LIGHT_BLOCK_INTENSITY;
       {
         vec3 ae=vec3(0.),af=vec3(0.);
         if(abs(B.x)>.5)
           ae=vec3(0.,1.,0.),af=vec3(0.,0.,1.);
         if(abs(B.y)>.5)
           ae=vec3(1.,0.,0.),af=vec3(0.,0.,1.);
         if(abs(B.z)>.5)
           ae=vec3(1.,0.,0.),af=vec3(0.,1.,0.);
         ae*=1.;
         af*=1.;
         vec3 ag=S(A,B),ah=ag,ai=saturate(ag*100000.),aj=S(A+ae/float(X),B);
         ah+=aj;
         ai+=saturate(aj*100000.);
         vec3 ak=S(A-ae/float(X),B);
         ah+=ak;
         ai+=saturate(ak*100000.);
         vec3 al=S(A+af/float(X),B);
         ah+=al;
         ai+=saturate(al*100000.);
         vec3 am=S(A-af/float(X),B);
         ah+=am;
         ai+=saturate(am*100000.);
         ah/=ai+vec3(.0001);
         j+=ah*u*L;
       }
       vec3 an=e(M+F.direction*C-1.,worldLightVector,B,g,X)*L*P*colorSunlight*l;
       if(isEyeInWater>0)
         ;
       j+=an;
     }
   vec3 k=m.xyz+H*C,V=(gbufferModelViewInverse*vec4(k.xyz,0.)).xyz;
   {
     vec3 J=ProjectBack(k);
     if(J.x>ScreenTexel.x&&J.x<1.-ScreenTexel.x&&J.y>ScreenTexel.y&&J.y<1.-ScreenTexel.y&&k.z<0.)
       {
         vec2 A=J.xy*2.-1.;
         float Q=1.-max(smoothstep(.5,1.,abs(A.x)),smoothstep(.5,1.,abs(A.y)));
         vec2 K=J.xy*.5+HalfScreen.xy;
         vec3 I=GetViewPositionNoJitter(J.xy,GetDepth(DownscaleTexcoord(J.xy))).xyz;
         if(length(I-k)<.03*length(I))
           j=mix(j.xyz,pow(texture2DLod(colortex1,K,0).xyz,vec3(2.2))*100.,vec3(Q));
       }
   }
   if(C<1000.)
     LandAtmosphericScattering(j,k-m,H,g,worldSunVector,1.);
   if(isEyeInWater>0)
     j*=1.2,UnderwaterFog(j,length(V),h,colorSkyUp,colorSunlight),j/=1.2;
   C*=saturate(dot(-h,x))*2.;
   return vec4(j,saturate(C/4.));
 }
 vec4 l(float v)
 {
   float y=v*v,s=y*v;
   vec4 i;
   i.x=-s+3*y-3*v+1;
   i.y=3*s-6*y+4;
   i.z=-3*s+3*y+3*v+1;
   i.w=s;
   return i/6.f;
 }
 vec4 g(in sampler2D v,in vec2 i)
 {
   vec2 y=vec2(viewWidth,viewHeight);
   i*=y;
   i-=.5;
   float s=fract(i.x),c=fract(i.y);
   i.x-=s;
   i.y-=c;
   vec4 m=l(s),x=l(c),f=vec4(i.x-.5,i.x+1.5,i.y-.5,i.y+1.5),z=vec4(m.x+m.y,m.z+m.w,x.x+x.y,x.z+x.w),d=f+vec4(m.y,m.w,x.y,x.w)/z,h=texture2DLod(v,vec2(d.x,d.z)/y,0),a=texture2DLod(v,vec2(d.y,d.z)/y,0),r=texture2DLod(v,vec2(d.x,d.w)/y,0),t=texture2DLod(v,vec2(d.y,d.w)/y,0);
   float n=z.x/(z.x+z.y),w=z.z/(z.z+z.w);
   return mix(mix(t,r,n),mix(a,h,n),w);
 }
 bool h(vec3 v,vec3 y)
 {
   vec3 s=normalize(cross(dFdx(v),dFdy(v))),x=normalize(y-v),c=normalize(x);
   return distance(v,y)<.05;
 }
 vec3 a(vec2 v)
 {
   vec2 y=vec2(viewWidth,viewHeight),c=1./y,s=v*y,i=floor(s-.5)+.5,x=s-i,z=x*x,f=x*z;
   float m=.5;
   vec2 d=-m*f+2.*m*z-m*x,a=(2.-m)*f-(3.-m)*z+1.,h=-(2.-m)*f+(3.-2.*m)*z+m*x,r=m*f-m*z,n=a+h,F=c*(i+h/n);
   vec3 t=texture2DLod(colortex4,vec2(F.x,F.y),0).xyz;
   vec2 k=c*(i-1.),B=c*(i+2.);
   vec4 w=vec4(texture2DLod(colortex4,vec2(F.x,k.y),0).xyz,1.)*(n.x*d.y)+vec4(texture2DLod(colortex4,vec2(k.x,F.y),0).xyz,1.)*(d.x*n.y)+vec4(t,1.)*(n.x*n.y)+vec4(texture2DLod(colortex4,vec2(B.x,F.y),0).xyz,1.)*(r.x*n.y)+vec4(texture2DLod(colortex4,vec2(F.x,B.y),0).xyz,1.)*(n.x*r.y);
   return max(vec3(0.),w.xyz*(1./w.w));
 }
 void main()
 {
   Texcoord=texcoord.xy;
   if(texcoord.x<HalfScreen.x||texcoord.y<HalfScreen.y)
     gl_FragData[0]=texture2DLod(colortex0,Texcoord.xy,0),gl_FragData[1]=texture2DLod(colortex1,Texcoord.xy,0),gl_FragData[2]=texture2DLod(colortex7,Texcoord.xy,0);
   else
     {
       Texcoord=texcoord.xy-HalfScreen;
       GBufferData v=GetGBufferData(Texcoord.xy);
       GBufferDataTransparent s=GetGBufferDataTransparent(Texcoord.xy);
       MaterialMask y=CalculateMasks(v.materialID,Texcoord.xy),i=CalculateMasks(s.materialID,Texcoord.xy);
       bool c=s.depth<v.depth;
       if(c)
         v.depth=s.depth,v.normal=s.normal,v.smoothness=s.smoothness,v.metalness=0.,v.mcLightmap=s.mcLightmap,i.sky=0.;
       bool x=abs(111.-s.materialID*255.)<.4&&c;
       vec4 f=GetViewPosition(Texcoord.xy,v.depth),m=gbufferModelViewInverse*vec4(f.xyz,1.),d=gbufferModelViewInverse*vec4(f.xyz,0.);
       vec3 z=normalize(f.xyz),h=normalize(d.xyz),n=normalize((gbufferModelViewInverse*vec4(v.normal,0.)).xyz),r=normalize((gbufferModelViewInverse*vec4(v.geoNormal,0.)).xyz);
       float a=length(f.xyz);
       vec4 w=vec4(0.);
       float t=e(v.smoothness,v.metalness);
       if(t>.0001&&i.sky<.5)
         w=G(1.-v.smoothness,v.metalness,m.xyz,f.xyz,n.xyz,r,h.xyz,y.leaves,v.mcLightmap.y,ExpToLinearDepth(v.depth),v.parallaxOffset,c);
       vec4 F=texture2DLod(colortex1,Texcoord.xy+HalfScreen,0);
       vec3 k=F.xyz;
       k.xyz=pow(k.xyz,vec3(2.2));
       if(x)
         k.xyz*=pow(s.albedo.xyz,vec3(1.))*10.;
       if(c&&!x)
         {
           vec3 J=GetViewPosition(Texcoord.xy,texture2DLod(depthtex1,Texcoord.xy,0).x).xyz;
           float p=length(J.xyz),g=p-a;
           vec3 B=s.normal-s.geoNormal*1.05;
           float L=saturate(g*.5)*.5;
           vec2 j=Texcoord.xy+B.xy/(a+1.5)*L;
           j=clamp(j,vec2(ScreenTexel),HalfScreen-ScreenTexel*2.);
           {
             float X=ExpToLinearDepth(texture2DLod(depthtex1,j,0).x),T=ExpToLinearDepth(texture2DLod(depthtex0,j,0).x);
             if(T>=X)
               j=Texcoord.xy;
           }
           k.xyz=pow(texture2DLod(colortex1,j.xy+HalfScreen,0).xyz,vec3(2.2));
           J=GetViewPosition(j.xy,texture2DLod(depthtex1,j.xy,0).x).xyz;
           f=GetViewPosition(j.xy,texture2DLod(depthtex0,j.xy,0).x);
           p=length(J.xyz);
           a=length(f.xyz);
           g=p-a;
           if(i.water>.5&&isEyeInWater<1)
             k.xyz*=100.,UnderwaterFog(k.xyz,g,h,colorSkyUp,colorSunlight),k.xyz*=.01;
           if(i.stainedGlass>.5)
             {
               vec3 V=normalize(s.albedo.xyz+.0001)*pow(length(s.albedo.xyz),.5);
               k.xyz*=mix(vec3(1.),V,vec3(pow(s.albedo.w,.2)));
               k.xyz*=mix(vec3(1.),V,vec3(pow(s.albedo.w,.2)));
             }
         }
       k.xyz=pow(k.xyz,vec3(1./2.2));
       gl_FragData[0]=texture2DLod(colortex0,Texcoord.xy,0);
       gl_FragData[1]=vec4(k.xyz,v.smoothness);
       gl_FragData[2]=max(vec4(0.),w*vec4(vec3(.1),1.));
     }
 };




/* DRAWBUFFERS:017 */
