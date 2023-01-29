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
	return pow(texture2DLod(colortex6, coord, 0).rgb, vec3(2.2));
}

vec2 GetNearFragment(vec2 coord, float depth)
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

	return coord + texel * targetFragment;
}

void 	MotionBlur(inout vec3 color) {

























































	vec3 dither = BlueNoiseTemporal(texcoord.xy);

	color.xy = (texture2DLod(colortex2, texcoord.xy / 8.0, 0).xy * 2.0 - 1.0) / 256.0;


}

#include "lib/Bloom.inc"

/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main() {

	#ifdef MOTION_BLUR

	vec2 maxVelocity = (texture2DLod(colortex2, texcoord.xy, 0).xy * 2.0 - 1.0);
	float maxLen = 0.0;

	if (texcoord.x < 1.0 / 16.0 && texcoord.y < 1.0 / 16.0)
	{
		for (int i = -2; i <= 2; i++)
		{
			for (int j = -2; j <= 2; j++)
			{
				vec2 coord = texcoord.xy + vec2(i, j) * ScreenTexel;

				coord = clamp(coord, vec2(0.0), vec2(1.0 / 16.0));

				vec2 vel = (texture2DLod(colortex2, coord, 0).xy * 2.0 - 1.0);
				float len = length(vel);

				if (len > maxLen 
					&& abs(dot(normalize(vec2(i, j)), normalize(vel))) > 0.9
					&& len > length(vec2(i, j)) * 0.1
				)
				{
					maxLen = len;
					maxVelocity = vel;
				}
			}
		}
	}

	gl_FragData[0] = texture2DLod(colortex6, texcoord.xy, 0);
	gl_FragData[1] = vec4(maxVelocity * 0.5 + 0.5, 0.0, 1.0);
	#else
	gl_FragData[0] = texture2DLod(colortex6, texcoord.xy, 0);
	gl_FragData[1] = texture2DLod(colortex2, texcoord.xy, 0);
	#endif
}

/* DRAWBUFFERS:12 */
