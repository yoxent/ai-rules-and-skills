```yaml
---
name: error-handling-resilience
description: Ensures systems fail safely, transparently, and recoverably with explicit error paths and actionable diagnostics
version: 1.0.0
category: Engineering
tags: [error-handling, resilience, fault-tolerance, retry-logic, recovery]
priority: Medium
depends_on: [correctness-validation]
flags_skills: [correctness-validation, bug-diagnosis, documentation-knowledge-transfer, observability, test-creation-strategy, regression-prevention]
inputs: [code_with_exception_paths, production_logs, failure_scenarios, reliability_requirements]
outputs: [error_handling_strategy, retry_logic, fallback_behavior, diagnostic_standards]
rules_applied:
  - MF-5  # Reliability Rule
  - GM-2  # Explain Before Acting
  - DT-1  # Explicit Tradeoff Logging
  - TQ-1  # Test Coverage Requirement
documents_needed: [reliability-requirements, failure-scenarios]
execution_context: Runs for production-bound code, external integrations, or reliability-critical features
---
```

# Skill: Error Handling & Resilience

## Purpose

**What this skill does:**
Ensures systems fail safely, transparently, and recoverably by designing explicit error paths, retry logic, and fallback behaviors that preserve system stability and provide actionable diagnostics.

Prevents cascading failures that bring down entire systems, maintains service availability during partial failures, reduces mean time to resolution through clear diagnostics, minimizes revenue loss from outages.

Creates predictable failure modes, enables effective diagnosis and debugging, maintains system health under stress, prevents silent data corruption, builds trust in system reliability.

## When to Use This Skill

### Triggers (Use this skill when):

* Code interfaces with external systems (APIs, databases, message queues)
* Production-bound code that must be resilient to failures
* Reliability-critical features where downtime has high cost
* Exception handling needs to be added or reviewed
* Error paths discovered during testing or code review
* Production incidents reveal inadequate error handling
* Integration points with unreliable dependencies
* Code that processes user data or financial transactions

### Do NOT use this skill for:

* Simple prototype or proof-of-concept code
* Local development scripts or one-off utilities
* Code with no external dependencies or I/O
* Pure computation with no failure modes
* Test code or mock implementations

**Execution Context Details:**
Runs when production-bound code is being prepared, external integrations are added, or reliability requirements demand fault tolerance. Often triggered by code review or post-incident analysis. Should run before deployment for any code that can fail.

## Inputs

**Required inputs:**

* **Code with exception paths or reliability concerns** - The actual implementation that needs error handling. Includes try/catch blocks, error conditions, external calls.
* **Production logs and failure scenarios** - Real-world evidence of how systems fail. Historical incidents inform error handling strategy.
* **System reliability requirements** - SLA targets, acceptable downtime, recovery time objectives that define "good enough" resilience.

**Optional inputs:**

* **Dependency reliability profiles** - Known failure rates and patterns of external services
* **Error budget** - How much failure is acceptable in a given time period
* **Monitoring capabilities** - What observability tools are available for diagnostics

**Documents/Context needed:**

* **Integration contracts** - What guarantees external dependencies provide

## Outputs

**Primary outputs:**

* **Error handling strategy with explicit failure modes** - Documented approach for how system should behave when things fail
* **Retry logic and backoff recommendations** - Specific algorithms (exponential backoff with jitter, circuit breakers, etc.)
* **Fallback behavior design** - What system does when primary path fails (degrade gracefully, use cache, return error)
* **Diagnostic message standards** - Structured logging format with actionable information

**Output format:**

* Error handling code with clear failure paths
* Structured logging with correlation IDs and context
* Circuit breaker or retry configurations
* Fallback behavior implementations

**Skill flags (if applicable):**

* Flag **correctness-validation** when error handling added, verify it doesn't break correctness
* Flag **bug-diagnosis** when error patterns reveal underlying bugs
* Flag **documentation-knowledge-transfer** when complex error handling needs documentation
* Flag **observability** when error patterns suggest monitoring gaps

