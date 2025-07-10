# Git Worktree Setup Toolkit

**Replicate professional Git worktree setups instantly for any project**

This toolkit provides a complete, battle-tested Git worktree development environment with automated setup, intelligent branch management, and cross-platform compatibility.

## 🚀 Quick Start

```bash
# 1. Clone this toolkit
git clone https://github.com/your-username/worktree-setup-toolkit.git
cd worktree-setup-toolkit

# 2. Setup any project with worktrees  
./scripts/setup-project.sh https://github.com/some-org/target-repo.git my-project

# 3. Start working immediately!
cd ../my-project
./create-feature.sh feature/awesome-feature --issue 42
```

**⚡ Get started in under 30 seconds!** See [QUICK_START.md](QUICK_START.md) for the fastest path to productivity.

## 📋 What You Get

- **🏗️ Automated Worktree Setup**: Convert any repository to a professional worktree-based workflow
- **🔧 Smart Scripts**: Feature creation, building, and context switching made simple
- **📚 Comprehensive Documentation**: Battle-tested workflows and troubleshooting guides
- **🛡️ Intelligent .gitignore**: Automatically excludes worktrees while preserving toolkit files
- **🌍 Cross-Platform**: Works on Linux, macOS, and Windows (Git Bash/WSL)
- **🎯 Issue Integration**: Automatic linking to GitHub issues and project management
- **🤖 AI Documentation**: Templates and patterns for AI-enhanced development workflows

## 🎯 Features

### **Professional Worktree Structure**
```
your-project/
├── ProjectName.git/          # Bare repository (don't touch)
├── main/                     # Main branch worktree  
├── feature/
│   ├── user-authentication/  # Feature worktrees
│   └── ui-improvements/
├── hotfix/
│   └── critical-bug-fix/     # Hotfix worktrees
├── create-feature.sh         # Create new features
├── build-branch.sh           # Build specific branches
└── switch-context.sh         # Quick context switching
```

### **Automated Scripts**

- **`create-feature.sh`**: Create feature branches with automatic issue linking
- **`build-branch.sh`**: Build specific worktrees (Flutter, Node.js, etc.)
- **`switch-context.sh`**: Quick context switching between worktrees
- **`sync-worktrees.sh`**: Sync all worktrees with remote repository
- **`setup-hooks.sh`**: Install consistent Git hooks across all worktrees

### **Project Templates**

Pre-configured templates for common project types:

| Project Type | Status | Features |
|--------------|--------|----------|
| Flutter Desktop | ✅ Ready | Cross-platform builds, hot reload |
| Node.js/React | ✅ Ready | npm scripts, environment configs |
| Python | ✅ Ready | Virtual environments, testing |
| AI-Enhanced | ✅ Ready | Documentation patterns, context management |

## 📖 Documentation

### Quick References
- **[QUICK_START.md](QUICK_START.md)**: Get running in 30 seconds
- **[Worktree Workflow](docs/worktree-workflow.md)**: Daily development workflow  
- **[Examples](examples/)**: Real project setups (Flutter, Node.js, Python, AI-docs)

### Comprehensive Guides
- **[Setup Guide](docs/setup-guide.md)**: Complete installation and configuration
- **[Git Hooks Implementation](docs/git-hooks-implementation.md)**: Advanced hook management
- **[Troubleshooting](docs/troubleshooting.md)**: Common issues and solutions

## 🛠️ Installation Methods

### Method 1: Automated Setup (Recommended)
```bash
# For new projects
./scripts/setup-project.sh <repo-url> <project-name> [options]

# Example: Setup a Flutter project  
./scripts/setup-project.sh https://github.com/flutter/samples.git my-flutter-dev \
  --config templates/flutter-project.json

# Example: Setup with AI documentation patterns
./scripts/setup-project.sh https://github.com/org/repo.git smart-project \
  --config templates/ai-docs-project.json
```

### Method 2: Manual Setup (Advanced Users)
```bash
# 1. Clone target repository as bare
git clone --bare <repo-url> ProjectName.git

# 2. Create main worktree
git -C ProjectName.git worktree add main main

# 3. Copy automation scripts
cp scripts/*.sh ./

# 4. Setup Git hooks (optional)
./setup-hooks.sh
```

### Method 3: Existing Project Migration
```bash
# Migrate existing repository to worktree setup
./scripts/migrate-existing.sh /path/to/existing/repo
```

## ⚙️ Configuration Options

### Basic Configuration
```bash
# Setup with custom base branch
./scripts/setup-project.sh <repo-url> <project> --base-branch develop

# Skip Git hooks installation
./scripts/setup-project.sh <repo-url> <project> --skip-hooks

# Dry run (preview only)
./scripts/setup-project.sh <repo-url> <project> --dry-run
```

