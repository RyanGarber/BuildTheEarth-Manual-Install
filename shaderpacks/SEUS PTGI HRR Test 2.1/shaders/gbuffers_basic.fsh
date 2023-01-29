#version 330 compatibility

#include "lib/Uniforms.inc"
#include "lib/Common.inc"

in vec4 color;
in vec4 preDownscaleProjPos;

/* DRAWBUFFERS:0 */


void main() {
	if (PixelOutOfScreenBounds(preDownscaleProjPos)) {
		discard;
		return;
	}
	vec4 albedo = color;
	albedo.a = 0.5;
	gl_FragData[0] = albedo;
}
