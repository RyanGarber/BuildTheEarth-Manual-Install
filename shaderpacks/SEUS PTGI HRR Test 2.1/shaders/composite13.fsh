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



/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////



in vec4 texcoord;
in vec3 lightVector;


in float timeSunriseSunset;
in float timeNoon;
in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;

in float avgSkyBrightness;

#define COLOR_TEX colortex1

const float overlap = 0.2;

const float rgOverlap = 0.1 * overlap;
const float rbOverlap = 0.01 * overlap;
const float gbOverlap = 0.04 * overlap;

const mat3 coneOverlap = mat3(1.0, 			rgOverlap, 	rbOverlap,
							  rgOverlap, 	1.0, 		gbOverlap,
							  rbOverlap, 	rgOverlap, 	1.0);

const mat3 coneOverlapInverse = mat3(	1.0 + (rgOverlap + rbOverlap), 			-rgOverlap, 	-rbOverlap,
									  	-rgOverlap, 		1.0 + (rgOverlap + gbOverlap), 		-gbOverlap,
									  	-rbOverlap, 		-rgOverlap, 	1.0 + (rbOverlap + rgOverlap));

// ACES
const mat3 ACESInputMat = mat3(
    0.59719, 0.35458, 0.04823,
    0.07600, 0.90834, 0.01566,
    0.02840, 0.13383, 0.83777
);

const mat3 ACESOutputMat = mat3(
     1.60475, -0.53108, -0.07367,
    -0.10208,  1.10813, -0.00605,
    -0.00327, -0.07276,  1.07602
);

vec3 Uncharted2Tonemap(vec3 x)
{
	x *= 3.0;

	// float A = 0.15;
	// float B = 0.50;
	// float C = 0.10;
	// float D = 0.20;
	// float E = 0.02;
	// float F = 0.30;

	float A = 0.9;
	float B = 0.8;
	float C = 0.1;
	float D = 1.0;
	float E = 0.02;
	float F = 0.30;

	x = x * coneOverlap;

	x = ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;

	x = x * coneOverlapInverse;

    return x;
}

float almostIdentity( float x, float m, float n )
{
    if( x>m ) return x;

    float a = 2.0*n - m;
    float b = 2.0*m - 3.0*n;
    float t = x/m;

    return (a*t + b)*t*t + n;
}

vec3 almostIdentity(vec3 x, vec3 m, vec3 n)
{
	return vec3(
		almostIdentity(x.x, m.x, n.x),
		almostIdentity(x.y, m.y, n.y),
		almostIdentity(x.z, m.z, n.z)
		);
}

vec3 BlackDepth(vec3 color, vec3 blackDepth)
{
	vec3 m = blackDepth;
	vec3 n = blackDepth * 0.5;
	return (almostIdentity(color, m, n) - n);// * (vec3(1.0) - n);
}

vec3 BurgessTonemap(vec3 col)
{
	col *= 0.9;
	col = col * coneOverlap;

	vec3 maxCol = col;


    const float p = 1.0;
    maxCol = pow(maxCol, vec3(p));

    vec3 retCol = (maxCol * (6.2 * maxCol + 0.05)) / (maxCol * (6.2 * maxCol + 2.3) + 0.06);
	retCol = pow(retCol, vec3(1.0 / p));

	retCol = retCol * coneOverlapInverse;

    return retCol;
}

vec3 SEUSTonemap(vec3 color)
{
	const float p = TONEMAP_CURVE;

		color = color * coneOverlap;

	color = pow(color, vec3(p));
	color = color / (1.0 + color);
	// color = 1.0 - exp(-color);
	color = pow(color, vec3((1.0 / GAMMA) / p));


		color = color * coneOverlapInverse;

	color = TransformOutputColor(color);

	return color;
}

vec3 ReinhardJodie(vec3 v)
{
	v = pow(v, vec3(TONEMAP_CURVE));
    float l = Luminance(v);
    vec3 tv = v / (1.0f + v);

    vec3 tonemapped = mix(v / (1.0f + l), tv, tv);
	tonemapped = pow(tonemapped, vec3(1.0 / TONEMAP_CURVE));

	return tonemapped;
}



