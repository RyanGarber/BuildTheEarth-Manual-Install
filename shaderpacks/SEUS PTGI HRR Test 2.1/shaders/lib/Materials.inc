#define MAT_ID_OPAQUE 1
#define MAT_ID_GRASS 2
#define MAT_ID_LEAVES 3
#define MAT_ID_HAND 4
#define MAT_ID_ENTITY_PLAYER 5
#define MAT_ID_WATER 6
#define MAT_ID_STAINED_GLASS 7
#define MAT_ID_ICE 8
#define MAT_ID_TORCH 30
#define MAT_ID_LAVA 31
#define MAT_ID_GLOWSTONE 32
#define MAT_ID_FIRE 33
#define MAT_ID_LIT_FURNACE 34
#define MAT_ID_DYNAMIC_ENTITY 35



struct MaterialMask
{
	float sky;
	float opaque;
	float grass;
	float leaves;
	float hand;
	float entityPlayer;
	float water;
	float stainedGlass;
	float ice;
	float torch;
	float lava;
	float glowstone;
	float fire;
	float litFurnace;
	float dynamicEntity;
};


float GetMaterialMask(const in int ID, in float matID) 
{
	//Catch last part of sky
	if (matID > 254.0f) 
	{
		matID = 0.0f;
	}

	if (matID == ID) 
	{
		return 1.0f;
	} 
	else 
	{
		return 0.0f;
	}
}

MaterialMask CalculateMasks(float materialID, vec2 coord)
{
	MaterialMask OmcxSfXfkJ;

	materialID *= 255.0;

	// if (isEyeInWater > 0)
	// {
	// 	// OmcxSfXfkJ.sky = 0.0f;
	// }
	// else
	{
		OmcxSfXfkJ.sky = 0.0;
		if (texture2D(depthtex1, coord.st).x > 0.999999)
		{
			OmcxSfXfkJ.sky = 1.0;
		}
	}
		//OmcxSfXfkJ.sky = GetMaterialMask(0, materialID);
		//OmcxSfXfkJ.sky = texture2D(depthtex1, texcoord).x > 0.999999 ? 1.0 : 0.0;



	OmcxSfXfkJ.opaque 		= GetMaterialMask(MAT_ID_OPAQUE, materialID);
	OmcxSfXfkJ.grass 			= GetMaterialMask(MAT_ID_GRASS, materialID);
	OmcxSfXfkJ.leaves 		= GetMaterialMask(MAT_ID_LEAVES, materialID);
	OmcxSfXfkJ.hand 			= GetMaterialMask(MAT_ID_HAND, materialID);
	OmcxSfXfkJ.entityPlayer 	= GetMaterialMask(MAT_ID_ENTITY_PLAYER, materialID);
	OmcxSfXfkJ.water 			= GetMaterialMask(MAT_ID_WATER, materialID);
	OmcxSfXfkJ.stainedGlass	= GetMaterialMask(MAT_ID_STAINED_GLASS, materialID);
	OmcxSfXfkJ.ice 			= GetMaterialMask(MAT_ID_ICE, materialID);
	OmcxSfXfkJ.torch 			= GetMaterialMask(MAT_ID_TORCH, materialID);
	OmcxSfXfkJ.lava 			= GetMaterialMask(MAT_ID_LAVA, materialID);
	OmcxSfXfkJ.glowstone 		= GetMaterialMask(MAT_ID_GLOWSTONE, materialID);
	OmcxSfXfkJ.fire 			= GetMaterialMask(MAT_ID_FIRE, materialID);
	OmcxSfXfkJ.litFurnace 	= GetMaterialMask(MAT_ID_LIT_FURNACE, materialID);
	OmcxSfXfkJ.dynamicEntity 	= GetMaterialMask(MAT_ID_DYNAMIC_ENTITY, materialID);

	return OmcxSfXfkJ;
}
