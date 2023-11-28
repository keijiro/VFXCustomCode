using UnityEngine;

[ExecuteInEditMode]
public sealed class VfxRopeBufferProvider : MonoBehaviour
{
    const int ElementCount = 32;

    (GraphicsBuffer, GraphicsBuffer) _buffers;

    GraphicsBuffer NewFloat3Buffer()
      => new GraphicsBuffer(GraphicsBuffer.Target.Structured, ElementCount, sizeof(float) * 3);

    void OnEnable()
    {
        _buffers = (NewFloat3Buffer(), NewFloat3Buffer());
    }

    void OnDisable()
    {
        _buffers.Item1?.Dispose();
        _buffers.Item2?.Dispose();
        _buffers = (null, null);
    }

    void Update()
    {
        Shader.SetGlobalBuffer("VfxRope_Buffer1", _buffers.Item1);
        Shader.SetGlobalBuffer("VfxRope_Buffer2", _buffers.Item2);
        _buffers = (_buffers.Item2, _buffers.Item1);
    }
}
