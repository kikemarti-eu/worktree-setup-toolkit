# QuixoticWhisper Backend - Improved Architecture

Professional-grade Appwrite backend with enhanced deployment, configuration management, and database migrations.

## 🏗️ Architecture Overview

Enhanced backend system providing:
- **Centralized Configuration**: Shared variables with environment-specific overrides
- **Database Migrations**: Version-controlled schema changes with rollback capabilities
- **API Versioning**: Path-based versioning with backward compatibility
- **Automated Deployment**: Template-driven deployment with validation
- **Multi-Environment**: Isolated development, staging, and production environments

## 📁 Project Structure

```
backend/
├── environments/                 # Environment configurations
│   ├── dev/
│   │   ├── appwrite.json        # Development Appwrite config
│   │   └── variables.json       # Development variables
│   ├── staging/
│   │   ├── appwrite.json        # Staging Appwrite config
│   │   └── variables.json       # Staging variables
│   └── prod/
│       ├── appwrite.json        # Production Appwrite config
│       └── variables.json       # Production variables
├── functions/                   # Appwrite Cloud Functions
│   ├── api-gateway/             # API versioning and routing
│   ├── upload-audio/
│   ├── transcribe/
│   ├── cleanup-cron/
│   └── shared/
│       ├── utils.py             # Shared utilities
│       └── config.py            # Configuration management
├── migrations/                  # Database migration scripts
│   ├── 001_initial_schema.js
│   ├── 002_add_usage_logs.js
│   ├── 003_add_status_defaults.js
│   └── migration-runner.js
├── schemas/                     # Database schema definitions
│   ├── collections/
│   │   ├── transcription_jobs.json
│   │   ├── usage_logs.json
│   │   └── user_credits.json
│   └── databases/
│       ├── main-dev.json
│       ├── main-staging.json
│       └── main-prod.json
├── scripts/                     # Deployment and management
│   ├── deploy/
│   │   ├── deploy-environment.sh
│   │   ├── sync-variables.sh
│   │   └── validate-deployment.sh
│   ├── migrations/
│   │   ├── run-migrations.sh
│   │   └── rollback-migration.sh
│   └── utils/
│       ├── create-function.sh
│       └── create-collection.sh
├── templates/                   # Configuration templates
│   ├── function-template/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   └── README.md
│   └── shared-variables.json    # Common variable definitions
└── .env.example                # Environment template
```

## 🚀 Operations Guide

### Creating a New Function

```bash
# 1. Generate function structure with dependency definition
./scripts/utils/create-function.sh upload-audio-v2

# 2. Define dependencies and routes
# Edit functions/upload-audio-v2/dependencies.json

# 3. Validate consistency before implementation  
./scripts/validation/check-consistency.sh

# 4. Implement function logic
# Edit functions/upload-audio-v2/main.py

# 5. Pre-deployment validation
./scripts/validation/validate-function.sh upload-audio-v2

# 6. Add to environment configurations
# Edit environments/{env}/appwrite.json

# 7. Deploy to development with order validation
./scripts/deploy/deploy-environment.sh dev

# 8. Post-deployment consistency check
./scripts/validation/check-deployment-consistency.sh dev
```

**Function Template Structure**:
```
functions/new-function/
├── main.py              # Function entry point
├── requirements.txt     # Dependencies
├── dependencies.json    # Function dependencies and routes
├── function.json        # Function metadata
└── README.md           # Function documentation
```

### Creating Database Collections

```bash
# 1. Define schema
# Edit schemas/collections/new-collection.json

# 2. Create migration script with schema sync validation
./scripts/migrations/create-migration.sh add_new_collection

# 3. Validate schema-migration consistency
./scripts/validation/check-schema-migration-sync.sh

# 4. Test migration in development
./scripts/migrations/run-migrations.sh dev

# 5. Validate final schema matches expected
./scripts/validation/validate-schemas.sh dev

# 6. Deploy to other environments
./scripts/deploy/deploy-environment.sh staging
./scripts/deploy/deploy-environment.sh prod
```

