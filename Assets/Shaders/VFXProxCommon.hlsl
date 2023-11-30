#ifndef _VFXPROX_COMMON_H_
#define _VFXPROX_COMMON_H_

#ifdef VFXPROX_RW
RWStructuredBuffer<float3> VFXProxBuffer;
RWStructuredBuffer<uint> VFXProxCounter;
#else
StructuredBuffer<float3> VFXProxBuffer;
StructuredBuffer<uint> VFXProxCounter;
#endif

static const uint VFXProxCellCount = 16;
static const uint VFXProxCellCapacity = 16;
static const float VFXProxCellSize = 1;

uint VFXProxCellIndex(float3 pos)
{
    uint3 crd = max(0, pos / VFXProxCellSize + VFXProxCellCount / 2);
    crd = min(crd, VFXProxCellCount - 1);
    return crd.x + VFXProxCellCount * (crd.y + VFXProxCellCount * crd.z);
}

float3 VFXProxLookUp(float3 pos, uint cell)
{
    uint count = VFXProxCounter[cell];

    float3 min_pos = 100000;
    float min_dist = 10000;

    for (uint i = 0; i < count; i++)
    {
        float3 e = VFXProxBuffer[cell * VFXProxCellCapacity + i];
        float d = length(e - pos);
        if (d < min_dist && d > 0.000001)
        {
            min_pos = e;
            min_dist = d;
        }
    }

    return min_pos;
}

#ifdef VFXPROX_RW

void VFXProxAddEntry(float3 pos)
{
    uint index = VFXProxCellIndex(pos);
    uint count = 0;
    InterlockedAdd(VFXProxCounter[index], 1, count);
    if (count < VFXProxCellCapacity)
        VFXProxBuffer[index * VFXProxCellCapacity + count] = pos;
}

#endif

#endif // _VFXPROX_COMMON_H_