### Advanced Configuration
```json
{
  "project_name": "MyProject",
  "base_branch": "main", 
  "enable_hooks": true,
  "build_targets": ["linux", "windows"],
  "ignore_patterns": ["custom-dir/"],
  "issue_tracking": {
    "enabled": true,
    "base_url": "https://github.com/org/repo/issues/"
  }
}
```

## 📁 Project Structure

```
worktree-setup-toolkit/
├── scripts/                 # Automation scripts
│   ├── setup-project.sh     # Main setup script ⭐
│   ├── create-feature.sh    # Feature branch creation
│   ├── build-branch.sh      # Build automation
│   ├── sync-worktrees.sh    # Sync utilities
│   ├── validate-toolkit.sh  # Toolkit validation
│   └── utils/               # Helper utilities
├── docs/                    # Comprehensive documentation
│   ├── worktree-workflow.md # Daily workflow guide
│   └── troubleshooting.md   # Problem solving
├── templates/               # Project templates
│   ├── flutter-project.json # Flutter desktop apps
│   ├── nodejs-project.json  # Node.js/React apps  
│   ├── python-project.json  # Python applications
│   └── ai-docs-project.json # AI-enhanced documentation
├── examples/                # Example setups
│   ├── flutter-project/     # Flutter demo setup
│   ├── node-project/        # Node.js demo setup
│   ├── python-project/      # Python demo setup
│   └── ai-docs-templates/   # AI documentation patterns
├── QUICK_START.md           # 30-second setup guide
└── README.md                # This file
```

## 🔧 Daily Workflow

### Creating Features
```bash
# Create feature with issue linking
./create-feature.sh feature/user-auth --issue 123

# Create from specific base branch
./create-feature.sh feature/experimental develop --issue 124
```

### Building Projects  
```bash
# Build specific worktree
./build-branch.sh feature/user-auth -- linux --release

# Clean build
./build-branch.sh main --clean -- linux --debug
```

### Context Switching
```bash
# List available worktrees
./switch-context.sh

# Switch to specific worktree
./switch-context.sh feature/user-auth
```

### Keeping in Sync
```bash
# Sync all worktrees with remote
./sync-worktrees.sh

# Preview sync operations
./sync-worktrees.sh --dry-run
```

## 🧪 Validation & Testing

```bash
# Validate toolkit integrity
./scripts/validate-toolkit.sh

# Auto-fix common issues
./scripts/validate-toolkit.sh --fix

# Validate a project setup
cd ../your-project && ./scripts/utils/validate-setup.sh
```

## 🌟 Special Features

### AI Documentation Integration
Includes templates and patterns for AI-enhanced development:
- **Architecture Decision Records (ADRs)**: Structured decision documentation
- **Context Management**: AI-friendly project documentation
- **Performance Analysis**: Detailed optimization planning templates
- **Git Hooks Implementation**: Complex technical implementation guides

### Cross-Platform Compatibility
- **Linux**: Native bash scripting
- **macOS**: Full compatibility with macOS Git
- **Windows**: Git Bash and WSL support
- **Auto-detection**: Platform-specific command adaptation

### Issue Tracking Integration
- **GitHub Issues**: Automatic linking to issues
- **Branch Naming**: Consistent issue-linked branch names
- **BRANCH_INFO.md**: Automatic issue documentation
- **Commit Templates**: Issue-aware commit message templates

## 🛟 Support & Troubleshooting

### Self-Diagnosis
- **Validation**: `./scripts/validate-toolkit.sh` checks toolkit health
- **Setup Validation**: `./scripts/utils/validate-setup.sh` checks project setup
- **Troubleshooting**: `./scripts/utils/troubleshoot.sh` provides diagnostic info

### Common Solutions
- **Script permissions**: Run `chmod +x scripts/*.sh`
- **Git version**: Ensure Git 2.5+ is installed
- **Path issues**: Always run scripts from project root
- **Remote issues**: Check bare repository remote configuration

### Getting Help
- **Documentation**: See [docs/](docs/) for comprehensive guides
- **Examples**: Check [examples/](examples/) for working setups
- **Issues**: Report problems via GitHub issues
- **Quick Start**: Use [QUICK_START.md](QUICK_START.md) for fastest resolution

## 🤝 Contributing

This toolkit is based on battle-tested patterns from real-world projects. Contributions welcome:

1. **Test with your projects**: Try the toolkit with different repository types
2. **Submit templates**: Add templates for new project types  
3. **Improve documentation**: Help make setup even easier
4. **Report issues**: Share any problems or edge cases discovered

## 📄 License

MIT License - Feel free to use this toolkit in your projects and organizations.

---

**🚀 Ready to supercharge your development workflow? Start with [QUICK_START.md](QUICK_START.md)!** 