**Collection Schema Format**:
```json
{
  "collectionId": "new_collection",
  "name": "New Collection", 
  "attributes": [
    {
      "key": "field_name",
      "type": "string",
      "required": true,
      "default": null
    }
  ],
  "indexes": [
    {
      "key": "idx_field_name", 
      "type": "key",
      "attributes": ["field_name"]
    }
  ],
  "migration_version": "003_add_new_collection"
}
```

### Function Deployment

```bash
# Deploy single function to specific environment
./scripts/deploy/deploy-function.sh dev upload-audio

# Deploy all functions to environment
./scripts/deploy/deploy-environment.sh dev

# Deploy with variable sync
./scripts/deploy/deploy-environment.sh dev --sync-variables

# Production deployment with confirmation
CONFIRM_PRODUCTION=yes ./scripts/deploy/deploy-environment.sh prod
```

### Collection Deployment

```bash
# Deploy schema changes
./scripts/deploy/deploy-schemas.sh dev

# Run pending migrations
./scripts/migrations/run-migrations.sh dev

# Combined deployment (schemas + migrations)
./scripts/deploy/deploy-environment.sh dev --include-schemas
```

### Database Migrations

```bash
# Create new migration
./scripts/migrations/create-migration.sh migration_name

# Run migrations
./scripts/migrations/run-migrations.sh {environment}

# Rollback last migration
./scripts/migrations/rollback-migration.sh {environment} 1

# Check migration status
./scripts/migrations/migration-status.sh {environment}
```

**Migration Script Structure**:
```javascript
// migrations/XXX_migration_name.js
export default {
  up: async (databases) => {
    // Forward migration logic
    await databases.updateDocument(...)
  },
  down: async (databases) => {
    // Rollback migration logic
    await databases.updateDocument(...)
  }
}
```

## 🌐 API Versioning System

### Architecture

```
Client Request → API Gateway → Versioned Function → Response
     ↓              ↓              ↓
  /v1/upload → api-gateway → upload-audio-v1
  /v2/upload → api-gateway → upload-audio-v2
```

### API Gateway Function

**Responsibilities**:
- Route requests based on version path (`/v1/`, `/v2/`)
- Handle version negotiation via headers
- Provide backward compatibility
- Centralize authentication and validation

**Routing Logic**:
```python
def route_request(context):
    version = extract_version(context.req.path)  # /v1/upload → v1
    operation = extract_operation(context.req.path)  # upload
    target_function = f"{operation}-{version}"
    
    return execute_function(target_function, context)
```

### Version Management

**Supported Versions**: v1 (current), v2 (development)
**Default Version**: v1
**Deprecation Policy**: 6 months notice, 12 months support

## 🔧 Configuration Management

### Variable Hierarchy

```
Global Variables (templates/shared-variables.json)
    ↓
Environment Overrides (environments/{env}/variables.json)
    ↓
Function-Specific Variables (in appwrite.json)
```

### Shared Variables Template

```json
{
  "shared": {
    "APPWRITE_FUNCTION_ENDPOINT": {
      "value": "https://cloud.appwrite.io/v1",
      "secret": false,
      "description": "Appwrite API endpoint"
    },
    "COST_PER_MINUTE": {
      "value": "0.006",
      "secret": false,
      "description": "OpenAI Whisper cost per minute"
    }
  },
  "environment_specific": {
    "dev": {
      "MAX_FILE_SIZE_MB": "10",
      "DEFAULT_USER_CREDITS": "50.0"
    },
    "prod": {
      "MAX_FILE_SIZE_MB": "25",
      "DEFAULT_USER_CREDITS": "10.0"
    }
  }
}
```

### Variable Synchronization

```bash
# Sync variables across all functions in environment
./scripts/deploy/sync-variables.sh dev

# Sync specific variable to all functions
./scripts/deploy/sync-variables.sh dev OPENAI_API_KEY

# Validate variable consistency
./scripts/deploy/validate-variables.sh dev
```

## 🗄️ Database Management

### Schema Evolution

**Schema Files**: Version-controlled JSON definitions in `schemas/`
**Migration Scripts**: Automated data transformations in `migrations/`
**Rollback Support**: Every migration includes rollback logic

### Migration Lifecycle

```
1. Create Migration Script
2. Test in Development
3. Apply to Staging
4. Validate Changes
5. Deploy to Production
6. Monitor & Rollback if needed
```

