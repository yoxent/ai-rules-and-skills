---
name: test-data-management
description: "Use when task requires Before test suites requiring data setup, or when non-determinism, stale fixtures, or PII compliance concerns arise. Generate, seed, and manage synthetic and anonymized test data."
---

# Test Data Management

name:test-data-management|pri:H|deps:[]|flags:[test-environment-management,security]|rules:[CL-3,CL-1,TQ-4,MF-1]

SCOPE: Before test suites requiring data setup, or when non-determinism, stale fixtures, or PII compliance concerns arise. Generate, seed, and manage synthetic and anonymized test data.

ENFORCE: Assert schema version before seeding; halt on mismatch. Verify no PII before each run; anonymize all production data including indirect identifiers. Generate synthetic data covering happy path, boundary values, nulls, and referential edge cases. Seed in FK dependency order; use upsert or truncate-first. Verify idempotency by running scripts twice. Guarantee teardown on failure and success. Document scenario-to-data-state coverage map.

PROHIBIT: Production data without verified anonymization; blind INSERT; hardcoded IDs; timestamp-dependent assertions; undocumented ambient fixtures.

ON_VIOLATION: pii_detected→halt→flag:security→confirm_clean_before_resume. seeding_fails_env→flag:test-environment-management→block. schema_mismatch→halt→coordinate:test-environment-management. nondeterminism_from_data→fix_seed→retest.

## Reference
- See [reference.md](reference.md) for distilled source details.
