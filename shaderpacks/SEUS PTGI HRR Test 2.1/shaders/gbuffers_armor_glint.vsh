#version 330 compatibility

out vec4 color;
out vec4 texcoord;
out vec3 worldPos;
out vec4 preDownscaleProjPos;

#include "lib/Uniforms.inc"
#include "lib/Common.inc"




void main() {

	texcoord = gl_MultiTexCoord0;


	// gl_Position = ftransform();

	worldPos = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;


	vec4 vp = gl_ModelViewMatrix * gl_Vertex;

	FinalVertexTransformTAA(gl_Position, preDownscaleProjPos);




	color = gl_Color;

	gl_FogFragCoord = gl_Position.z;
}
