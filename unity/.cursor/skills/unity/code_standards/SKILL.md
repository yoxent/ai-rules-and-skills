---
name: unity_code_standards
description: C# Best Practices. Enforces naming, lifecycle ordering, serialization attributes, and code documentation standards.
---

# C# & MonoBehaviour Standards

## Lifecycle Ordering
Serialized Fields -> Private Fields -> Properties -> Awake/OnEnable/Start -> Update/FixedUpdate/LateUpdate -> OnDisable/OnDestroy.

## Serialization Attributes
- `[Header("Label")]` to group inspector fields.
- `[Tooltip("Info")]` for internal docs.
- `[Range(min, max)]` to constrain numerics.

## Clean Code Patterns
- Pattern matching + string interpolation.
- Expression-bodied members for simple properties.
- XML Docs: `<summary>` on public classes; `<param>`/`<returns>` on public methods.

## Example Standard Mono
```csharp
public class LifecycleExample : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private float _speed = 5f;

    private Rigidbody _rigidbody;

    public float CurrentSpeed => _speed;

    private void Awake()
    {
        if (!TryGetComponent(out _rigidbody))
        {
             Debug.LogError("Missing RB");
        }
    }
}
```