### Collections

#### transcription_jobs
```json
{
  "job_id": "string (UUID)",
  "user_id": "string", 
  "file_id": "string",
  "filename": "string",
  "status": "uploaded|processing|completed|failed",
  "estimated_cost": "number",
  "actual_cost": "number",
  "transcription_text": "string",
  "api_version": "string",
  "created_at": "datetime",
  "completed_at": "datetime"
}
```

#### usage_logs
```json
{
  "log_id": "string (UUID)",
  "user_id": "string",
  "job_id": "string",
  "operation": "string",
  "api_version": "string",
  "cost": "number",
  "credits_before": "number",
  "credits_after": "number",
  "timestamp": "datetime"
}
```

#### user_credits
```json
{
  "user_id": "string",
  "credits": "number",
  "total_transcriptions": "number",
  "total_minutes_transcribed": "number",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

## 🚀 Deployment Pipeline

### Environment Flow

```
Development → Staging → Production
     ↓           ↓         ↓
  Continuous   Manual    Controlled
  Integration  Testing   Release
```

### Deployment Process

```bash
# 1. Validate configuration
./scripts/deploy/validate-deployment.sh {environment}

# 2. Backup current state
./scripts/deploy/backup-environment.sh {environment}

# 3. Deploy changes
./scripts/deploy/deploy-environment.sh {environment}

# 4. Run migrations
./scripts/migrations/run-migrations.sh {environment}

# 5. Validate deployment
./scripts/deploy/validate-deployment.sh {environment}
```

### Safety Mechanisms

- **Pre-deployment validation**: Configuration and dependency checks
- **Automatic backups**: Before any production deployment
- **Rollback capabilities**: For functions and database changes
- **Health checks**: Post-deployment validation
- **Gradual rollout**: Environment-by-environment deployment

## 🔒 Security & Compliance

### Enhanced Security Features

- **Secret Management**: Centralized secret storage with rotation
- **API Key Rotation**: Automated key rotation for external services
- **Audit Logging**: Enhanced logging with API version tracking
- **Access Control**: Environment-based access restrictions

### Compliance Features

- **Data Retention**: Configurable retention policies
- **Audit Trails**: Complete operation logging
- **Backup Verification**: Automated backup validation
- **Change Tracking**: Version-controlled schema changes

## 📊 Monitoring & Observability

### Metrics Collection

**Function Metrics**:
- Execution time, success/failure rates
- API version usage distribution
- Resource utilization

**Business Metrics**:
- Credit consumption patterns
- User activity trends
- Cost optimization opportunities

### Alerting

**Critical Alerts**:
- Function failures > 5% in 5 minutes
- Database connection failures
- Credit system inconsistencies

**Warning Alerts**:
- API version deprecation usage
- Migration execution time > threshold
- Storage quota approaching limits

## 🔧 Development Workflow

### Function Development

```bash
# 1. Create function from template
./scripts/utils/create-function.sh new-feature

# 2. Validate consistency before implementation
./scripts/validation/check-consistency.sh

# 3. Implement and test locally
cd functions/new-feature && python main.py

# 4. Pre-deployment validation
./scripts/validation/validate-function.sh new-feature

# 5. Deploy to development
./scripts/deploy/deploy-function.sh dev new-feature

# 6. Post-deployment consistency check
./scripts/validation/check-deployment-consistency.sh dev

# 7. Promote to staging
./scripts/deploy/deploy-function.sh staging new-feature
```

### Database Changes

```bash
# 1. Create migration
./scripts/migrations/create-migration.sh add_new_field

# 2. Validate schema consistency
./scripts/validation/check-schema-migration-sync.sh

# 3. Test migration
./scripts/migrations/run-migrations.sh dev

# 4. Validate schema matches migration result
./scripts/validation/validate-schemas.sh dev

# 5. Deploy to staging
./scripts/migrations/run-migrations.sh staging
```

## 🔍 **Consistency Management**

### Automated Validation Checks

#### Pre-Development Checks
```bash
# Check all consistency before starting work
./scripts/validation/check-consistency.sh

