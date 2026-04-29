```yaml
---
name: documentation-knowledge-transfer
description: Preserves understanding through documentation explaining why, not just what, enabling knowledge transfer
version: 1.0.0
category: Product & Documentation
tags: [documentation, knowledge-transfer, adr, comments, onboarding]
priority: Low
depends_on: []
flags_skills: [api-design, abstraction-domain-modeling, stakeholder-communication]
inputs: [source_code, design_rationale, architectural_decisions, handoff_requirements]
outputs: [inline_documentation, adrs, usage_guides, api_documentation, onboarding_materials]
rules_applied:
  - DA-1
  - MF-2
  - PS-4
  - GM-2
execution_context: Runs for complex logic, architectural changes, or public APIs; can be deferred for internal changes
---
```

# Skill: Documentation & Knowledge Transfer

## Purpose

**What this skill does:**
Preserves understanding of system behavior, design decisions, and intent through documentation that explains why decisions were made, not just what the code does. Enables effective knowledge transfer and future maintenance by capturing reasoning that isn't apparent from reading code alone.

Reduces onboarding time for new team members, prevents knowledge silos from forming, enables business continuity when people leave, reduces time spent reverse-engineering decisions.

Preserves decision context that prevents repeating past mistakes, enables effective handoffs, reduces maintenance friction, documents non-obvious trade-offs and constraints.

## When to Use This Skill

### Triggers (Use this skill when):

* Complex business logic implemented that isn't self-explanatory
* Architectural decisions made that affect system structure
* Public APIs designed that external consumers will use
* Non-obvious algorithms or performance optimizations applied
* Design trade-offs made that future maintainers should understand
* Team member preparing to hand off work or onboard someone
* Production incidents reveal documentation gaps
* Code review reveals intent that isn't clear from code

### Do NOT use this skill for:

* Self-explanatory code where structure is clear
* Temporary prototypes or experimental code
* Code that follows obvious patterns
* Internal helper functions with clear names
* Generated code or boilerplate

**Execution Context Details:**
Runs when complex logic, architectural changes, or public APIs need documentation. Can be deferred for simple internal changes. Priority increases for handoffs, onboarding, or public-facing work.

## Inputs

**Required inputs:**

* **Source code and design rationale** - The implementation and the reasoning behind design choices
* **Architectural decisions and their context** - What was decided and why, including alternatives considered
* **Handoff requirements or onboarding needs** - What knowledge needs to be transferred and to whom

**Optional inputs:**

* **Previous documentation** - Existing docs that may need updating
* **Stakeholder questions** - Common confusion points that documentation should address
* **Team conventions** - Documentation standards and templates in use

**Documents/Context needed:**

* **Architectural decisions (ADRs)** - Records of significant design choices
* **API specifications** - Contracts for public interfaces
* **Domain glossary** - Business terminology definitions

## Outputs

**Primary outputs:**

* **Inline documentation and code comments** - Explains why code does what it does
* **Architecture Decision Records (ADRs)** - Formal documentation of architectural choices
* **Usage guides and API documentation** - How to use components or APIs correctly
* **Onboarding or handoff materials** - Knowledge transfer documents for new team members

**Output format:**

* Inline comments explaining intent and non-obvious choices
* Markdown ADRs following standard template
* API documentation with examples
* README files for modules or components

**Skill flags (if applicable):**

* Flag **api-design** when API needs comprehensive documentation
* Flag **abstraction-domain-modeling** when domain concepts need explanation
* Flag **stakeholder-communication** when documentation is for non-technical audiences

## Step-by-Step Execution

1. **Identify What Needs Documentation** - Find non-obvious decisions, complex logic, public interfaces
2. **Explain Intent and Reasoning** - Document why, not just what
3. **Record Architectural Decisions** - Create ADRs for significant choices per PS-4
4. **Write Usage Documentation** - Explain how to use components correctly
5. **Keep Documentation Synchronized** - Update docs when code changes
6. **Review Documentation Quality** - Ensure docs explain intent, not mechanics

## Core Responsibilities

1. Explain intent and reasoning, not just mechanics
2. Keep documentation synchronized with code as it evolves per DA-1
3. Document non-obvious decisions and alternatives considered per PS-4
4. Distinguish between what code does and why it was designed that way
5. Track undocumented decisions as knowledge debt per MF-2

## Constraints (Rules Applied)

* **DA-1**: Well-structured code reduces documentation burden. Documentation compensates for unavoidable complexity, not poor code structure.
* **MF-2**: Undocumented decisions are knowledge debt. Log them and create tickets to document later if needed.
* **PS-4**: Major decisions must be documented with reasoning. Stakeholders need transparency into design choices.
* **GM-2**: When sensitive or confidential information appears in documentation scope, request guidance.