/////////////////////////////////////////////////////////////////////////////////
//	ACES Fitting by Stephen Hill
vec3 RRTAndODTFit(vec3 v)
{
    vec3 a = v * (v + 0.0245786f) - 0.000090537f;
    vec3 b = v * (1.0f * v + 0.4329510f) + 0.238081f;
    return a / b;
}

vec3 ACESTonemap2(vec3 color)
{
	color *= 1.5;
	color = color * ACESInputMat;

    // Apply RRT and ODT
    color = RRTAndODTFit(color);


    // Clamp to [0, 1]
	color = color * ACESOutputMat;
    color = saturate(color);

    return color;
}
/////////////////////////////////////////////////////////////////////////////////





vec3 ACESTonemap(vec3 color)
{
	color *= 0.7;

		color = color * coneOverlap;



		vec3 crosstalk = vec3(0.05, 0.2, 0.05) * 2.9;

		// float avgColor = (color.r + color.g + color.b) * 0.33333;
		float avgColor = Luminance(color.rgb);

		// color = mix(color, vec3(avgColor), crosstalk);


	const float p = 1.0;
	color = pow(color, vec3(p));
	color = (color * (2.51 * color + 0.03)) / (color * (2.43 * color + 0.59) + 0.14);
	// color = (color * (2.51 * color + 0.03)) / (color * (2.43 * color + 0.59) + 0.1);
	color = pow(color, vec3(1.0 / p));

		color = color * coneOverlapInverse;


		// float avgColorTonemapped = (color.r + color.g + color.b) * 0.33333;
		float avgColorTonemapped = Luminance(color.rgb);

		// color = mix(color, vec3(avgColorTonemapped), -crosstalk * 1.0);


	color = saturate(color);

	color = pow(color, vec3(0.9));

	// color = mix(color, vec3(avgColorTonemapped), vec3(-saturate(avgColor * 0.25 + 0.0)));


	return color;
}




void CalculateExposureEyeBrightness(inout vec3 color) 
{
	float exposureMax = 1.55f;
		  //exposureMax *= mix(1.0f, 0.25f, timeSunriseSunset);
		  //exposureMax *= mix(1.0f, 0.0f, timeMidnight);
		  //exposureMax *= mix(1.0f, 0.25f, rainStrength);
		  exposureMax *= avgSkyBrightness * 2.0;
	float exposureMin = 0.07f;
	float exposure = pow(eyeBrightnessSmooth.y / 240.0f, 6.0f) * exposureMax + exposureMin;

	//exposure = 1.0f;

	color.rgb /= vec3(exposure);
	color.rgb *= 350.0;
}



void 	Vignette(inout vec3 color) {
	float dist = distance(texcoord.st, vec2(0.5f)) * 2.0f;
		  dist /= 1.5142f;

		  //dist = pow(dist, 1.1f);

	color.rgb *= 1.0f - dist * 0.5;

}

void DoNightEye(inout vec3 color)
{
	float lum = Luminance(color * vec3(1.0, 1.0, 1.0));
	float mixSize = 1250000.0;
	float mixFactor = 0.01 / (pow(lum * mixSize, 2.0) + 0.01);


	vec3 nightColor = mix(color, vec3(lum), vec3(0.9)) * vec3(0.25, 0.5, 1.0) * 2.0;

	color = mix(color, nightColor, mixFactor);
}

void Overlay(inout vec3 color, vec3 overlayColor)
{
	vec3 overlay = vec3(0.0);

	for (int i = 0; i < 3; i++)
	{
		if (color[i] > 0.5)
		{
			float valueUnit = (1.0 - color[i]) / 0.5;
			float minValue = color[i] - (1.0 - color[i]);
			overlay[i] = (overlayColor[i] * valueUnit) + minValue;
		}
		else
		{
			float valueUnit = color[i] / 0.5;
			overlay[i] = overlayColor[i] * valueUnit;
		}
	}

	color = overlay;
}

