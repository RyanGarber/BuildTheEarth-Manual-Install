#version 330 compatibility

#include "lib/Uniforms.inc"
#include "lib/Common.inc"

in vec4 color;
in vec4 preDownscaleProjPos;


void main() {
	if (PixelOutOfScreenBounds(preDownscaleProjPos)) {
		discard;
		return;
	}
	vec3 skyColor = color.rgb;

	

	skyColor.rgb *= 0.0;
	//skyColor.rgb = vec3(1.0, 0.0, 0.0);

	//if (color.a < 0.6f)
	//{
	//	skyColor.rgb = vec3(0.75f);
	//}

	float saturation = abs(color.r - color.g) + abs(color.r - color.b) + abs(color.g - color.b);

	if (saturation <= 0.01 && length(color.rgb) > 0.5)
	{
		skyColor.rgb = vec3(0.4);
	}

	

	gl_FragData[0] = vec4(skyColor.rgb, 1.0);
	gl_FragData[1] = vec4(0.0f, 0.0f, 0.0f, 1.0f);
	
	
	//gl_FragData[2] = vec4(0.0f, 0.0f, 0.0f, 1.0f);
	//gl_FragData[3] = vec4(0.0f, 0.0f, 0.0f, 1.0f);
}

/* DRAWBUFFERS:01 */
