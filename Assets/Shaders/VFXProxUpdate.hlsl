#define VFXPROX_RW
#include "VFXProxCommon.hlsl"

void VFXProxUpdate(inout VFXAttributes attributes)
{
    VFXProxAddPoint(attributes.position);
}
