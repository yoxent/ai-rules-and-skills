---
name: framework-mastery
description: "Use when task requires Stage 7 when framework lifecycle, DI, or config patterns required. Apply conventions correctly for the confirmed framework version."
---

# Framework Mastery

name:framework-mastery|pri:M|deps:[]|flags:[security,backward-compatibility,language-specific-implementation]|rules:[DA-1,DA-5,MF-3,TQ-1]

SCOPE: Stage 7 when framework lifecycle, DI, or config patterns required. Apply conventions correctly for the confirmed framework version.

ENFORCE: Confirm version before selecting patterns; Validate against existing project usage (DA-1); Prefer framework built-ins over custom (DA-5); Verify DI bindings in test and production contexts; Flag security when security defaults modified; Assess breaking changes before upgrades (MF-3); Test lifecycle edge cases (TQ-1); Log deviations via DT-1.

PROHIBIT: Field injection when constructor injection is project standard; Business logic in framework infrastructure; Preview APIs without stability note; Upgrade without breaking change assessment; Unjustified security default changes.

ON_VIOLATION: security_misconfiguration→flag:security→block. upgrade_breaking→flag:backward-compatibility→block. pervasive_antipattern→log:MF-2→do_not_replicate. version_unconfirmed→clarify→block. language_layer_incomplete→flag:language-specific-implementation→complete_language_layer_first.

## Reference
- See [reference.md](reference.md) for distilled source details.