## Preconditions

**Conditions that must be met before execution:**

* Code with potential failure points identified
* Reliability requirements defined or inferable
* Access to production logs or failure history (if available)
* Understanding of external dependency behavior

**Validation checks:**

* [ ] Failure modes identified for all external calls
* [ ] Reliability requirements understood
* [ ] Error handling doesn't mask correctness issues per MF-5
* [ ] Test infrastructure supports error path testing

## Step-by-Step Execution Procedure

### Step 1: Identify All Failure Points

**Questions to answer:**
- Where can this code fail (external calls, I/O, parsing, etc.)?
- What are the failure modes for each dependency?
- Are there cascading failure scenarios?
- Which failures are transient vs permanent?

**Actions:**
- [ ] Identify all external calls (network, database, file system, third-party APIs)
- [ ] Map out failure modes for each dependency
- [ ] Distinguish transient failures (retry-able) from permanent failures
- [ ] Identify resource exhaustion scenarios (timeout, memory, connections)
- [ ] Check for cascading failure risks

**Red flags / Warning signs:**
- No error handling on external calls
- Catch-all exception handlers with no logging
- Silent failures that corrupt state
- No timeout on network calls
- Infinite retry loops

**Decision points:**
- If failure is transient, design retry logic
- If failure is permanent, design fallback or fail-fast behavior
- If failure can cascade, design circuit breaker

### Step 2: Design Retry Logic for Transient Failures

**Questions to answer:**
- Is this failure likely to resolve with a retry?
- How many retries are appropriate?
- What backoff strategy prevents retry storms?
- When should retry be abandoned?

**Actions:**
- [ ] Implement exponential backoff with jitter to prevent thundering herd
- [ ] Set maximum retry count based on timeout budget
- [ ] Add circuit breaker for repeated failures
- [ ] Log each retry attempt with context
- [ ] Track retry metrics for monitoring

**Red flags / Warning signs:**
- Aggressive retries without backoff (retry storms)
- Infinite retry loops
- No circuit breaker for repeated failures
- Retrying non-idempotent operations
- No timeout on retry logic

**Decision points:**
- If retries consistently fail, open circuit breaker
- If operation is not idempotent, use different strategy
- If retry budget exhausted, fall back or fail

### Step 3: Design Fallback Behavior

**Questions to answer:**
- What should system do when primary path fails?
- Is there a cached or default value to use?
- Can we degrade functionality gracefully?
- What's the user experience during failure?

**Actions:**
- [ ] Define fallback behavior for each failure mode
- [ ] Implement graceful degradation where possible
- [ ] Use cached data when appropriate
- [ ] Design user-facing error messages that are actionable
- [ ] Ensure fallback doesn't introduce new failure modes

**Red flags / Warning signs:**
- No fallback behavior (hard failure only)
- Fallback behavior untested
- Fallback introduces worse problems
- Masking errors without logging per DT-1
- User sees cryptic technical error messages

**Decision points:**
- If cached data available, use it during failure
- If degraded mode acceptable, implement it
- If no fallback possible, fail fast with clear error
- Request confirmation if error masking proposed per GM-2

### Step 4: Implement Structured Error Logging

**Questions to answer:**
- What information is needed to diagnose failures?
- How can errors be correlated across services?
- Are errors actionable for on-call engineers?
- What severity levels are appropriate?

**Actions:**
- [ ] Log all errors with structured format (JSON, key-value pairs)
- [ ] Include correlation IDs for distributed tracing
- [ ] Log context: input parameters, state, timing
- [ ] Use appropriate severity levels (ERROR, WARN, INFO)
- [ ] Avoid logging sensitive data (PII, credentials)

**Red flags / Warning signs:**
- Generic error messages ("An error occurred")
- No stack traces or context
- Logging sensitive information
- No correlation between related errors
- Errors logged but not actionable

**Decision points:**
- If error is actionable by user, include it in user-facing message
- If error needs escalation, include severity and context
- If error contains sensitive data, sanitize before logging

