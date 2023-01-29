

vec2 rot(vec2 p, float angle)
{
    vec2 po = p;
    // p.x = po.x * cos(angle) - po.y * sin(angle);
    // p.y = po.x * sin(angle) - po.y * cos(angle);

    mat2 mat = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));

    p = mat * p;

    return p;
}

vec2 WeylNth(int n)
{
	#ifdef SKIP_AA
	return vec2(0.0);
	#endif
	// return fract(vec2(n * 12664745, n*9560333) / exp2(24.0));
	

	// vec2 v = vec2(n % 2, (n / 2) % 2).yx / 2.0;
	// return v;

	const int bayerMatrix[16] = int[16](
		0,  8,  2, 10,
		12, 4,  14, 6, 
		3,  11, 1,  9,
		15, 7,  13, 5
	);
	int i = bayerMatrix[n];
	return vec2(i % 4, (i / 4) % 4).yx / 4.0;


	const vec2 m[8] = vec2[8](
		vec2(0.0, 0.0)
		,vec2(0.5, 0.5)
		,vec2(0.5, 0.0)
		,vec2(0.0, 0.5)
		,vec2(0.24, 0.24) 
		,vec2(0.74, 0.74)
		,vec2(0.74, 0.24) 
		,vec2(0.24, 0.74)
	);
	return m[n % 8];
	// return m[n % 4];

}

vec2 JitterSampleOffset(int frameOffset)
{
	return (WeylNth((frameCounter + frameOffset) % 16) * 2.0 - 1.0);
}

void TemporalJitterProjPos(inout vec4 pos)
{
	pos.xy += (JitterSampleOffset(0) * 1.0) / vec2(viewWidth, viewHeight);
}

void TemporalJitterProjPos01(inout vec2 pos)
{
	pos.xy += (JitterSampleOffset(0) * 0.5) / vec2(viewWidth, viewHeight);
}

void TemporalJitterProjPosInv01(inout vec2 pos)
{
	pos.xy -= (JitterSampleOffset(0) * 0.5) / vec2(viewWidth, viewHeight);
}


void TemporalJitterProjPosPrevInv(inout vec4 pos)
{
	vec2 prevOffset = JitterSampleOffset(-1);
	vec2 thisOffset = JitterSampleOffset(0);
	pos.xy += (prevOffset - thisOffset) / vec2(viewWidth, viewHeight) * 0.5;
	// pos.xy += (JitterSampleOffset(-1)) / vec2(viewWidth, viewHeight);
}







#define DOWNSCALE_FACTOR 0.5
#define DOWNSCALE_FACTOR_MULT 2

vec4 DownscaleProjectionCoord(vec4 pos) {
	pos.xy = pos.xy * 0.5 + 0.5;
	pos.xy *= DOWNSCALE_FACTOR;
	pos.xy = pos.xy * 2.0 - 1.0;
	return pos;
}

vec2 UndownscaleTexcoord(vec2 coord) {
	return coord / DOWNSCALE_FACTOR;
}

vec2 DownscaleTexcoord(vec2 coord) {
	return coord * DOWNSCALE_FACTOR;
}

void CropQuadForDownscale(inout vec4 pos, inout vec4 coord) {
	// pos = DownscaleProjectionCoord(pos);
	// pos += sin(FRAME_TIME);
	pos.xy *= DOWNSCALE_FACTOR;
	pos.xy -= 0.5;
	coord.xy *= DOWNSCALE_FACTOR;
}





void FinalVertexTransformTAA(inout vec4 pos, inout vec4 preDownscaleProjPos) {
	//Temporal jitter
	preDownscaleProjPos = pos;
	pos.xyz /= pos.w;
	pos = DownscaleProjectionCoord(pos);
	TemporalJitterProjPos(pos);
	pos.xyz *= pos.w;
}

bool PixelOutOfScreenBounds(vec4 preDownscaleProjPos) {
	return  (preDownscaleProjPos.x / preDownscaleProjPos.w > (1.0 + ScreenTexel.x) || preDownscaleProjPos.y / preDownscaleProjPos.w > (1.0 + ScreenTexel.y));
}
