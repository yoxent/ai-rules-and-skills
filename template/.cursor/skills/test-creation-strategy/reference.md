# Skill Human Spec: Test Creation & Strategy

```yaml
---
name: test-creation-strategy
description: Creates tests validating business behavior and preventing regressions using appropriate test types
version: 1.1.0
category: Testing & QA
tags: [testing, unit-tests, integration-tests, test-strategy, tdd, test-quality]
priority: High
depends_on: [correctness-validation, abstraction-domain-modeling]
flags_skills: [test-interpretation-failure-diagnosis, correctness-validation, regression-prevention, test-environment-management]
inputs: [business_requirements, feature_descriptions, source_code, architecture_design, existing_test_suite, coverage_report]
outputs: [unit_tests, integration_tests, test_strategy_notes, coverage_improvements]
rules_applied:
  - TQ-1
  - TQ-4
  - DA-2
  - MF-1
execution_context: Runs for every new feature implementation by default; also for bug fixes and refactoring
---
```

# Skill: Test Creation & Strategy

## Purpose

**What this skill does:**
Proactively creates and maintains tests that validate business behavior and prevent regressions, selecting the appropriate test type (unit, integration, or mock-based) based on what is being tested and why.

Prevents costly production regressions, enables confident iteration, reduces manual QA costs, maintains feature quality over time, enables safe refactoring.

Validates behavior matches requirements, documents system behavior through executable examples, catches bugs early when they're cheapest to fix, enables confident refactoring.

## When to Use This Skill

### Triggers (Use this skill when):

* New feature implementation complete (every feature needs tests per TQ-1)
* Bug fix implemented (regression test prevents recurrence)
* Refactoring performed (tests verify behavior unchanged)
* Code review reveals inadequate test coverage
* Production incident shows coverage gap
* Complex business logic added
* Integration points with external systems created
* Critical calculation or validation logic implemented

### Do NOT use this skill for:

* Code that's already well-tested with comprehensive coverage
* Prototype or experimental code not intended for production
* Simple getters/setters with no business logic
* Generated code with framework-provided tests
* One-off scripts or utilities

**Execution Context Details:**
Runs by default for every new feature per TQ-1. Also runs for bug fixes (regression tests) and refactoring (verify behavior preserved). Priority is high - tests are not optional.

## Inputs

**Required inputs:**

* **Business requirements and feature descriptions** - What the code should do from a business perspective
* **Source code and architecture design** - What was implemented and how it's structured
* **Existing test suite and coverage report** - Current test landscape and gaps

**Optional inputs:**

* **Production incident history** - Real-world failures inform test scenarios
* **Performance requirements** - May need performance tests in addition to functional tests
* **Integration dependencies** - Understanding external systems helps determine integration test scope

**Documents/Context needed:**

* **Business requirements** - Source of truth for expected behavior
* **Test specifications** - Standards for test organization and conventions

## Outputs

**Primary outputs:**

* **Unit tests for new features and bug fixes** - Fast, isolated tests of individual components
* **Integration tests where cross-boundary behavior must be validated** - Tests of component interactions
* **Test strategy notes explaining tier selection rationale** - Why unit vs integration for each case

**Output format:**

* Test files following project conventions (e.g., test_*.py, *.spec.js)
* Test names that clearly describe what they validate
* Assertions on business behavior, not implementation details per DA-2

**Skill flags (if applicable):**

* Flag **test-interpretation-failure-diagnosis** when a test fails during creation or update work
* Flag **correctness-validation** when new tests validate correctness of implementation
* Flag **regression-prevention** when tests specifically guard against known failures
* Flag **test-environment-management** when integration tests require significant infrastructure

## Step-by-Step Execution

### Step 1: Understand Business Behavior to Test

**Questions to answer:**
- What business behavior does this code implement?
- What are the acceptance criteria from requirements?
- What are the happy path scenarios?
- What edge cases exist?
- What failure modes are possible?

**Actions:**
- [ ] Read business requirements thoroughly
- [ ] Identify all acceptance criteria
- [ ] List happy path scenarios
- [ ] Enumerate edge cases and boundary conditions
- [ ] Identify error scenarios

