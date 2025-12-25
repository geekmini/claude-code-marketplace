---
name: swagger
description: This skill should be used when the user asks to "regenerate swagger", "update API docs", "generate OpenAPI spec", "run swag init", or mentions "swagger documentation". Regenerates Swagger/OpenAPI documentation after implementation changes.
---

# Swagger Documentation

Regenerate Swagger/OpenAPI documentation to reflect implementation changes. Supports multiple swagger tools and frameworks.

## Overview

This skill:
- Detects the swagger tool in use
- Regenerates API documentation
- Validates the generated spec
- Reports any annotation issues

## Supported Tools

| Tool                | Framework      | Command                      |
| ------------------- | -------------- | ---------------------------- |
| `swag`              | Go (Gin, Echo) | `swag init`                  |
| `swagger-cli`       | Node.js        | `swagger-cli validate`       |
| `openapi-generator` | Multi-language | `openapi-generator generate` |

## Process

### Step 1: Detect Swagger Tool

```bash
# Check for swag (Go)
which swag && swag --version

# Check for swagger-cli (Node)
which swagger-cli && swagger-cli --version

# Check for existing swagger file
ls swagger.json swagger.yaml docs/swagger.json docs/swagger.yaml 2>/dev/null
```

### Step 2: Regenerate Documentation

**For Go (swag)**:

```bash
# Standard regeneration
swag init

# With custom paths
swag init -g cmd/main.go -o docs/

# With specific parseDependency
swag init --parseDependency --parseInternal
```

**For Node.js (swagger-cli)**:

```bash
# Validate existing spec
swagger-cli validate swagger.yaml

# Bundle multiple files
swagger-cli bundle swagger.yaml -o dist/swagger.json
```

### Step 3: Validate Generated Spec

```bash
# Validate JSON
swagger-cli validate swagger.json

# Check for common issues
grep -E "TODO|FIXME|XXX" swagger.json
```

### Step 4: Report Results

```markdown
## Swagger Documentation Updated

**Tool**: [swag/swagger-cli]
**Output**: [file path]

### Endpoints Documented
- `GET /api/v1/users` - List users
- `POST /api/v1/users` - Create user
- [additional endpoints]

### Warnings
- [Any annotation warnings]

### Validation
✅ Spec is valid OpenAPI 3.0
```

## Go Swagger Annotations

For Go projects using swag, ensure handlers have proper annotations:

```go
// @Summary Create user
// @Description Create a new user account
// @Tags users
// @Accept json
// @Produce json
// @Param user body CreateUserRequest true "User data"
// @Success 201 {object} UserResponse
// @Failure 400 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /users [post]
func CreateUser(c *gin.Context) {
    // implementation
}
```

## Common Issues

### Missing Annotations

If endpoints are missing from generated docs:
- Check handler functions have `@Router` annotation
- Verify `@Summary` and `@Description` are present
- Ensure request/response types are documented

### Type Resolution

If types aren't resolving:
- Add `--parseDependency` flag
- Check import paths are correct
- Verify struct tags are present

### Path Conflicts

If routes conflict:
- Check for duplicate `@Router` paths
- Verify HTTP methods are different for same path

## Session Integration

When called from implementation phase:

1. Check session `config.enableSwagger`
2. Run regeneration if enabled
3. Update session with result:

```json
{
  "phases": {
    "4_implementation": {
      "output": {
        "swaggerRegenerated": true,
        "swaggerFile": "docs/swagger.json"
      }
    }
  }
}
```

## Standalone Usage

When invoked directly:
1. Detect swagger tool
2. Run regeneration
3. Validate output
4. Report results
