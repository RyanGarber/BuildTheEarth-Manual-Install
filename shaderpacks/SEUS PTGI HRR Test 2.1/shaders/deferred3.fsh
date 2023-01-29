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


#include "lib/Uniforms.inc"
#include "lib/Common.inc"
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
   int x=v.x*v.y;
   return f(FloorToInt(floor(pow(float(x),.333333))));
 }
 int t()
 {
   ivec2 v=ivec2(2048,2048);
   int x=v.x*v.y;
   return t(FloorToInt(floor(pow(float(x),.333333))));
 }
 vec3 d(vec2 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=m.x*m.y,y=f();
   ivec2 n=ivec2(v.x*m.x,v.y*m.y);
   float h=float(n.y/y),i=float(int(n.x+mod(m.x*h,y))/y);
   i+=floor(m.x*h/y);
   vec3 s=vec3(0.,0.,i);
   s.x=mod(n.x+mod(m.x*h,y),y);
   s.y=mod(n.y,y);
   s.xyz=floor(s.xyz);
   s/=y;
   s.xyz=s.xzy;
   return s;
 }
 vec2 r(vec3 v)
 {
   ivec2 m=ivec2(viewWidth,viewHeight);
   int x=f();
   vec3 i=v.xzy*x;
   i=floor(i+1e-05);
   float y=i.z;
   vec2 n;
   n.x=mod(i.x+y*x,m.x);
   float s=i.x+y*x;
   n.y=i.y+floor(s/m.x)*x;
   n+=.5;
   n/=m;
   return n;
 }
 vec3 n(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,y=t();
   ivec2 n=ivec2(i.x*m.x,i.y*m.y);
   float h=float(n.y/y),f=float(int(n.x+mod(m.x*h,y))/y);
   f+=floor(m.x*h/y);
   vec3 s=vec3(0.,0.,f);
   s.x=mod(n.x+mod(m.x*h,y),y);
   s.y=mod(n.y,y);
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
 vec3 x(vec3 v)
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
   vec3 v=cameraPosition.xyz+.5,i=previousCameraPosition.xyz+.5,x=floor(v-.0001),y=floor(i-.0001);
   return x-y;
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
 vec3 d(vec3 v,vec3 i,vec2 n,vec2 m,vec4 s,vec4 f,inout float x,out vec2 y)
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
   vec3 h,z;
   if(i.x>.5)
     h=vec3(0.,0.,-1.),z=vec3(0.,-1.,0.);
   else
      if(i.x<-.5)
       h=vec3(0.,0.,1.),z=vec3(0.,-1.,0.);
     else
        if(i.y>.5)
         h=vec3(1.,0.,0.),z=vec3(0.,0.,1.);
       else
          if(i.y<-.5)
           h=vec3(1.,0.,0.),z=vec3(0.,0.,-1.);
         else
            if(i.z>.5)
             h=vec3(1.,0.,0.),z=vec3(0.,-1.,0.);
           else
              if(i.z<-.5)
               h=vec3(-1.,0.,0.),z=vec3(0.,-1.,0.);
   y=clamp((n.xy-m.xy)*100000.,vec2(0.),vec2(1.));
   float R=.15,e=.15;
   if(f.x==10.||f.x==11.)
     {
       if(abs(i.y)<.01&&r||i.y>.99)
         R=.1,e=.1,x=0.;
       else
          x=1.;
     }
   if(f.x==51||f.x==53)
     R=.5,e=.1;
   if(f.x==76)
     R=.2,e=.2;
   if(f.x-255.+39.>=103.&&f.x-255.+39.<=113.)
     e=.025,R=.025;
   h=normalize(s.xyz);
   z=normalize(cross(h,i.xyz)*sign(s.w));
   vec3 d=v.xyz+mix(h*R,-h*R,vec3(y.x));
   d.xyz+=mix(z*R,-z*R,vec3(y.y));
   d.xyz-=i.xyz*e;
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
 void e(inout SPcacsgCKo v)
 {
   v.OmcxSfXfkJ=step(v.UekatYTTmj.xyz,v.UekatYTTmj.yzx)*step(v.UekatYTTmj.xyz,v.UekatYTTmj.zxy),v.UekatYTTmj+=v.OmcxSfXfkJ*v.vAdYwconYe,v.GadGLQcpqX+=v.OmcxSfXfkJ*v.AZVxALDdtL;
 }
 void d(in Ray v,in vec3 i[2],out float x,out float y)
 {
   float f,z,h,n;
   x=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   f=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   h=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   n=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   x=max(max(x,f),h);
   y=min(min(y,z),n);
 }
 vec3 d(const vec3 v,const vec3 i,vec3 y)
 {
   const float x=1e-05;
   vec3 h=(i+v)*.5,n=(i-v)*.5,f=y-h,z=vec3(0.);
   z+=vec3(sign(f.x),0.,0.)*step(abs(abs(f.x)-n.x),x);
   z+=vec3(0.,sign(f.y),0.)*step(abs(abs(f.y)-n.y),x);
   z+=vec3(0.,0.,sign(f.z))*step(abs(abs(f.z)-n.z),x);
   return normalize(z);
 }
 bool e(const vec3 v,const vec3 i,Ray m,out vec2 f)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(i-m.origin),n=min(x,y),s=max(x,y);
   vec2 z=max(n.xx,n.yz);
   float h=max(z.x,z.y);
   z=min(s.xx,s.yz);
   float e=min(z.x,z.y);
   f.x=h;
   f.y=e;
   return e>max(h,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),h=m.inv_direction*(i+1e-05-m.origin),f=min(h,z),n=max(h,z);
   vec2 s=max(f.xx,f.yz);
   float t=max(s.x,s.y);
   s=min(n.xx,n.yz);
   float e=min(s.x,s.y);
   bool c=e>max(t,0.)&&max(t,0.)<x;
   if(c)
     y=d(v-1e-05,i+1e-05,m.origin+m.direction*t),x=t;
   return c;
 }
 vec3 e(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 f=m(v);
   float h=.5;
   vec3 n=vec3(1.)*shadow2DLod(shadowtex0,vec3(f.xy,f.z-.0006*h),2).x;
   n*=saturate(dot(i,y));
   {
     vec4 s=texture2DLod(shadowcolor1,f.xy-vec2(0.,.5),4);
     float t=abs(s.x*256.-(v.y+cameraPosition.y)),R=GetCausticsComposite(v,i,t),e=shadow2DLod(shadowtex0,vec3(f.xy-vec2(0.,.5),f.z+1e-06),4).x;
     n=mix(n,n*R,1.-e);
   }
   n=TintUnderwaterDepth(n);
   return n*(1.-rainStrength);
 }
 vec3 f(vec3 y,vec3 i,vec3 x,vec3 h,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 f=v(y);
   f+=1.;
   f-=Fract01(cameraPosition+.5);
   vec3 n=m(f+x*.99);
   float s=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*s),3).x;
   r*=saturate(dot(i,x));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*s),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   r=mix(r,r*e,vec3(1.-t));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 f=m(v);
   float h=.5;
   vec3 n=vec3(1.)*shadow2DLod(shadowtex0,vec3(f.xy,f.z-.0006*h),2).x;
   n*=saturate(dot(i,y));
   n=TintUnderwaterDepth(n);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(f.xy-vec2(.5,0.),f.z-.0006*h),3).x;
   vec3 s=texture2DLod(shadowcolor,vec2(f.xy-vec2(.5,0.)),3).xyz;
   s*=s;
   n=mix(n,n*s,vec3(1.-t));
   #endif
   return n*(1.-rainStrength);
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
 CPrmwMXxJc c(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return w(texture2DLod(colortex5,v,0));
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
 bool c(vec3 v,float x,Ray i,bool y,inout float h,inout vec3 z)
 {
   bool f=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(y)
     return false;
   if(x>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),i,h,z);
   f=m;
   #else
   if(x<40.)
     return m=d(v,v+vec3(1.,1.,1.),i,h,z),m;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float n=.5;
       if(x==41.)
         n=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,n,1.),i,h,z);
       f=f||m;
     }
   if(x==42.||x>=55.&&x<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,h,z),f=f||m;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float n=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         n=0.;
       m=d(v+vec3(0.,n,0.),v+vec3(.5,.5+n,.5),i,h,z);
       f=f||m;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float n=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         n=0.;
       m=d(v+vec3(.5,n,0.),v+vec3(1.,.5+n,.5),i,h,z);
       f=f||m;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float n=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         n=0.;
       m=d(v+vec3(.5,n,.5),v+vec3(1.,.5+n,1.),i,h,z);
       f=f||m;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float n=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         n=0.;
       m=d(v+vec3(0.,n,.5),v+vec3(.5,.5+n,1.),i,h,z);
       f=f||m;
     }
   if(x>=67.&&x<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,h,z),f=f||m;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float n=8.,s=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         n=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         s=16.;
       m=d(v+vec3(n,6.,7.)/16.,v+vec3(s,9.,9.)/16.,i,h,z);
       f=f||m;
       m=d(v+vec3(n,12.,7.)/16.,v+vec3(s,15.,9.)/16.,i,h,z);
       f=f||m;
     }
   if(x>=71.&&x<=82.)
     {
       float n=8.,s=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         s=16.;
       if(x>=75.&&x<=82.)
         n=0.;
       m=d(v+vec3(7.,6.,n)/16.,v+vec3(9.,9.,s)/16.,i,h,z);
       f=f||m;
       m=d(v+vec3(7.,12.,n)/16.,v+vec3(9.,15.,s)/16.,i,h,z);
       f=f||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(x>=83.&&x<=86.)
     {
       vec3 n=vec3(0),s=vec3(0);
       if(x==83.)
         n=vec3(0,0,0),s=vec3(16,16,3);
       if(x==84.)
         n=vec3(0,0,13),s=vec3(16,16,16);
       if(x==86.)
         n=vec3(0,0,0),s=vec3(3,16,16);
       if(x==85.)
         n=vec3(13,0,0),s=vec3(16,16,16);
       m=d(v+n/16.,v+s/16.,i,h,z);
       f=f||m;
     }
   if(x>=87.&&x<=102.)
     {
       vec3 n=vec3(0.),s=vec3(1.);
       if(x>=87.&&x<=94.)
         {
           float e=0.;
           if(x>=91.&&x<=94.)
             e=13.;
           n=vec3(0.,e,0.)/16.;
           s=vec3(16.,e+3.,16.)/16.;
         }
       if(x>=95.&&x<=98.)
         {
           float e=13.;
           if(x==97.||x==98.)
             e=0.;
           n=vec3(0.,0.,e)/16.;
           s=vec3(16.,16.,e+3.)/16.;
         }
       if(x>=99.&&x<=102.)
         {
           float e=13.;
           if(x==99.||x==100.)
             e=0.;
           n=vec3(e,0.,0.)/16.;
           s=vec3(e+3.,16.,16.)/16.;
         }
       m=d(v+n,v+s,i,h,z);
       f=f||m;
     }
   if(x>=103.&&x<=113.)
     {
       vec3 n=vec3(0.),s=vec3(1.);
       if(x>=103.&&x<=110.)
         {
           float e=float(x)-float(103.)+1.;
           s.y=e*2./16.;
         }
       if(x==111.)
         s.y=.0625;
       if(x==112.)
         n=vec3(1.,0.,1.)/16.,s=vec3(15.,1.,15.)/16.;
       if(x==113.)
         n=vec3(1.,0.,1.)/16.,s=vec3(15.,.5,15.)/16.;
       m=d(v+n,v+s,i,h,z);
       f=f||m;
     }
   #endif
   #endif
   return f;
 }
 vec3 h(vec2 v)
 {
   vec2 x=vec2(v.xy*vec2(viewWidth,viewHeight));
   x*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   x=(floor(x*64.)+.5)/64.;
   vec3 f=texture2D(noisetex,x).xyz,h=vec3(sqrt(.2),sqrt(2.),1.61803);
   f=mod(f+float(frameCounter%64)*h,vec3(1.));
   return f;
 }
 float e(float v,float y)
 {
   return exp(-pow(v/(.9*y),2.));
 }
 void main()
 {
   vec4 x=texture2DLod(colortex7,texcoord.xy,0),v=texture2DLod(colortex2,texcoord.xy,0);
   if(texcoord.x<HalfScreen.x&&texcoord.y>HalfScreen.y)
     {
       vec2 f=texcoord.xy-vec2(0.,HalfScreen.y);
       vec4 n=texture2DLod(colortex4,f.xy,0);
       vec3 m=n.xyz;
       float s=Luminance(m.xyz);
       vec3 y=GetNormals(f.xy);
       float h=GetDepthLinear(f.xy);
       vec2 z=vec2(0.);
       float e=4.,R=sin(frameTimeCounter)>0.?1.:0.;
       vec4 r=vec4(0.),t=vec4(0.);
       float a=0.;
       int d=0;
       for(int p=-1;p<=1;p++)
         {
           for(int w=-1;w<=1;w++)
             {
               vec2 j=(vec2(p,w)+z)/vec2(viewWidth,viewHeight)*e,o=f.xy+j.xy;
               o=clamp(o,4./vec2(viewWidth,viewHeight),1.-4./vec2(viewWidth,viewHeight));
               vec4 G=texture2DLod(colortex4,o,0);
               r+=G;
               t+=G*G;
               d++;
             }
         }
       r/=d+1e-06;
       t/=d+1e-06;
       vec3 G=r.xyz;
       float w=dot(r.xyz,vec3(1.));
       vec4 p=sqrt(max(vec4(0.),t-r*r));
       float o=dot(p.xyz,vec3(6.));
       if(a<.0001)
         G=m;
       x=vec4(n.xyz,o);
     }
   CPrmwMXxJc f=c(texcoord.xy);
   if(texcoord.x<HalfScreen.x&&texcoord.y<HalfScreen.y)
     {
       float m=f.avjkUoKnfB,n=m;
       for(int s=-1;s<=1;s++)
         {
           for(int y=-1;y<=1;y++)
             {
               vec2 h=vec2(s,y)/vec2(viewWidth,viewHeight),z=texcoord.xy+h.xy;
               float e=c(z.xy).avjkUoKnfB;
               n=min(n,e);
             }
         }
       f.avjkUoKnfB=n;
     }
   gl_FragData[0]=v;
   gl_FragData[1]=i(f);
   gl_FragData[2]=x;
 };




/* DRAWBUFFERS:257 */
