# Convention Discovery Checklist

Use this checklist when exploring a codebase to identify patterns and conventions.

## Project Documentation

Check for these files first:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project guidelines, architecture, conventions |
| `AGENTS.md` | Custom agent definitions |
| `README.md` | Project overview, setup instructions |
| `CONTRIBUTING.md` | Contribution guidelines |
| `.editorconfig` | Code style settings |
| `tsconfig.json` / `pyproject.toml` | Language configuration |

## Architecture Style

Identify the architectural pattern:

- **Layered**: presentation → business → data
- **Clean Architecture**: entities → use cases → adapters → frameworks
- **MVC**: model → view → controller
- **Microservices**: service boundaries, API contracts
- **Monolith**: single deployable unit
- **Hexagonal**: ports and adapters

## Naming Conventions

### Files and Directories

| Convention | Example |
|------------|---------|
| kebab-case | `user-service.ts` |
| snake_case | `user_service.py` |
| camelCase | `userService.js` |
| PascalCase | `UserService.cs` |

### Functions and Methods

| Convention | Example |
|------------|---------|
| camelCase | `getUserById()` |
| snake_case | `get_user_by_id()` |
| PascalCase | `GetUserById()` |

### Classes and Types

| Convention | Example |
|------------|---------|
| PascalCase | `UserRepository` |
| Interface prefix | `IUserRepository` |
| Type suffix | `UserType`, `UserDTO` |

## Testing Patterns

### Framework Detection

```bash
# Check package.json for JS/TS
grep -E "jest|mocha|vitest|cypress" package.json

# Check for Python
ls pytest.ini pyproject.toml | grep -E "pytest|unittest"

# Check for Go
ls *_test.go
```

### Test Structure

- Unit tests location: `__tests__/`, `tests/`, `*_test.*`
- Integration tests location
- E2E tests location
- Mock/fixture patterns
- Test naming conventions

## Error Handling

- Custom error classes
- Error response format
- Logging patterns
- Retry mechanisms

## API Patterns

For REST APIs:
- Base path (`/api/v1/`, `/v2/`)
- Authentication method
- Request/response format
- Pagination style
- Error response format

## Database Patterns

- ORM/query builder used
- Migration approach
- Naming (tables, columns)
- Relationship patterns

## Dependency Injection

- DI container used
- Registration patterns
- Scope management

## Configuration

- Environment variables
- Config files
- Secrets management

## Logging

- Logger library
- Log levels used
- Structured logging format
- Correlation IDs

## Similar Feature Detection

To find features similar to the one being built:

```bash
# Search for similar handlers/controllers
grep -r "Handler\|Controller\|Service" --include="*.ts" --include="*.go"

# Search for similar API endpoints
grep -r "router\.\|app\.\(get\|post\|put\|delete\)" --include="*.ts" --include="*.js"

# Search for similar models
grep -r "interface\|type\|struct\|class" --include="*.ts" --include="*.go"
```

## Output Format

Document findings in this structure:

```markdown
## Codebase Conventions

### Architecture
- Style: [identified style]
- Layers: [list layers]

### Naming
- Files: [convention]
- Functions: [convention]
- Classes: [convention]

### Testing
- Framework: [name]
- Location: [path pattern]
- Coverage: [requirement if any]

### Error Handling
- Pattern: [description]
- Custom errors: [yes/no, location]

### Similar Features
1. [Feature name] in [path]
   - Reusable: [what can be reused]
   - Pattern: [what pattern to follow]
```
