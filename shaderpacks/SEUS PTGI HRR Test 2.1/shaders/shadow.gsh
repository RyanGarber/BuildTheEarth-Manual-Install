#version 330 compatibility

layout(triangles) in;
layout(triangle_strip, max_vertices = 6) out;

in vec4 vTexcoord[];
in vec4 vColor[];
// in vec3 vnormal[];
// in vec3 vrawNormal[];
in vec4 vViewPos[];
in float vMaterialIDs[];

in float NfBQQONGIL[];
in vec2 iqqNEmzHrA[];   	
in float GgEUdJcgVD[];
// in float vIsWater[];
// in float vIsStainedGlass[];
in float vMCEntity[];
in vec3 MHKfCXtBYe[];  

in vec4 zoZckPcbco[];
in vec4 RrnawHBGMh[];



out vec4 color;
out vec4 texcoord;
// out vec3 normal;
// out vec3 rawNormal;
out vec4 viewPos;
out float materialIDs;

out float aGBCSUeTQs;		
out vec2 sbxhonUINy;		
out float fragDepth;
// out float isWater;
// out float isStainedGlass;
out float mcEntity;
out vec3 zrEuGoMOCd;  	


void main()
{
	int i;
	vec4 vertex;

	//Standard shadow pos
	for (i = 0; i < 3; i++)
	{
		vertex = gl_in[1].gl_Position;

		//...
		vertex = RrnawHBGMh[i];

		gl_Position = vertex;

		//copy varying here
		color = vColor[i];
		texcoord = vTexcoord[i];
		// normal = vnormal[i];
		// rawNormal = vrawNormal[i];
		viewPos = vViewPos[i];
		materialIDs = vMaterialIDs[i];
		sbxhonUINy = iqqNEmzHrA[i];
		fragDepth = GgEUdJcgVD[i];
		// isWater = vIsWater[i];
		// isStainedGlass = vIsStainedGlass[i];
		mcEntity = vMCEntity[i];
		aGBCSUeTQs = 0.0;

		EmitVertex();
	}
	EndPrimitive();


	//volume pos
	bool valid = true;
	if (NfBQQONGIL[0] > 0.5 || NfBQQONGIL[1] > 0.5 || NfBQQONGIL[2] > 0.5)
	{
		valid = false;
	}

	if (valid)
	{
		if (distance(zoZckPcbco[0].xy, zoZckPcbco[1].xy) > 1.0 / 1024.0 ||
			distance(zoZckPcbco[0].xy, zoZckPcbco[2].xy) > 1.0 / 1024.0 ||
			distance(zoZckPcbco[1].xy, zoZckPcbco[2].xy) > 1.0 / 1024.0)
		{

		}
		else
		{
			for (i = 0; i < 3; i++)
			{
				vertex = gl_in[1].gl_Position;

				//...
				vertex = zoZckPcbco[i];


				gl_Position = vertex;

				//copy varying here
				color = vColor[i];
				texcoord = vTexcoord[i];
				// normal = vnormal[i];
				// rawNormal = vrawNormal[i];
				viewPos = vViewPos[i];
				materialIDs = vMaterialIDs[i];
				sbxhonUINy = iqqNEmzHrA[i];
				fragDepth = GgEUdJcgVD[i];
				// isWater = vIsWater[i];
				// isStainedGlass = vIsStainedGlass[i];
				mcEntity = vMCEntity[i];
				zrEuGoMOCd = MHKfCXtBYe[i];
				aGBCSUeTQs = 1.0;


				EmitVertex();
			}
			EndPrimitive();
		}
	}


	// vec4 bottomLeft = 	vec4(-1.0, 	0.0, 	0.0, 1.0);
	// vec4 bottomRight = 	vec4(0.0, 	0.0, 	0.0, 1.0);
	// vec4 topLeft = 		vec4(-1.0, 	1.0,    0.0, 1.0);
	// vec4 topRight = 	vec4(0.0, 	1.0,    0.0, 1.0);

	// //Albedo quad
	// color = vec4(1.0);
	// normal = vec3(1.0);
	// rawNormal = vec3(1.0);
	// viewPos = vec4(0.0);
	// materialIDs = 1.0;
	// isStainedGlass = 0.0;
	// aGBCSUeTQs = 0.0;

	// texcoord = vec4(0.0, 0.0, 0.0, 0.0);
	// gl_Position = bottomLeft;

	// EmitVertex();


	// texcoord = vec4(0.0, 1.0, 0.0, 0.0);
	// gl_Position = topLeft;

	// EmitVertex();


	// texcoord = vec4(1.0, 1.0, 0.0, 0.0);
	// gl_Position = topRight;

	// EmitVertex();


	// EndPrimitive();



	// texcoord = vec4(0.0, 0.0, 0.0, 0.0);
	// gl_Position = bottomLeft;

	// EmitVertex();



	// texcoord = vec4(1.0, 1.0, 0.0, 0.0);
	// gl_Position = topRight;

	// EmitVertex();



	// texcoord = vec4(1.0, 0.0, 0.0, 0.0);
	// gl_Position = bottomRight;

	// EmitVertex();


	// EndPrimitive();



}
