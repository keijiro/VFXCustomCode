using UnityEngine;

[ExecuteInEditMode]
public sealed class VFXProxBuffer : MonoBehaviour
{
    #region Shader related constants

    // These constants should match with ones in VFXProxCommon.hlsl
    const int CellsPerAxis = 16;
    const int CellCapacity = 16;
    const float CellSize = 1;

    #endregion

    #region Project asset reference

    [field:SerializeField, HideInInspector] ComputeShader _compute = null;

    #endregion

    #region Private properties and objects

    int TotalCells = CellsPerAxis * CellsPerAxis * CellsPerAxis;

    (GraphicsBuffer point, GraphicsBuffer count) _buffer;

    #endregion

    #region MonoBehaviour implementation

    void OnEnable()
    {
        _buffer.point = new GraphicsBuffer
          (GraphicsBuffer.Target.Structured,
           TotalCells * CellCapacity, sizeof(float) * 3);

        _buffer.count = new GraphicsBuffer
          (GraphicsBuffer.Target.Structured,
           TotalCells, sizeof(uint));

        Shader.SetGlobalBuffer("VFXProxPointBuffer", _buffer.point);
        Shader.SetGlobalBuffer("VFXProxCountBuffer", _buffer.count);
    }

    void OnDisable()
    {
        _buffer.point?.Dispose();
        _buffer.count?.Dispose();
        _buffer = (null, null);
    }

    void Update()
      => _compute.DispatchThreads(0, CellsPerAxis, CellsPerAxis, CellsPerAxis);

    #endregion
}
