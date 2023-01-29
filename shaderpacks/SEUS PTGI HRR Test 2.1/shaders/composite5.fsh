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


#include "lib/Uniforms.inc"
#include "lib/Common.inc"
#include "lib/GBufferData.inc"
#include "lib/MedianFilter.inc"


/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////




const bool colortex3MipmapEnabled = false;


in vec4 texcoord;
in vec3 lightVector;


in float timeSunriseSunset;
in float timeNoon;
in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;

in mat4 gbufferPreviousModelViewInverse;

#define PREV_COLOR_TEX colortex3
#define CURR_COLOR_TEX colortex1


#include "lib/FXAA.inc"


vec3 GetColorForBloom(vec2 coord)
{
	coord = coord * 0.5 + 0.5; // upper right quadrant
	coord = clamp(coord, (0.5 + ScreenTexel.xy * 2.0), vec2(1.0));

	vec3 color = GammaToLinear(texture2D(CURR_COLOR_TEX, coord).rgb);

	return color;
}

vec2 ClampCoord(vec2 coord, vec2 texel)
{
	//return clamp(coord, texel, 1.0 - texel);
	return saturate(coord);
}

vec3 GrabBlurH(vec2 coord, const float octave, const vec2 offset)
{
	float scale = exp2(octave);

	coord += offset;
	coord *= scale;

	vec2 texel = scale / vec2(viewWidth, viewHeight);
	vec2 lowBound  = 0.0 - 10.0 * texel;
	vec2 highBound = 1.0 + 10.0 * texel;

	if (coord.x < lowBound.x || coord.x > highBound.x || coord.y < lowBound.y || coord.y > highBound.y)
	{
		return vec3(0.0);
	}

	//vec3 color = GetColorForBloom(coord);

	vec3 color = vec3(0.0);

/*
	float weights[3] = float[3](0.27343750, 0.32812500, 0.03515625);
	float offsets[3] = float[3](0.00000000, 1.33333333, 3.11111111);




	color += GetColorForBloom(ClampCoord(coord, texel)) * weights[0];

	for (int i = 1; i < 3; i++)
	{
		color += GetColorForBloom(ClampCoord(coord + vec2(offsets[i] * 1.0, 0.0) * texel, texel)) * weights[i];
		color += GetColorForBloom(ClampCoord(coord - vec2(offsets[i] * 1.0, 0.0) * texel, texel)) * weights[i];
	}
*/

	float weights[5] = float[5](0.27343750, 0.21875000, 0.10937500, 0.03125000, 0.00390625);
	float offsets[5] = float[5](0.00000000, 1.00000000, 2.00000000, 3.00000000, 4.00000000);

	color += GetColorForBloom(ClampCoord(coord, texel)) * weights[0];

	for (int i = 1; i < 5; i++)
	{
		color += GetColorForBloom(ClampCoord(coord + vec2(offsets[i] * 2.0, 0.0) * texel, texel)) * weights[i];
		color += GetColorForBloom(ClampCoord(coord - vec2(offsets[i] * 2.0, 0.0) * texel, texel)) * weights[i];
	}

	return color;
}

vec2 CalcOffset(float octave)
{
    vec2 offset = vec2(0.0);
    
    vec2 padding = vec2(30.0) / vec2(viewWidth, viewHeight);

    octave += 0.0001;	// AMD FIX
    
    offset.x = -min(1.0, floor(octave / 3.0)) * (0.25 + padding.x);
    
    offset.y = -(1.0 - (1.0 / exp2(octave))) - padding.y * octave;

	offset.y += min(1.0, floor(octave / 3.0)) * 0.35;
    
 	return offset;   
}


#define DEPTH_MIX_SCALE (1.0 / 30.0)

vec3 MixDepth(vec3 color, float depth, vec2 coord, const bool isPrev)
{

	vec3 wp = vec3(0.0);
	if (isPrev)
	{
	coord *= 2.0;
		vec4 prevViewPos = gbufferProjectionInverse * vec4(
			coord.xy * 2.0 - 1.0,
			depth * 2.0 - 1.0,
			1.0
		);
		prevViewPos /= prevViewPos.w;
		vec3 prevDepthWorldPos = (gbufferPreviousModelViewInverse * vec4(prevViewPos.xyz, 1.0)).xyz;
		prevDepthWorldPos += previousCameraPosition;
		prevDepthWorldPos -= cameraPosition;

		wp = prevDepthWorldPos;
	}
	else
	{
		vec4 vp = GetViewPosition(coord.xy, depth);
		wp = (gbufferModelViewInverse * vec4(vp.xyz, 1.0)).xyz;
	}

	return mix(color, vec3(saturate(length(wp) * DEPTH_MIX_SCALE)), vec3(0.5));

	// return mix(color, vec3(saturate(depth * DEPTH_MIX_SCALE)), vec3(0.5));
	// return color * saturate(depth * DEPTH_MIX_SCALE);
}

