#include "VFXProxCommon.hlsl"

void VFXProxLookUpNearest(float3 pos, out float3 first, out float3 second)
{
    float4 cand1 = 1e+5;
    float4 cand2 = 1e+5;

    for (int i = -1; i < 2; i++)
    {
        for (int j = -1; j < 2; j++)
        {
            for (int k = -1; k < 2; k++)
            {
                uint cell = VFXProxCellIndex(pos + float3(i, j, k) * VFXProxCellSize);
                VFXProxLookUp(pos, cell, cand1, cand2);
            }
        }
    }

    first  = cand1.w < 1e+5 ? cand1.xyz : pos;
    second = cand2.w < 1e+5 ? cand2.xyz : pos;
}