### Step 5: Design Recovery Behavior

**Questions to answer:**
- How does system recover from failure state?
- Are there resources that need cleanup?
- Can partial work be rolled back?
- How do we maintain consistency?

**Actions:**
- [ ] Implement cleanup in finally blocks or deferred functions
- [ ] Ensure transactions rollback on error
- [ ] Release resources (connections, locks, file handles)
- [ ] Return system to consistent state per MF-5
- [ ] Document recovery procedures for manual intervention

**Red flags / Warning signs:**
- Resource leaks on error paths
- Partial state changes without rollback
- No cleanup of allocated resources
- System left in inconsistent state
- No path to recovery from certain failures

**Decision points:**
- If state is corrupted, rollback transaction
- If resources allocated, ensure cleanup
- If manual intervention needed, provide runbook

### Step 6: Test Error Paths

**Questions to answer:**
- Are all error paths covered by tests?
- Do tests verify retry logic works correctly?
- Are fallback behaviors tested?
- Do tests validate logging is actionable?

**Actions:**
- [ ] Write tests for each error path per TQ-1
- [ ] Test retry logic with mock failures
- [ ] Test circuit breaker opens and closes correctly
- [ ] Test fallback behaviors produce expected results
- [ ] Verify error logging contains necessary context

**Red flags / Warning signs:**
- Error paths not tested
- Tests only cover happy path
- Retry logic untested
- Fallback behavior assumed to work
- No integration tests for error scenarios

**Decision points:**
- If coverage inadequate, flag test-creation-strategy
- If error path cannot be tested, document why
- If test reveals bug, flag bug-diagnosis

### Final Step: Generate Error Handling Strategy Document

**Report/Output structure:**

```markdown
## Error Handling & Resilience Strategy

**System:** [Component/Service Name]
**Date:** [YYYY-MM-DD]
**Reliability Target:** [SLA/Uptime requirement]

### Failure Modes Identified

1. **[Dependency/Operation]**
   - Failure Type: [Transient | Permanent | Resource Exhaustion]
   - Strategy: [Retry | Fallback | Fail-fast | Circuit breaker]
   - Expected Frequency: [Rare | Occasional | Frequent]

### Retry Logic

**Exponential Backoff Configuration:**
- Initial delay: [e.g., 100ms]
- Max delay: [e.g., 30s]
- Max retries: [e.g., 3]
- Jitter: [e.g., ±25%]
- Circuit breaker threshold: [e.g., 5 consecutive failures]

### Fallback Behaviors

| Failure Scenario | Fallback Strategy | Degradation Impact |
|------------------|-------------------|-------------------|
| [Scenario 1] | [Strategy] | [User impact] |
| [Scenario 2] | [Strategy] | [User impact] |

### Recovery Procedures

**Automatic Recovery:**
- [Description of self-healing mechanisms]

**Manual Intervention Required:**
- [Runbook for operators]

### Logging Standards

**Error Log Format:**
```json
{
  "timestamp": "ISO8601",
  "severity": "ERROR|WARN|INFO",
  "correlation_id": "UUID",
  "error_type": "category",
  "message": "human-readable",
  "context": {
    "operation": "name",
    "input": "sanitized",
    "stack_trace": "..."
  }
}
```

### Test Coverage

✅ Error path tests: [X/Y paths covered]
✅ Retry logic tests: [Scenarios tested]
✅ Fallback tests: [Scenarios tested]
⚠️ [Any gaps in coverage]

### Skills Flagged
- **[Skill]**: [Reason]
```

## Core Responsibilities

**Primary responsibilities (in order):**

1. Prevent silent failures that corrupt state or produce incorrect results per MF-5
2. Ensure all exception paths handled explicitly, never swallowed
3. Maintain system stability under partial failures
4. Provide actionable, structured diagnostic information
5. Design retry logic that doesn't amplify failures
6. Implement graceful degradation where possible
7. Test error paths with same rigor as happy paths per TQ-1

**Quality criteria:**

