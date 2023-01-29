#version 330 compatibility

out vec4 color;
out vec4 preDownscaleProjPos;

#include "lib/Uniforms.inc"
#include "lib/Common.inc"




void main() {
	gl_Position = ftransform();

	FinalVertexTransformTAA(gl_Position, preDownscaleProjPos);

	
	color = gl_Color;

	gl_FogFragCoord = gl_Position.z;
}
