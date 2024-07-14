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

#endif // _VFXPROX_COMMON_H_
