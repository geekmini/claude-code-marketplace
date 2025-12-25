# Planning Question Categories

Use these question categories to thoroughly clarify requirements before implementation.

## Scope Questions

Define boundaries of the feature:

- What functionality is included in this feature?
- What is explicitly out of scope for this iteration?
- Are there related features that should be considered?
- Is this a new feature or enhancement to existing functionality?
- What is the minimum viable implementation?

## Data Model Questions

Define the data structure:

- What entities/models are involved?
- What fields does each entity need?
- Which fields are required vs optional?
- What are the data types for each field?
- Are there relationships between entities?
- What are the cardinality rules (one-to-one, one-to-many)?
- Are there any computed/derived fields?
- What is the primary key strategy (UUID, auto-increment)?
- Are there soft delete requirements?
- What timestamps are needed (created_at, updated_at)?

## API Design Questions

For REST APIs:

- What endpoints are needed?
- What HTTP methods for each endpoint?
- What is the URL structure/naming?
- What parameters are needed (path, query, body)?
- What is the request body format?
- What is the response body format?
- What HTTP status codes should be returned?
- Is pagination needed? What style?
- What filtering/sorting options are needed?

## Business Rules Questions

Define logic and constraints:

- What validation rules apply to each field?
- What are the allowed values for enum fields?
- Are there any cross-field validation rules?
- What business logic determines outcomes?
- Are there any conditional behaviors?
- What calculations or transformations are needed?
- Are there any rate limits or quotas?
- What are the ordering/priority rules?

## Authentication & Authorization Questions

Define access control:

- Is this a public or protected endpoint?
- What authentication method is used?
- What roles/permissions are required?
- Are there different access levels?
- Is there resource-level authorization?
- Are there any tenant/organization boundaries?

## Error Handling Questions

Define failure scenarios:

- What can go wrong during this operation?
- How should each error type be handled?
- What error messages should users see?
- Should errors be logged/alerted?
- Are there retry scenarios?
- What happens if external services fail?

## Performance Questions

Define performance requirements:

- What is the expected load/volume?
- Are there response time requirements?
- Is caching needed?
- Are there batch processing needs?
- Is async processing needed?
- What are the scalability requirements?

## Integration Questions

Define external dependencies:

- What external services are involved?
- What APIs need to be called?
- Are there webhook requirements?
- What happens if integrations are unavailable?
- Are there data synchronization needs?

## Testing Questions

Define testing requirements:

- What scenarios must be tested?
- Are there specific edge cases to cover?
- What is the expected test coverage?
- Are integration tests needed?
- Are E2E tests needed?

## Question Prioritization

Ask questions in this order:

1. **Critical** (must know before any design)
   - Core scope
   - Primary data model
   - Main API endpoints

2. **Important** (affects architecture)
   - Authentication requirements
   - Key business rules
   - Integration points

3. **Clarifying** (refines implementation)
   - Edge cases
   - Error handling
   - Performance needs

## Question Templates

### Multiple Choice

```markdown
**Question**: What authentication method should be used?

1. JWT tokens (stateless, scalable)
2. Session-based (simpler, stateful)
3. API keys (for service-to-service)
4. OAuth2 (for third-party integration)
```

### Open-Ended

```markdown
**Question**: What validation rules apply to the email field?

Please describe any format requirements, uniqueness constraints, or other validation needs.
```

### Yes/No with Follow-up

```markdown
**Question**: Is soft delete required for this entity?

- Yes (records marked as deleted, not removed)
- No (hard delete, records removed permanently)

If yes, should deleted records be excluded from queries by default?
```

### Numeric/Range

```markdown
**Question**: What is the maximum allowed file size for uploads?

Please specify in MB. Consider storage costs and user experience.
```
