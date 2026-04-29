---
name: code-standards
description: "Use when task requires Always active on all Unity C# scripts. Enforce lifecycle order, serialization attributes, naming, and XML docs."
---

# Code Standards

name:code-standards|pri:H|deps:[]|flags:[]|rules:[DA-1,DA-7,MF-1]
SCOPE: Always active on all Unity C# scripts. Enforce lifecycle order, serialization attributes, naming, and XML docs.
ENFORCE: Lifecycle order: serialized fields→private fields→properties→Awake/OnEnable/Start→Update/FixedUpdate/LateUpdate→OnDisable/OnDestroy; [Header],[Tooltip],[Range] on inspector fields; TryGetComponent with null check where absence is possible; XML <summary> on public classes, <param>/<returns> on public methods; _camelCase prefix on private fields; pattern matching, string interpolation, expression-bodied members.
PROHIBIT: Lifecycle methods out of canonical order; GetComponent result unchecked; public fields on MonoBehaviours where [SerializeField] private fits; magic numbers without [Range] or named constant.
ON_VIOLATION: lifecycle_wrong→warn→reorder. unchecked_getcomponent→warn→trygetcomponent. xml_missing→warn. magic_number→warn→named_constant. naming_wrong→warn→corrected_name.

## Reference
- See [reference.md](reference.md) for distilled source details.
