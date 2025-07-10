# Node.js Project Example

This directory demonstrates how to use the worktree-setup-toolkit with Node.js/React applications.

## Setup

```bash
# From the toolkit root
./scripts/setup-project.sh https://github.com/facebook/create-react-app.git my-react-app \
  --config templates/nodejs-project.json
```

## Features

- **npm/yarn support**: Automatic package management
- **Environment isolation**: Independent node_modules per worktree
- **Development servers**: Isolated dev servers per feature
- **Build optimization**: Parallel builds across worktrees

## Workflow

```bash
cd ../my-react-app
./create-feature.sh feature/user-dashboard --issue 123
cd feature/user-dashboard

# Normal Node.js development
npm install
npm start
npm test
```

## Template Configuration

The `nodejs-project.json` template includes:
- npm script integration
- Environment variable management
- Testing configuration
- Build and deployment settings

See `templates/nodejs-project.json` for full configuration. 