**Decision points:**
- If business intent unclear, request clarification before writing tests
- If requirements lack acceptance criteria, work with stakeholders to define them

### Step 2: Determine Appropriate Test Tier

**Questions to answer:**
- Is this testing a single unit of logic (unit test)?
- Does this test cross-component boundaries (integration test)?
- Are external dependencies involved (mock or real)?
- What's the trade-off between speed and realism?

**Actions:**
- [ ] Choose unit tests for isolated business logic
- [ ] Choose integration tests for cross-boundary behavior
- [ ] Decide whether to mock external dependencies
- [ ] Document tier choice rationale

**Decision points:**
- If logic is isolated, write unit test
- If behavior depends on integration, write integration test
- If mocking would miss contract drift, use real dependencies

### Step 3: Write Tests for Happy Paths

**Actions:**
- [ ] Write tests for main user flows
- [ ] Assert on business outcomes, not implementation details per DA-2
- [ ] Use clear, descriptive test names
- [ ] Include just enough setup to make test understandable

**Red flags:**
- Test names like test_1, test_2 (not descriptive)
- Assertions on internal implementation details
- Excessive setup obscuring what's being tested
- Tests that pass but don't actually validate business behavior

### Step 4: Write Tests for Edge Cases

**Actions:**
- [ ] Test boundary values (min, max, zero, empty)
- [ ] Test null/undefined inputs
- [ ] Test invalid input handling
- [ ] Test race conditions if applicable
- [ ] Test timeout scenarios

**Decision points:**
- If edge case unlikely but high impact, test it
- If edge case is pure implementation detail, may skip

### Step 5: Write Tests for Error Paths

**Actions:**
- [ ] Test exception handling
- [ ] Test validation failures
- [ ] Test external dependency failures
- [ ] Verify error messages are meaningful
- [ ] Check that errors don't leak sensitive information

**Decision points:**
- If error path critical for reliability, must test per TQ-1
- If fallback behavior exists, test that fallback works

### Step 6: Review Test Quality

**Questions to answer:**
- Do tests assert on business behavior per DA-2?
- Are tests maintainable and not brittle?
- Do tests provide clear failure messages?
- Can tests run independently in any order?
- Are tests fast enough to run frequently?

**Actions:**
- [ ] Verify tests assert on observable behavior, not internals
- [ ] Check tests don't depend on execution order
- [ ] Ensure test names clearly describe what's validated
- [ ] Review mocking strategy - not too much, not too little
- [ ] Verify tests fail for the right reasons

**Red flags per TQ-4:**
- Tests coupled to implementation details (break on refactor)
- Tests with unclear failure messages
- Tests that depend on other tests running first
- Over-mocking that prevents catching real bugs
- Tests that pass but provide false confidence

## Core Responsibilities

1. Generate unit tests for every new feature by default per TQ-1
2. Determine when integration tests required vs unit tests with mocks
3. Ensure tests reflect business intent per DA-2, not implementation details
4. Cover happy paths, edge cases, and failure modes comprehensively
5. Avoid brittle tests tied to internal structure per TQ-4
6. Ensure new tests don't conflict with existing correct behavior per MF-1

## Constraints (Rules Applied)

* **TQ-1: Test Coverage Requirement** - Every feature and bug fix must produce or update tests. This is non-negotiable.
* **TQ-4: Test Quality Rule** - Tests must be meaningful, maintainable, and intention-revealing. High coverage percentage means nothing if tests are weak.
* **DA-2: Abstraction by Business Meaning** - Tests must assert on domain behavior, not internal wiring. Tests should survive refactoring.
* **MF-1: Feature Consistency** - New tests must not conflict with or invalidate existing correct behavior.

## Tradeoff Handling

### Tradeoff 1: Test Depth vs Development Speed

**Scenario:** Exhaustive testing slows delivery, but insufficient testing risks production bugs.

**Resolution:** Calibrate test depth to risk level. Critical paths (payments, auth) get exhaustive testing. Low-risk features get baseline coverage.

