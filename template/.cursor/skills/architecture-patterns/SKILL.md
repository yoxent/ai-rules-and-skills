---
name: architecture-patterns
description: "Use when task requires After code-standards on new systems or cross-system interaction. Validates Event Channels, Service Locator, StateMachine<T>, Command pattern."
---

# Architecture Patterns

name:architecture-patterns|pri:H|deps:[code-standards]|flags:[]|rules:[DA-1,DA-2,DA-3,DA-7]
SCOPE: After code-standards on new systems or cross-system interaction. Validates Event Channels, Service Locator, StateMachine<T>, Command pattern.
ENFORCE: Cross-system via ScriptableObject EventChannel<T> (Raise/Register/Unregister); ServiceLocator register Awake, retrieve without caching, deregister OnDestroy; StateMachine<T>+IState(Enter/Execute/Exit) for character/game-flow; ICommand+CommandManager for reversible/replayable ops; new patterns consistent with documented decisions per DA-7.
PROHIBIT: MonoBehaviour-to-MonoBehaviour refs across system boundaries; singleton chains (GameManager.Instance); nested if/else in Update instead of state machine; business logic inside event handlers (handler invokes method, not contains logic).
ON_VIOLATION: cross_system_ref→warn→EventChannel_wiring. singleton_chain→warn→ServiceLocator. update_conditionals→warn→StateMachine. logic_in_handler→warn→extract_to_method. pattern_mismatch→flag_DA-7→document_decision.

## Reference
- See [reference.md](reference.md) for distilled source details.
