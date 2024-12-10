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

// Get cell indices for a specific point
uint3 VFXProx_GetIndicesAt(float3 pos)
{
    return pos / VFXProx_CellSize + VFXProx_CellsPerAxis / 2;
}

// Get a flattened cell index for a specific point
uint VFXProx_GetFlatIndexAt(float3 pos)
{
    return VFXProx_FlattenIndices(VFXProx_GetIndicesAt(pos));
}

// Boundary check
bool VFXProx_CheckBounds(float3 pos, uint margin = 0)
{
    float3 ext = VFXProx_CellSize * (VFXProx_CellsPerAxis * 0.5 - margin);
    return all(-ext < pos) && all(pos < ext);
}

// Add a point to the structure
void VFXProx_AddPoint(float3 pos)
{
    if (!VFXProx_CheckBounds(pos)) return;
    uint index = VFXProx_GetFlatIndexAt(pos);
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
    first = pos;
    second = pos;

    if (!VFXProx_CheckBounds(pos, 1)) return;

    float4 cand1 = float4(pos, 1e+5);
    float4 cand2 = float4(pos, 1e+5);

    uint3 idx = VFXProx_GetIndicesAt(pos);

    for (uint i = 0; i < 3; i++)
    {
        for (uint j = 0; j < 3; j++)
        {
            for (uint k = 0; k < 3; k++)
            {
                uint cell = VFXProx_FlattenIndices(idx + uint3(i, j, k) - 1);
                VFXProx_LookUpNearestPairInCell(pos, cell, cand1, cand2);
            }
        }
    }

    first = cand1.xyz;
    second = cand2.xyz;
}

#endif // _VFXPROX_COMMON_H_
