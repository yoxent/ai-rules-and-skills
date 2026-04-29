---
name: input-system
description: "Use when task requires After code-standards on input-handling scripts. Validates Generated C# class, Action Maps, lifecycle wiring, and rebinding."
---

# Input System

name:input-system|pri:M|deps:[code-standards]|flags:[]|rules:[DA-1,DA-7,MF-1]
SCOPE: After code-standards on input-handling scripts. Validates Generated C# class, Action Maps, lifecycle wiring, and rebinding.
ENFORCE: Generated C# class (e.g. PlayerInputActions) instantiated in Awake, accessed via typed property paths (not strings); Gameplay map (Move Vector2, Jump/Fire Button) and UI map (Navigate, Submit, Cancel) in .inputactions; Subscribe in OnEnable, Unsubscribe in OnDisable; ActionMap.Enable/Disable paired in OnEnable/OnDisable; InputActionRebindingExtensions.RebindingOperation Disposed after completion.
PROHIBIT: Input.GetKey/GetAxis/GetButton/GetMouseButton; FindAction("string") access; subscribe in Awake without OnDisable unsubscription; ActionMap enabled but never disabled; RebindingOperation not disposed.
ON_VIOLATION: legacy_input→BLOCK→Generated_class_subscription. subscribe_no_unsub→SAFETY_BLOCK→OnDisable_pair. enable_no_disable→warn→lifecycle_pair. string_action→warn→typed_property. rebind_no_dispose→warn.

## Reference
- See [reference.md](reference.md) for distilled source details.