## Example Use Cases

### Example 1: Architecture Decision Record for Queue-Based Processing

**Scenario:** Team decided to use message queue instead of synchronous processing for order fulfillment.

**Documentation created:**
```markdown
# ADR 001: Use Message Queue for Order Fulfillment

## Status
Accepted

## Context
Order fulfillment involves multiple steps (inventory check, payment, shipping) that can take 10-30 seconds total.
Synchronous processing causes:
- API timeout issues (30s limit)
- Poor user experience (long waits)
- Wasted resources (holding connections)

## Decision
Use RabbitMQ message queue for asynchronous order processing.

## Consequences

### Positive
- API responds immediately (200ms vs 30s)
- Better resource utilization
- Natural retry mechanism
- Easier to scale each step independently

### Negative
- Added complexity (queue infrastructure)
- Eventual consistency (order status not immediate)
- Need dead letter queue handling
- Monitoring more complex

## Alternatives Considered
1. **Synchronous processing** - Rejected due to timeout issues
2. **Background jobs (Celery)** - Similar to queue but less flexible for our workflow
3. **Webhooks** - Doesn't solve timeout problem, adds external dependency

## Notes
- Queue retention set to 7 days
- Dead letter queue alerts on-call
- Status polling API for clients to check order progress
```

### Example 2: Inline Comment for Non-Obvious Algorithm

**Scenario:** Performance optimization uses specific algorithm that isn't obvious.

```python
def find_duplicates(items):
    # Use two-pointer technique instead of nested loops (O(n log n) vs O(n²))
    # Why: With 100k+ items, nested loops take 10s vs 100ms with sorting
    # Trade-off: Mutates input order, but caller doesn't depend on it (verified)
    items.sort()
    duplicates = []
    i = 0
    while i < len(items) - 1:
        if items[i] == items[i + 1]:
            duplicates.append(items[i])
            # Skip all duplicates of this item
            while i < len(items) - 1 and items[i] == items[i + 1]:
                i += 1
        i += 1
    return duplicates
```

### Example 3: API Documentation with Examples

**Scenario:** Public API endpoint needs clear usage documentation.

```markdown
## POST /api/orders

Creates a new order with the provided items.

### Request Body
```json
{
  "customer_id": "string (required)",
  "items": [
    {
      "product_id": "string (required)",
      "quantity": "integer (required, min: 1)"
    }
  ],
  "shipping_address": {
    "street": "string (required)",
    "city": "string (required)",
    "postal_code": "string (required)",
    "country": "string (required, ISO 3166-1 alpha-2)"
  }
}
```

### Response
**Success (201 Created)**
```json
{
  "order_id": "ord_1234567890",
  "status": "pending",
  "created_at": "2025-02-16T10:30:00Z",
  "estimated_delivery": "2025-02-20"
}
```

**Error (400 Bad Request)**
```json
{
  "error": "validation_failed",
  "details": [
    {
      "field": "items[0].quantity",
      "message": "must be at least 1"
    }
  ]
}
```

### Important Notes
- Orders are processed asynchronously. Use GET /api/orders/{order_id} to check status.
- Inventory is reserved immediately but payment is processed async.
- If payment fails, order status becomes "payment_failed" and inventory is released.
```

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Documentation describing what code does (redundant with reading code)
✅ **Correct approach:** Document why decisions were made and what alternatives were considered

❌ **Anti-pattern 2:** Documentation out of sync with code
✅ **Correct approach:** Update documentation when code changes, treat docs as part of the feature

❌ **Anti-pattern 3:** Undocumented design decisions requiring reverse-engineering
✅ **Correct approach:** Write ADRs for significant decisions per PS-4

❌ **Anti-pattern 4:** Over-documenting obvious mechanics
✅ **Correct approach:** Focus on non-obvious intent, trade-offs, and constraints per DA-1

❌ **Anti-pattern 5:** Comments explaining how, not why
```python
# Increment counter
counter += 1  # ❌ Obvious
```
✅ **Correct approach:**
```python
# Track failed login attempts for rate limiting (lock account at 5 failures)
failed_attempts += 1
```

❌ **Anti-pattern 6:** No ADRs for architectural decisions
✅ **Correct approach:** Document major decisions with context, consequences, and alternatives

❌ **Anti-pattern 7:** Documentation as afterthought
✅ **Correct approach:** Write docs as you design, update as you implement

❌ **Anti-pattern 8:** Stale documentation misleading readers
✅ **Correct approach:** Remove outdated docs or update them, never leave them wrong
