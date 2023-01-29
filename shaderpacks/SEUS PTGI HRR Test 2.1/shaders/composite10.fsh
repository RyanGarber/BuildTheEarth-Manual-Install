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



#include "lib/Uniforms.inc"
#include "lib/Common.inc"




in vec4 texcoord;


vec3 GetColorTexture(vec2 coord)
{
	return pow(texture2DLod(colortex1, coord, 0).rgb, vec3(2.2));
}

#include "lib/Bloom.inc"

/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main() {

	vec3 color = vec3(0.0);

	color = GetColorTexture(texcoord.st);

	#ifdef MOTION_BLUR
	float VelMult = 0.125 * MOTION_BLUR_INTENSITY;

	vec2 velocity = ((texture2DLod(colortex2, texcoord.xy / 16.0, 0).xy * 2.0 - 1.0) / 1.0) * VelMult;

	// vec3 dither = BlueNoiseTemporal(texcoord.xy) - 0.5;
	vec3 dither = vec3(0.0);



	vec3 sum = vec3(0.0);
	float weights = 0.0;

	for (int i = -2; i <= 2; i++)
	{
		float fi = float(i + dither.x) / 5.0;
		vec2 offs = fi * velocity;
		vec2 coord = texcoord.xy + offs;

		float weight = 1.0;

		sum += GetColorTexture(coord);// * weight;
		weights += weight;
	}

	sum /= weights;
	color = sum;
	#endif


	color = pow(color, vec3(1.0 / 2.2));


	gl_FragData[0] = vec4(color, Luminance(color));
	gl_FragData[1] = vec4(CurveBloomInputColor(color), 1.0);
}

/* DRAWBUFFERS:17 */