# Validates:
# - Variable definition conflicts
# - Function naming vs routing consistency  
# - Schema vs migration synchronization
# - Environment configuration drift
# - Dependency graph validation
```

#### Pre-Deployment Checks
```bash
# Validate specific component before deployment
./scripts/validation/validate-function.sh function-name
./scripts/validation/validate-migration.sh migration-name
./scripts/validation/validate-environment.sh environment-name

# Comprehensive pre-deployment validation
./scripts/validation/pre-deployment-check.sh environment
```

#### Post-Deployment Checks
```bash
# Verify deployment consistency
./scripts/validation/check-deployment-consistency.sh environment

# Validates:
# - Deployed functions match configuration
# - Variables synchronized correctly
# - API routes functional
# - Database schema matches expected state
```

### Dependency Management

#### Function Dependencies
**Definition**: `functions/{function-name}/dependencies.json`
```json
{
  "depends_on": ["api-gateway", "shared-utils"],
  "depended_by": ["cleanup-cron"],
  "api_routes": ["/v1/upload", "/v2/upload"],
  "required_variables": ["OPENAI_API_KEY", "MAX_FILE_SIZE_MB"]
}
```

#### Deployment Order Validation
```bash
# Automatically determine correct deployment order
./scripts/validation/check-deployment-order.sh environment

# Example output:
# 1. shared-utils (no dependencies)
# 2. upload-audio-v1 (depends on shared-utils)  
# 3. api-gateway (depends on upload-audio-v1)
```

### Variable Hierarchy Validation

#### Variable Precedence Rules
```
Function-Specific (appwrite.json)
    ↓ overrides
Environment Variables (environments/{env}/variables.json)  
    ↓ overrides
Shared Variables (templates/shared-variables.json)
```

#### Validation Script
```bash
# Check variable conflicts and precedence
./scripts/validation/check-variable-hierarchy.sh environment function-name

# Example output:
# ✅ OPENAI_API_KEY: Correctly set as secret in environment
# ⚠️  MAX_FILE_SIZE_MB: Conflicts between shared (25) and environment (10)
# ❌ COST_PER_MINUTE: Missing in function but required by dependencies.json
```

### Schema-Migration Synchronization

#### Bidirectional Validation
```bash
# Ensure schema files match migration results
./scripts/validation/check-schema-migration-sync.sh

# Validates:
# - Schema files reflect all applied migrations
# - No pending migrations that would change schema
# - Migration down() functions properly reverse changes
```

#### Schema Generation from Migrations
```bash
# Auto-generate schema files from migration history
./scripts/utils/generate-schema-from-migrations.sh environment

# Updates schemas/collections/ based on applied migrations
# Detects drift between declared schema and actual database
```

### API Gateway Route Validation

#### Route-Function Mapping
**Definition**: `functions/api-gateway/routes.json`
```json
{
  "routes": {
    "/v1/upload": {
      "function": "upload-audio-v1",
      "method": "POST",
      "required_scopes": ["files.write"]
    },
    "/v2/upload": {
      "function": "upload-audio-v2", 
      "method": "POST",
      "required_scopes": ["files.write"]
    }
  }
}
```

#### Route Validation
```bash
# Validate all routes point to existing functions
./scripts/validation/check-api-routes.sh

# ✅ /v1/upload → upload-audio-v1 (exists)
# ❌ /v2/transcribe → transcribe-v2 (function not found)
```

## 🔄 Maintenance Operations

### Regular Maintenance

**Daily**:
- Monitor function execution logs
- Check credit system consistency
- Validate backup integrity

**Weekly**:
- Review API version usage
- Analyze performance metrics
- Update security patches

**Monthly**:
- Rotate API keys
- Review and optimize costs
- Update documentation

### Troubleshooting

**Common Issues**:
- Variable synchronization failures
- Migration rollback procedures
- API version compatibility problems
- Function deployment conflicts

**Debug Tools**:
- `validate-deployment.sh` - Comprehensive health check
- `migration-status.sh` - Database state verification
- `sync-variables.sh` - Variable consistency check

---

**Status**: 🚧 Enhanced Architecture Design  
**Implementation Status**: Pending  
**Target Completion**: Q1 2025  
**Breaking Changes**: API versioning system, variable management  
**Migration Required**: Yes - automated migration scripts included