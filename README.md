# ROS Noetic Docker Environment

A containerized ROS Noetic development environment.

## Quick Start

```bash
# Start container
docker compose up -d

# Enter container
docker compose exec ros bash
```

## Environment Variables

- `PROJECT_DIR`: Path to your project on host
- `PROJECT_BASENAME`: Project directory name in container (default "project")

## Features

- ROS Noetic on Ubuntu 20.04
- Non-root user with sudo access
- Development tools (git, vim, Python)
- Code quality tools (autopep8, flake8)

## Container Management

To stop the container when you're done:
```bash
docker compose down
```

If you've modified the Dockerfile and need to rebuild:
```bash
docker compose build --no-cache
```
