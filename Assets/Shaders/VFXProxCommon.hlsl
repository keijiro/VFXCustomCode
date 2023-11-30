#ifndef _VFXPROX_COMMON_H_
#define _VFXPROX_COMMON_H_

// These constants should match with ones in VFXProxBuffer.cs
static const uint VFXProxCellsPerAxis = 16;
static const uint VFXProxCellCapacity = 16;
static const float VFXProxCellSize = 1;

#ifdef VFXPROX_RW
RWStructuredBuffer<float3> VFXProxPointBuffer;
RWStructuredBuffer<uint>   VFXProxCountBuffer;
#else
StructuredBuffer<float3> VFXProxPointBuffer;
StructuredBuffer<uint>   VFXProxCountBuffer;
#endif

uint VFXProxCellIndex(float3 pos)
{
    uint3 c = max(0, pos / VFXProxCellSize + VFXProxCellsPerAxis / 2);
    c = min(c, VFXProxCellsPerAxis - 1);
    return c.x + VFXProxCellsPerAxis * (c.y + VFXProxCellsPerAxis * c.z);
}

#ifdef VFXPROX_RW

void VFXProxAddPoint(float3 pos)
{
    uint index = VFXProxCellIndex(pos);
    uint count = 0;
    InterlockedAdd(VFXProxCountBuffer[index], 1, count);
    if (count < VFXProxCellCapacity)
        VFXProxPointBuffer[index * VFXProxCellCapacity + count] = pos;
}

#endif

float4 VFXProxLookUp(float3 pos, uint cell, float4 cand)
{
    uint count = VFXProxCountBuffer[cell];
    uint ref_i = cell * VFXProxCellCapacity;
    for (uint i = 0; i < count; i++)
    {
        float3 pt = VFXProxPointBuffer[ref_i++];
        float dist = length(pt - pos);
        if (1e-5f < dist && dist < cand.w) cand = float4(pt, dist);
    }
    return cand;
}

#endif // _VFXPROX_COMMON_H_
