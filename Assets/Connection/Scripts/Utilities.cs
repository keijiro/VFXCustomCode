using UnityEngine;

static class ComputeShaderExtensions
{
    public static void DispatchThreads
      (this ComputeShader compute, int kernel, int x, int y = 1, int z = 1)
    {
        uint xc, yc, zc;
        compute.GetKernelThreadGroupSizes(kernel, out xc, out yc, out zc);
        x = (x + (int)xc - 1) / (int)xc;
        y = (y + (int)yc - 1) / (int)yc;
        z = (z + (int)zc - 1) / (int)zc;
        compute.Dispatch(kernel, x, y, z);
    }
}
