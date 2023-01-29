#version 330 compatibility

#include "lib/Uniforms.inc"
#include "lib/Common.inc"

out vec4 color;
out vec4 texcoord;
out vec4 preDownscaleProjPos;


void main() {
	gl_Position = ftransform();

	FinalVertexTransformTAA(gl_Position, preDownscaleProjPos);

	
	color = gl_Color;
	
	texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;

	gl_FogFragCoord = gl_Position.z;

	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;


	vec3 viewVec = normalize(viewPos.xyz);


}
