#include "VFXProxCommon.hlsl"

float3 VFXProxLookUpNearest(float3 pos)
{
    float3 cand = 10000;
    float dist = 10000;

    for (int i = -1; i < 2; i++)
    {
        for (int j = -1; j < 2; j++)
        {
            for (int k = -1; k < 2; k++)
            {
                uint cell = VFXProxCellIndex(pos + float3(i, j, k) * VFXProxCellSize);
                float3 p = VFXProxLookUp(pos, cell);
                float d = length(p - pos);
                if (d < dist)
                {
                    cand = p;
                    dist = d;
                }
            }
        }
    }

    return dist < 1000 ? cand : pos;
}
