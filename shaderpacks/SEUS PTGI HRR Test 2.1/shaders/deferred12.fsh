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

/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////











const int 		shadowMapResolution 	= 4096;
const float 	shadowDistance 			= 120.0; // Shadow distance. Set lower if you prefer nicer close shadows. Set higher if you prefer nicer distant shadows. [80.0 120.0 180.0 240.0]
const float 	shadowIntervalSize 		= 1.0f;
const bool 		shadowHardwareFiltering0 = true;

const bool 		shadowtexMipmap = true;
const bool 		shadowtex1Mipmap = false;
const bool 		shadowtex1Nearest = false;
const bool 		shadowcolor0Mipmap = false;
const bool 		shadowcolor0Nearest = false;
const bool 		shadowcolor1Mipmap = false;
const bool 		shadowcolor1Nearest = false;

const float shadowDistanceRenderMul = 1.0f;

const int 		RGB8 					= 0;
const int 		RGBA8 					= 0;
const int 		RGBA16 					= 0;
const int 		RGBA16F 				= 0;
const int 		RGBA32F 				= 0;
const int 		RG16 					= 0;
const int 		RGB16 					= 0;
const int 		R11F_G11F_B10F 			= 0;
const int 		colortex0Format 			= RGBA8;
const int 		colortex1Format 			= RGBA16;
const int 		colortex2Format 			= RGBA16;
const int 		colortex3Format 			= RGBA16;
const int 		colortex4Format 			= RGBA32F;
const int 		colortex5Format 			= RGBA32F;
const int 		colortex6Format 			= RGBA32F;
const int 		colortex7Format 			= RGBA16F;

const bool colortex3Clear = false;
const bool colortex4Clear = false;
const bool colortex5Clear = false;
const bool colortex6Clear = false;

const int 		superSamplingLevel 		= 0;

const float		sunPathRotation 		= -40.0f;

const int 		noiseTextureResolution  = 64;

const float 	ambientOcclusionLevel 	= 0.06f;



const float wetnessHalflife = 100.0;
const float drynessHalflife = 100.0;




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




/////////////////////////STRUCTS///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////STRUCTS///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#include "lib/GBufferData.inc"






/////////////////////////STRUCT FUNCTIONS//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////STRUCT FUNCTIONS//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




vec2 Texcoord;