void AverageExposure(inout vec3 color)
{
	// float avglod = int(log2(min(viewWidth, viewHeight))) - 0;
	// color /= pow(Luminance(texture2DLod(colortex3, vec2(0.65, 0.65), avglod).rgb), 1.5) * 3.9 + 0.00015;

	float avgLum = texture2DLod(colortex6, vec2(0.0, 0.0), 0).a * 0.01;

	// color /= avgLum * 3.9 + 0.00015;
	color /= avgLum * 23.9 + 0.0008;
}


#include "lib/Bloom.inc"

#include "lib/FXAA.inc"

/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main() {


	vec3 color = 	(texture2D(COLOR_TEX, texcoord.st).rgb);



	
	color = GammaToLinear(color);

	#ifndef SKIP_AA
	#if PIXEL_LOOK == 1
	{
		const float s = 0.33;
		vec3 mb = GammaToLinear(texture2D(COLOR_TEX, texcoord.st + ScreenTexel * vec2(s, s)).rgb)
				  + GammaToLinear(texture2D(COLOR_TEX, texcoord.st + ScreenTexel * vec2(s, -s)).rgb)
				  + GammaToLinear(texture2D(COLOR_TEX, texcoord.st + ScreenTexel * vec2(-s, s)).rgb)
				  + GammaToLinear(texture2D(COLOR_TEX, texcoord.st + ScreenTexel * vec2(-s, -s)).rgb);

		color = mix(color, mb * 0.25, vec3(0.999));
	}
	#endif
	#endif



	color = mix(color, GetBloom(texcoord.st), vec3(0.055 * BLOOM_AMOUNT + isEyeInWater * 0.6));


	Vignette(color);

	color = BlackDepth(color, vec3(0.000015 * BLACK_DEPTH * BLACK_DEPTH));


	AverageExposure(color);
	// color *= 71.0;




	// const float blackRolloff = 0.005 * BLACK_DEPTH;
	// const float blackClip = 0.0;

 //    color = vec3(
 //    	almostIdentity(color.x, blackRolloff, blackClip),
 //    	almostIdentity(color.y, blackRolloff, blackClip),
 //    	almostIdentity(color.z, blackRolloff, blackClip)
 //    	) - blackClip;




	color *= 9.6 * EXPOSURE; 


	color = saturate(TONEMAP_OPERATOR(color) * (1.0 + WHITE_CLIP));


	// color = texture2DLod(shadowcolor1, texcoord.st * 0.5 + 0.5, 0).rrr;



	color = pow(color, vec3(1.0 / 2.2 + (1.0 - GAMMA)));


	color = (mix(color, vec3(Luminance(color)), vec3(1.0 - SATURATION)));
	// color = (mix(color, vec3(Luminance(color)), vec3(
	// 	(-Luminance(color) * 0.4) + 0.1
	// 	)));

	// color = (mix(color, vec3(Luminance(color)), vec3(
	// 	(-Luminance(color) * 0.2) + 0.0
	// )));




	color += rand(texcoord.st) * (1.0 / 255.0);

	// color = mix(color, SampleCPrmwMXxJc(texcoord.xy).PVAMAgODVh * 3.0, vec3(0.9));

	// color = vec3(texture2DLod(colortex7, texcoord.st, 0).a);

	// color = texture2D(colortex6, texcoord.st).rgb * 12.0;
	// color = texture2D(colortex2, texcoord.st).rgb * 1.0;

	// color = vec3(texture2D(colortex2, texcoord.st).rgb) * 1.0;
	// color = vec3(texture2D(colortex4, texcoord.st).rgb) * 12.0;

	// color = vec3(texture2D(colortex1, texcoord.st).rgb) * 10.0;



	gl_FragData[0] = vec4(color.rgb, Luminance(color.rgb));
}


/* DRAWBUFFERS:0 */
