#version 330 compatibility


#include "lib/Uniforms.inc"
#include "lib/Common.inc"



attribute vec4 mc_Entity;
attribute vec4 at_tangent;
attribute vec4 mc_midTexCoord;

out vec4 vTexcoord;
out vec4 vColor;
// out vec4 lmcoord;

// out vec3 normal;
out vec4 vViewPos;
out float vMaterialIDs;

out float vMCEntity;
// out float isWater;
// out float isStainedGlass;

out float NfBQQONGIL;		
out float oKoDrswuAC;			
out float GgEUdJcgVD;			
out vec2 iqqNEmzHrA;			

out vec4 zoZckPcbco;		
out vec4 RrnawHBGMh;		
out vec3 MHKfCXtBYe;        



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
   ivec2 x=ivec2(viewWidth,viewHeight);
   int s=x.x*x.y,y=f();
   ivec2 n=ivec2(v.x*x.x,v.y*x.y);
   float z=float(n.y/y),i=float(int(n.x+mod(x.x*z,y))/y);
   i+=floor(x.x*z/y);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(n.x+mod(x.x*z,y),y);
   m.y=mod(n.y,y);
   m.xyz=floor(m.xyz);
   m/=y;
   m.xyz=m.xzy;
   return m;
 }
 vec2 x(vec3 v)
 {
   ivec2 x=ivec2(viewWidth,viewHeight);
   int y=f();
   vec3 i=v.xzy*y;
   i=floor(i+1e-05);
   float s=i.z;
   vec2 n;
   n.x=mod(i.x+s*y,x.x);
   float m=i.x+s*y;
   n.y=i.y+floor(m/x.x)*y;
   n+=.5;
   n/=x;
   return n;
 }
 vec3 n(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 x=ivec2(2048,2048);
   int s=x.x*x.y,y=t();
   ivec2 n=ivec2(i.x*x.x,i.y*x.y);
   float z=float(n.y/y),f=float(int(n.x+mod(x.x*z,y))/y);
   f+=floor(x.x*z/y);
   vec3 m=vec3(0.,0.,f);
   m.x=mod(n.x+mod(x.x*z,y),y);
   m.y=mod(n.y,y);
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
   vec2 n;
   n.x=mod(i.x+s*y,x.x);
   float m=i.x+s*y;
   n.y=i.y+floor(m/x.x)*y;
   n+=.5;
   n/=x;
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
   int x=t();
   v=v-vec3(.5);
   v*=x;
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
 vec3 s(vec3 v)
 {
   int x=f();
   v=v-vec3(.5);
   v*=x;
   return v;
 }
 vec3 d()
 {
   vec3 x=cameraPosition.xyz+.5,v=previousCameraPosition.xyz+.5,y=floor(x-.0001),s=floor(v-.0001);
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
 vec3 d(vec3 v,vec3 m,vec2 x,vec2 y,vec4 n,vec4 i,inout float s,out vec2 f)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(i.x==8||i.x==9||i.x==79||i.x<1.||!r||i.x==20.||i.x==171.||min(abs(m.x),abs(m.z))>.2)
     s=1.;
   if(i.x==50.||i.x==52.||i.x==76.)
     {
       s=0.;
       if(m.y<.5)
         s=1.;
     }
   if(i.x==51||i.x==53)
     s=0.;
   if(i.x>255)
     s=0.;
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
   f=clamp((x.xy-y.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,o=.15;
   if(i.x==10.||i.x==11.)
     {
       if(abs(m.y)<.01&&r||m.y>.99)
         h=.1,o=.1,s=0.;
       else
          s=1.;
     }
   if(i.x==51||i.x==53)
     h=.5,o=.1;
   if(i.x==76)
     h=.2,o=.2;
   if(i.x-255.+39.>=103.&&i.x-255.+39.<=113.)
     o=.025,h=.025;
   z=normalize(n.xyz);
   e=normalize(cross(z,m.xyz)*sign(n.w));
   vec3 G=v.xyz+mix(z*h,-z*h,vec3(f.x));
   G.xyz+=mix(e*h,-e*h,vec3(f.y));
   G.xyz-=m.xyz*o;
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
 void d(in Ray v,in vec3 m[2],out float x,out float i)
 {
   float y,z,s,f;
   x=(m[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   i=(m[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(m[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   z=(m[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   s=(m[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   f=(m[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   x=max(max(x,y),s);
   i=min(min(i,z),f);
 }
 vec3 d(const vec3 v,const vec3 x,vec3 y)
 {
   const float s=1e-05;
   vec3 z=(x+v)*.5,i=(x-v)*.5,m=y-z,f=vec3(0.);
   f+=vec3(sign(m.x),0.,0.)*step(abs(abs(m.x)-i.x),s);
   f+=vec3(0.,sign(m.y),0.)*step(abs(abs(m.y)-i.y),s);
   f+=vec3(0.,0.,sign(m.z))*step(abs(abs(m.z)-i.z),s);
   return normalize(f);
 }
 bool e(const vec3 v,const vec3 m,Ray i,out vec2 y)
 {
   vec3 x=i.inv_direction*(v-i.origin),s=i.inv_direction*(m-i.origin),n=min(s,x),f=max(s,x);
   vec2 r=max(n.xx,n.yz);
   float z=max(r.x,r.y);
   r=min(f.xx,f.yz);
   float e=min(r.x,r.y);
   y.x=z;
   y.y=e;
   return e>max(z,0.);
 }
 bool d(const vec3 v,const vec3 m,Ray i,inout float x,inout vec3 y)
 {
   vec3 s=i.inv_direction*(v-1e-05-i.origin),z=i.inv_direction*(m+1e-05-i.origin),n=min(z,s),f=max(z,s);
   vec2 r=max(n.xx,n.yz);
   float h=max(r.x,r.y);
   r=min(f.xx,f.yz);
   float e=min(r.x,r.y);
   bool G=e>max(h,0.)&&max(h,0.)<x;
   if(G)
     y=d(v-1e-05,m+1e-05,i.origin+i.direction*h),x=h;
   return G;
 }
 vec3 e(vec3 v,vec3 i,vec3 y,vec3 x,int z)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 n=m(v);
   float s=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*s),2).x;
   f*=saturate(dot(i,y));
   {
     vec4 r=texture2DLod(shadowcolor1,n.xy-vec2(0.,.5),4);
     float e=abs(r.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,i,e),o=shadow2DLod(shadowtex0,vec3(n.xy-vec2(0.,.5),n.z+1e-06),4).x;
     f=mix(f,f*h,1.-o);
   }
   f=TintUnderwaterDepth(f);
   return f*(1.-rainStrength);
 }
 vec3 f(vec3 x,vec3 i,vec3 y,vec3 z,int f)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 s=v(x);
   s+=1.;
   s-=Fract01(cameraPosition+.5);
   vec3 n=m(s+y*.99);
   float h=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*h),3).x;
   r*=saturate(dot(i,y));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float e=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*h),3).x;
   vec3 G=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   G*=G;
   r=mix(r,r*G,vec3(1.-e));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 x,vec3 y,vec3 i,int f)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 n=m(v);
   float s=.5;
   vec3 z=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*s),2).x;
   z*=saturate(dot(x,y));
   z=TintUnderwaterDepth(z);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float r=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*s),3).x;
   vec3 e=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   e*=e;
   z=mix(z,z*e,vec3(1.-r));
   #endif
   return z*(1.-rainStrength);
 }struct CPrmwMXxJc{float pzBOsrqcFy;float ivaOqoXyFu;float OxTKjfMYEH;float avjkUoKnfB;vec3 PVAMAgODVh;};
 vec4 G(CPrmwMXxJc v)
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
 CPrmwMXxJc i(vec4 v)
 {
   CPrmwMXxJc i;
   vec2 x=UnpackTwo16BitFrom32Bit(v.y),n=UnpackTwo16BitFrom32Bit(v.z),y=UnpackTwo16BitFrom32Bit(v.w);
   i.pzBOsrqcFy=v.x;
   i.OxTKjfMYEH=x.y;
   i.avjkUoKnfB=n.y;
   i.ivaOqoXyFu=y.y*255.;
   i.PVAMAgODVh=pow(vec3(x.x,n.x,y.x),vec3(8.));
   return i;
 }
 CPrmwMXxJc w(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),y=vec2(viewWidth,viewHeight);
   v=(floor(v*y)+.5)*x;
   return i(texture2DLod(colortex5,v,0));
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
 bool G(vec3 v,float x,Ray y,bool m,inout float i,inout vec3 f)
 {
   bool s=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(m)
     return false;
   if(x>=67.)
     return false;
   r=d(v,v+vec3(1.,1.,1.),y,i,f);
   s=r;
   #else
   if(x<40.)
     return r=d(v,v+vec3(1.,1.,1.),y,i,f),r;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float z=.5;
       if(x==41.)
         z=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,z,1.),y,i,f);
       s=s||r;
     }
   if(x==42.||x>=55.&&x<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),y,i,f),s=s||r;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float z=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         z=0.;
       r=d(v+vec3(0.,z,0.),v+vec3(.5,.5+z,.5),y,i,f);
       s=s||r;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float z=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         z=0.;
       r=d(v+vec3(.5,z,0.),v+vec3(1.,.5+z,.5),y,i,f);
       s=s||r;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float z=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         z=0.;
       r=d(v+vec3(.5,z,.5),v+vec3(1.,.5+z,1.),y,i,f);
       s=s||r;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float z=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         z=0.;
       r=d(v+vec3(0.,z,.5),v+vec3(.5,.5+z,1.),y,i,f);
       s=s||r;
     }
   if(x>=67.&&x<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,y,i,f),s=s||r;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float z=8.,n=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         z=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         n=16.;
       r=d(v+vec3(z,6.,7.)/16.,v+vec3(n,9.,9.)/16.,y,i,f);
       s=s||r;
       r=d(v+vec3(z,12.,7.)/16.,v+vec3(n,15.,9.)/16.,y,i,f);
       s=s||r;
     }
   if(x>=71.&&x<=82.)
     {
       float z=8.,n=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         n=16.;
       if(x>=75.&&x<=82.)
         z=0.;
       r=d(v+vec3(7.,6.,z)/16.,v+vec3(9.,9.,n)/16.,y,i,f);
       s=s||r;
       r=d(v+vec3(7.,12.,z)/16.,v+vec3(9.,15.,n)/16.,y,i,f);
       s=s||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(x>=83.&&x<=86.)
     {
       vec3 z=vec3(0),n=vec3(0);
       if(x==83.)
         z=vec3(0,0,0),n=vec3(16,16,3);
       if(x==84.)
         z=vec3(0,0,13),n=vec3(16,16,16);
       if(x==86.)
         z=vec3(0,0,0),n=vec3(3,16,16);
       if(x==85.)
         z=vec3(13,0,0),n=vec3(16,16,16);
       r=d(v+z/16.,v+n/16.,y,i,f);
       s=s||r;
     }
   if(x>=87.&&x<=102.)
     {
       vec3 z=vec3(0.),n=vec3(1.);
       if(x>=87.&&x<=94.)
         {
           float h=0.;
           if(x>=91.&&x<=94.)
             h=13.;
           z=vec3(0.,h,0.)/16.;
           n=vec3(16.,h+3.,16.)/16.;
         }
       if(x>=95.&&x<=98.)
         {
           float h=13.;
           if(x==97.||x==98.)
             h=0.;
           z=vec3(0.,0.,h)/16.;
           n=vec3(16.,16.,h+3.)/16.;
         }
       if(x>=99.&&x<=102.)
         {
           float h=13.;
           if(x==99.||x==100.)
             h=0.;
           z=vec3(h,0.,0.)/16.;
           n=vec3(h+3.,16.,16.)/16.;
         }
       r=d(v+z,v+n,y,i,f);
       s=s||r;
     }
   if(x>=103.&&x<=113.)
     {
       vec3 z=vec3(0.),n=vec3(1.);
       if(x>=103.&&x<=110.)
         {
           float e=float(x)-float(103.)+1.;
           n.y=e*2./16.;
         }
       if(x==111.)
         n.y=.0625;
       if(x==112.)
         z=vec3(1.,0.,1.)/16.,n=vec3(15.,1.,15.)/16.;
       if(x==113.)
         z=vec3(1.,0.,1.)/16.,n=vec3(15.,.5,15.)/16.;
       r=d(v+z,v+n,y,i,f);
       s=s||r;
     }
   #endif
   #endif
   return s;
 }
 vec3 h(vec2 x)
 {
   vec2 v=vec2(x.xy*vec2(viewWidth,viewHeight));
   v*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(x.x<2./viewWidth||x.x>1.-2./viewWidth||x.y<2./viewHeight||x.y>1.-2./viewHeight)
     ;
   v=(floor(v*64.)+.5)/64.;
   vec3 r=texture2D(noisetex,v).xyz,y=vec3(sqrt(.2),sqrt(2.),1.61803);
   r=mod(r+float(frameCounter%64)*y,vec3(1.));
   return r;
 }
 vec4 G(vec3 x,vec2 v,out float i,inout float z)
 {
   vec3 y=x;
   int s=t();
   x=clamp(x,vec3(1./s),vec3(1.-1./s));
   if(distance(x,y)>.005/s)
     z=1.;
   float r=dot(abs(x-y),vec3(1.));
   #ifdef MC_GL_VENDOR_ATI
   #endif
   vec2 m=d(x,s);
   m+=v.xy*(1./vec2(4096));
   m=m*2.-1.;
   i=r;
   return vec4(m,i,1.);
 }
 void main()
 {
   gl_Position=ftransform();
   vTexcoord=gl_MultiTexCoord0;
   vMCEntity=mc_Entity.x;
   vViewPos=gl_ModelViewMatrix*gl_Vertex;
   vec4 v=gl_Position;
   v=shadowProjectionInverse*v;
   v=shadowModelViewInverse*v;
   v.xyz+=cameraPosition.xyz;
   vec3 x=v.xyz;
   vMaterialIDs=30.;
   float z=0.,s=0.f,i=0.f;
   if(mc_Entity.x==8||mc_Entity.x==9)
     z=1.f;
   if(mc_Entity.x==95||mc_Entity.x==160||mc_Entity.x==90||mc_Entity.x==165||mc_Entity.x==79)
     i=1.f;
   if(mc_Entity.x==79)
     s=1.f;
   if(mc_Entity.x==18.||mc_Entity.x==161.f)
     vMaterialIDs=36.;
   if(mc_Entity.x==79.f||mc_Entity.x==174.f)
     vMaterialIDs=37.;
   if(mc_Entity.x==50||mc_Entity.x==52||mc_Entity.x==76)
     vMaterialIDs=241.;
   if(mc_Entity.x==10||mc_Entity.x==11)
     vMaterialIDs=241.;
   if(mc_Entity.x==89||mc_Entity.x==124||mc_Entity.x==10||mc_Entity.x==11||mc_Entity.x==169||mc_Entity.x==91)
     vMaterialIDs=31.;
   if(mc_Entity.x==51||mc_Entity.x==53)
     vMaterialIDs=241.;
   #ifdef GLOWING_LAPIS_LAZULI_BLOCK
   if(mc_Entity.x==22)
     vMaterialIDs=31.;
   #endif
   #ifdef GLOWING_REDSTONE_BLOCK
   if(mc_Entity.x==152)
     vMaterialIDs=31.;
   #endif
   #ifdef GLOWING_EMERALD_BLOCK
   if(mc_Entity.x==133)
     vMaterialIDs=31.;
   #endif
   if(mc_Entity.x==95||mc_Entity.x==160)
     vMaterialIDs=240.;
   if(mc_Entity.x==188)
     vMaterialIDs=32.;
   if(mc_Entity.x==189)
     vMaterialIDs=33.;
   if(mc_Entity.x==190)
     vMaterialIDs=34.;
   if(mc_Entity.x==191)
     vMaterialIDs=35.;
   vec3 y=gl_Normal,r=normalize(gl_NormalMatrix*y);
   if(abs(vMaterialIDs-2.)<.1)
     y=vec3(0.,1.,0.);
   iqqNEmzHrA=mc_midTexCoord.xy;
   vColor=gl_Color;
   NfBQQONGIL=0.;
   {
     vec2 f;
     vec3 m=d(v.xyz,gl_Normal.xyz,vTexcoord.xy,mc_midTexCoord.xy,at_tangent,mc_Entity,NfBQQONGIL,f);
     if(mc_Entity.x>255)
       vMaterialIDs=mc_Entity.x-255.+39.;
     m=floor(m);
     m-=cameraPosition.xyz;
     int h=t();
     m=n(m,h);
     MHKfCXtBYe=m*h;
     zoZckPcbco=G(m,f,GgEUdJcgVD,NfBQQONGIL);
     if(mc_Entity.x==51||mc_Entity.x==53||mc_Entity.x==50||mc_Entity.x==52||mc_Entity.x==76)
       GgEUdJcgVD+=.9;
   }
   {
     v.xyz-=cameraPosition.xyz;
     v=shadowModelView*v;
     v=shadowProjection*v;
     gl_Position=v;
     float f=sqrt(gl_Position.x*gl_Position.x+gl_Position.y*gl_Position.y),e=1.f-SHADOW_MAP_BIAS+f*SHADOW_MAP_BIAS;
     gl_Position.xy*=.95f/e;
     gl_Position.xy*=.5;
     gl_Position.xy+=.5;
     if(z>.5)
       gl_Position.y-=1.;
     if(i>.5)
       gl_Position.x-=1.;
     gl_Position.z=mix(gl_Position.z,.5,.8);
     RrnawHBGMh=gl_Position;
     gl_FrontColor=gl_Color;
   }
 };



