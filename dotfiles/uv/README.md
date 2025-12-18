# uv - Python Package & Version Manager

[uv](https://github.com/astral-sh/uv) is a fast Python package installer and resolver written in Rust.

## Shell Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `py` | `python3` | Run Python |
| `uvr` | `uv run` | Run script with auto-created venv |
| `uvs` | `uv sync` | Sync dependencies from pyproject.toml |
| `uvi` | `uv pip install` | Install packages |
| `uve` | `uv venv && source .venv/bin/activate` | Create and activate venv |

## Python Version Management

```bash
# List available versions
uv python list

# Install a specific version
uv python install 3.12
uv python install 3.11

# List installed versions
uv python list --only-installed

# Use specific version for a project
uv venv --python 3.11
```

## Project Workflows

### New Project
```bash
uv init myproject
cd myproject
uv add requests pandas numpy
uv run python main.py
```

### Existing Project (with pyproject.toml)
```bash
uv sync                  # Install all dependencies
uv run python app.py     # Run with project's venv
```

### Quick Script (no project setup)
```bash
uv run script.py         # Auto-creates venv, installs deps from inline metadata
```

### Add Dependencies
```bash
uv add requests          # Add to dependencies
uv add --dev pytest      # Add to dev dependencies
uv remove requests       # Remove a package
```

## Virtual Environments

```bash
# Create venv (uses .venv by default)
uv venv

# Create with specific Python version
uv venv --python 3.11

# Activate (standard method)
source .venv/bin/activate

# Or use uv run (no activation needed)
uv run python script.py
```

## Package Management

```bash
# Install packages (in active venv)
uv pip install requests
uv pip install -r requirements.txt

# Compile requirements (like pip-tools)
uv pip compile requirements.in -o requirements.txt

# Sync from lockfile
uv pip sync requirements.txt
```

## Tips

- **Speed**: uv is 10-100x faster than pip
- **No activation needed**: `uv run` handles venv automatically
- **Lockfiles**: `uv.lock` provides reproducible builds
- **Inline metadata**: Scripts can declare deps in comments (PEP 723)

## Links

- [uv Documentation](https://docs.astral.sh/uv/)
- [GitHub](https://github.com/astral-sh/uv)