### Tradeoff 2: Unit vs Integration vs Mock-Based

**Scenario:** Mocks are fast but may not catch contract drift. Integration tests are realistic but slow and complex.

**Resolution:** Use test pyramid - mostly unit tests, some integration tests, few end-to-end tests. Mock stable external contracts, use real dependencies for internal integration.

### Tradeoff 3: Test Isolation vs Coverage Realism

**Scenario:** Highly isolated unit tests miss integration issues. Integration tests catch more but are slower and flakier.

**Resolution:** Balance the test suite - fast unit tests for business logic, focused integration tests for cross-boundary behavior.

## Example Use Cases

### Example 1: Tax Calculation Feature

**Scenario:** E-commerce system needs sales tax calculation with jurisdiction rates, rounding rules, and exemptions.

**Tests created:**
```python
class TestTaxCalculation:
    def test_calculates_tax_for_standard_items(self):
        """Standard items taxed at jurisdiction rate"""
        order = Order(items=[Item(price=100, category="standard")])
        tax = TaxCalculator.calculate(order, jurisdiction="CA")
        assert tax == 8.875  # CA rate: 8.875%

    def test_rounds_to_nearest_cent(self):
        """Tax amounts rounded to 2 decimal places"""
        order = Order(items=[Item(price=10.01)])
        tax = TaxCalculator.calculate(order, jurisdiction="CA")
        assert tax == 0.89  # 10.01 * 0.08875 = 0.8884375 → 0.89

    def test_exempts_qualifying_items(self):
        """Food and medicine exempt from tax"""
        order = Order(items=[
            Item(price=100, category="food"),
            Item(price=50, category="medicine")
        ])
        tax = TaxCalculator.calculate(order, jurisdiction="CA")
        assert tax == 0.00

    def test_mixed_exempt_and_taxable(self):
        """Only taxable items contribute to tax"""
        order = Order(items=[
            Item(price=100, category="food"),      # exempt
            Item(price=50, category="standard")    # taxed
        ])
        tax = TaxCalculator.calculate(order, jurisdiction="CA")
        assert tax == 4.44  # Only $50 taxed

    def test_handles_zero_amount(self):
        """Zero amount orders have zero tax"""
        order = Order(items=[Item(price=0)])
        tax = TaxCalculator.calculate(order, jurisdiction="CA")
        assert tax == 0.00

    def test_raises_for_unknown_jurisdiction(self):
        """Unknown jurisdiction raises ValueError"""
        order = Order(items=[Item(price=100)])
        with pytest.raises(ValueError, match="Unknown jurisdiction: XX"):
            TaxCalculator.calculate(order, jurisdiction="XX")
```

**Test strategy notes:**
- Unit tests: Tax calculation is pure business logic, no external dependencies
- Parameterized tests could reduce duplication (considered but kept verbose for clarity)
- Integration test with real orders deferred to E2E test suite
- Coverage: All rounding rules, exemptions, error cases covered

### Example 2: Repository Layer - Real DB vs Mocks

**Scenario:** UserRepository fetches users from database with complex queries.

**Decision:** Use real database for tests because query logic is non-trivial.

```python
class TestUserRepository:
    @pytest.fixture
    def db(self):
        """Test database with known state"""
        db = create_test_database()
        db.execute("INSERT INTO users VALUES (1, 'alice@example.com', 'active')")
        db.execute("INSERT INTO users VALUES (2, 'bob@example.com', 'inactive')")
        yield db
        db.close()

    def test_find_by_email_returns_user(self, db):
        """Repository finds user by email"""
        repo = UserRepository(db)
        user = repo.find_by_email("alice@example.com")
        assert user.id == 1
        assert user.email == "alice@example.com"

    def test_find_active_users_excludes_inactive(self, db):
        """Repository filters to only active users"""
        repo = UserRepository(db)
        active_users = repo.find_active()
        assert len(active_users) == 1
        assert active_users[0].email == "alice@example.com"

    def test_find_by_email_returns_none_if_not_found(self, db):
        """Repository returns None for non-existent email"""
        repo = UserRepository(db)
        user = repo.find_by_email("nonexistent@example.com")
        assert user is None
```

