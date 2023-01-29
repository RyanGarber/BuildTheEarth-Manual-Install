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
   float z=float(n.y/y),i=float(int(n.x+mod(m.x*z,y))/y);
   i+=floor(m.x*z/y);
   vec3 s=vec3(0.,0.,i);
   s.x=mod(n.x+mod(m.x*z,y),y);
   s.y=mod(n.y,y);
   s.xyz=floor(s.xyz);
   s/=y;
   s.xyz=s.xzy;
   return s;
 }
 vec2 x(vec3 v)
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
   float z=float(n.y/y),f=float(int(n.x+mod(m.x*z,y))/y);
   f+=floor(m.x*z/y);
   vec3 s=vec3(0.,0.,f);
   s.x=mod(n.x+mod(m.x*z,y),y);
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
   int x=f();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 r(vec3 v)
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
 vec3 d(vec3 v,vec3 i,vec2 n,vec2 x,vec4 s,vec4 m,inout float y,out vec2 f)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(m.x==8||m.x==9||m.x==79||m.x<1.||!r||m.x==20.||m.x==171.||min(abs(i.x),abs(i.z))>.2)
     y=1.;
   if(m.x==50.||m.x==52.||m.x==76.)
     {
       y=0.;
       if(i.y<.5)
         y=1.;
     }
   if(m.x==51||m.x==53)
     y=0.;
   if(m.x>255)
     y=0.;
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
   f=clamp((n.xy-x.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(m.x==10.||m.x==11.)
     {
       if(abs(i.y)<.01&&r||i.y>.99)
         h=.1,e=.1,y=0.;
       else
          y=1.;
     }
   if(m.x==51||m.x==53)
     h=.5,e=.1;
   if(m.x==76)
     h=.2,e=.2;
   if(m.x-255.+39.>=103.&&m.x-255.+39.<=113.)
     e=.025,h=.025;
   z=normalize(s.xyz);
   c=normalize(cross(z,i.xyz)*sign(s.w));
   vec3 d=v.xyz+mix(z*h,-z*h,vec3(f.x));
   d.xyz+=mix(c*h,-c*h,vec3(f.y));
   d.xyz-=i.xyz*e;
   return d;
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
 void e(inout SPcacsgCKo v)
 {
   v.OmcxSfXfkJ=step(v.UekatYTTmj.xyz,v.UekatYTTmj.yzx)*step(v.UekatYTTmj.xyz,v.UekatYTTmj.zxy),v.UekatYTTmj+=v.OmcxSfXfkJ*v.vAdYwconYe,v.GadGLQcpqX+=v.OmcxSfXfkJ*v.AZVxALDdtL;
 }
 void d(in Ray v,in vec3 i[2],out float f,out float y)
 {
   float x,z,r,e;
   f=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   e=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   f=max(max(f,x),r);
   y=min(min(y,z),e);
 }
 vec3 d(const vec3 v,const vec3 i,vec3 y)
 {
   const float x=1e-05;
   vec3 z=(i+v)*.5,m=(i-v)*.5,s=y-z,f=vec3(0.);
   f+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-m.x),x);
   f+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-m.y),x);
   f+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-m.z),x);
   return normalize(f);
 }
 bool e(const vec3 v,const vec3 i,Ray m,out vec2 f)
 {
   vec3 y=m.inv_direction*(v-m.origin),x=m.inv_direction*(i-m.origin),s=min(x,y),n=max(x,y);
   vec2 c=max(s.xx,s.yz);
   float z=max(c.x,c.y);
   c=min(n.xx,n.yz);
   float e=min(c.x,c.y);
   f.x=z;
   f.y=e;
   return e>max(z,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(i+1e-05-m.origin),n=min(s,z),c=max(s,z);
   vec2 f=max(n.xx,n.yz);
   float h=max(f.x,f.y);
   f=min(c.xx,c.yz);
   float e=min(f.x,f.y);
   bool t=e>max(h,0.)&&max(h,0.)<x;
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
   float f=.5;
   vec3 t=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*f),2).x;
   t*=saturate(dot(i,y));
   {
     vec4 n=texture2DLod(shadowcolor1,s.xy-vec2(0.,.5),4);
     float c=abs(n.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,i,c),e=shadow2DLod(shadowtex0,vec3(s.xy-vec2(0.,.5),s.z+1e-06),4).x;
     t=mix(t,t*h,1.-e);
   }
   t=TintUnderwaterDepth(t);
   return t*(1.-rainStrength);
 }
 vec3 f(vec3 y,vec3 i,vec3 x,vec3 z,int f)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 s=v(y);
   s+=1.;
   s-=Fract01(cameraPosition+.5);
   vec3 n=m(s+x*.99);
   float h=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*h),3).x;
   c*=saturate(dot(i,x));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float t=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*h),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   c=mix(c,c*e,vec3(1.-t));
   #endif
   return c*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 s=m(v);
   float f=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*f),2).x;
   c*=saturate(dot(i,y));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float n=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*f),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   c=mix(c,c*e,vec3(1.-n));
   #endif
   return c*(1.-rainStrength);
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
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),s=UnpackTwo16BitFrom32Bit(v.z),n=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=m.y;
   i.avjkUoKnfB=s.y;
   i.ivaOqoXyFu=n.y*255.;
   i.PVAMAgODVh=pow(vec3(m.x,s.x,n.x),vec3(8.));
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
 bool c(vec3 v,float y,Ray i,bool x,inout float f,inout vec3 z)
 {
   bool m=false,s=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(x)
     return false;
   if(y>=67.)
     return false;
   s=d(v,v+vec3(1.,1.,1.),i,f,z);
   m=s;
   #else
   if(y<40.)
     return s=d(v,v+vec3(1.,1.,1.),i,f,z),s;
   if(y==40.||y==41.||y>=43.&&y<=54.)
     {
       float c=.5;
       if(y==41.)
         c=.9375;
       s=d(v+vec3(0.,0.,0.),v+vec3(1.,c,1.),i,f,z);
       m=m||s;
     }
   if(y==42.||y>=55.&&y<=66.)
     s=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,f,z),m=m||s;
   if(y==43.||y==46.||y==47.||y==52.||y==53.||y==54.||y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
     {
       float c=.5;
       if(y==55.||y==58.||y==59.||y==64.||y==65.||y==66.)
         c=0.;
       s=d(v+vec3(0.,c,0.),v+vec3(.5,.5+c,.5),i,f,z);
       m=m||s;
     }
   if(y==43.||y==45.||y==48.||y==51.||y==53.||y==54.||y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
     {
       float c=.5;
       if(y==55.||y==57.||y==60.||y==63.||y==65.||y==66.)
         c=0.;
       s=d(v+vec3(.5,c,0.),v+vec3(1.,.5+c,.5),i,f,z);
       m=m||s;
     }
   if(y==44.||y==45.||y==49.||y==51.||y==52.||y==54.||y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
     {
       float c=.5;
       if(y==56.||y==57.||y==61.||y==63.||y==64.||y==66.)
         c=0.;
       s=d(v+vec3(.5,c,.5),v+vec3(1.,.5+c,1.),i,f,z);
       m=m||s;
     }
   if(y==44.||y==46.||y==50.||y==51.||y==52.||y==53.||y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
     {
       float c=.5;
       if(y==56.||y==58.||y==62.||y==63.||y==64.||y==65.)
         c=0.;
       s=d(v+vec3(0.,c,.5),v+vec3(.5,.5+c,1.),i,f,z);
       m=m||s;
     }
   if(y>=67.&&y<=82.)
     s=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,f,z),m=m||s;
   if(y==68.||y==69.||y==70.||y==72.||y==73.||y==74.||y==76.||y==77.||y==78.||y==80.||y==81.||y==82.)
     {
       float c=8.,n=8.;
       if(y==68.||y==70.||y==72.||y==74.||y==76.||y==78.||y==80.||y==82.)
         c=0.;
       if(y==69.||y==70.||y==73.||y==74.||y==77.||y==78.||y==81.||y==82.)
         n=16.;
       s=d(v+vec3(c,6.,7.)/16.,v+vec3(n,9.,9.)/16.,i,f,z);
       m=m||s;
       s=d(v+vec3(c,12.,7.)/16.,v+vec3(n,15.,9.)/16.,i,f,z);
       m=m||s;
     }
   if(y>=71.&&y<=82.)
     {
       float c=8.,n=8.;
       if(y>=71.&&y<=74.||y>=79.&&y<=82.)
         n=16.;
       if(y>=75.&&y<=82.)
         c=0.;
       s=d(v+vec3(7.,6.,c)/16.,v+vec3(9.,9.,n)/16.,i,f,z);
       m=m||s;
       s=d(v+vec3(7.,12.,c)/16.,v+vec3(9.,15.,n)/16.,i,f,z);
       m=m||s;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(y>=83.&&y<=86.)
     {
       vec3 c=vec3(0),n=vec3(0);
       if(y==83.)
         c=vec3(0,0,0),n=vec3(16,16,3);
       if(y==84.)
         c=vec3(0,0,13),n=vec3(16,16,16);
       if(y==86.)
         c=vec3(0,0,0),n=vec3(3,16,16);
       if(y==85.)
         c=vec3(13,0,0),n=vec3(16,16,16);
       s=d(v+c/16.,v+n/16.,i,f,z);
       m=m||s;
     }
   if(y>=87.&&y<=102.)
     {
       vec3 c=vec3(0.),n=vec3(1.);
       if(y>=87.&&y<=94.)
         {
           float h=0.;
           if(y>=91.&&y<=94.)
             h=13.;
           c=vec3(0.,h,0.)/16.;
           n=vec3(16.,h+3.,16.)/16.;
         }
       if(y>=95.&&y<=98.)
         {
           float h=13.;
           if(y==97.||y==98.)
             h=0.;
           c=vec3(0.,0.,h)/16.;
           n=vec3(16.,16.,h+3.)/16.;
         }
       if(y>=99.&&y<=102.)
         {
           float h=13.;
           if(y==99.||y==100.)
             h=0.;
           c=vec3(h,0.,0.)/16.;
           n=vec3(h+3.,16.,16.)/16.;
         }
       s=d(v+c,v+n,i,f,z);
       m=m||s;
     }
   if(y>=103.&&y<=113.)
     {
       vec3 c=vec3(0.),n=vec3(1.);
       if(y>=103.&&y<=110.)
         {
           float e=float(y)-float(103.)+1.;
           n.y=e*2./16.;
         }
       if(y==111.)
         n.y=.0625;
       if(y==112.)
         c=vec3(1.,0.,1.)/16.,n=vec3(15.,1.,15.)/16.;
       if(y==113.)
         c=vec3(1.,0.,1.)/16.,n=vec3(15.,.5,15.)/16.;
       s=d(v+c,v+n,i,f,z);
       m=m||s;
     }
   #endif
   #endif
   return m;
 }
 vec3 w(vec2 v)
 {
   vec2 y=vec2(v.xy*vec2(viewWidth,viewHeight));
   y*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   y=(floor(y*64.)+.5)/64.;
   vec3 s=texture2D(noisetex,y).xyz,c=vec3(sqrt(.2),sqrt(2.),1.61803);
   s=mod(s+float(frameCounter%64)*c,vec3(1.));
   return s;
 }
 void d(inout float v,inout float y,float i,float f,vec3 c,float x)
 {
   v*=mix(2.4,3.4,f);
   v*=1.25;
   float s=dot(c,vec3(1.));
   y*=1.-pow(f,.4);
   y/=i*.1+2e-06;
   y*=.25;
   if(x<.12)
     y=0.;
 }
 float c(vec3 v,vec3 y,float m)
 {
   float i=dot(abs(v-y),vec3(.3333));
   i*=m;
   return i;
 }
 vec4 c(sampler2D v,vec2 i,bool y,float x,float m,vec2 f,const bool z,out float s)
 {
   CPrmwMXxJc n=c(i.xy);
   s=n.avjkUoKnfB;
   vec2 h=vec2(0.,HalfScreen.y);
   vec4 e=texture2DLod(v,i.xy+h,0);
   vec3 t=e.xyz;
   float r=e.w;
   if(s<.95&&z)
     return e;
   vec3 a,w;
   GetBothNormals(i.xy,a,w);
   float R=GetDepth(i.xy),o=ExpToLinearDepth(R);
   vec3 p=GetViewPosition(i.xy,R).xyz,H=normalize(p);
   vec2 j=vec2(0.);
   if(y||s>.95)
     j=BlueNoiseTemporal(i.xy).xy-.5;
   float G=x*1,b=m;
   d(G,b,e.w,s,t,o);
   float S=24.*mix(1.,1.,s),Y=mix(3.,3.,s)/o,J=0.;
   vec4 X=vec4(0.);
   float F=0.;
   vec4 O=vec4(vec3(.3),1.);
   int u=0;
   vec2 P=normalize(cross(w,vec3(0.,0.,1.)).xy),l=P.yx*vec2(1.,-1.);
   l*=saturate(dot(w,-H))*.8+.2;
   for(int C=-1;C<=1;C++)
     {
       {
         vec2 U=vec2(C+j.x)*f;
         U=U.x*P+U.y*l;
         U*=G*ScreenTexel;
         vec2 B=i.xy+U.xy;
         B=clamp(B,vec2(0.)+ScreenTexel*2.,HalfScreen-ScreenTexel*2.);
         vec4 T=texture2DLod(v,B+h,0);
         vec3 A,L;
         GetBothNormals(B,A,L);
         vec3 E=GetViewPosition(B,GetDepth(B)).xyz,g=E.xyz-p.xyz;
         float D=length(g);
         vec3 M=g/(D+1e-06);
         float V=dot(g,w);
         bool k=V>.05&&Luminance(T.xyz)<Luminance(t.xyz);
         float I=saturate(exp(-abs(V)*100.))*pow(saturate(dot(a,A)),S),q=exp(-(abs(E.z-p.z)*Y));
         if(k&&D<1.&&dot(-M,L)>0.)
           I=8./x;
         float K=exp(-c(T.xyz,t,b)),W=I*K*q;
         X+=T*W;
         F+=W;
         u++;
       }
     }
   X/=F+.0001;
   if(F<.0001)
     X=e;
   return X;
 }
 void main()
 {
   float v;
   vec4 y=c(colortex7,texcoord.xy,true,2.,2.,vec2(1.,-1.),false,v);
   float z=1.;
   if(texcoord.y<.25)
     {
       vec2 i=texcoord.xy*vec2(4.,4.),n=vec2(i.x,(i.y-floor(mod(FRAME_TIME*60.f,60.f)))/60.f);
       if(texcoord.x<.25)
         z=texture2DLod(colortex0,n.xy,0).x;
       else
          if(texcoord.x>.25&&texcoord.x<.5)
           z=texture2DLod(colortex0,n.xy,0).y;
         else
            if(texcoord.x>.5&&texcoord.x<.75)
             z=texture2DLod(colortex0,n.xy,0).z;
           else
              z=texture2DLod(colortex0,n.xy,0).w;
     }
   vec2 i=1.-abs(texcoord.xy*2.-1.);
   i=saturate(i*10.);
   float x=min(i.x,i.y);
   gl_FragData[0]=vec4(y.xyz,z);
 };




/* DRAWBUFFERS:7 */