float GetColorVariance(sampler2D tex, vec2 coord, vec2 width) {
	vec4 sum = vec4(0.0);
	vec4 sum2 = vec4(0.0);

	int c = 0;
	for (int i = -1; i <= 1; i++)
	{
		for (int j = -1; j <= 1; j++)
		{
			vec2 coordOffset = vec2(i, j) * width;
			vec4 colorSample = texture2DLod(tex, coord + coordOffset, 0);
			colorSample.rgb = MixDepth(colorSample.rgb, GetDepth2(coord + coordOffset - HalfScreen), coord + coordOffset - HalfScreen, false);
			
			sum += colorSample;
			sum2 += colorSample * colorSample;
			c++;
		}
	}

	sum /= c + 0.00000001;
	sum2 /= c + 0.00000001;

	float sumLum = dot(sum.rgb, vec3(1.0));
	vec4 spatialVariance = sqrt(max(vec4(0.00000001), sum2 - sum * sum));
	float spatialVarianceLum = dot(spatialVariance.rgb, vec3(1.0));

	return spatialVarianceLum;
}



/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main() {

	//vec3 color = GammaToLinear(texture2D(colortex6, texcoord.st).rgb);

	vec4 auxOut = vec4(0.0, 0.0, 0.0, 1.0);


	if (texcoord.x < 0.5 && texcoord.y < 0.5) 
	{
		// vec2 bloomCoord = texcoord.st * 2.0;

		// vec3 bloomColor = vec3(0.0);
		// bloomColor += GrabBlurH(bloomCoord, 1.0, vec2(0.0, 0.0));
		// bloomColor += GrabBlurH(bloomCoord, 2.0, CalcOffset(1.0));
		// bloomColor += GrabBlurH(bloomCoord, 3.0, CalcOffset(2.0));
		// bloomColor += GrabBlurH(bloomCoord, 4.0, CalcOffset(3.0));
		// bloomColor += GrabBlurH(bloomCoord, 5.0, CalcOffset(4.0));
		// bloomColor += GrabBlurH(bloomCoord, 6.0, CalcOffset(5.0));
		// bloomColor += GrabBlurH(bloomCoord, 7.0, CalcOffset(6.0));
		// bloomColor += GrabBlurH(bloomCoord, 8.0, CalcOffset(7.0));
		// bloomColor += GrabBlurH(bloomCoord, 9.0, CalcOffset(8.0));

		// bloomColor = LinearToGamma(bloomColor);

		// auxOut.rgb = bloomColor.rgb;

	}

	


	// if (texcoord.x > 0.5 && texcoord.y < 0.5) 
	// {
	// 	auxOut.rgb = vec3(GetColorVariance(CURR_COLOR_TEX, (texcoord.st) * 1.0 - vec2(HalfScreen.x, 0.0) + HalfScreen, ScreenTexel * 1.0));
	// }

	if (texcoord.y > 0.5) {
		if (texcoord.x < 0.5) {
			vec2 coord = LockRenderPixelCoord(texcoord.st + vec2(HalfScreen.x, 0.0));
			auxOut.rgb = MedianFilter(CURR_COLOR_TEX, coord, ScreenTexel);
			// auxOut.rgb = texture2DLod(CURR_COLOR_TEX, coord, 0).rgb;
			auxOut.rgb = MixDepth(auxOut.rgb, GetDepth2(coord - HalfScreen), coord - HalfScreen, false);
			auxOut.a = GetColorVariance(CURR_COLOR_TEX, coord, ScreenTexel * 1.0);
		} else
		{
			vec2 coord = LockRenderPixelCoord((texcoord.st - HalfScreen) * 2.0);
			auxOut.rgb = MedianFilter(PREV_COLOR_TEX, coord, ScreenTexel * 2.0);
			// auxOut.rgb = texture2DLod(PREV_COLOR_TEX, coord, 0).rgb;
			// auxOut.rgb *= saturate(ExpToLinearDepth(texture2DLod(colortex6, texcoord.st - HalfScreen, 0).a) * DEPTH_MIX_SCALE);
			auxOut.rgb = MixDepth(auxOut.rgb, texture2DLod(colortex6, texcoord.st - HalfScreen, 0).a, texcoord.st - HalfScreen, true);
		}
	}



	// Fix missing pixels on lower and left edge
	vec4 col;

	if (texcoord.x >= HalfScreen.x && texcoord.y >= HalfScreen.y)
	{
		vec2 coord = clamp(texcoord.xy, HalfScreen + ScreenTexel, vec2(1.0));
		col = texture2DLod(colortex1, coord, 0);
		
		GBufferData gbuffer = GetGBufferData(coord - HalfScreen);
		col.a = gbuffer.materialID;
	}
	if (texcoord.x < HalfScreen.x && texcoord.y < HalfScreen.y)
	{
		vec2 coord = clamp(texcoord.xy + HalfScreen, HalfScreen + ScreenTexel, vec2(1.0));
		col.rgb = DoFXAA(colortex1, coord, ScreenTexel);
		// col = texture2DLod(colortex1, coord, 0);
		col.a = 1.0;
	}
	gl_FragData[0] = col; 	
	gl_FragData[1] = auxOut;

}


/* DRAWBUFFERS:12 */