* No silent exception swallowing
* All error paths have explicit handling
* Retry logic includes backoff and circuit breaking
* Diagnostic logs contain actionable information
* System returns to consistent state after failures per MF-5
* Error paths have test coverage per TQ-1

## Constraints (Rules Applied)

* **MF-5: Reliability Rule** — Systems must fail safely, predictably, and recoverably. No silent failures, no swallowed exceptions, no undefined recovery behavior. Every exception path must be handled; partial failures must leave system in consistent state.

* **GM-2: Explain Before Acting** — Risky error-masking decisions require explanation and confirmation. Don't mask errors for UX without explicit justification; explain trade-offs between showing technical errors vs hiding them.

* **DT-1: Explicit Tradeoff Logging** — When errors are masked for UX reasons, log the decision. Document why certain errors are not surfaced to users and create an audit trail of error handling decisions.

* **TQ-1: Test Coverage Requirement** — Error paths must have test coverage, not just happy paths. Write tests that simulate failures; verify retry logic, fallback behavior, and error logging.

## Tradeoff Handling

### Tradeoff 1: User Experience vs Strict Correctness

**Scenario:** Surfacing internal errors to users is bad UX, but masking them entirely hides problems.

**Default behavior:** Find the right diagnostic boundary - log everything internally, show actionable errors to users.

**Resolution workflow:**
```
Error needs user-facing message
  ↓
Options:
  A. Show technical error (bad UX, but honest)
  B. Show generic error, log technical details (better UX, diagnostic info preserved)
  C. Mask error entirely (best UX, worst observability)
  ↓
Request confirmation if masking proposed per GM-2
  ↓
If masking approved → Log decision per DT-1 → Document which errors are masked
  ↓
Implement with structured logging for internal diagnostics
```

### Tradeoff 2: Retry Aggressiveness vs System Load

**Scenario:** Aggressive retries improve resilience but can amplify failures under load (retry storm).

**Default behavior:** Use exponential backoff with jitter and circuit breakers.

**Resolution workflow:**
```
Retry logic needed for transient failure
  ↓
Calculate retry budget:
  - Max retries based on timeout budget
  - Exponential backoff to spread load
  - Jitter to prevent synchronized retries
  - Circuit breaker for persistent failures
  ↓
If retry storm risk exists → Add circuit breaker → Limit max retries
  ↓
Test retry logic under load conditions
```

## Failure & Escalation Behavior

### Escalation Scenario 1: Error Masking Proposed

**Trigger:** Code wants to swallow exceptions or mask errors for UX reasons without proper logging.

**Action:**
- Request justification per GM-2
- Explain observability impact
- Require structured logging if masking approved
- Log decision per DT-1

**Escalation format:**
```
⚠️ ERROR MASKING JUSTIFICATION NEEDED

Issue: Code proposes to catch and swallow [ExceptionType] without logging
Context: [Location and reason for masking]

Impact of masking:
- Failures will be invisible to monitoring
- Debugging production issues will be difficult
- No metrics on failure rate

Options:
A. Log error with full context, show generic message to user (recommended)
B. Mask error entirely (requires explicit justification and approval)
C. Surface error to user (poor UX but maximum observability)

Question: Please justify error masking or choose option A.
```

### Escalation Scenario 2: Error Pattern Suggests Monitoring Gap

**Trigger:** Error handling reveals that certain failure modes are not monitored.

**Action:**
- Flag observability skill (Phase 2)
- Document which metrics/alerts are missing
- Suggest monitoring strategy

### Escalation Scenario 3: Error Handling Reveals Underlying Bug

**Trigger:** During error handling design, root cause of failures appears to be a bug in the code.

**Action:**
- Flag bug-diagnosis skill
- Document suspected bug with evidence
- Defer error handling until bug is investigated

### Escalation Scenario 4: Implementation Complete

**Trigger:** Error handling code produced.

**Action:**
- Flag `regression-prevention` to validate no behavioral regressions introduced
- Flag `correctness-validation` to verify error handling doesn't break existing correctness
- Flag `test-creation-strategy` to ensure error paths have test coverage per TQ-1

