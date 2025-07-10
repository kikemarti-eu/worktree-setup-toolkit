# AI Documentation Templates

This directory contains example `ai_docs/` structures and documentation patterns from real-world projects using Git worktrees.

## Overview

The `ai_docs/` folder is a powerful pattern for maintaining project documentation, architectural decisions, and development guidelines alongside your code. When combined with Git worktrees, it enables:

- **Version-controlled documentation** that evolves with your code
- **Branch-specific planning** and architectural documents  
- **Shared knowledge base** across all worktrees
- **AI-friendly context** for development tools like Cursor/Claude

## Templates Included

### 1. Git Hooks Implementation (`git-hooks/`)
Example documentation for implementing Git hooks in worktree environments:
- `original-git-hooks-worktree-implementation.md` - Complete technical implementation
- `target-git-hooks-implementation.md` - Target architecture and goals

### 2. Backend Architecture Planning (`backend-architecture-plan/`)
Example of using ai_docs for architecture planning:
- `dev-env-plus-phased_migration_plan.md` - Migration planning
- `target-improved_backend_architecture.md` - Target architecture design
- `migration_plan.md` - Step-by-step migration approach

### 3. Performance Optimization (`performance/`)
Documentation patterns for performance initiatives:
- `linux-paste-optimization.md` - Detailed performance analysis and optimization plans

## Usage Patterns

### Pattern 1: Branch-Specific Planning
```
ai_docs/
├── feature-planning/
│   ├── user-authentication-plan.md
│   ├── payment-integration-design.md
│   └── mobile-app-architecture.md
└── implemented/
    ├── auth-system-final.md
    └── payment-flow-final.md
```

### Pattern 2: Living Architecture Documentation
```
ai_docs/
├── architecture/
│   ├── backend-current.md
│   ├── frontend-current.md
│   └── database-design.md
├── decisions/
│   ├── 001-framework-choice.md
│   ├── 002-state-management.md
│   └── 003-deployment-strategy.md
└── guides/
    ├── development-workflow.md
    ├── testing-strategy.md
    └── deployment-guide.md
```

### Pattern 3: AI Context Management
```
ai_docs/
├── context/
│   ├── project-overview.md
│   ├── current-priorities.md
│   └── technical-constraints.md
├── prompts/
│   ├── code-review-prompt.md
│   ├── feature-development-prompt.md
│   └── debugging-prompt.md
└── lessons-learnt/
    ├── performance-optimizations.md
    ├── deployment-issues.md
    └── architecture-decisions.md
```

## Integration with Worktrees

### Automatic Context Generation
The toolkit's `setup-project.sh` can automatically:
1. Copy relevant ai_docs templates to new projects
2. Customize templates with project-specific information
3. Set up documentation structure that works across all worktrees

### Best Practices
- **Keep documentation close to code** - ai_docs/ in repository root
- **Version with branches** - let documentation evolve with features
- **Use consistent naming** - follow established patterns
- **Link to issues** - connect documentation to GitHub issues/PRs
- **Update regularly** - treat docs as living artifacts

## Getting Started

1. **Copy templates** to your project:
   ```bash
   # When setting up a new project with the toolkit
   ./scripts/setup-project.sh <repo-url> <project-name> --config templates/ai-docs-project.json
   ```

2. **Customize for your project**:
   - Update project names and URLs
   - Adapt architectural patterns to your stack
   - Modify planning templates for your workflow

3. **Establish workflows**:
   - Document major decisions in ai_docs/decisions/
   - Plan new features in ai_docs/planning/
   - Maintain current state in ai_docs/architecture/

## Examples in Action

See the included template files for real-world examples of:
- Complex Git hooks implementation planning
- Backend architecture migration strategies  
- Performance optimization documentation
- AI-assisted development workflows

These templates come from production projects and demonstrate proven patterns for maintaining high-quality technical documentation in a worktree-based development environment. 