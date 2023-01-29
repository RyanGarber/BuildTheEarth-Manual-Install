#version 330 compatibility
#extension GL_ARB_gpu_shader5 : enable

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

















in vec4 color;
in vec4 texcoord;
in vec4 lmcoord;
in vec3 worldPosition;
in vec3 viewPos;
in vec4 preDownscaleProjPos;
in vec4 glPosition;

in vec3 worldNormal;

in vec2 blockLight;

in float materialIDs;


in mat3 tbnMatrix;
in vec3 tangent;
in vec3 binormal;
in vec3 normal;





#include "lib/Uniforms.inc"
#include "lib/Common.inc"
#include "lib/GBufferData.inc"
#include "lib/GBuffersCommon.inc"

ivec2 AtlasTiles;
ivec2 TextureSize;
vec2 TextureTexel;


vec2 OffsetCoord(in vec2 coord, in vec2 offset, in int level)
{
































	vec2 tileCoord = coord * AtlasTiles;
	ivec2 tileCoordI = ivec2(tileCoord);
	vec2 interTileCoord = fract(tileCoord + offset * AtlasTiles);
	return (tileCoordI + interTileCoord) / vec2(AtlasTiles);
	

}

float BilinearHeightSample(vec2 coord) {
	vec2 pc = coord;
	vec2 fpc = fract(pc * TextureSize + 0.5);
	vec2 fpcT = mod(fpc, vec2(TEXTURE_RESOLUTION));


	vec4 sh;

	// if (fpcT.x > TEXTURE_RESOLUTION - 1 || fpcT.y > TEXTURE_RESOLUTION - 1)

	{
		sh = vec4(
			texture2DLod(normals, OffsetCoord(coord, vec2(0.0, 				TextureTexel.y) - TextureTexel * 0.5, 0), 	0).a,
			texture2DLod(normals, OffsetCoord(coord, vec2(TextureTexel.x, 	TextureTexel.y) - TextureTexel * 0.5, 0), 	0).a,
			texture2DLod(normals, OffsetCoord(coord, vec2(TextureTexel.x, 	0.0           ) - TextureTexel * 0.5, 0), 	0).a,
			texture2DLod(normals, OffsetCoord(coord, vec2(0.0, 				0.0           ) - TextureTexel * 0.5, 0), 	0).a
		);
	}






	return mix(
		mix(sh.w, sh.z, fpc.x),
		mix(sh.x, sh.y, fpc.x),
		fpc.y
	);
}

vec2 CalculateParallaxCoord(vec2 coord, vec3 viewVector, vec2 texGradX, vec2 texGradY, out vec3 offsetCoord)
{
	vec2 parallaxCoord = coord.st;
	const int maxSteps = 112;
	vec3 stepSize = vec3(0.001, 0.001, 0.15);

	float parallaxDepth = PARALLAX_DEPTH;




	const float gradThreshold = 0.004;
	float absoluteTexGrad = dot(abs(texGradX) + abs(texGradY), vec2(1.0));

	parallaxDepth *= saturate((1.0 - saturate(absoluteTexGrad / gradThreshold)) * 1.0);
	if (absoluteTexGrad > gradThreshold)
	{
		offsetCoord = vec3(0.0, 0.0, 1.0);
		return texcoord.st;
	}

	float parallaxStepSize = 0.5;

	stepSize.xy *= parallaxDepth;
	stepSize *= parallaxStepSize;

	#ifdef SMOOTH_PARALLAX
	float heightmap = BilinearHeightSample(coord.xy);
	#else
	float heightmap = textureGrad(normals, coord.st, texGradX, texGradY).a;
	#endif

	vec3 pCoord = vec3(0.0f, 0.0f, 1.0f);


	if (heightmap < 1.0)
	{
		const int maxRefinements = 4;
		int numRefinements = 0;

		vec3 step = viewVector 
			* stepSize * 0.25
			* (absoluteTexGrad * 15500.0 + 1.0)
			;
		float sampleHeight = heightmap;

		
		for (int i = 0; i < 80; i++)
		{
			pCoord += step;

			parallaxCoord = OffsetCoord(coord.xy, pCoord.xy, 0);

			#ifdef SMOOTH_PARALLAX
			sampleHeight = BilinearHeightSample(parallaxCoord);
			#else
			sampleHeight = textureGrad(normals, OffsetCoord(coord.st, pCoord.st, 0), texGradX, texGradY).a;
			#endif


			if (sampleHeight > pCoord.z)
			{
				if (numRefinements < maxRefinements)
				{
					pCoord -= step;
					step *= 0.5;
					numRefinements++;
				}
				else
				{
					break;
				}
			}
		}
	}

	offsetCoord = pCoord;






	return parallaxCoord;
}