vec3 WorldPosToShadowProjPosBias(vec3 worldPos, vec3 worldNormal, out float dist, out float distortFactor)
{
	vec3 sn = normalize((shadowModelView * vec4(worldNormal.xyz, 0.0)).xyz) * vec3(1, 1, -1);

	vec4 sp = (shadowModelView * vec4(worldPos, 1.0));
	sp = shadowProjection * sp;
	sp /= sp.w;

	dist = sqrt(sp.x * sp.x + sp.y * sp.y);
	distortFactor = (1.0f - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;

	sp.xyz += sn * 0.002 * distortFactor;
	sp.xy *= 0.95f / distortFactor;
	sp.z = mix(sp.z, 0.5, 0.8);
	sp = sp * 0.5f + 0.5f;		//Transform from shadow space to shadow map coordinates


	//move to quadrant
	sp.xy *= 0.5;
	sp.xy += 0.5;

	return sp.xyz;
}

vec3 CalculateSunlightVisibility(vec4 screenSpacePosition, MaterialMask OmcxSfXfkJ, vec3 worldGeoNormal, 
	float parallaxOffset) 
{
	// if (rainStrength >= 0.99f)
		// return vec3(1.0f);



	//if (shadingStruct.directionect > 0.0f) {
		float distance = sqrt(  screenSpacePosition.x * screenSpacePosition.x 	//Get surface distance in meters
							  + screenSpacePosition.y * screenSpacePosition.y
							  + screenSpacePosition.z * screenSpacePosition.z);

		vec4 ssp = screenSpacePosition;

		// if (isEyeInWater > 0.5)
		// {
		// 	ssp.xy *= 0.82;
		// }

		vec3 worldPos = (gbufferModelViewInverse * ssp).xyz;

		// worldPos += worldGeoNormal * 0.04;

		if (OmcxSfXfkJ.grass > 0.5)
		{
			worldGeoNormal.xyz = vec3(0, 1, 0);
		}


		float dist;
		float distortFactor;
		vec3 shadowProjPos = WorldPosToShadowProjPosBias(worldPos.xyz, worldGeoNormal, dist, distortFactor);

		// float fademult = 0.15f;
			// shadowMult = clamp((shadowDistance * 1.4f * fademult) - (distance * fademult), 0.0f, 1.0f);	//Calculate shadowMult to fade shadows out

		float shadowMult = 1.0;

		float shading = 0.0;
		vec3 result = vec3(0.0);

		if (shadowMult > 0.0) 
		{

			float diffthresh = dist * 1.0f + 0.10f;
				  diffthresh *= 2.0f / (shadowMapResolution / 2048.0f);
			// diffthresh = 0.0;
				  //diffthresh /= shadingStruct.directionect + 0.1f;


			// shadowProjPos.xyz += shadowNormal * 0.0004 * (dist + 0.5);




			float vpsSpread = 0.105 / distortFactor;

			float avgDepth = 0.0;
			float minDepth = 11.0;
			int c;

			for (int i = -1; i <= 1; i++)
			{
				for (int j = -1; j <= 1; j++)
				{
					vec2 lookupCoord = shadowProjPos.xy + (vec2(i, j) / shadowMapResolution) * 8.0 * vpsSpread;
					//avgDepth += pow(texture2DLod(shadowtex1, lookupCoord, 2).x, 4.1);
					float depthSample = texture2DLod(shadowtex1, lookupCoord, 2).x;
					minDepth = min(minDepth, depthSample);
					avgDepth += pow(min(max(0.0, shadowProjPos.z - depthSample) * 1.0, 0.025), 2.0);
					c++;
				}
			}

			avgDepth /= c;
			avgDepth = pow(avgDepth, 1.0 / 2.0);

			// float penumbraSize = min(abs(shadowProjPos.z - minDepth), 0.15);
			float penumbraSize = avgDepth;

			//if (OmcxSfXfkJ.leaves > 0.5)
			//{
				//penumbraSize = 0.02;
			//}

			int count = 0;
			float spread = penumbraSize * 0.055 * vpsSpread + 0.55 / shadowMapResolution;


			vec3 noise = BlueNoiseTemporal(Texcoord.st);

			diffthresh *= 0.5 + avgDepth * 50.0;
			// diffthresh *= 20.0;



			const int latSamples = 5;
			const int lonSamples = 5;

			// shadowProjPos.xyz += shadowNormal * diffthresh * 0.001;
			// shadowProjPos.xyz += shadowNormal * diffthresh * 0.001;

			float dfs = 0.00022 * dist + (noise.z * 0.00005) + 0.00002 + avgDepth * 0.012 + 0.0002 * parallaxOffset;

			for (int i = 0; i < 25; i++)
			{
				float fi = float(i + noise.x) * 0.1;
				float r = float(i + noise.x) * 3.14159265 * 2.0 * 1.61;

				vec2 radialPos = vec2(cos(r), sin(r));
				vec2 coordOffset = radialPos * spread * sqrt(fi) * 2.0;

				
				// shading += shadow2DLod(shadowtex0, vec3(shadowProjPos.st + coordOffset, shadowProjPos.z - 0.0012f * diffthresh - (noise.z * 0.00005)), 0).x;
				shading += shadow2DLod(shadowtex0, vec3(shadowProjPos.st + coordOffset, shadowProjPos.z - dfs), 0).x;
				count += 1;
			}
			shading /= count;

			shading = saturate(shading * (1.0 + avgDepth 
					* 5.0 
					* (1.0 / (abs(dot(worldGeoNormal, worldLightVector)) + 0.001))
					));

			result = vec3(shading);


			// stained glass shadow
			{
				float stainedGlassShadow = shadow2DLod(shadowtex0, vec3(shadowProjPos.st - vec2(0.5, 0.0), shadowProjPos.z - 0.0012 * diffthresh), 2).x;
				vec3 stainedGlassColor = texture2DLod(shadowcolor, vec2(shadowProjPos.st - vec2(0.5, 0.0)), 2).rgb;
				stainedGlassColor *= stainedGlassColor;
				result = mix(result, result * stainedGlassColor, vec3(1.0 - stainedGlassShadow));

				// result = mix(result, vec3(0.0), vec3(1.0 - stainedGlassShadow));
			}

			// CAUSTICS
			// water shadow (caustics)
			{
				// float waterDepth = abs(texture2DLod(shadowcolor1, shadowProjPos.st - vec2(0.0, 0.5), 4).x * 256.0 - (worldPos.y + cameraPosition.y));
				float waterDepth = abs(texture2DLod(shadowcolor1, shadowProjPos.st - vec2(0.0, 0.5), 3).x * 256.0 - (worldPos.y + cameraPosition.y));

				// float caustics = GetCausticsDeferred(worldPos, waterDepth);
				vec3 caustics = vec3(0.0);
				caustics.r = GetCausticsDeferred(worldPos, 										worldLightVector, waterDepth);
				// caustics.g = GetCausticsDeferred(worldPos + vec3(0.003 * waterDepth, 0.0, 0.0), worldLightVector, waterDepth);
				// caustics.b = GetCausticsDeferred(worldPos + vec3(0.006 * waterDepth, 0.0, 0.0), worldLightVector, waterDepth);
				caustics.g = caustics.r;
				caustics.b = caustics.r;

				float waterShadow = shadow2DLod(shadowtex0, vec3(shadowProjPos.st - vec2(0.0, 0.5), shadowProjPos.z - 0.0012 * diffthresh - noise.z * 0.0001), 3).x;
				result = mix(result, 
					// result * caustics * exp(-GetWaterAbsorption() * waterDepth), 
					result * caustics, 
					vec3(1.0 - waterShadow));
			}
		}



		result = mix(vec3(1.0), result, shadowMult);





		return result;
	//} else {
	//	return vec3(0.0f);
	//}
}


vec3 SubsurfaceScatteringSunlight(vec3 worldNormal, vec3 worldPos, vec3 albedo)
{
	vec4 shadowProjPos = shadowModelView * vec4(worldPos.xyz, 1.0);	//Transform from world space to shadow space
	shadowProjPos = shadowProjection * shadowProjPos;
	shadowProjPos /= shadowProjPos.w;

	float dist = sqrt(shadowProjPos.x * shadowProjPos.x + shadowProjPos.y * shadowProjPos.y);
	float distortFactor = (1.0f - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;
	shadowProjPos.xy *= 0.95f / distortFactor;
	shadowProjPos.z = mix(shadowProjPos.z, 0.5, 0.8);
	shadowProjPos = shadowProjPos * 0.5f + 0.5f;		//Transform from shadow space to shadow map coordinates

	//move to quadrant
	shadowProjPos.xy *= 0.5;
	shadowProjPos.xy += 0.5;

	float subsurfaceDepth = 0.0;
	float depthThresh = 0.0005;
	float weights = 0.0;

	vec2 dither = BlueNoiseTemporal(Texcoord.st).xy - 0.5;

	for (int i = -1; i <= 1; i++)
	{
		for (int j = -1; j <= 1; j++)
		{
			vec2 coordOffset = vec2(i + dither.x, j + dither.y) * 0.001;
			subsurfaceDepth += max(0.0, (shadowProjPos.z - texture2DLod(shadowtex1, shadowProjPos.xy + coordOffset, 0).x) / depthThresh);
			weights += 1.0;
		}
	}

	subsurfaceDepth /= weights;

	// subsurfaceDepth = exp(-subsurfaceDepth * 10.0);

	vec3 subsurfaceColor = 1.0 - (normalize(albedo.rgb + 0.000001) * 0.3);
	// vec3 subsurfaceColor = 1.0 - (albedo.rgb * 0.5);
	// vec3 subsurfaceColor = 1.0 - (albedo.rgb * 0.8);
	// vec3 subsurfaceColor = 1.0 - vec3(0.7, 0.5, 0.1);
	vec3 sss = exp(-subsurfaceDepth * subsurfaceColor * 6.0) * (1.0 - subsurfaceColor);

	return sss * 24.0 * colorSunlight;
}


float ScreenSpaceShadow(vec3 origin, float depth, vec3 viewDir, vec3 normal, MaterialMask OmcxSfXfkJ)
{
	if (OmcxSfXfkJ.sky > 0.5)
	{
		return 1.0;
	}
	


	float fov = 2.0*atan( 1.0/gbufferProjection[1][1] ) * 180.0 / 3.14159265;

	vec3 rayPos = origin;
	vec3 rayDir = lightVector 
		* -origin.z
		* 0.000035 * fov
		;


	float NdotL = saturate(dot(lightVector, normal));

	if (OmcxSfXfkJ.grass < 0.5 && OmcxSfXfkJ.leaves < 0.5) 
	{
		rayPos += normal * 0.00001 * -origin.z * fov * 0.15;
		rayPos += rayDir * 13000.0 * min(ScreenTexel.x, ScreenTexel.y) * 0.15;
		// rayPos += rayDir * 2.0;
	}


	float randomness = rand(Texcoord.st + sin(frameTimeCounter)).x;


	float zThickness = 0.025 * -origin.z;
	float shadow = 1.0;
	float numSamplesf = 64.0;
	int numSamples = int(numSamplesf);
	float absorption = 0.0;
	if (OmcxSfXfkJ.grass > 0.5)
	{
		absorption = 0.5;
	}
	if (OmcxSfXfkJ.leaves > 0.5)
	{
		absorption = 0.85;
	}
	absorption = pow(absorption, sqrt(length(origin)) * 0.5);



	float ds = 1.0;
	for (int i = 0; i < 12; i++)
	{
		float fi = float(i) / float(12);
		
		rayPos += rayDir * ds;
		ds += 0.3;

		vec3 thisRayPos = rayPos + rayDir * randomness * ds;

		vec2 rayProjPos = ProjectBack(thisRayPos).xy;

		rayProjPos *= 0.5;
		TemporalJitterProjPos01(rayProjPos);
		rayProjPos *= 2.0;
		
		vec3 samplePos = GetViewPositionNoJitter(rayProjPos.xy, GetDepth(DownscaleTexcoord(rayProjPos.xy))).xyz; // half res rendering fix

		float depthDiff = samplePos.z - thisRayPos.z;

		if (depthDiff > 0.0 && depthDiff < zThickness
		)
		{
			shadow *= absorption;
		}
	}

	return shadow;




































}


float OrenNayar(vec3 normal, vec3 eyeDir, vec3 lightDir)
{
	const float PI = 3.14159;
	const float roughness = 0.55;

	// interpolating normals will change the length of the normal, so renormalize the normal.



	// normal = normalize(normal + surface.lightVector * pow(clamp(dot(eyeDir, surface.lightVector), 0.0, 1.0), 5.0) * 0.5);

	// normal = normalize(normal + eyeDir * clamp(dot(normal, eyeDir), 0.0f, 1.0f));

	// calculate intermediary values
	float NdotL = dot(normal, lightDir);
	float NdotV = dot(normal, eyeDir);

	float angleVN = acos(NdotV);
	float angleLN = acos(NdotL);

	float alpha = max(angleVN, angleLN);
	float beta = min(angleVN, angleLN);
	float gamma = dot(eyeDir - normal * dot(eyeDir, normal), lightDir - normal * dot(lightDir, normal));

	float roughnessSquared = roughness * roughness;

	// calculate A and B
	float A = 1.0 - 0.5 * (roughnessSquared / (roughnessSquared + 0.57));

	float B = 0.45 * (roughnessSquared / (roughnessSquared + 0.09));

	float C = sin(alpha) * tan(beta);

	// put it all together
	float L1 = max(0.0, NdotL) * (A + B * max(0.0, gamma) * C);

	//return max(0.0f, surface.NdotL * 0.99f + 0.01f);
	return clamp(L1, 0.0f, 1.0f);
}





float GetCoverage(in float coverage, in float density, in float clouds)
{
	clouds = clamp(clouds - (1.0f - coverage), 0.0f, 1.0f -density) / (1.0f - density);
		clouds = max(0.0f, clouds * 1.1f - 0.1f);
	 clouds = clouds = clouds * clouds * (3.0f - 2.0f * clouds);
	 // clouds = pow(clouds, 1.0f);
	return clouds;
}

float   CalculateSunglow(vec3 npos, vec3 lightVector) {

	float curve = 4.0f;

	vec3 halfVector2 = normalize(-lightVector + npos);
	float factor = 1.0f - dot(halfVector2, npos);

	return factor * factor * factor * factor;
}

float G1V(float dotNV, float k)
{
	return 1.0 / (dotNV * (1.0 - k) + k);
}

vec3 SpecularGGX(vec3 N, vec3 V, vec3 L, float roughness, float F0)
{
	float alpha = roughness * roughness;

	vec3 H = normalize(V + L);

	float dotNL = saturate(dot(N, L));
	float dotNV = saturate(dot(N, V));
	float dotNH = saturate(dot(N, H));
	float dotLH = saturate(dot(L, H));

	float F, D, vis;

	float alphaSqr = alpha * alpha;
	float pi = 3.14159265359;
	float denom = dotNH * dotNH * (alphaSqr - 1.0) + 1.0;
	D = alphaSqr / (pi * denom * denom);

	float dotLH5 = pow(1.0f - dotLH, 5.0);
	F = F0 + (1.0 - F0) * dotLH5;

	float k = alpha / 2.0;
	vis = G1V(dotNL, k) * G1V(dotNV, k);

	vec3 specular = vec3(dotNL * D * F * vis) * colorSunlight;

	//specular = vec3(0.1);
	#ifndef PHYSICALLY_BASED_MAX_ROUGHNESS
	specular *= saturate(pow(1.0 - roughness, 0.7) * 2.0);
	#endif


	return specular;
}




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
   ivec2 s=ivec2(viewWidth,viewHeight);
   int x=s.x*s.y,z=f();
   ivec2 n=ivec2(v.x*s.x,v.y*s.y);
   float y=float(n.y/z),i=float(int(n.x+mod(s.x*y,z))/z);
   i+=floor(s.x*y/z);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(n.x+mod(s.x*y,z),z);
   m.y=mod(n.y,z);
   m.xyz=floor(m.xyz);
   m/=z;
   m.xyz=m.xzy;
   return m;
 }
 vec2 v(vec3 v)
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
   ivec2 s=ivec2(2048,2048);
   int x=s.x*s.y,z=t();
   ivec2 n=ivec2(i.x*s.x,i.y*s.y);
   float y=float(n.y/z),f=float(int(n.x+mod(s.x*y,z))/z);
   f+=floor(s.x*y/z);
   vec3 m=vec3(0.,0.,f);
   m.x=mod(n.x+mod(s.x*y,z),z);
   m.y=mod(n.y,z);
   m.xyz=floor(m.xyz);
   m/=z;
   m.xyz=m.xzy;
   return m;
 }
 vec2 d(vec3 v,int z)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 i=v.xzy*z;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 n;
   n.x=mod(i.x+x*z,m.x);
   float s=i.x+x*z;
   n.y=i.y+floor(s/m.x)*z;
   n+=.5;
   n/=m;
   n.xy*=.5;
   return n;
 }
 vec3 f(vec3 v,int z)
 {
   return v*=1./z,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 n(vec3 v,int z)
 {
   return v*=1./z,v=v+vec3(.5),v;
 }
 vec3 m(vec3 v)
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
 vec3 x(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 d()
 {
   vec3 v=cameraPosition.xyz+.5,i=previousCameraPosition.xyz+.5,x=floor(v-.0001),z=floor(i-.0001);
   return x-z;
 }
 vec3 r(vec3 v)
 {
   vec4 i=vec4(v,1.);
   i=shadowModelView*i;
   i=shadowProjection*i;
   i/=i.w;
   float x=sqrt(i.x*i.x+i.y*i.y),z=1.f-SHADOW_MAP_BIAS+x*SHADOW_MAP_BIAS;
   i.xy*=.95f/z;
   i.z=mix(i.z,.5,.8);
   i=i*.5f+.5f;
   i.xy*=.5;
   i.xy+=.5;
   return i.xyz;
 }
 vec3 d(vec3 v,vec3 i,vec2 n,vec2 z,vec4 s,vec4 m,inout float x,out vec2 f)
 {
   bool y=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   y=!y;
   if(m.x==8||m.x==9||m.x==79||m.x<1.||!y||m.x==20.||m.x==171.||min(abs(i.x),abs(i.z))>.2)
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
   f=clamp((n.xy-z.xy)*100000.,vec2(0.),vec2(1.));
   float h=.15,w=.15;
   if(m.x==10.||m.x==11.)
     {
       if(abs(i.y)<.01&&y||i.y>.99)
         h=.1,w=.1,x=0.;
       else
          x=1.;
     }
   if(m.x==51||m.x==53)
     h=.5,w=.1;
   if(m.x==76)
     h=.2,w=.2;
   if(m.x-255.+39.>=103.&&m.x-255.+39.<=113.)
     w=.025,h=.025;
   r=normalize(s.xyz);
   c=normalize(cross(r,i.xyz)*sign(s.w));
   vec3 o=v.xyz+mix(r*h,-r*h,vec3(f.x));
   o.xyz+=mix(c*h,-c*h,vec3(f.y));
   o.xyz-=i.xyz*w;
   return o;
 }struct SPcacsgCKo{vec3 GadGLQcpqX;vec3 GadGLQcpqXOrigin;vec3 vAdYwconYe;vec3 AZVxALDdtL;vec3 UekatYTTmj;vec3 OmcxSfXfkJ;};
 SPcacsgCKo e(Ray v)
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
 void d(in Ray v,in vec3 i[2],out float x,out float z)
 {
   float y,r,f,n;
   x=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   z=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   y=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   f=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   n=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   x=max(max(x,y),f);
   z=min(min(z,r),n);
 }
 vec3 d(const vec3 v,const vec3 i,vec3 z)
 {
   const float x=1e-05;
   vec3 y=(i+v)*.5,m=(i-v)*.5,s=z-y,f=vec3(0.);
   f+=vec3(sign(s.x),0.,0.)*step(abs(abs(s.x)-m.x),x);
   f+=vec3(0.,sign(s.y),0.)*step(abs(abs(s.y)-m.y),x);
   f+=vec3(0.,0.,sign(s.z))*step(abs(abs(s.z)-m.z),x);
   return normalize(f);
 }
 bool e(const vec3 v,const vec3 i,Ray m,out vec2 n)
 {
   vec3 x=m.inv_direction*(v-m.origin),z=m.inv_direction*(i-m.origin),s=min(z,x),c=max(z,x);
   vec2 f=max(s.xx,s.yz);
   float y=max(f.x,f.y);
   f=min(c.xx,c.yz);
   float h=min(f.x,f.y);
   n.x=y;
   n.y=h;
   return h>max(y,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 z)
 {
   vec3 y=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(i+1e-05-m.origin),n=min(s,y),f=max(s,y);
   vec2 r=max(n.xx,n.yz);
   float h=max(r.x,r.y);
   r=min(f.xx,f.yz);
   float c=min(r.x,r.y);
   bool t=c>max(h,0.)&&max(h,0.)<x;
   if(t)
     z=d(v-1e-05,i+1e-05,m.origin+m.direction*h),x=h;
   return t;
 }
 vec3 e(vec3 v,vec3 i,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 m=r(v);
   float n=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*n),2).x;
   f*=saturate(dot(i,z));
   {
     vec4 s=texture2DLod(shadowcolor1,m.xy-vec2(0.,.5),4);
     float c=abs(s.x*256.-(v.y+cameraPosition.y)),h=GetCausticsComposite(v,i,c),w=shadow2DLod(shadowtex0,vec3(m.xy-vec2(0.,.5),m.z+1e-06),4).x;
     f=mix(f,f*h,1.-w);
   }
   f=TintUnderwaterDepth(f);
   return f*(1.-rainStrength);
 }
 vec3 f(vec3 v,vec3 i,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 f=m(v);
   f+=1.;
   f-=Fract01(cameraPosition+.5);
   vec3 s=r(f+z*.99);
   float n=.5;
   vec3 c=vec3(1.)*shadow2DLod(shadowtex0,vec3(s.xy,s.z-.0006*n),3).x;
   c*=saturate(dot(i,z));
   c=TintUnderwaterDepth(c);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float h=shadow2DLod(shadowtex0,vec3(s.xy-vec2(.5,0.),s.z-.0006*n),3).x;
   vec3 t=texture2DLod(shadowcolor,vec2(s.xy-vec2(.5,0.)),3).xyz;
   t*=t;
   c=mix(c,c*t,vec3(1.-h));
   #endif
   return c*(1.-rainStrength);
 }
 vec3 m(vec3 v,vec3 i,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 m=r(v);
   float n=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*n),2).x;
   f*=saturate(dot(i,z));
   f=TintUnderwaterDepth(f);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float h=shadow2DLod(shadowtex0,vec3(m.xy-vec2(.5,0.),m.z-.0006*n),3).x;
   vec3 s=texture2DLod(shadowcolor,vec2(m.xy-vec2(.5,0.)),3).xyz;
   s*=s;
   f=mix(f,f*s,vec3(1.-h));
   #endif
   return f*(1.-rainStrength);
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
   vec2 x=1./vec2(viewWidth,viewHeight),z=vec2(viewWidth,viewHeight);
   v=(floor(v*z)+.5)*x;
   return w(texture2DLod(colortex5,v,0));
 }
 float e(float v,float z)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+z,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool d(vec3 v,float x,Ray z,bool i,inout float f,inout vec3 y)
 {
   bool m=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(i)
     return false;
   if(x>=67.)
     return false;
   r=d(v,v+vec3(1.,1.,1.),z,f,y);
   m=r;
   #else
   if(x<40.)
     return r=d(v,v+vec3(1.,1.,1.),z,f,y),r;
   if(x==40.||x==41.||x>=43.&&x<=54.)
     {
       float s=.5;
       if(x==41.)
         s=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,s,1.),z,f,y);
       m=m||r;
     }
   if(x==42.||x>=55.&&x<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),z,f,y),m=m||r;
   if(x==43.||x==46.||x==47.||x==52.||x==53.||x==54.||x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
     {
       float s=.5;
       if(x==55.||x==58.||x==59.||x==64.||x==65.||x==66.)
         s=0.;
       r=d(v+vec3(0.,s,0.),v+vec3(.5,.5+s,.5),z,f,y);
       m=m||r;
     }
   if(x==43.||x==45.||x==48.||x==51.||x==53.||x==54.||x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
     {
       float s=.5;
       if(x==55.||x==57.||x==60.||x==63.||x==65.||x==66.)
         s=0.;
       r=d(v+vec3(.5,s,0.),v+vec3(1.,.5+s,.5),z,f,y);
       m=m||r;
     }
   if(x==44.||x==45.||x==49.||x==51.||x==52.||x==54.||x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
     {
       float s=.5;
       if(x==56.||x==57.||x==61.||x==63.||x==64.||x==66.)
         s=0.;
       r=d(v+vec3(.5,s,.5),v+vec3(1.,.5+s,1.),z,f,y);
       m=m||r;
     }
   if(x==44.||x==46.||x==50.||x==51.||x==52.||x==53.||x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
     {
       float s=.5;
       if(x==56.||x==58.||x==62.||x==63.||x==64.||x==65.)
         s=0.;
       r=d(v+vec3(0.,s,.5),v+vec3(.5,.5+s,1.),z,f,y);
       m=m||r;
     }
   if(x>=67.&&x<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,z,f,y),m=m||r;
   if(x==68.||x==69.||x==70.||x==72.||x==73.||x==74.||x==76.||x==77.||x==78.||x==80.||x==81.||x==82.)
     {
       float s=8.,c=8.;
       if(x==68.||x==70.||x==72.||x==74.||x==76.||x==78.||x==80.||x==82.)
         s=0.;
       if(x==69.||x==70.||x==73.||x==74.||x==77.||x==78.||x==81.||x==82.)
         c=16.;
       r=d(v+vec3(s,6.,7.)/16.,v+vec3(c,9.,9.)/16.,z,f,y);
       m=m||r;
       r=d(v+vec3(s,12.,7.)/16.,v+vec3(c,15.,9.)/16.,z,f,y);
       m=m||r;
     }
   if(x>=71.&&x<=82.)
     {
       float s=8.,c=8.;
       if(x>=71.&&x<=74.||x>=79.&&x<=82.)
         c=16.;
       if(x>=75.&&x<=82.)
         s=0.;
       r=d(v+vec3(7.,6.,s)/16.,v+vec3(9.,9.,c)/16.,z,f,y);
       m=m||r;
       r=d(v+vec3(7.,12.,s)/16.,v+vec3(9.,15.,c)/16.,z,f,y);
       m=m||r;
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
       r=d(v+s/16.,v+c/16.,z,f,y);
       m=m||r;
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
           float h=13.;
           if(x==99.||x==100.)
             h=0.;
           s=vec3(h,0.,0.)/16.;
           c=vec3(h+3.,16.,16.)/16.;
         }
       r=d(v+s,v+c,z,f,y);
       m=m||r;
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
       r=d(v+s,v+c,z,f,y);
       m=m||r;
     }
   #endif
   #endif
   return m;
 }
 vec3 G(vec2 v)
 {
   vec2 x=vec2(v.xy*vec2(viewWidth,viewHeight));
   x*=1./64.;
   const vec2 i[16]=vec2[16](vec2(-1,-1),vec2(0,-.333333),vec2(-.5,.333333),vec2(.5,-.777778),vec2(-.75,-.111111),vec2(.25,.555556),vec2(-.25,-.555556),vec2(.75,.111111),vec2(-.875,.777778),vec2(.125,-.925926),vec2(-.375,-.259259),vec2(.625,.407407),vec2(-.625,-.703704),vec2(.375,-.037037),vec2(-.125,.62963),vec2(.875,-.481482));
   if(v.x<2./viewWidth||v.x>1.-2./viewWidth||v.y<2./viewHeight||v.y>1.-2./viewHeight)
     ;
   x=(floor(x*64.)+.5)/64.;
   vec3 f=texture2D(noisetex,x).xyz,z=vec3(sqrt(.2),sqrt(2.),1.61803);
   f=mod(f+float(frameCounter%64)*z,vec3(1.));
   return f;
 }
 vec3 a(vec3 v)
 {
   float x=fract(frameCounter*.0123456);
   int s=t(),c=f();
   vec3 m=BlueNoiseTemporal(Texcoord.xy).xyz,z=BlueNoiseTemporal(Texcoord.xy+.1).xyz,y=v,i=Fract01(cameraPosition.xyz+.5)+vec3(0.,0.,0.),r=i;
   i=f(i,s);
   Ray n=MakeRay(i*s-vec3(1.),y);
   vec3 h=vec3(1.),w=vec3(0.);
   for(int e=0;e<1;e++)
     {
       vec3 a=vec3(floor(n.origin)),G=abs(vec3(length(n.direction))/(n.direction+.0001)),o=sign(n.direction),p=(sign(n.direction)*(a-n.origin)+sign(n.direction)*.5+.5)*G,Y;
       vec4 T=vec4(0.);
       vec3 l=vec3(0.);
       float S=.5;
       for(int R=0;R<190;R++)
         {
           l=a/float(s);
           vec2 H=d(l,s);
           T=texture2DLod(shadowcolor,H,0);
           if(abs(T.w*255.-130.)<.5)
             w+=.06125*h*colorTorchlight*S;
           else
             {
               if(T.w*255.<254.f&&R!=0)
                 {
                   break;
                 }
             }
           Y=step(p.xyz,p.yzx)*step(p.xyz,p.zxy);
           p+=Y*G;
           a+=Y*o;
           S=1.;
         }
       w+=T.xyz;
     }
   w*=1.;
   return w;
 }
 vec3 G(vec3 x,vec3 z)
 {
   x+=Fract01(cameraPosition.xyz+.5)-.5;
   vec3 y=s(x+z*.1),f=i(v(y)).PVAMAgODVh;
   return f;
 }
 vec3 G(vec2 v,vec3 z,float x,vec3 y)
 {
   vec3 s=texture2DLod(colortex7,v+vec2(0.,HalfScreen.y),0).xyz;
   return s;
 }
 void main()
 {
   Texcoord=texcoord.xy;
   GBufferData v=GetGBufferData(Texcoord);
   MaterialMask x=CalculateMasks(v.materialID,Texcoord);
   vec4 s=GetViewPosition(Texcoord.xy,v.depth),c=gbufferModelViewInverse*vec4(s.xyz,1.),i=gbufferModelViewInverse*vec4(s.xyz,0.);
   vec3 m=normalize(s.xyz),z=normalize(i.xyz),f=normalize((gbufferModelViewInverse*vec4(v.normal,0.)).xyz),y=normalize((gbufferModelViewInverse*vec4(v.geoNormal,0.)).xyz);
   float n=length(s.xyz);
   vec3 r=vec3(0.),h=f;
   if(x.grass>.5)
     f=vec3(0.,1.,0.);
   vec3 t=G(Texcoord.xy,v.normal,v.depth,s.xyz)*10.,w=t*v.albedo.xyz;
   const float S=75.;
   if(n>S)
     {
       vec3 a=FromSH(skySHR,skySHG,skySHB,f);
       a*=pow(v.mcLightmap.y,.5);
       vec3 R=a*v.albedo.xyz*4.5;
       const float Y=3.7;
       R+=v.mcLightmap.x*colorTorchlight*v.albedo.xyz*.025*Y;
       vec3 T=normalize(v.albedo.xyz+.0001)*pow(length(v.albedo.xyz),1.)*colorSunlight*.13*v.mcLightmap.y;
       R+=T*v.albedo.xyz*5.;
       float p=.3;
       w=mix(w,R,vec3(saturate(n*p-S*p)));
     }
   r.xyz=w+v.albedo.xyz*1e-05;
   #ifdef HELD_LIGHT
   {
     float p=float(heldBlockLightValue+heldBlockLightValue2)/16.,Y=OrenNayar(h,-z,-z),o=1./(dot(i.xyz,i.xyz)+.3);
     r+=v.albedo.xyz*p*o*Y*colorTorchlight*.3;
   }
   #endif
   #ifdef VISUALIZE_DANGEROUS_LIGHT_LEVEL
   {
     float Y=BlockLightTorchLinear(v.mcLightmap.x)*16.;
     Y=Y;
     r.x+=Y<=6.75?1.:0.;
   }
   #endif
   float Y=24.*(1.-sqrt(wetness)),o=dot(f,worldLightVector),a=OrenNayar(f,-z,worldLightVector);
   if(x.leaves>.5)
     a=mix(a,.5,.5);
   if(x.grass>.5)
     v.metalness=0.;
   vec3 p=CalculateSunlightVisibility(s,x,y,v.parallaxOffset);
   #ifdef SUNLIGHT_LEAK_FIX
   float T=saturate(v.mcLightmap.y*100.);
   if(isEyeInWater<1)
     p*=T;
   #endif
   p*=ScreenSpaceShadow(s.xyz,v.depth,m.xyz,v.geoNormal.xyz,x);
   r+=TintUnderwaterDepth(DoNightEyeAtNight(a*v.albedo.xyz*p*Y*colorSunlight,timeMidnight));
   vec3 R=SpecularGGX(f,-z,worldLightVector,1.-v.smoothness,v.metalness*.96+.04)*Y*p;
   R*=mix(vec3(1.),v.albedo.xyz,vec3(v.metalness));
   R*=mix(1.,.5,x.grass);
   if(isEyeInWater<.5)
     r*=1.-e(v.smoothness,v.metalness)*v.metalness,r+=DoNightEyeAtNight(R,timeMidnight);
   if(x.sky>.5||v.depth>1.)
     {
       vec3 l=z.xyz;
       if(isEyeInWater>0)
         l.xyz=refract(l.xyz,vec3(0.,-1.,0.),1.2533);
       vec3 H=SkyShading(l.xyz,worldSunVector.xyz,rainStrength);
       r=H;
       vec3 J=AtmosphereAbsorption(l.xyz,AtmosphereExtent);
       r+=v.albedo.xyz*J*.5;
       r+=RenderSunDisc(l,worldSunVector,colorSunlight)*J*2000.;
       CloudPlane(r,-l,worldLightVector,worldSunVector,colorSunlight,colorSkyUp,H,timeMidnight,true);
     }
   if(x.glowstone>.5)
     r.xyz+=v.albedo.xyz*GI_LIGHT_BLOCK_INTENSITY;
   if(x.torch>.5)
     r.xyz+=v.albedo.xyz*pow(length(v.albedo.xyz),2.)*.5*GI_LIGHT_TORCH_INTENSITY;
   if(x.lava>.5)
     r+=v.albedo.xyz*.75*GI_LIGHT_BLOCK_INTENSITY;
   if(x.fire>.5)
     r+=v.albedo.xyz*3.*GI_LIGHT_TORCH_INTENSITY;
   if(x.litFurnace>.5)
     {
       float J=saturate(v.albedo.x-(v.albedo.y+v.albedo.z)*.5-.2);
       r+=v.albedo.xyz*J*2.*GI_LIGHT_TORCH_INTENSITY*vec3(2.,.35,.025);
     }
   float H=0.;
   r*=.001;
   r=LinearToGamma(r);
   r+=rand(Texcoord.xy+sin(frameTimeCounter))*(1./65535.);
   gl_FragData[0]=vec4(r.xyz,1.);
 };




/* DRAWBUFFERS:1 */