### When to halt execution:

* Error masking proposed without observability plan
* Retry logic would create unbounded resource consumption
* Fallback behavior would corrupt data
* Error handling fundamentally incompatible with correctness per MF-5

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

Runs when production-bound code needs reliability hardening. Often runs after correctness-validation confirms happy path works, before deployment. Can be triggered by post-incident analysis or code review.

### How This Skill Integrates

**Does NOT directly call other skills.** Instead, this skill **flags** when other skills should review.

**Integration workflow:**
1. **Orchestrator** invokes error-handling-resilience for production-bound code
2. This skill designs error paths, retry logic, fallback behaviors
3. This skill **outputs flags** for other skills in report
4. **Orchestrator** decides which skills to invoke next based on flags

## Related Skills

**Skills this skill depends on:**

* **correctness-validation** - Must verify happy path correctness before adding error handling. Error handling should not mask correctness bugs.

**Skills this skill cooperates with:**

* **bug-diagnosis** - Works together when errors reveal underlying bugs rather than legitimate failure handling
* **test-creation-strategy** - Coordinates on error path test coverage
* **observability** (Phase 2) - Ensures error logging integrates with monitoring

**Skills this skill may invoke/flag:**

* **correctness-validation** - When error handling added, verify it doesn't break correctness
* **bug-diagnosis** - When error patterns reveal underlying bugs
* **documentation-knowledge-transfer** - When complex error handling needs documentation
* **observability** - When error patterns suggest monitoring gaps

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Never swallow exceptions silently per MF-5
* [ ] Log all error masking decisions per DT-1
* [ ] Request confirmation for error masking per GM-2
* [ ] Ensure error paths have test coverage per TQ-1
* [ ] Maintain system consistency after failures per MF-5
* [ ] Provide actionable diagnostic information in all error logs
* [ ] Document retry logic and circuit breaker configurations

**Audit trail requirements:**

* All error masking decisions logged with justification
* Retry logic configurations documented
* Fallback behaviors tested and verified
* Error handling strategy documented for operations teams

## Example Use Cases

### Example 1: Third-Party API Integration with Retry Logic

**Scenario:** E-commerce checkout calls payment processing API that occasionally times out or returns 503 errors.

**Inputs provided:**
- Code: checkout flow calling PaymentAPI.process()
- Reliability requirement: 99.9% success rate for checkouts
- Historical data: API fails ~2% of time with transient 503 errors

**Execution steps:**
1. Identify failure point: PaymentAPI.process() call
2. Classify failures: 503 errors are transient, timeout is transient, 4xx errors are permanent
3. Design retry logic:
   - Exponential backoff: 100ms, 200ms, 400ms (max 3 retries)
   - Jitter: ±25% to prevent thundering herd
   - Circuit breaker: open after 5 consecutive failures
4. Design fallback: Queue payment for async processing if all retries fail
5. Implement logging:
   ```json
   {
     "event": "payment_retry",
     "attempt": 2,
     "order_id": "12345",
     "error": "503 Service Unavailable",
     "backoff_ms": 200
   }
   ```
6. Test error paths: Simulate 503 responses, verify retry logic, test circuit breaker

**Result:** ✅ PASS - Resilient payment processing with graceful degradation

**Skills flagged:** None

