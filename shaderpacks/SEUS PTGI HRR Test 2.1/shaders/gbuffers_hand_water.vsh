#version 330 compatibility



#define GLOWING_REDSTONE_BLOCK // If enabled, redstone blocks are treated as light sources for GI
#define GLOWING_LAPIS_LAZULI_BLOCK // If enabled, lapis lazuli blocks are treated as light sources for GI


#define GENERAL_GRASS_FIX

#include "lib/Uniforms.inc"


attribute vec4 mc_Entity;
attribute vec4 at_tangent;
attribute vec4 mc_midTexCoord;



out vec4 color;
out vec4 texcoord;
out vec4 lmcoord;
out vec3 worldPosition;
out vec3 viewPos;
out vec4 preDownscaleProjPos;

out vec3 worldNormal;

out vec2 blockLight;

out float materialIDs;


#include "lib/Common.inc"
#include "lib/Materials.inc"


void main() {

	color = gl_Color;

	texcoord = gl_MultiTexCoord0;
	lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;

	blockLight.x = clamp((lmcoord.x * 33.05f / 32.0f) - 1.05f / 32.0f, 0.0f, 1.0f);
	blockLight.y = clamp((lmcoord.y * 33.75f / 32.0f) - 1.05f / 32.0f, 0.0f, 1.0f);

	worldNormal = gl_Normal;

	
	vec4 localWorldPos = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

	worldPosition = localWorldPos.xyz + cameraPosition.xyz;
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;


	


	//Gather materials
	materialIDs = 7.0f;

	// // if (mc_Entity.x == 95 || mc_Entity.x == 160)
	// if (mc_Entity.x  < 1)
	// {
	// 	materialIDs = 7.0;
	// }

	if (mc_Entity.x == 79.0) // ice
	{
		materialIDs = 8.0;
	}



	


	float fixOldLighting = 1.0;

	if (color.r == 1.0 && color.g == 1.0 && color.b == 1.0)
	{
		fixOldLighting = 0.0;
	}













	gl_Position = gl_ProjectionMatrix * gbufferModelView * localWorldPos;

	FinalVertexTransformTAA(gl_Position, preDownscaleProjPos);


}
