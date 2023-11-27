using UnityEngine;
using UnityEngine.VFX;
using UnityEngine.VFX.Utility;

[AddComponentMenu("VFX/Property Binders/Test")]
[VFXBinder("Test")]
public sealed class TestPropertyBinder : VFXBinderBase
{
    (GraphicsBuffer position, GraphicsBuffer velocity) _buffers;

    protected override void OnEnable()
    {
        _buffers.position = new GraphicsBuffer();
        _buffers.velocity = new GraphicsBuffer();
        base.OnEnable();
    }

    protected override void OnDisable()
    {
        _buffers.position?.Dispose();
        _buffers.velocity?.Dispose();
        _buffers = (null, null);
        base.OnDisable();
    }

    public string PositionBufferProperty
      { get => (string)_positionBufferProperty;
        set => _positionBufferProperty = value; }

    public string VelocityBufferProperty
      { get => (string)_velocityBufferProperty;
        set => _velocityBufferProperty = value; }

    [VFXPropertyBinding("UnityEngine.GraphicsBuffer"), SerializeField]
    ExposedProperty _positionBufferProperty = "PositionBuffer";

    [VFXPropertyBinding("UnityEngine.GraphicsBuffer"), SerializeField]
    ExposedProperty _velocityBufferProperty = "VelocityBuffer";

    public override bool IsValid(VisualEffect component)
      => component.HasGraphicsBuffer(_positionBufferProperty) &&
         component.HasGraphicsBuffer(_velocityBufferProperty);

    public override void UpdateBinding(VisualEffect component)
    {
        component.SetGraphicsBuffer(_positionBufferProperty, _buffers.position);
        component.SetGraphicsBuffer(_velocityBufferProperty, _buffers.velocity);
    }

    public override string ToString()
      => $"Test : {_positionBufferProperty}, {_velocityBufferProperty}";
}