**Output produced:**
```python
class PaymentProcessor:
    def __init__(self):
        self.circuit_breaker = CircuitBreaker(threshold=5, timeout=60)
        self.max_retries = 3

    async def process_payment(self, order):
        if self.circuit_breaker.is_open():
            logger.warning("Circuit breaker open, queueing payment",
                         order_id=order.id)
            await self.queue_for_async_processing(order)
            return PaymentResult.QUEUED

        for attempt in range(self.max_retries):
            try:
                result = await self.payment_api.process(order)
                self.circuit_breaker.record_success()
                return result
            except (Timeout, ServiceUnavailable) as e:
                if attempt < self.max_retries - 1:
                    backoff_ms = (2 ** attempt) * 100
                    jitter = random.uniform(-0.25, 0.25) * backoff_ms
                    delay = backoff_ms + jitter

                    logger.warning(
                        "Payment API failure, retrying",
                        attempt=attempt + 1,
                        order_id=order.id,
                        error=str(e),
                        backoff_ms=delay
                    )
                    await asyncio.sleep(delay / 1000)
                else:
                    self.circuit_breaker.record_failure()
                    logger.error(
                        "Payment API exhausted retries",
                        order_id=order.id,
                        error=str(e)
                    )
                    await self.queue_for_async_processing(order)
                    return PaymentResult.QUEUED
            except PaymentDeclined as e:
                # Permanent failure, don't retry
                logger.info("Payment declined", order_id=order.id, reason=e.reason)
                return PaymentResult.DECLINED
```

### Example 2: Database Connection Error Handling

**Scenario:** Web application queries database for user profile. Database occasionally unavailable during deployment or maintenance.

**Inputs provided:**
- Code: UserService.getProfile(userId)
- Reliability requirement: Graceful degradation acceptable
- Deployment windows: Database offline ~5 minutes during deployments

**Execution steps:**
1. Identify failure: Database connection error
2. Classify: Transient during deployments, permanent if misconfigured
3. Design retry: Short backoff (1s, 2s, 4s) for deployment windows
4. Design fallback: Return cached profile if available, else show "temporarily unavailable" message
5. Implement structured logging with correlation IDs
6. Test: Simulate DB unavailability, verify cache fallback, test retry logic

**Result:** ✅ PASS - Graceful degradation during DB maintenance

**Skills flagged:** None

**Output produced:**
```python
class UserService:
    def __init__(self, db, cache, logger):
        self.db = db
        self.cache = cache
        self.logger = logger
        self.max_retries = 3

    def get_profile(self, user_id, correlation_id=None):
        for attempt in range(self.max_retries):
            try:
                profile = self.db.query_profile(user_id)
                self.cache.set(f"profile:{user_id}", profile, ttl=300)
                return profile
            except DatabaseConnectionError as e:
                self.logger.error(
                    "Database connection failed",
                    correlation_id=correlation_id,
                    user_id=user_id,
                    attempt=attempt + 1,
                    error=str(e)
                )

                if attempt < self.max_retries - 1:
                    time.sleep(2 ** attempt)  # 1s, 2s, 4s
                else:
                    # Exhausted retries, try cache
                    cached = self.cache.get(f"profile:{user_id}")
                    if cached:
                        self.logger.info(
                            "Returning cached profile",
                            correlation_id=correlation_id,
                            user_id=user_id,
                            cache_age_seconds=cached.age
                        )
                        return cached.value
                    else:
                        self.logger.error(
                            "No cached profile available",
                            correlation_id=correlation_id,
                            user_id=user_id
                        )
                        raise ServiceUnavailableError(
                            "User profile temporarily unavailable"
                        )
```

### Example 3: File Processing with Resource Cleanup

**Scenario:** Batch job processes uploaded files. Files may be corrupted, too large, or processing may timeout.

**Inputs provided:**
- Code: FileProcessor.process(file_path)
- Reliability requirement: Must not leak file handles or temporary files
- Failure modes: Corrupted files, size limits exceeded, processing timeout

**Execution steps:**
1. Identify failure points: File open, parsing, processing, cleanup
2. Design error handling:
   - Corrupted file: Skip and log
   - Size exceeded: Skip and log
   - Timeout: Terminate and cleanup
3. Implement cleanup in finally block
4. Log all failures with file metadata
5. Test: Simulate each failure mode, verify cleanup occurs

**Result:** ✅ PASS - Robust file processing with guaranteed cleanup

**Skills flagged:** None