**Test strategy notes:**
- Integration test: Uses real database (SQLite in-memory for speed)
- Why not mocks: Query logic in repository is non-trivial, want to verify SQL correctness
- Trade-off: Slower than mocked tests but catches real SQL bugs
- Alternative considered: Mock database - rejected because misses SQL errors

### Example 3: External API Client - Mocked

**Scenario:** PaymentClient calls third-party payment API.

**Decision:** Mock external API to avoid test brittleness and cost.

```python
class TestPaymentClient:
    def test_successful_payment(self, mocker):
        """Client processes successful payment"""
        mock_api = mocker.Mock()
        mock_api.charge.return_value = {"status": "success", "transaction_id": "tx_123"}

        client = PaymentClient(api=mock_api)
        result = client.process_payment(amount=100, card="4111111111111111")

        assert result.success is True
        assert result.transaction_id == "tx_123"
        mock_api.charge.assert_called_once()

    def test_retries_on_503_error(self, mocker):
        """Client retries transient failures"""
        mock_api = mocker.Mock()
        mock_api.charge.side_effect = [
            ServiceUnavailable(),  # First call fails
            ServiceUnavailable(),  # Second call fails
            {"status": "success", "transaction_id": "tx_123"}  # Third succeeds
        ]

        client = PaymentClient(api=mock_api)
        result = client.process_payment(amount=100, card="4111111111111111")

        assert result.success is True
        assert mock_api.charge.call_count == 3

    def test_does_not_retry_declined_card(self, mocker):
        """Client does not retry permanent failures"""
        mock_api = mocker.Mock()
        mock_api.charge.side_effect = CardDeclined("Insufficient funds")

        client = PaymentClient(api=mock_api)
        result = client.process_payment(amount=100, card="4111111111111111")

        assert result.success is False
        assert mock_api.charge.call_count == 1  # No retries
```

**Test strategy notes:**
- Unit test with mocks: External API is expensive and unreliable for testing
- Why mocks: Avoid real API calls, test retry logic in isolation
- Trade-off: May miss API contract changes - mitigated by contract testing (Phase 6)
- Alternative considered: Test against sandbox - rejected due to reliability and speed

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Tests that pass but don't catch real regressions due to over-mocking
✅ **Correct approach:** Mock stable external contracts, use real dependencies for internal integration

❌ **Anti-pattern 2:** Tests coupled to implementation details that break on every refactor
✅ **Correct approach:** Assert on observable behavior per DA-2, not internal structure

❌ **Anti-pattern 3:** Coverage gaps in error paths and edge cases
✅ **Correct approach:** Test error cases with same rigor as happy paths per TQ-1

❌ **Anti-pattern 4:** Tests asserting on implementation, not behavior
```python
def test_user_service():
    service.process()
    assert service.internal_cache == {...}  # ❌ Testing implementation detail
```
✅ **Correct approach:**
```python
def test_user_service():
    result = service.process()
    assert result.status == "success"  # ✅ Testing observable behavior
```

❌ **Anti-pattern 5:** Brittle tests requiring constant updates
✅ **Correct approach:** Test public contracts, not internal implementation

❌ **Anti-pattern 6:** No tests for bug fixes (regression risk)
✅ **Correct approach:** Every bug fix includes regression test per TQ-1

❌ **Anti-pattern 7:** Mocking everything (contract drift undetected)
✅ **Correct approach:** Balance mocks with integration tests

❌ **Anti-pattern 8:** Tests with unclear intent
```python
def test_1():  # ❌ Unclear what this validates
```
✅ **Correct approach:**
```python
def test_calculate_tax_rounds_to_nearest_cent():  # ✅ Clear intent
```

❌ **Anti-pattern 9:** Tests depending on execution order
✅ **Correct approach:** Each test sets up own state, runs independently

❌ **Anti-pattern 10:** Not running tests after writing them
✅ **Correct approach:** Verify tests actually fail when they should (mutation testing concept)
