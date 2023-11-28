using UnityEngine;

[ExecuteInEditMode]
public sealed class VFXProxBufferProvider : MonoBehaviour
{
    const int CellCount = 16;
    const int CellCapacity = 16;
    const float CellSize = 1;

    [field:SerializeField] ComputeShader _compute = null;

    GraphicsBuffer _buffer;
    GraphicsBuffer _counter;

    void OnEnable()
    {
        var totalCells = CellCount * CellCount * CellCount;

        _buffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured,
                                     totalCells * CellCapacity,
                                     sizeof(float) * 3);

        _counter = new GraphicsBuffer(GraphicsBuffer.Target.Structured,
                                      totalCells, sizeof(uint));

        Shader.SetGlobalBuffer("VFXProxBuffer", _buffer);
        Shader.SetGlobalBuffer("VFXProxCounter", _counter);
    }

    void OnDisable()
    {
        _buffer?.Dispose();
        _counter?.Dispose();
        (_buffer, _counter) = (null, null);
    }

    void Update()
      => _compute.Dispatch(0, CellCount / 4, CellCount / 4, CellCount / 4);
}