**Output produced:**
```python
class FileProcessor:
    def __init__(self, max_size_mb=100, timeout_seconds=300):
        self.max_size_mb = max_size_mb
        self.timeout_seconds = timeout_seconds

    def process_file(self, file_path):
        temp_file = None
        file_handle = None

        try:
            # Check file size before opening
            size_mb = os.path.getsize(file_path) / (1024 * 1024)
            if size_mb > self.max_size_mb:
                logger.warning(
                    "File exceeds size limit",
                    file=file_path,
                    size_mb=size_mb,
                    limit_mb=self.max_size_mb
                )
                return ProcessResult.SKIPPED

            # Open file with timeout
            with timeout_context(self.timeout_seconds):
                file_handle = open(file_path, 'rb')
                temp_file = self._create_temp_file()

                # Process file
                result = self._process_contents(file_handle, temp_file)

                logger.info(
                    "File processed successfully",
                    file=file_path,
                    records_processed=result.count
                )
                return result

        except CorruptedFileError as e:
            logger.error(
                "File corrupted, skipping",
                file=file_path,
                error=str(e)
            )
            return ProcessResult.SKIPPED

        except TimeoutError:
            logger.error(
                "File processing timeout",
                file=file_path,
                timeout_seconds=self.timeout_seconds
            )
            return ProcessResult.TIMEOUT

        except Exception as e:
            logger.error(
                "Unexpected error processing file",
                file=file_path,
                error=str(e),
                stack_trace=traceback.format_exc()
            )
            raise

        finally:
            # Guaranteed cleanup
            if file_handle:
                try:
                    file_handle.close()
                except Exception as e:
                    logger.warning("Error closing file", error=str(e))

            if temp_file and os.path.exists(temp_file):
                try:
                    os.remove(temp_file)
                except Exception as e:
                    logger.warning("Error removing temp file",
                                 temp_file=temp_file, error=str(e))
```

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Silent exception swallowing that hides failures
```python
try:
    api.call()
except:
    pass  # ❌ Silent failure
```
✅ **Correct approach:** Log all exceptions with context, even if recovering
```python
try:
    api.call()
except Exception as e:
    logger.error("API call failed", error=str(e), context=...)
    # Then handle appropriately
```

❌ **Anti-pattern 2:** Retry storms amplifying failures under load
```python
while True:
    try:
        return api.call()
    except:
        continue  # ❌ Infinite retries with no backoff
```
✅ **Correct approach:** Exponential backoff with jitter and max retries
```python
for attempt in range(max_retries):
    try:
        return api.call()
    except TransientError:
        if attempt < max_retries - 1:
            backoff = (2 ** attempt) * base_delay
            jitter = random.uniform(-0.25, 0.25) * backoff
            time.sleep(backoff + jitter)
        else:
            raise
```

❌ **Anti-pattern 3:** Generic error messages with no diagnostic value
```python
except Exception as e:
    return "An error occurred"  # ❌ Useless message
```
✅ **Correct approach:** Structured logging with actionable information
```python
except Exception as e:
    logger.error(
        "Payment processing failed",
        order_id=order.id,
        user_id=user.id,
        error_type=type(e).__name__,
        error_message=str(e),
        stack_trace=traceback.format_exc()
    )
    return "Payment processing is temporarily unavailable. Order ID: {order.id}"
```

❌ **Anti-pattern 4:** Catch-all exception handlers masking different failure types
```python
try:
    result = process()
except Exception:  # ❌ Treats all failures the same
    return None
```
✅ **Correct approach:** Handle different exception types appropriately
```python
try:
    result = process()
except ValidationError as e:
    logger.warning("Validation failed", details=e.details)
    return ValidationResult.INVALID
except TransientError as e:
    logger.warning("Transient failure, retrying", error=str(e))
    return retry_with_backoff()
except PermanentError as e:
    logger.error("Permanent failure", error=str(e))
    raise
```

