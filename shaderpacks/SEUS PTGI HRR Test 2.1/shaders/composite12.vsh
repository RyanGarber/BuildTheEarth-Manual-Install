#version 330 compatibility


#include "lib/Uniforms.inc"

out vec4 texcoord;


out vec3 lightVector;
out vec3 upVector;

out float timeSunriseSunset;
out float timeNoon;
out float timeMidnight;
out float timeSkyDark;

out vec3 colorSunlight;
out vec3 colorSkylight;
out vec3 colorSunglow;
out vec3 colorBouncedSunlight;
out vec3 colorScatteredSunlight;
out vec3 colorTorchlight;
out vec3 colorWaterMurk;
out vec3 colorWaterBlue;
out vec3 colorSkyTint;


float CubicSmooth(in float x)
{
	return x * x * (3.0f - 2.0f * x);
}

float clamp01(float x)
{
	return clamp(x, 0.0, 1.0);
}

vec2 Crop(vec2 p)
{
	p.x *= 0.51;
	return p;
}

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0;

	gl_Position.xy = gl_Position.xy * 0.5 + 0.5;
	texcoord.xy = Crop(texcoord.xy);
	gl_Position.xy = Crop(gl_Position.xy);
	gl_Position.xy = gl_Position.xy * 2.0 - 1.0;

}
