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
   y=clamp((n.xy-m.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,e=.15;
   if(f.x==10.||f.x==11.)
     {
       if(abs(i.y)<.01&&r||i.y>.99)
         h=.1,e=.1,x=0.;
       else
          x=1.;
     }
   if(f.x==51||f.x==53)
     h=.5,e=.1;
   if(f.x==76)
     h=.2,e=.2;
   if(f.x-255.+39.>=103.&&f.x-255.+39.<=113.)
     e=.025,h=.025;
   z=normalize(s.xyz);
   c=normalize(cross(z,i.xyz)*sign(s.w));
   vec3 G=v.xyz+mix(z*h,-z*h,vec3(y.x));
   G.xyz+=mix(c*h,-c*h,vec3(y.y));
   G.xyz-=i.xyz*e;
   return G;
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
 void d(in Ray v,in vec3 i[2],out float f,out float x)
 {
   float y,z,r,e;
   f=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   e=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   f=max(max(f,y),r);
   x=min(min(x,z),e);
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
   vec3 x=m.inv_direction*(v-m.origin),y=m.inv_direction*(i-m.origin),s=min(y,x),n=max(y,x);
   vec2 r=max(s.xx,s.yz);
   float z=max(r.x,r.y);
   r=min(n.xx,n.yz);
   float e=min(r.x,r.y);
   f.x=z;
   f.y=e;
   return e>max(z,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 y)
 {
   vec3 z=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(i+1e-05-m.origin),f=min(s,z),n=max(s,z);
   vec2 r=max(f.xx,f.yz);
   float h=max(r.x,r.y);
   r=min(n.xx,n.yz);
   float e=min(r.x,r.y);
   bool c=e>max(h,0.)&&max(h,0.)<x;
   if(c)
     y=d(v-1e-05,i+1e-05,m.origin+m.direction*h),x=h;
   return c;
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
     vec4 n=texture2DLod(shadowcolor1,f.xy-vec2(0.,.5),4);
     float c=abs(n.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,i,c),e=shadow2DLod(shadowtex0,vec3(f.xy-vec2(0.,.5),f.z+1e-06),4).x;
     r=mix(r,r*h,1.-e);
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
   float n=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*n),3).x;
   c*=saturate(dot(i,x));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float h=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*n),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   c=mix(c,c*e,vec3(1.-h));
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
   float n=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(f.xy,f.z-.0006*n),2).x;
   r*=saturate(dot(i,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float h=shadow2DLod(shadowtex0,vec3(f.xy-vec2(.5,0.),f.z-.0006*n),3).x;
   vec3 s=texture2DLod(shadowcolor,vec2(f.xy-vec2(.5,0.)),3).xyz;
   s*=s;
   r=mix(r,r*s,vec3(1.-h));
   #endif
   return r*(1.-rainStrength);
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
 CPrmwMXxJc w(vec4 v)
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
   return w(texture2DLod(colortex5,v,0));
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
 bool d(vec3 v,float x,Ray i,bool y,inout float f,inout vec3 z)
 {
   bool r=false,m=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(y)
     return false;
   if(x>=67.)
     return false;
   m=d(v,v+vec3(1.,1.,1.),i,f,z);
   r=m;
   #else
   if(x<40.)
     return m=d(v,v+vec3(1.,1.,1.),i,f,z),m;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float s=.5;
       if(x==41.)
         s=.9375;
       m=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),i,f,z);
       r=r||m;
     }
   if(x==42.||x>=55.&&x<=66.)
     m=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,f,z),r=r||m;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float s=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         s=0.;
       m=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),i,f,z);
       r=r||m;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float s=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         s=0.;
       m=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),i,f,z);
       r=r||m;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float s=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         s=0.;
       m=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),i,f,z);
       r=r||m;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float s=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         s=0.;
       m=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),i,f,z);
       r=r||m;
     }
   if(x>=67.&&x<=82.)
     m=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,f,z),r=r||m;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float s=8.,c=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         s=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         c=16.;
       m=d(v+vec3(s,6.,7.)/16.,v+vec3(c,9.,9.)/16.,i,f,z);
       r=r||m;
       m=d(v+vec3(s,12.,7.)/16.,v+vec3(c,15.,9.)/16.,i,f,z);
       r=r||m;
     }
   if(x>=71.&&x<=82.)
     {
       float s=8.,c=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         c=16.;
       if(x>=75.&&x<=82.)
         s=0.;
       m=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,c)/16.,i,f,z);
       r=r||m;
       m=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,c)/16.,i,f,z);
       r=r||m;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(x>=83.&&x<=86.)
     {
       vec3 s=vec3(0),c=vec3(0);
       if(x==83.)
         s=vec3(0,0,0),c=vec3(16,16,3);
       if(x==84.)
         s=vec3(0,0,13),c=vec3(16,16,16);
       if(x==86.)
         s=vec3(0,0,0),c=vec3(3,16,16);
       if(x==85.)
         s=vec3(13,0,0),c=vec3(16,16,16);
       m=d(v+s/16.,v+c/16.,i,f,z);
       r=r||m;
     }
   if(x>=87.&&x<=102.)
     {
       vec3 s=vec3(0.),c=vec3(1.);
       if(x>=87.&&x<=94.)
         {
           float h=0.;
           if(x>=91.&&x<=94.)
             h=13.;
           s=vec3(0.,h,0.)/16.;
           c=vec3(16.,h+3.,16.)/16.;
         }
       if(x>=95.&&x<=98.)
         {
           float n=13.;
           if(x==97.||x==98.)
             n=0.;
           s=vec3(0.,0.,n)/16.;
           c=vec3(16.,16.,n+3.)/16.;
         }
       if(x>=99.&&x<=102.)
         {
           float n=13.;
           if(x==99.||x==100.)
             n=0.;
           s=vec3(n,0.,0.)/16.;
           c=vec3(n+3.,16.,16.)/16.;
         }
       m=d(v+s,v+c,i,f,z);
       r=r||m;
     }
   if(x>=103.&&x<=113.)
     {
       vec3 s=vec3(0.),c=vec3(1.);
       if(x>=103.&&x<=110.)
         {
           float n=float(x)-float(103.)+1.;
           c.y=n*2./16.;
         }
       if(x==111.)
         c.y=.0625;
       if(x==112.)
         s=vec3(1.,0.,1.)/16.,c=vec3(15.,1.,15.)/16.;
       if(x==113.)
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
   vec2 x=vec2(v.xy*vec2(viewWidth,viewHeight));
   x*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   x=(floor(x*64.)+.5)/64.;
   vec3 r=texture2D(noisetex,x).xyz,s=vec3(sqrt(.2),sqrt(2.),1.61803);
   r=mod(r+float(frameCounter%64)*s,vec3(1.));
   return r;
 }
 void G(inout float v,inout float x,float i,float y,vec3 s,float z)
 {
   v*=mix(2.4,3.4,y);
   v*=1.25;
   float r=dot(s,vec3(1.));
   x*=1.-pow(y,.4);
   x/=i*.1+2e-06;
   x*=.25;
   if(z<.12)
     x=0.;
 }
 float G(vec3 v,vec3 y,float m)
 {
   float x=dot(abs(v-y),vec3(.3333));
   x*=m;
   return x;
 }
 vec4 G(sampler2D v,vec2 f,bool x,float y,float m,vec2 s,const bool z,out float r)
 {
   CPrmwMXxJc n=i(f.xy);
   r=n.avjkUoKnfB;
   vec2 c=vec2(0.,HalfScreen.y);
   vec4 e=texture2DLod(v,f.xy+c,0);
   vec3 h=e.xyz;
   float w=e.w;
   if(r<.95&&z)
     return e;
   vec3 a,t;
   GetBothNormals(f.xy,a,t);
   float R=GetDepth(f.xy),o=ExpToLinearDepth(R);
   vec3 d=GetViewPosition(f.xy,R).xyz,H=normalize(d);
   vec2 j=vec2(0.);
   if(x||r>.95)
     j=BlueNoiseTemporal(f.xy).xy-.5;
   float p=y*1,Y=m;
   G(p,Y,e.w,r,h,o);
   float b=24.*mix(1.,1.,r),S=mix(3.,3.,r)/o,J=0.;
   vec4 X=vec4(0.);
   float F=0.;
   vec4 O=vec4(vec3(.3),1.);
   int u=0;
   vec2 P=normalize(cross(t,vec3(0.,0.,1.)).xy),l=P.yx*vec2(1.,-1.);
   l*=saturate(dot(t,-H))*.8+.2;
   for(int C=-1;C<=1;C++)
     {
       {
         vec2 U=vec2(C+j.x)*s;
         U=U.x*P+U.y*l;
         U*=p*ScreenTexel;
         vec2 B=f.xy+U.xy;
         B=clamp(B,vec2(0.)+ScreenTexel*2.,HalfScreen-ScreenTexel*2.);
         vec4 T=texture2DLod(v,B+c,0);
         vec3 A,L;
         GetBothNormals(B,A,L);
         vec3 E=GetViewPosition(B,GetDepth(B)).xyz,g=E.xyz-d.xyz;
         float D=length(g);
         vec3 V=g/(D+1e-06);
         float M=dot(g,t);
         bool k=M>.05&&Luminance(T.xyz)<Luminance(h.xyz);
         float I=saturate(exp(-abs(M)*100.))*pow(saturate(dot(a,A)),b),q=exp(-(abs(E.z-d.z)*S));
         if(k&&D<1.&&dot(-V,L)>0.)
           I=8./y;
         float K=exp(-G(T.xyz,h,Y)),W=I*K*q;
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
   vec4 x=G(colortex7,texcoord.xy,true,1.,0.,vec2(1.,0.),false,v);
   gl_FragData[0]=x;
 };




/* DRAWBUFFERS:7 */
