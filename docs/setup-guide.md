# Complete Setup Guide

This guide provides detailed instructions for installing, configuring, and getting started with the Git Worktree Setup Toolkit.

## 📋 Prerequisites

### System Requirements

- **Operating System**: Linux, macOS, Windows (Git Bash/WSL)
- **Git Version**: 2.5 or higher (worktree support)
- **Disk Space**: ~50MB for toolkit, additional space for projects
- **Network**: Internet connection for cloning repositories

### Required Software

```bash
# Check Git version
git --version
# Should show 2.5.0 or higher

# Check available disk space
df -h .
```

### Development Tools (Project-Specific)

Depending on your project type, you may need:

**Flutter Projects**:
```bash
# Install Flutter
snap install flutter --classic
flutter doctor
```

**Node.js Projects**:
```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Python Projects**:
```bash
# Install Python 3
sudo apt install python3 python3-pip python3-venv
```

## 🚀 Installation

### Method 1: Clone from Repository (Recommended)

```bash
# 1. Clone the toolkit
git clone https://github.com/your-username/worktree-setup-toolkit.git
cd worktree-setup-toolkit

# 2. Verify installation
./scripts/validate-toolkit.sh

# 3. Make scripts executable (if needed)
chmod +x scripts/*.sh
```

### Method 2: Download and Extract

```bash
# Download latest release
wget https://github.com/your-username/worktree-setup-toolkit/archive/main.zip
unzip main.zip
mv worktree-setup-toolkit-main worktree-setup-toolkit
cd worktree-setup-toolkit

# Make scripts executable
chmod +x scripts/*.sh
```

## ⚙️ Configuration

### Basic Configuration

The toolkit works out-of-the-box with default settings. For customization:

```bash
# Copy and edit configuration template (optional)
cp templates/flutter-project.json my-project-config.json
nano my-project-config.json
```

### Git Configuration

Ensure Git is properly configured:

```bash
# Set global Git identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Configure default branch (recommended)
git config --global init.defaultBranch main

# Enable helpful Git settings
git config --global push.default simple
git config --global pull.rebase false
```

### SSH Keys (Recommended)

For private repositories, set up SSH keys:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub
# Add this to your GitHub/GitLab account
```

## 🎯 First Project Setup

### Quick Setup (30 seconds)

```bash
# Setup your first project
./scripts/setup-project.sh https://github.com/flutter/samples.git my-first-project

# Start working
cd ../my-first-project
./create-feature.sh feature/my-first-feature
```

### Detailed Setup Process

1. **Choose Repository**
   ```bash
   # Use any public repository for testing
   REPO_URL="https://github.com/flutter/gallery.git"
   PROJECT_NAME="flutter-gallery-dev"
   ```

2. **Run Setup Script**
   ```bash
   ./scripts/setup-project.sh "$REPO_URL" "$PROJECT_NAME" --config templates/flutter-project.json
   ```

3. **Verify Setup**
   ```bash
   cd "../$PROJECT_NAME"
   
   # Check project structure
   ls -la
   # Should show: ProjectName.git/, main/, scripts/, *.sh files
   
   # Validate setup
   ./scripts/utils/validate-setup.sh
   ```

4. **Test Workflow**
   ```bash
   # Create test feature
   ./create-feature.sh feature/test-setup
   
   # Switch to feature
   cd feature/test-setup
   
   # Make test change
   echo "# Test" > TEST.md
   git add TEST.md
   git commit -m "test: verify worktree setup"
   
   # Switch back to main
   cd ../../main
   ```

## 🔧 Advanced Configuration

### Custom Project Templates

Create a custom template for your organization:

```json
{
  "project_type": "custom",
  "name": "My Organization Template",
  "description": "Standard setup for our projects",
  
  "worktree_structure": {
    "main": { "description": "Production branch", "protected": true },
    "develop": { "description": "Development branch", "protected": false },
    "feature/": { "pattern": "feature/*", "auto_create": true },
    "hotfix/": { "pattern": "hotfix/*", "auto_create": true }
  },
  
  "build_targets": {
    "production": {
      "command": "npm run build:prod",
      "output_path": "dist/",
      "requirements": ["node", "npm"]
    }
  },
  
  "git_hooks": {
    "pre-commit": {
      "enabled": true,
      "commands": ["npm run lint", "npm run test"]
    }
  },
  
  "ignore_patterns": [
    "node_modules/",
    "dist/",
    ".env.local"
  ]
}
```

### Environment-Specific Settings

```bash
# Development environment
export WORKTREE_DEFAULT_BRANCH="develop"
export WORKTREE_AUTO_SYNC="true"
export WORKTREE_BUILD_PARALLEL="true"

# Add to ~/.bashrc or ~/.zshrc for persistence
echo 'export WORKTREE_DEFAULT_BRANCH="develop"' >> ~/.bashrc
```

### Git Hooks Configuration

```bash
# Enable all hooks for rigorous development
./scripts/utils/setup-hooks.sh --enable-all

# Or selective hooks
./scripts/utils/setup-hooks.sh --pre-commit --commit-msg

# Disable hooks for rapid prototyping
./scripts/utils/setup-hooks.sh --disable-all
```

## 🏢 Organization Setup

### Team Standards

Create standardized setup for your team:

1. **Fork the toolkit** to your organization
2. **Customize templates** for your tech stack
3. **Add organization-specific scripts**
4. **Document team conventions**

### Automated Deployment

```bash
# Add deployment script to your toolkit
cat > scripts/deploy-production.sh << 'EOF'
#!/bin/bash
# Organization-specific deployment script
./build-branch.sh main --clean -- production
rsync -avz build/ production-server:/var/www/app/
EOF

chmod +x scripts/deploy-production.sh
```

### CI/CD Integration

Example GitHub Actions workflow:

```yaml
# .github/workflows/worktree-ci.yml
name: Worktree CI
on:
  push:
    branches: [ main, develop, 'feature/**' ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup worktree environment
      run: |
        git clone https://github.com/your-org/worktree-setup-toolkit.git toolkit
        ./toolkit/scripts/setup-project.sh . ci-project
    - name: Run tests
      run: |
        cd ci-project
        ./build-branch.sh main -- test
```

## 🎓 Learning Path

### Beginner (Week 1)
1. Complete basic setup
2. Practice creating features
3. Learn context switching
4. Understand project structure

### Intermediate (Week 2-3)
1. Customize project templates
2. Set up Git hooks
3. Integrate with your IDE
4. Practice parallel development

### Advanced (Week 4+)
1. Create organization templates
2. Automate deployment workflows
3. Integrate with CI/CD
4. Contribute improvements

## 🛠️ IDE Integration

### VS Code

```json
// .vscode/settings.json
{
  "git.autoRepositoryDetection": "subFolders",
  "git.enableSmartCommit": true,
  "terminal.integrated.cwd": "${workspaceFolder}"
}

// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Create Feature",
      "type": "shell",
      "command": "./create-feature.sh",
      "args": ["feature/${input:featureName}"],
      "group": "build"
    }
  ],
  "inputs": [
    {
      "id": "featureName",
      "description": "Feature name",
      "default": "new-feature",
      "type": "promptString"
    }
  ]
}
```

### JetBrains IDEs

```xml
<!-- .idea/externalDependencies.xml -->
<component name="ExternalDependencies">
  <dependency groupId="git.worktree" artifactId="toolkit" version="1.0"/>
</component>
```

## 📊 Performance Optimization

### Large Repositories

```bash
# Enable partial clone for large repos
git config --global clone.defaultRemoteName origin
git config --global clone.filterSpec blob:none

# Use shallow clones for CI
./scripts/setup-project.sh <repo-url> <project> --shallow
```

### Network Optimization

```bash
# Enable Git protocol version 2
git config --global protocol.version 2

# Configure compression
git config --global core.compression 9
git config --global core.looseCompression 1
```

## 🔍 Validation and Testing

### Complete Validation

```bash
# Full toolkit validation
./scripts/validate-toolkit.sh --verbose

# Test with sample repository
./scripts/setup-project.sh https://github.com/octocat/Hello-World.git test --dry-run

# Performance benchmark
time ./scripts/setup-project.sh <large-repo-url> perf-test
```

### Common Issues

See [troubleshooting.md](troubleshooting.md) for detailed issue resolution.

## 📚 Next Steps

1. **Read the [Quick Start Guide](../QUICK_START.md)** for immediate productivity
2. **Study the [Workflow Guide](worktree-workflow.md)** for daily development patterns
3. **Explore the [Examples](../examples/)** for real-world setups
4. **Customize [Templates](../templates/)** for your specific needs

## 🤝 Support

- **Documentation**: See [README.md](../README.md) for complete reference
- **Troubleshooting**: Check [troubleshooting.md](troubleshooting.md) for solutions
- **Community**: Join discussions in GitHub Issues
- **Updates**: Watch the repository for new features

---

**🎉 Congratulations!** You're now ready to leverage the power of Git worktrees for professional development workflows. 