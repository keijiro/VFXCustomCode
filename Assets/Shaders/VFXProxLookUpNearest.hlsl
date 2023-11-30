#include "VFXProxCommon.hlsl"

float3 VFXProxLookUpNearest(float3 pos)
{
    float4 cand = 1e+5;
    for (int i = -1; i < 2; i++)
    {
        for (int j = -1; j < 2; j++)
        {
            for (int k = -1; k < 2; k++)
            {
                uint cell = VFXProxCellIndex(pos + float3(i, j, k) * VFXProxCellSize);
                cand = VFXProxLookUp(pos, cell, cand);
            }
        }
    }
    return cand.w < 1e+5 ? cand.xyz : pos;
}
