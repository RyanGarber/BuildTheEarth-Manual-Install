

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////// Bloom Prepass ////////////////////////////////////////////////////////////////////////////////////
vec3 CurveBloomInputColor(vec3 color)
{
	// color = pow(length(color), 2.0) * 10.0 * normalize(color + 0.000001);
	return color;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////// Bloom Pass 1 /////////////////////////////////////////////////////////////////////////////////////
vec3 GetColorForBloomPass1(vec2 coord)
{
	return texture2D(colortex7, coord).rgb;
}

vec2 BloomClampCoord(vec2 coord, vec2 texel)
{
	//return clamp(coord, texel, 1.0 - texel);
	return saturate(coord);
}

vec3 GrabBlurH(vec2 coord, const float octave, const vec2 offset)
{
	float scale = exp2(octave);

	coord += offset;
	coord *= scale;

	vec2 texel = scale * ScreenTexel;
	vec2 lowBound  = 0.0 - 10.0 * texel;
	vec2 highBound = 1.0 + 10.0 * texel;

	if (coord.x < lowBound.x || coord.x > highBound.x || coord.y < lowBound.y || coord.y > highBound.y)
	{
		return vec3(0.0);
	}

	vec3 color = vec3(0.0);

	float weights[5] = float[5](0.27343750, 0.21875000, 0.10937500, 0.03125000, 0.00390625);
	float offsets[5] = float[5](0.00000000, 1.00000000, 2.00000000, 3.00000000, 4.00000000);

	color += GammaToLinear(GetColorForBloomPass1(BloomClampCoord(coord, texel))) * weights[0];

	for (int i = 1; i < 5; i++)
	{
		color += GammaToLinear(GetColorForBloomPass1(BloomClampCoord(coord + vec2(offsets[i], 0.0) * texel, texel))) * weights[i];
		color += GammaToLinear(GetColorForBloomPass1(BloomClampCoord(coord - vec2(offsets[i], 0.0) * texel, texel))) * weights[i];
	}

	return color;
}

vec2 GetBloomLevelOffset(float octave)
{
    vec2 offset = vec2(0.0);
    vec2 padding = vec2(30.0) * ScreenTexel;

    octave += 0.0001;	// AMD FIX
    
    offset.x = -min(1.0, floor(octave / 3.0)) * (0.25 + padding.x);
    offset.y = -(1.0 - (1.0 / exp2(octave))) - padding.y * octave;
	offset.y += min(1.0, floor(octave / 3.0)) * 0.35;
    
 	return offset;   
}


vec3 CalculateBloomPass1(vec2 coord)
{
	vec3 bloomColor = vec3(0.0);
	bloomColor += GrabBlurH(coord, 1.0, vec2(0.0, 0.0));
	bloomColor += GrabBlurH(coord, 2.0, GetBloomLevelOffset(1.0));
	bloomColor += GrabBlurH(coord, 3.0, GetBloomLevelOffset(2.0));
	bloomColor += GrabBlurH(coord, 4.0, GetBloomLevelOffset(3.0));
	bloomColor += GrabBlurH(coord, 5.0, GetBloomLevelOffset(4.0));
	bloomColor += GrabBlurH(coord, 6.0, GetBloomLevelOffset(5.0));
	bloomColor += GrabBlurH(coord, 7.0, GetBloomLevelOffset(6.0));
	bloomColor += GrabBlurH(coord, 8.0, GetBloomLevelOffset(7.0));
	bloomColor += GrabBlurH(coord, 9.0, GetBloomLevelOffset(8.0));

	bloomColor = LinearToGamma(bloomColor);

	return bloomColor;
}







////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////// Bloom Pass 2 /////////////////////////////////////////////////////////////////////////////////////
vec3 GetColorForBloomPass2(vec2 coord)
{
	return texture2DLod(colortex7, coord, 0).rgb;
}

vec3 BlurV(vec2 coord)
{

	vec3 color = vec3(0.0);

	vec2 texel = ScreenTexel;


	float weights[5] = float[5](0.27343750, 0.21875000, 0.10937500, 0.03125000, 0.00390625);
	float offsets[5] = float[5](0.00000000, 1.00000000, 2.00000000, 3.00000000, 4.00000000);
	
	color += GammaToLinear(GetColorForBloomPass2(coord)) * weights[0];

	for (int i = 1; i < 5; i++)
	{
		color += GammaToLinear(GetColorForBloomPass2(coord + vec2(0.0, offsets[i] * 1.0) * texel)) * weights[i];
		color += GammaToLinear(GetColorForBloomPass2(coord - vec2(0.0, offsets[i] * 1.0) * texel)) * weights[i];
	}

	return color;
}

vec3 CalculateBloomPass2(vec2 coord)
{
	return BlurV(coord);
}







////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////// Final retrieval of bloom /////////////////////////////////////////////////////////////////////////
vec3 GetBloomTex(vec2 coord)
{
	return texture2DLod(colortex7, coord, 0).rgb;
}

vec3 GetBloomTap(vec2 coord, const float octave, const vec2 offset)
{
	float scale = exp2(octave);

	coord /= scale;
	coord -= offset;

	// return GammaToLinear(BicubicTexture(BLOOM_TEX, coord).rgb);
	return (GetBloomTex(coord));
}

vec3 GetBloom(vec2 coord)
{
	vec3 bloom = vec3(0.0);

	// bloom += GetBloomTap(coord, 1.0, vec2(0.0)) 			   * 2.0;
	// bloom += GetBloomTap(coord, 2.0, GetBloomLevelOffset(1.0)) * 1.5;
	// bloom += GetBloomTap(coord, 3.0, GetBloomLevelOffset(2.0)) * 1.2;
	// bloom += GetBloomTap(coord, 4.0, GetBloomLevelOffset(3.0)) * 1.3;
	// bloom += GetBloomTap(coord, 5.0, GetBloomLevelOffset(4.0)) * 1.4;
	// bloom += GetBloomTap(coord, 6.0, GetBloomLevelOffset(5.0)) * 1.3;
	// bloom += GetBloomTap(coord, 7.0, GetBloomLevelOffset(6.0)) * 1.2;
	// bloom += GetBloomTap(coord, 8.0, GetBloomLevelOffset(7.0)) * 1.1;
	// bloom += GetBloomTap(coord, 9.0, GetBloomLevelOffset(8.0)) * 0.0;


	// bloom /= 12.6;

	float w = 0.0;
	float ws = 0.0;
	const float p = 1.3;
		
	w = 1.0 / pow(p, 1.0); ws += w; bloom += GetBloomTap(coord, 1.0, vec2(0.0)) 			   		* w;
	w = 1.0 / pow(p, 2.0); ws += w; bloom += GetBloomTap(coord, 2.0, GetBloomLevelOffset(1.0)) 	* w;
	w = 1.0 / pow(p, 3.0); ws += w; bloom += GetBloomTap(coord, 3.0, GetBloomLevelOffset(2.0)) 	* w;
	w = 1.0 / pow(p, 4.0); ws += w; bloom += GetBloomTap(coord, 4.0, GetBloomLevelOffset(3.0)) 	* w;
	w = 1.0 / pow(p, 5.0); ws += w; bloom += GetBloomTap(coord, 5.0, GetBloomLevelOffset(4.0)) 	* w;
	w = 1.0 / pow(p, 6.0); ws += w; bloom += GetBloomTap(coord, 6.0, GetBloomLevelOffset(5.0)) 	* w;
	w = 1.0 / pow(p, 7.0); ws += w; bloom += GetBloomTap(coord, 7.0, GetBloomLevelOffset(6.0)) 	* w;
	w = 1.0 / pow(p, 8.0); ws += w; bloom += GetBloomTap(coord, 8.0, GetBloomLevelOffset(7.0)) 	* w;
	w = 1.0 / pow(p, 9.0); ws += w; bloom += GetBloomTap(coord, 9.0, GetBloomLevelOffset(8.0)) 	* w;
	
	bloom /= ws;

	return bloom;
}
