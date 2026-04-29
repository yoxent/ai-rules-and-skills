---
name: design-reference
description: "Use when task requires Before implementing mechanics/lore. Verify GDD/NDD consulted; require section citation in code; log deviations via DT-1."
---

# Design Reference

name:design-reference|pri:M|deps:[]|flags:[]|rules:[GM-4,DA-7,DT-1]
SCOPE: Before implementing mechanics/lore. Verify GDD/NDD consulted; require section citation in code; log deviations via DT-1.
ENFORCE: GDD/NDD section covering mechanic must exist in Assets/Design/ before implementation; cite specific document+section in code comment; flag undocumented behaviours as assumptions; log all deviations from design intent via DT-1 with rationale before proceeding.
PROHIBIT: Implementing mechanics without GDD/NDD backing; treating inferred intent as documented design; vague reference comments without section; proceeding past stub GDD entry without escalation; merging deviation without DT-1 entry.
ON_VIOLATION: no_design_doc→BLOCK→request_gdd. assumption_unmarked→flag→escalate. missing_citation→warn→section_ref. deviation_no_log→BLOCK→require_dt1.

## Reference
- See [reference.md](reference.md) for distilled source details.
