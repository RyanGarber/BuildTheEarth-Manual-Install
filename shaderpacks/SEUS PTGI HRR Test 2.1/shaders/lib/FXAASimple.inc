
vec3 DoFXAASimple(sampler2D tex, vec2 coord, vec2 texelSize)
{   
	#ifdef SKIP_AA
	return texture2DLod(tex, coord, 0).rgb;
	#endif
/*---------------------------------------------------------*/





	const float FXAA_REDUCE_MIN =  (1.0/8.0);
	const float FXAA_REDUCE_MUL =  (1.0/16.0);
	const float FXAA_SPAN_MAX   =  (16.0);

/*---------------------------------------------------------*/
	vec2 coordSubpixShifted = coord - texelSize * (0.5);
	vec3 rgbNW = texture2DLod(tex, coordSubpixShifted, 0).xyz;
	vec3 rgbNE = texture2DLod(tex, coordSubpixShifted + vec2(1,0) * texelSize, 0).xyz;
	vec3 rgbSW = texture2DLod(tex, coordSubpixShifted + vec2(0,1) * texelSize, 0).xyz;
	vec3 rgbSE = texture2DLod(tex, coordSubpixShifted + vec2(1,1) * texelSize, 0).xyz;
	vec3 rgbM  = texture2DLod(tex, coord, 0).xyz;
/*---------------------------------------------------------*/
	vec3 luma = vec3(0.299, 0.587, 0.114);
	float lumaNW = dot(rgbNW, luma);
	float lumaNE = dot(rgbNE, luma);
	float lumaSW = dot(rgbSW, luma);
	float lumaSE = dot(rgbSE, luma);
	float lumaM  = dot(rgbM,  luma);
/*---------------------------------------------------------*/
	float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
	float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
/*---------------------------------------------------------*/
	vec2 dir; 
	dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
	dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));

	// dir.xy = min(abs(dir.xy), vec2(0.015)) * sign(dir.xy);
/*---------------------------------------------------------*/
	float dirReduce = max(
		(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
		FXAA_REDUCE_MIN);
	float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
	dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX), 
		  max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), 
		  dir * rcpDirMin)) * texelSize;
/*--------------------------------------------------------*/
	vec3 rgbA = (1.0/2.0) * (
		texture2DLod(tex, coord.xy + dir * (1.0/3.0 - 0.5), 0).xyz +
		texture2DLod(tex, coord.xy + dir * (2.0/3.0 - 0.5), 0).xyz);
	vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
		texture2DLod(tex, coord.xy + dir * (0.0/3.0 - 0.5), 0).xyz +
		texture2DLod(tex, coord.xy + dir * (3.0/3.0 - 0.5), 0).xyz);
	float lumaB = dot(rgbB, luma);
	if((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;
	return rgbB; 
}
