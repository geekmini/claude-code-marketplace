---
name: postman
description: This skill should be used when the user asks to "sync postman", "update postman collection", "add endpoints to postman", "export to postman", or mentions "postman integration". Syncs API endpoints with Postman collection.
---

# Postman Integration

Sync new API endpoints with a Postman collection. Requires Postman MCP integration or manual export.

## Overview

This skill:
- Adds new endpoints to Postman collection
- Updates existing endpoint documentation
- Organizes endpoints into folders
- Sets up environment variables

## Prerequisites

For automated sync, one of:
- Postman MCP server configured
- Postman API key in environment

For manual sync:
- Export collection as JSON
- Import after modifications

## Process

### Step 1: Check for Postman Integration

Look for MCP tools:
```
# Check for postman MCP tools
mcp__postman__createCollection
mcp__postman__addRequest
```

Or check for API key:
```bash
echo $POSTMAN_API_KEY
```

### Step 2: Gather Endpoint Information

From the specification, extract:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/users` | POST | Create user |
| `/api/v1/users/:id` | GET | Get user |
| `/api/v1/users/:id` | PUT | Update user |
| `/api/v1/users/:id` | DELETE | Delete user |

### Step 3: Add to Collection

**With Postman MCP**:

```
Use mcp__postman__addRequest for each endpoint:
- name: [Endpoint name]
- method: [HTTP method]
- url: {{baseUrl}}/api/v1/users
- body: [Request body JSON]
- headers: [Required headers]
```

**Manual Export/Import**:

1. Export existing collection
2. Add new requests to JSON
3. Import updated collection

### Step 4: Organize Collection

Structure endpoints in folders:

```
Collection: [Project Name]
├── Auth
│   ├── Login
│   └── Logout
├── Users
│   ├── Create User
│   ├── Get User
│   ├── Update User
│   └── Delete User
└── [Feature Name]
    ├── [Endpoint 1]
    └── [Endpoint 2]
```

### Step 5: Set Up Environment Variables

Add/update environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `baseUrl` | API base URL | `http://localhost:3000` |
| `authToken` | JWT token | `{{login.token}}` |
| `userId` | Current user ID | `{{createUser.id}}` |

### Step 6: Report Results

```markdown
## Postman Collection Updated

**Collection**: [name]
**Endpoints Added**: [count]

### New Requests
- `POST /api/v1/users` → Users/Create User
- `GET /api/v1/users/:id` → Users/Get User

### Environment Variables
- `baseUrl` - API base URL
- `authToken` - Authentication token

### Test Scripts Added
- Response status validation
- Schema validation
- Token extraction
```

## Request Template

For each endpoint, create request with:

```json
{
  "name": "Create User",
  "request": {
    "method": "POST",
    "header": [
      {
        "key": "Content-Type",
        "value": "application/json"
      },
      {
        "key": "Authorization",
        "value": "Bearer {{authToken}}"
      }
    ],
    "body": {
      "mode": "raw",
      "raw": "{\n  \"name\": \"John Doe\",\n  \"email\": \"john@example.com\"\n}"
    },
    "url": {
      "raw": "{{baseUrl}}/api/v1/users",
      "host": ["{{baseUrl}}"],
      "path": ["api", "v1", "users"]
    }
  }
}
```

## Test Scripts

Add basic test scripts to each request:

```javascript
// Status code validation
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});

// Response time
pm.test("Response time is acceptable", function () {
    pm.expect(pm.response.responseTime).to.be.below(500);
});

// Schema validation
pm.test("Response has required fields", function () {
    const response = pm.response.json();
    pm.expect(response).to.have.property('id');
    pm.expect(response).to.have.property('name');
});

// Save variables for chaining
pm.test("Save user ID", function () {
    const response = pm.response.json();
    pm.collectionVariables.set("userId", response.id);
});
```

## Session Integration

When called from delivery phase:

1. Check session `config.enablePostman`
2. Add endpoints if enabled
3. Update session with result:

```json
{
  "phases": {
    "6_delivery": {
      "output": {
        "postmanAdded": true,
        "endpointsAdded": 4
      }
    }
  }
}
```

## Standalone Usage

When invoked directly:
1. Ask for spec file or endpoint list
2. Check for Postman integration
3. Add endpoints to collection
4. Report results

## Without MCP Integration

If no Postman MCP available:

1. Generate collection JSON manually
2. Provide import instructions:

```markdown
## Manual Import Required

I've generated the Postman collection JSON.

**To import**:
1. Open Postman
2. Click Import
3. Select the generated file or paste JSON
4. Choose collection destination
```