void main() 
{	
	if (PixelOutOfScreenBounds(preDownscaleProjPos)) {
		discard;
		return;
	}
	float lodOffset = 0.0;

	vec2 texGradX = dFdx(texcoord.st) * 0.25;
	vec2 texGradY = dFdy(texcoord.st) * 0.25;
	vec2 textureCoordinate = texcoord.st;

	// #ifndef SKIP_AA
	// vec3 dither = BlueNoiseStatic(abs(glPosition.xy / glPosition.w) * 1.0).rgb;
	// textureCoordinate = OffsetCoord(textureCoordinate, dither.x * texGradX * 2.0 + dither.y * texGradY * 2.0, 0);
	// #endif



	vec3 N;
	mat3 tbn;
	mat3 tbnRaw;
	CalculateNormalAndTBN(viewPos.xyz, texcoord.st, N, tbn, tbnRaw);

	#ifdef PARALLAX

		{
			TextureSize = textureSize(texture, 0);
			TextureTexel = 1.0 / vec2(TextureSize);
			AtlasTiles = TextureSize / TEXTURE_RESOLUTION;
		}

		// vec3 texViewVector = normalize(tbn * viewPos.xyz);
		vec3 texViewVector = normalize(tbnRaw * viewPos.xyz);
		int tileResolution = TEXTURE_RESOLUTION;
		ivec2 atlasTiles = atlasSize / TEXTURE_RESOLUTION;
		float atlasAspectRatio = atlasTiles.x / atlasTiles.y;
		texViewVector.y *= atlasAspectRatio;
		texViewVector = normalize(texViewVector);


		vec3 offsetCoord;
		textureCoordinate = CalculateParallaxCoord(texcoord.st, texViewVector, texGradX, texGradY, offsetCoord);
	#endif



	// vec4 albedo = GetSourceTexture(texture, textureCoordinate);

	vec4 albedo = textureGrad(texture, textureCoordinate, texGradX, texGradY);










	albedo *= color;

	vec2 mcLightmap = blockLight;



	float wetnessModulator = 1.0;

	vec3 rainNormal = vec3(0.0, 0.0, 0.0);
	#ifdef RAIN_SPLASH_EFFECT
	rainNormal = GetRainSplashNormal(worldPosition, worldNormal, wetnessModulator);
	#endif

	wetnessModulator *= saturate(worldNormal.y * 10.5 + 0.7);
	wetnessModulator *= saturate(abs(2.0 - materialIDs));
	wetnessModulator *= clamp(blockLight.y * 1.05 - 0.7, 0.0, 0.3) / 0.3;
	wetnessModulator *= saturate(wetness * 1.1 - 0.1);








	vec4 specTex = textureGrad(specular, textureCoordinate, texGradX, texGradY);
	#ifdef SPEC_SMOOTHNESS_AS_ROUGHNESS
	specTex.SPEC_CHANNEL_SMOOTHNESS = 1.0 - specTex.SPEC_CHANNEL_SMOOTHNESS;
	#endif
	specTex.SPEC_CHANNEL_SMOOTHNESS = specTex.SPEC_CHANNEL_SMOOTHNESS * 0.992; 								// Fix weird specular issue
	

	vec4 normalTex = textureGrad(normals, textureCoordinate, texGradX, texGradY) * 2.0 - 1.0;
	normalTex.xy = sign(normalTex.xy) * max(vec2(0.0), abs(normalTex.xy) - 0.003);

	float normalMapStrength = 3.0;
	// normalMapStrength = 0.5;
	#ifdef FORCE_WET_EFFECT
	normalMapStrength = mix(normalMapStrength, 0.1, wetnessModulator * wetnessModulator * wetnessModulator * wetnessModulator);


	vec3 viewNormal = tbn * normalize(normalTex.xyz * vec3(normalMapStrength, normalMapStrength, 1.0) + rainNormal * wetnessModulator);
	#else
	vec4 normalTex = textureGrad(normals, textureCoordinate, texGradX, texGradY) * 2.0 - 1.0;
	vec3 viewNormal;
	{
		const float eps = 0.00001;
		float cD = BilinearHeightSample(textureCoordinate);
		float rD = BilinearHeightSample(textureCoordinate + vec2(eps, 0.0));
		float uD = BilinearHeightSample(textureCoordinate + vec2(0.0, eps));

		float xDiff = (cD - rD) / eps;
		float yDiff = (cD - uD) / eps;

		vec3 heightNormal = normalize(vec3(2.0 * xDiff, 2.0 * yDiff, -4.0));

		viewNormal = tbn * heightNormal;
	}
	#endif
	
	// Get specular data from specular texture
	float smoothness = specTex.SPEC_CHANNEL_SMOOTHNESS;
	float metallic = specTex.SPEC_CHANNEL_METALNESS;
	float emissive = specTex.b;

	#ifdef FORCE_WET_EFFECT
	if (isEyeInWater < 1)
	{
		smoothness = mix(smoothness, 1.0, saturate(wetnessModulator * 1.0 * saturate(1.0 - metallic)));
	}
	#endif

	// Darker albedo when wet
	albedo.rgb = pow(albedo.rgb, vec3(1.0 + wetnessModulator * (1.0 - metallic) * 0.3));




	// Fix impossible normal angles
	vec3 viewDir = -normalize(viewPos.xyz);
	vec3 relfectDir = reflect(-viewDir, viewNormal);
	// make outright impossible
	viewNormal.xyz = normalize(viewNormal.xyz + (N / (pow(saturate(dot(viewNormal, viewDir)) + 0.001, 0.5)) * 1.0));





	// vec3 analyticNormal = normalize(cross(dFdx(viewPos.xyz), dFdy(viewPos.xyz)));

	// albedo.rgb = analyticNormal.xyz * 0.5 + 0.5;
	// albedo.rgb *= 0.5;
	// albedo.rgb = vec3(0.1);
	// smoothness = 0.0;
	// metallic = 0.0;


	// metallic += 0.05;
	// smoothness = 0.85;




	GBufferData gbuffer;
	gbuffer.albedo = albedo * 1.0;
	gbuffer.normal = viewNormal.xyz;
	gbuffer.mcLightmap = mcLightmap;
	gbuffer.smoothness = smoothness;
	gbuffer.metalness = metallic;
	gbuffer.materialID = (materialIDs + 0.1) / 255.0;
	gbuffer.emissive = saturate(specTex.a);
	gbuffer.geoNormal = N.xyz;
	gbuffer.totalTexGrad = length(fwidth(texcoord.st)) * (256.0 / 8.0);


	#ifdef PARALLAX

		vec3 worldPos = (gbufferModelViewInverse * vec4(viewPos.xyz, 0.0)).xyz;
		vec3 worldViewDir = normalize(worldPos.xyz);
		float NdotV = dot(worldNormal.xyz, -worldViewDir);


		vec3 parallaxWorldPos = worldPos.xyz;
		float height = normalTex.a;

		parallaxWorldPos += normalize(worldPos) * (1.0 - offsetCoord.z) * 0.2 / (saturate(NdotV) + 0.00001);

		parallaxWorldPos = (gbufferModelView * vec4(parallaxWorldPos.xyz, 0.0)).xyz;

		vec4 projPos = gbufferProjection * vec4(parallaxWorldPos.xyz, 1.0);
		projPos /= projPos.w;
		projPos = projPos * 0.5 + 0.5;

		gl_FragDepth = projPos.z;

		// albedo.rgb = vec3(NdotV);

		gbuffer.parallaxOffset = (1.0 - offsetCoord.z);





	#endif


	vec4 frag0, frag1, frag2, frag3;

	OutputGBufferDataSolid(gbuffer, frag0, frag1, frag2, frag3);

	gl_FragData[0] = frag0;
	gl_FragData[1] = frag1;
	gl_FragData[2] = frag2;

}

/* DRAWBUFFERS:012 */
