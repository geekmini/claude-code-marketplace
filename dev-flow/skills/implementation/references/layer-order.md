# Implementation Layer Order

Follow these implementation sequences based on architecture style to ensure dependencies are satisfied.

## Layered Architecture

Implement from bottom to top:

```
1. Data Layer
   └── Database migrations
   └── Entity/Model definitions
   └── Repository interfaces
   └── Repository implementations

2. Business Layer
   └── Service interfaces
   └── Service implementations
   └── Validation logic
   └── Business rules

3. Presentation Layer
   └── Request/Response DTOs
   └── Controllers/Handlers
   └── Route registration
   └── Middleware

4. Cross-Cutting
   └── Error handling
   └── Logging
   └── Authentication hooks
```

## Clean Architecture

Implement from core outward:

```
1. Entities (Core)
   └── Domain models
   └── Value objects
   └── Domain errors

2. Use Cases (Application)
   └── Use case interfaces
   └── Use case implementations
   └── Input/Output ports

3. Interface Adapters
   └── Controllers
   └── Presenters
   └── Repository adapters
   └── External service adapters

4. Frameworks & Drivers
   └── Database connections
   └── Web framework setup
   └── External API clients
```

## MVC Pattern

Implement in this order:

```
1. Model
   └── Database schema
   └── Model definitions
   └── Relationships
   └── Validations

2. Controller
   └── Route handlers
   └── Request parsing
   └── Response formatting
   └── Error handling

3. View (if applicable)
   └── Templates
   └── Serializers
   └── Response formatters
```

## Microservices

For each service:

```
1. API Contract
   └── OpenAPI/Protobuf definitions
   └── Request/Response schemas

2. Data Layer
   └── Database schema
   └── Repository

3. Business Logic
   └── Service implementation
   └── Event handlers

4. API Layer
   └── HTTP/gRPC handlers
   └── Middleware

5. Integration
   └── Service clients
   └── Message publishers
   └── Event consumers
```

## Test Implementation Order

Mirror the implementation order:

```
1. Unit Tests (bottom-up)
   └── Model/Entity tests
   └── Service tests (with mocks)
   └── Validation tests

2. Integration Tests
   └── Repository tests (with test DB)
   └── Service integration tests

3. API Tests
   └── Endpoint tests
   └── Authentication tests
   └── Error handling tests

4. E2E Tests (if applicable)
   └── Full flow tests
   └── Multi-service tests
```

## File Naming Patterns

### Go

```
internal/
├── models/
│   └── user.go
├── repository/
│   ├── user_repository.go
│   └── user_repository_test.go
├── service/
│   ├── user_service.go
│   └── user_service_test.go
└── handler/
    ├── user_handler.go
    └── user_handler_test.go
```

### TypeScript/Node

```
src/
├── models/
│   └── user.model.ts
├── repositories/
│   ├── user.repository.ts
│   └── user.repository.spec.ts
├── services/
│   ├── user.service.ts
│   └── user.service.spec.ts
└── controllers/
    ├── user.controller.ts
    └── user.controller.spec.ts
```

### Python

```
src/
├── models/
│   └── user.py
├── repositories/
│   └── user_repository.py
├── services/
│   └── user_service.py
└── handlers/
    └── user_handler.py

tests/
├── unit/
│   ├── test_user_service.py
│   └── test_user_repository.py
└── integration/
    └── test_user_api.py
```

## Dependency Checklist

Before implementing each layer, verify:

- [ ] All dependencies from lower layers exist
- [ ] Interfaces are defined before implementations
- [ ] Test utilities/mocks are available
- [ ] Database migrations have run
- [ ] External service contracts are defined

## Common Pitfalls

### Pitfall 1: Top-Down Implementation

❌ Starting with controllers before services exist
✅ Start with data layer, work up

### Pitfall 2: Missing Interfaces

❌ Implementing concrete classes without interfaces
✅ Define interfaces first for testability

### Pitfall 3: Circular Dependencies

❌ Service A depends on Service B which depends on Service A
✅ Use interfaces or extract shared logic

### Pitfall 4: Tests After All Code

❌ Writing all code, then all tests
✅ Write tests alongside each layer
