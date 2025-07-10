# Python Project Example

This directory demonstrates how to use the worktree-setup-toolkit with Python applications.

## Setup

```bash
# From the toolkit root
./scripts/setup-project.sh https://github.com/django/django.git my-django-app \
  --config templates/python-project.json
```

## Features

- **Virtual environment isolation**: Independent Python environments per worktree
- **Package management**: pip/pipenv/poetry support
- **Testing frameworks**: pytest, unittest integration
- **Development tools**: linting, formatting, type checking

## Workflow

```bash
cd ../my-django-app
./create-feature.sh feature/api-endpoints --issue 456
cd feature/api-endpoints

# Normal Python development
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python manage.py runserver
```

## Template Configuration

The `python-project.json` template includes:
- Virtual environment setup
- Testing configuration
- Linting and formatting tools
- Package dependency management

See `templates/python-project.json` for full configuration. 