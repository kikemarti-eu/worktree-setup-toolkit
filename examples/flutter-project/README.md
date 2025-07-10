# Flutter Project Example

This directory demonstrates how to use the worktree-setup-toolkit with Flutter desktop applications.

## Setup

```bash
# From the toolkit root
./scripts/setup-project.sh https://github.com/flutter/samples.git my-flutter-app \
  --config templates/flutter-project.json
```

## Features

- **Cross-platform builds**: Linux, Windows, macOS support
- **Hot reload**: Full Flutter development experience
- **Isolated environments**: Each worktree has independent build outputs
- **Automated workflows**: Build scripts handle platform detection

## Workflow

```bash
cd ../my-flutter-app
./create-feature.sh feature/dark-mode --issue 42
cd feature/dark-mode

# Normal Flutter development
flutter pub get
flutter run -d linux
```

## Template Configuration

The `flutter-project.json` template includes:
- Build targets for all platforms
- Flutter-specific ignore patterns
- QA checks and validation
- Hot reload configuration

See `templates/flutter-project.json` for full configuration. 