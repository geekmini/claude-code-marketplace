# Confidence Scoring Guidelines

Use these guidelines to assign confidence scores to code review findings. Only issues with confidence >= 80% should be reported.

## Scoring Scale

| Score Range | Confidence Level | Report? |
|-------------|------------------|---------|
| 90-100 | Certain | Yes |
| 80-89 | Very likely | Yes |
| 70-79 | Likely | No |
| 50-69 | Possible | No |
| 25-49 | Unlikely | No |
| 0-24 | False positive | No |

## Factors That Increase Confidence

### +20-30 Points: Clear Evidence

- Obvious null/undefined access without check
- SQL string concatenation with user input
- Hardcoded credentials in source code
- Infinite loop with no exit condition
- Division by zero without guard

### +15-20 Points: Pattern Match

- Known vulnerability pattern (OWASP Top 10)
- Documented anti-pattern for the framework
- Explicit violation of project conventions
- Missing required error handling

### +10-15 Points: Context Confirms

- Similar bugs exist elsewhere in codebase
- Test case demonstrates the bug
- Spec explicitly requires different behavior
- Security tool/linter flags the same issue

### +5-10 Points: Reasonable Suspicion

- Code smell that often leads to bugs
- Missing edge case handling
- Inconsistent with similar code nearby
- Complexity suggests likely error

## Factors That Decrease Confidence

### -20-30 Points: Likely False Positive

- Code is defensive/intentional
- Framework handles the concern automatically
- Test coverage proves correct behavior
- Comment explains the unusual pattern

### -15-20 Points: Context Unclear

- Cannot trace full execution path
- External dependency behavior unknown
- Configuration might change behavior
- Multi-threaded concerns unclear

### -10-15 Points: Subjective

- Style preference, not correctness
- Multiple valid approaches exist
- Trade-off choice, not error
- Pre-existing code pattern

### -5-10 Points: Minor Concern

- Optimization opportunity, not bug
- Readability suggestion
- Non-critical duplication
- Documentation improvement

## Category-Specific Scoring

### Bugs (Start at 70)

**90-100**: Definitely causes incorrect behavior
- Logic that provably produces wrong result
- Exception that will crash the application
- Data corruption scenario

**80-89**: Very likely causes issues
- Missing null check where null is possible
- Race condition in concurrent code
- Integer overflow in calculation

**70-79**: Might cause issues
- Edge case not handled
- Defensive code missing
- Assumption that might not hold

### Security (Start at 75)

**90-100**: Exploitable vulnerability
- SQL injection with user input
- Stored XSS vector
- Authentication bypass

**80-89**: Likely security issue
- Missing input sanitization
- Sensitive data in logs
- Weak cryptography

**70-79**: Potential security concern
- Overly permissive CORS
- Missing rate limiting
- Verbose error messages

### Convention (Start at 60)

**90-100**: Direct violation of documented rule
- Explicit CLAUDE.md rule broken
- Framework-specific required pattern missing

**80-89**: Clear inconsistency
- Different from all similar code
- Breaks established project pattern

**70-79**: Questionable choice
- Unusual but might be intentional
- Undocumented pattern

### Quality (Start at 50)

**90-100**: Objectively poor code
- Duplicate 50+ line blocks
- Cyclomatic complexity > 25
- No tests for critical logic

**80-89**: Significant quality issue
- Clear DRY violation (3+ copies)
- Missing error handling on external call
- Untested edge cases

**70-79**: Room for improvement
- Minor duplication
- Could be more readable
- Additional tests helpful

## Example Scores

### Score: 95 - SQL Injection

```go
query := "SELECT * FROM users WHERE id = " + userInput
```

- Clear vulnerability pattern (+30)
- User input directly concatenated (+25)
- OWASP Top 10 category (+20)
- No sanitization visible (+20)

### Score: 85 - Null Pointer

```typescript
const name = user.profile.name; // user might be null
```

- Obvious null access without check (+25)
- Context shows user comes from DB query (+20)
- No null check in calling code (+20)
- Similar code elsewhere uses null check (+20)

### Score: 72 - Missing Error Handling

```python
response = requests.get(url)
data = response.json()
```

- External call without try/catch (+15)
- Could raise exception (+15)
- Similar code elsewhere has handling (+15)
- Might be intentional (let it bubble) (-13)
- Not in critical path (-10)

**Not reported** (below 80)

### Score: 55 - Style Preference

```javascript
const x = arr.filter(i => i > 0).map(i => i * 2);
// Could be: arr.reduce(...)
```

- Functional approach works (+10)
- Performance difference negligible (-15)
- Both approaches valid (-20)
- Team might prefer this style (-10)
- No correctness issue (-10)

**Not reported** (below 80)

## Review Checklist

Before reporting an issue, verify:

- [ ] Confidence score calculated using guidelines
- [ ] Score >= 80
- [ ] Not a false positive due to missing context
- [ ] Not pre-existing code (unless specifically requested)
- [ ] Not a style preference
- [ ] Has concrete suggested fix
- [ ] File and line number accurate

## Issue Report Template

```markdown
**Confidence**: [score]% ([level])

**Category**: [Bug | Security | Convention | Quality]

**File**: `path/to/file.ext:line`

**Issue**: [Clear, specific description]

**Evidence**:
- [Factor 1 that increased confidence]
- [Factor 2 that increased confidence]

**Suggested Fix**:
```[language]
// Corrected code
```

**Risk if Not Fixed**: [Impact description]
```
