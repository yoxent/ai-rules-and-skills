---
name: api-design
description: "Use when task requires Designs clear, stable, business-aligned APIs that are consistent, predictable, and maintainable across versions"
---

# API Design

name:api-design|pri:M|deps:[correctness-validation,abstraction-domain-modeling]|flags:[backward-compatibility,documentation-knowledge-transfer,error-handling-resilience,contract-api-testing,versioning]|rules:[MF-3,DA-2,PS-1,DT-2,PS-4,GM-2]
SCOPE: Designs clear, stable, business-aligned APIs that are consistent, predictable, and maintainable across versions
ENFORCE: Understand consumer use cases: validate requirements with actual consumer needs per PS-1; Design interface: create endpoint definitions, schemas, error contracts; Apply domain abstraction per DA-2: API reflects business concepts, not implementation details; Assess backward compatibility per MF-3: check for breaking changes; Plan versioning strategy for evolution and migration; Document contracts clearly and transparently per PS-4; Ensure consistency and predictability across all API surfaces; Request confirmation for breaking changes per DT-2
PROHIBIT: Exposing internal implementation details through API; Breaking changes without migration path per MF-3; Inconsistent naming or patterns across endpoints; Leaking technical concerns into API surface; Versioning every minor change; No error handling strategy; Designing for current consumer only, ignoring evolution; Ignoring existing API patterns in same system
ON_VIOLATION: breaking_changes → request_confirmation per DT-2 → require_migration_plan. consumer_unclear → validate_requirements_with_stakeholders. contract_impact_many → coordinate_migration → flag backward-compatibility. api_needs_docs → flag documentation-knowledge-transfer. api_error_contracts → flag error-handling-resilience. api_needs_validation → flag contract-api-testing. breaking_change_design→flag:versioning

## Reference
- See [reference.md](reference.md) for distilled source details.