❌ **Anti-pattern 5:** Not testing error paths
```python
# Only testing happy path
def test_process_payment():
    assert process_payment(valid_order) == SUCCESS
# ❌ No tests for failures
```
✅ **Correct approach:** Test all error paths per TQ-1
```python
def test_payment_retry_on_503():
    with mock_api_failure(status=503, times=2):
        result = process_payment(order)
        assert result == SUCCESS
        assert retry_count == 2

def test_payment_fails_after_max_retries():
    with mock_api_failure(status=503, times=5):
        result = process_payment(order)
        assert result == QUEUED
```

❌ **Anti-pattern 6:** No timeout on network calls
```python
response = requests.get(url)  # ❌ Can hang forever
```
✅ **Correct approach:** Always set timeouts
```python
response = requests.get(url, timeout=(3, 10))  # connect, read
```

❌ **Anti-pattern 7:** Swallowing exceptions in finally blocks
```python
finally:
    file.close()  # ❌ If close() raises, original exception lost
```
✅ **Correct approach:** Handle cleanup errors separately
```python
finally:
    try:
        file.close()
    except Exception as e:
        logger.warning("Cleanup error", error=str(e))
```

❌ **Anti-pattern 8:** Resource leaks on error paths
```python
def process():
    conn = database.connect()
    return conn.query()  # ❌ Connection never closed if query fails
```
✅ **Correct approach:** Use context managers or finally blocks
```python
def process():
    with database.connect() as conn:
        return conn.query()  # ✅ Connection always closed
```

❌ **Anti-pattern 9:** Masking errors for UX without logging
```python
try:
    result = external_api.call()
except:
    return "Success"  # ❌ Lie to user, hide failure
```
✅ **Correct approach:** Log internally, show appropriate message per DT-1
```python
try:
    result = external_api.call()
except Exception as e:
    logger.error("API call failed", error=str(e))
    return "Request received, processing may be delayed"
```

❌ **Anti-pattern 10:** Retry non-idempotent operations blindly
```python
def charge_credit_card(amount):
    for attempt in range(3):
        try:
            return payment_api.charge(amount)  # ❌ May double-charge
        except:
            continue
```
✅ **Correct approach:** Use idempotency tokens for retries
```python
def charge_credit_card(amount, idempotency_key):
    for attempt in range(3):
        try:
            return payment_api.charge(amount, idempotency_key=idempotency_key)
        except TransientError:
            continue  # ✅ Safe to retry with same key
```

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ **Performance optimization** - Handled by performance-optimization skill. This skill focuses on correctness and resilience, not speed.
* ❌ **Monitoring and alerting configuration** - Handled by observability skill (Phase 2). This skill designs error handling, not monitoring infrastructure.
* ❌ **Root cause analysis of bugs** - Handled by bug-diagnosis skill. This skill handles legitimate failures, not implementation bugs.
* ❌ **Security vulnerabilities** - Handled by security skill (Phase 2). This skill ensures systems fail safely, not securely.
* ❌ **Distributed system consensus** - Handled by system-design skill (Phase 2). This skill handles individual component failures, not distributed coordination.

**Boundary clarifications:**

* This skill designs how code should behave when things fail (error handling strategy)
* Observability skill (Phase 2) determines how to monitor and alert on those failures
* Bug-diagnosis skill investigates why failures occur unexpectedly
* Security skill ensures failures don't leak sensitive information or create vulnerabilities

## Notes for LLM Implementation

1. **Be systematic about failure modes**: Enumerate all possible failure points. Don't assume code can't fail.
2. **Be evidence-based on retry logic**: Use exponential backoff with jitter as default. Don't invent custom retry algorithms without justification.
3. **Be conservative on error masking**: Default to logging everything. Require explicit justification per GM-2 for masking errors.
4. **Be explicit about recovery**: Document exactly how system returns to consistent state per MF-5.
5. **Be thorough on testing**: Insist on error path test coverage per TQ-1. Don't accept "tested manually."
6. Provide code examples with structured logging format (JSON), retry configurations (delays, max retries, jitter), and test code for error paths.
7. Different domains have different resilience needs; some failures are acceptable (best-effort features). Error handling should not degrade performance; logging volume must be sustainable (don't log every retry).
