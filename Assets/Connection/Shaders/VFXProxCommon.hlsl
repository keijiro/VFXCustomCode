#ifndef _VFXPROX_COMMON_H_
#define _VFXPROX_COMMON_H_

// These constants must match those defined in VFXProxBuffer.cs
static const uint VFXProx_CellsPerAxis = 16;
static const uint VFXProx_CellCapacity = 16;

// Uniforms and resources
float3 VFXProx_CellSize;
RWStructuredBuffer<uint> VFXProx_CountBuffer;
RWStructuredBuffer<float3> VFXProx_PointBuffer;

// Flatten cell indices
uint VFXProx_FlattenIndices(uint3 i)
{
    return i.x + VFXProx_CellsPerAxis * (i.y + VFXProx_CellsPerAxis * i.z);
}

// Get a flattened cell index for a specific point
uint VFXProx_GetIndexAt(float3 pos)
{
    uint3 c = pos / VFXProx_CellSize + VFXProx_CellsPerAxis / 2;
    return VFXProx_FlattenIndices(max(0, min(VFXProx_CellsPerAxis - 1, c)));
}

// Add a point to the structure
void VFXProx_AddPoint(float3 pos)
{
    uint index = VFXProx_GetIndexAt(pos);
    uint count = 0;
    InterlockedAdd(VFXProx_CountBuffer[index], 1, count);
    if (count < VFXProx_CellCapacity)
        VFXProx_PointBuffer[index * VFXProx_CellCapacity + count] = pos;
}

// Look up the nearest point pair in a specific cell
void VFXProx_LookUpNearestPairInCell
  (float3 pos, uint cell, inout float4 cand1, inout float4 cand2)
{
    uint count = VFXProx_CountBuffer[cell];
    uint ref_i = cell * VFXProx_CellCapacity;
    for (uint i = 0; i < count; i++)
    {
        float3 pt = VFXProx_PointBuffer[ref_i++];
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

// Look up the nearest point pair in the entire structure
void VFXProx_LookUpNearestPair
  (float3 pos, out float3 first, out float3 second)
{
    float4 cand1 = 1e+5;
    float4 cand2 = 1e+5;

    for (int i = -1; i < 2; i++)
    {
        for (int j = -1; j < 2; j++)
        {
            for (int k = -1; k < 2; k++)
            {
                float3 offset = float3(i, j, k) * VFXProx_CellSize;
                uint cell = VFXProx_GetIndexAt(pos + offset);
                VFXProx_LookUpNearestPairInCell(pos, cell, cand1, cand2);
            }
        }
    }

    first  = cand1.w < 1e+5 ? cand1.xyz : pos;
    second = cand2.w < 1e+5 ? cand2.xyz : pos;
}

#endif // _VFXPROX_COMMON_H_
