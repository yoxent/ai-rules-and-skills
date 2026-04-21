---
name: unity_architecture_patterns
description: Unity Architecture Patterns. Implements Event Channels, Composition Root DI, State Machines, and Command patterns.
---

# Unity Architecture Patterns

## Event Channels (ScriptableObjects)
Standard for decoupled communication.
```csharp
[CreateAssetMenu(menuName = "Events/Int Event")]
public class IntEventChannel : ScriptableObject {
    private event Action<int> _onEvent;
    public void Raise(int val) => _onEvent?.Invoke(val);
    public void Subscribe(Action<int> action) => _onEvent += action;
    public void Unsubscribe(Action<int> action) => _onEvent -= action;
}
```

## Dependency Injection (Simple Injector / Composition Root)
- No global/static service locators.
- Scene-wired `GameContext` (composition root) holds shared services; pass explicitly (serialized field or `Initialize(...)`).
- Reflection-free; traceable via inspector + call sites.

## Data-Driven Configuration
- ScriptableObject / config-asset driven systems for rules, scoring, AI tuning, balance.
- Centralize tunables in data assets; no scattered gameplay constants in MonoBehaviours.

## State Machine
Generic `StateMachine<T>` + `IState` interfaces for characters / game flow.

## Command Pattern
`ICommand` + `CommandManager` for undo/redo or input record/playback.
