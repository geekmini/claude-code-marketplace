# [Feature Name] Specification

**Status**: Draft
**Created**: YYYY-MM-DD
**Author**: [name]
**Version**: 1.0

---

## Overview

[Provide a clear, concise description of the feature. Explain what problem it solves and who benefits from it. 1-2 paragraphs.]

## Goals

Primary objectives this feature achieves:

- [Goal 1 - measurable outcome]
- [Goal 2 - measurable outcome]
- [Goal 3 - measurable outcome]

## Non-Goals

Explicitly out of scope for this iteration:

- [Non-goal 1]
- [Non-goal 2]

---

## Data Model

### [Primary Entity]

| Field        | Type     | Required | Default | Description           |
| ------------ | -------- | -------- | ------- | --------------------- |
| id           | UUID     | Yes      | auto    | Primary key           |
| created_at   | DateTime | Yes      | now()   | Creation timestamp    |
| updated_at   | DateTime | Yes      | now()   | Last update timestamp |
| [field_name] | [type]   | [Yes/No] | [value] | [description]         |

**Constraints**:
- [Constraint 1]
- [Constraint 2]

**Relationships**:
- [Relationship to other entities]

### [Secondary Entity] (if applicable)

[Same structure as above]

---

## API Endpoints

### Create [Resource]

**Endpoint**: `POST /api/v1/[resources]`

**Description**: Creates a new [resource].

**Authentication**: Required (Bearer token)

**Authorization**: [Role required]

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body**:
```json
{
  "field1": "string",
  "field2": 123,
  "field3": true
}
```

**Validation Rules**:
- `field1`: Required, max 255 characters
- `field2`: Required, positive integer
- `field3`: Optional, defaults to false

**Response (201 Created)**:
```json
{
  "id": "uuid",
  "field1": "string",
  "field2": 123,
  "field3": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Error Responses**:

| Status | Code             | Description              |
| ------ | ---------------- | ------------------------ |
| 400    | VALIDATION_ERROR | Invalid request body     |
| 401    | UNAUTHORIZED     | Missing or invalid token |
| 403    | FORBIDDEN        | Insufficient permissions |
| 409    | CONFLICT         | Resource already exists  |

---

### Get [Resource]

**Endpoint**: `GET /api/v1/[resources]/:id`

**Description**: Retrieves a single [resource] by ID.

**Authentication**: Required

**Path Parameters**:
- `id` (UUID): Resource identifier

**Response (200 OK)**:
```json
{
  "id": "uuid",
  "field1": "string",
  "field2": 123,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

**Error Responses**:

| Status | Code      | Description        |
| ------ | --------- | ------------------ |
| 404    | NOT_FOUND | Resource not found |

---

### List [Resources]

**Endpoint**: `GET /api/v1/[resources]`

**Description**: Lists [resources] with pagination and filtering.

**Authentication**: Required

**Query Parameters**:

| Parameter | Type    | Default    | Description              |
| --------- | ------- | ---------- | ------------------------ |
| page      | integer | 1          | Page number              |
| limit     | integer | 20         | Items per page (max 100) |
| sort      | string  | created_at | Sort field               |
| order     | string  | desc       | Sort order (asc/desc)    |
| [filter]  | string  | -          | Filter by [field]        |

**Response (200 OK)**:
```json
{
  "data": [
    {
      "id": "uuid",
      "field1": "string"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}
```

---

### Update [Resource]

**Endpoint**: `PUT /api/v1/[resources]/:id`

**Description**: Updates an existing [resource].

**Authentication**: Required

**Request Body**:
```json
{
  "field1": "updated string",
  "field2": 456
}
```

**Response (200 OK)**:
```json
{
  "id": "uuid",
  "field1": "updated string",
  "field2": 456,
  "updated_at": "2024-01-02T00:00:00Z"
}
```

---

### Delete [Resource]

**Endpoint**: `DELETE /api/v1/[resources]/:id`

**Description**: Deletes a [resource].

**Authentication**: Required

**Response (204 No Content)**: Empty body

---

## Business Rules

### Rule 1: [Name]

**Description**: [Detailed explanation of the business rule]

**When**: [Trigger condition]

**Then**: [Expected behavior]

**Example**:
- Input: [example input]
- Output: [expected output]

### Rule 2: [Name]

[Same structure]

---

## Implementation Checklist

### Phase 1: Data Layer

- [ ] Create database migration for [entity]
- [ ] Create model/entity file
- [ ] Create repository interface
- [ ] Create repository implementation

### Phase 2: Business Layer

- [ ] Create service interface
- [ ] Create service implementation
- [ ] Implement validation logic
- [ ] Implement business rules

### Phase 3: API Layer

- [ ] Create request/response DTOs
- [ ] Create controller/handler
- [ ] Add route registration
- [ ] Add authentication middleware

### Phase 4: Testing

- [ ] Unit tests for service layer
- [ ] Unit tests for validation
- [ ] Integration tests for repository
- [ ] API tests for endpoints

### Phase 5: Documentation

- [ ] Update API documentation
- [ ] Update README if needed
- [ ] Add code comments

---

## Architecture Decision

**Selected Approach**: [Option name from planning phase]

**Rationale**:
1. [Reason 1]
2. [Reason 2]
3. [Reason 3]

**Trade-offs Accepted**:
- [Trade-off 1]
- [Trade-off 2]

---

## Dependencies

### Internal

- [Module/service this feature depends on]

### External

- [External API or service]

---

## Security Considerations

- [Security measure 1]
- [Security measure 2]

---

## Performance Considerations

- [Performance requirement or optimization]

---

## Open Questions

- [ ] [Unresolved question 1]
- [ ] [Unresolved question 2]

---

## Changelog

| Version | Date       | Author | Changes               |
| ------- | ---------- | ------ | --------------------- |
| 1.0     | YYYY-MM-DD | [name] | Initial specification |

---

*Generated by dev-flow plugin*
