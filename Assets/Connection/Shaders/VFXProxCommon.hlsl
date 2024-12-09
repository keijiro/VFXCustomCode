#ifndef _VFXPROX_COMMON_H_
#define _VFXPROX_COMMON_H_

// These constants must match those defined in VFXProxBuffer.cs
static const uint VFXProxCellsPerAxis = 16;
static const uint VFXProxCellCapacity = 16;

RWStructuredBuffer<float3> VFXProxPointBuffer;
RWStructuredBuffer<uint>   VFXProxCountBuffer;

float3 VFXProxCellSize;

uint VFXProxCellIndex(float3 pos)
{
    uint3 c = max(0, pos / VFXProxCellSize + VFXProxCellsPerAxis / 2);
    c = min(c, VFXProxCellsPerAxis - 1);
    return c.x + VFXProxCellsPerAxis * (c.y + VFXProxCellsPerAxis * c.z);
}

void VFXProxAddPoint(float3 pos)
{
    uint index = VFXProxCellIndex(pos);
    uint count = 0;
    InterlockedAdd(VFXProxCountBuffer[index], 1, count);
    if (count < VFXProxCellCapacity)
        VFXProxPointBuffer[index * VFXProxCellCapacity + count] = pos;
}

void VFXProxLookUp(float3 pos, uint cell, inout float4 cand1, inout float4 cand2)
{
    uint count = VFXProxCountBuffer[cell];
    uint ref_i = cell * VFXProxCellCapacity;
    for (uint i = 0; i < count; i++)
    {
        float3 pt = VFXProxPointBuffer[ref_i++];
        float dist = length(pt - pos);
        if (1e-5f < dist)
        {
            if (dist < cand1.w)
            {
                cand2 = cand1;
                cand1 = float4(pt, dist);
            }
            else if (dist < cand2.w)
            {
                cand2 = float4(pt, dist);
            }
        }
    }
}

void VFXProxLookUpNearestPair(float3 pos, out float3 first, out float3 second)
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

#endif // _VFXPROX_COMMON_H_
