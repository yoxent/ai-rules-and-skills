# Skill Human Spec: Refactoring

```yaml
---
name: refactoring
description: Improves code structure, readability, and modularity without changing observable behavior
version: 1.0.0
category: Engineering
tags: [refactoring, technical-debt, code-quality, modularity, readability]
priority: Medium
depends_on: [correctness-validation, clean-code-solid]
flags_skills: [test-creation-strategy, regression-prevention, design-pattern-selection, technical-debt-management, correctness-validation]
inputs: [existing_code, structural_issues, technical_debt_register, test_suite_coverage]
outputs: [refactored_code, structural_improvements, refactoring_report, deferred_areas]
rules_applied:
  - TQ-3  # Regression Prevention
  - MF-1  # Feature Consistency
  - DA-1  # SOLID & Clean Code First
  - DT-1  # Explicit Tradeoff Logging
  - GM-2  # Explain Before Acting
documents_needed: [test-coverage-report, technical-debt-register]
execution_context: Runs when technical debt needs addressing, readability issues identified, or preparing code for new features
---
```

# Skill: Refactoring

## Purpose

Improves code structure, readability, and modularity without changing observable behavior, reducing technical debt and preparing code for future changes.

## When to Use This Skill

**Triggers:**
* Technical debt register entries need addressing
* Code review identifies structural issues (duplication, complexity, poor naming)
* Preparing code area for new feature implementation
* SOLID violations identified by clean-code-solid skill
* Growing complexity impeding development velocity
* Onboarding reveals comprehension difficulties

**Do NOT use for:**
* Changing business behavior (that's feature development, not refactoring)
* Code with insufficient test coverage (fix coverage first)
* Speculative improvements without clear benefit
* Minor style issues (use linter/formatter instead)

**Execution Context:** Runs when technical debt needs addressing. Often flagged by clean-code-solid skill. Works incrementally to reduce risk.

## Inputs & Outputs

**Required inputs:**
* Existing code exhibiting structural issues, duplication, or complexity
* Technical debt register entries
* Test suite coverage report

**Primary outputs:**
* Refactored code with identical behavior
* Explanation of structural improvements made
* Notes on any areas deferred due to coverage gaps

## Step-by-Step Execution

1. **Verify Test Coverage** - Check coverage adequate before refactoring, defer if insufficient
2. **Establish Baseline** - Run all tests, ensure green before starting
3. **Plan Refactoring Steps** - Break into small, incremental changes
4. **Execute Incrementally** - One small change at a time, verify tests after each
5. **Verify Behavior Preservation** - Run regression suite after each step per TQ-3
6. **Document Improvements** - Explain structural changes, note deferred items

## Core Responsibilities

1. Preserve observable behavior throughout all refactoring steps
2. Improve modularity, naming, and separation of concerns
3. Ensure test coverage adequate before refactoring begins
4. Work incrementally to reduce risk
5. Move code toward SOLID/Clean Code principles per DA-1

## Constraints (Rules Applied)

* **TQ-3**: Regression checks required after every refactoring step - never skip
* **MF-1**: No existing functionality may be altered during refactoring - behavior must remain identical
* **DA-1**: Refactoring must move code toward SOLID/Clean Code, not away from them
* **DT-1**: When refactor scope reduced for delivery, log the deferral with timeline
* **GM-2**: Explain risks before major structural changes

## Tradeoff Handling

**Refactor Depth vs Delivery Time:** Deep structural refactoring may conflict with sprint commitments; scope conservatively and confirm
**Refactoring Risk vs Technical Debt Cost:** Defer refactors in low-coverage areas until tests added

## Failure & Escalation

* Coverage insufficient → flag test-creation-strategy → defer refactor until covered
* Refactor reveals architectural debt → flag technical-debt-management
* Behavior uncertainty exists → request clarification before proceeding
* Scope expanding beyond original intent → halt and reassess
* Code refactored → flag `correctness-validation`, `regression-prevention`

## Skills Flagged

* **test-creation-strategy** - when coverage insufficient to safely refactor
* **regression-prevention** - when regression risk high, need extra validation
* **design-pattern-selection** - when refactoring suggests pattern opportunity
* **technical-debt-management** - when refactor reveals deeper architectural issues
* **correctness-validation** - when refactoring changes may affect existing correctness

## Anti-Patterns to Catch

1. Behavioral regressions introduced during structural changes
2. Refactoring in areas with no test coverage (invisible risk)
3. Scope creep turning refactor into unplanned feature rewrite
4. Large-bang refactoring instead of incremental steps
5. Refactoring without running tests between steps
6. Changing behavior "while we're in there"
7. Premature optimization disguised as refactoring
8. Refactoring to preferred style without measurable benefit
