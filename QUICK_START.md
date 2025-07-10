# 🚀 Quick Start Guide

Get a professional Git worktree development environment up and running in **under 2 minutes**.

## Prerequisites

- Git 2.5+ installed
- Basic command line familiarity
- Target repository URL (GitHub, GitLab, etc.)

## 🏃‍♂️ 30-Second Setup

```bash
# 1. Clone this toolkit
git clone https://github.com/your-username/worktree-setup-toolkit.git
cd worktree-setup-toolkit

# 2. Setup your project (replace with your repo)
./scripts/setup-project.sh https://github.com/flutter/samples.git my-flutter-project

# 3. Start working immediately!
cd ../my-flutter-project
./create-feature.sh feature/awesome-new-feature
```

**That's it!** You now have a professional worktree-based development environment.

## 🎯 Common Use Cases

### Use Case 1: Flutter Desktop App
```bash
./scripts/setup-project.sh https://github.com/your-org/flutter-app.git my-app \
  --config templates/flutter-project.json

cd ../my-app
./create-feature.sh feature/dark-mode --issue 42
cd feature/dark-mode
# Work normally - all Flutter tooling works as expected
```

### Use Case 2: Node.js/React Project
```bash
./scripts/setup-project.sh https://github.com/your-org/react-app.git my-react-app \
  --config templates/nodejs-project.json

cd ../my-react-app
./create-feature.sh feature/user-dashboard --issue 123
cd feature/user-dashboard
npm install && npm start
```

### Use Case 3: AI-Enhanced Documentation
```bash
./scripts/setup-project.sh https://github.com/your-org/any-project.git smart-project \
  --config templates/ai-docs-project.json

cd ../smart-project
# Includes ai_docs/ structure with architecture decision records,
# AI context management, and automated documentation generation
```

## 🔧 What You Get

After setup, your project structure looks like:

```
your-project/
├── ProjectName.git/          # Bare repository (don't touch)
├── main/                     # Main branch worktree
├── feature/                  # Feature branch worktrees
├── hotfix/                   # Hotfix branch worktrees
├── create-feature.sh         # Create new features with issue linking
├── build-branch.sh           # Build specific branches/worktrees
├── switch-context.sh         # Quick context switching
└── sync-worktrees.sh         # Sync all worktrees with remote
```

## 🎪 Daily Workflow

### Create a new feature
```bash
./create-feature.sh feature/user-authentication --issue 456
cd feature/user-authentication
# Work normally - full Git functionality
git add . && git commit -m "feat: add login form"
git push origin feature/user-authentication
```

### Work on multiple features simultaneously
```bash
# Terminal 1: Work on feature A
cd feature/user-auth
npm run dev

# Terminal 2: Work on feature B  
cd feature/payments
npm run test

# Terminal 3: Quick fix on main
cd main
git pull && git commit -m "fix: typo in README"
```

### Build specific branches
```bash
# Build just one worktree
./build-branch.sh feature/user-auth -- --release

# Build main branch
./build-branch.sh main -- --debug
```

### Keep everything in sync
```bash
./sync-worktrees.sh
```

## 🚨 Common Gotchas (Avoid These!)

❌ **DON'T** modify files in `ProjectName.git/` - it's a bare repository  
❌ **DON'T** run `git clone` inside worktrees - use the provided scripts  
❌ **DON'T** manually manage worktrees - use `create-feature.sh`  

✅ **DO** use the provided scripts for all worktree operations  
✅ **DO** work normally with Git inside each worktree  
✅ **DO** commit, push, pull as usual - everything works normally  

## 🛟 Need Help?

- **Setup issues**: Run `./scripts/{utils}/validate-setup.sh --fix`
- **Troubleshooting**: Run `./scripts/{utils}/troubleshoot.sh` 
- **Full documentation**: See [README.md](README.md) and [docs/](docs/)
- **Issues**: Check [troubleshooting guide](docs/troubleshooting.md)

## 🎉 Success Indicators

You'll know it's working when:
- ✅ `cd feature/my-feature` switches context instantly
- ✅ You can work on multiple branches simultaneously  
- ✅ All your tools (VS Code, etc.) work normally in each worktree
- ✅ Git operations (commit, push, pull) work normally
- ✅ Builds are isolated per worktree

**🚀 Happy coding with worktrees!** 