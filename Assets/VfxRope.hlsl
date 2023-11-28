RWStructuredBuffer<float3> VfxRope_Buffer1;
RWStructuredBuffer<float3> VfxRope_Buffer2;

void VfxRope_Reset(inout VFXAttributes attributes)
{
    uint id = attributes.particleId;
    VfxRope_Buffer1[id] = VfxRope_Buffer2[id] = attributes.position;
}

void VfxSpring_Constrain(inout VFXAttributes attributes,
                         float3 root, float force, float deltaTime)
{
    uint id = attributes.particleId;

    if (id == 0)
    {
        attributes.position = root;
        attributes.velocity = 0;
    }
    else
    {
        float3 pos = attributes.position;
        float3 parent = VfxRope_Buffer2[max(id, 1) - 1];
        float3 updated = parent + 0.1 * normalize(pos - parent);
        attributes.position = updated;
        attributes.velocity = (updated - VfxRope_Buffer2[id]) / max(1.0 / 60, deltaTime);
    }

    VfxRope_Buffer1[id] = attributes.position;
}