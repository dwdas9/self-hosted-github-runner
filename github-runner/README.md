# GitHub Actions Self-Hosted Runner Docker Container

This Docker container runs a GitHub Actions self-hosted runner on Ubuntu Linux.

## Prerequisites

- Docker installed on your Windows machine
- GitHub Personal Access Token with appropriate permissions
- GitHub repository or organization to register the runner with

## Setup Instructions

### 1. Create GitHub Personal Access Token

1. Go to GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Click "Generate new token (classic)"
3. For **repository runners**: Select `repo` scope
4. For **organization runners**: Select `admin:org` scope
5. Copy the generated token

### 2. Configure Environment

1. Copy the environment template:
   ```cmd
   copy .env.example .env
   ```

2. Edit `.env` file with your values:
   ```
   GITHUB_TOKEN=ghp_your_token_here
   GITHUB_REPOSITORY=your-username/your-repository
   RUNNER_NAME=my-docker-runner
   RUNNER_LABELS=docker,ubuntu,self-hosted
   ```

### 3. Build and Run

#### Option A: Using Docker Compose (Recommended)
```cmd
docker-compose up -d
```

#### Option B: Using Docker directly
```cmd
:: Build the image
docker build -t github-runner .

:: Run the container
docker run -d ^
  --name github-actions-runner ^
  -e GITHUB_TOKEN=your_token_here ^
  -e GITHUB_REPOSITORY=your-username/your-repository ^
  -e RUNNER_NAME=my-docker-runner ^
  -e RUNNER_LABELS=docker,ubuntu,self-hosted ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  --restart unless-stopped ^
  github-runner
```

### 4. Verify Runner Registration

1. Go to your GitHub repository/organization
2. Navigate to Settings > Actions > Runners
3. You should see your runner listed as "Idle"

## Configuration Options

### Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `GITHUB_TOKEN` | Yes | GitHub Personal Access Token | `ghp_xxxxxxxxxxxx` |
| `GITHUB_REPOSITORY` | Yes* | Repository for repo-level runner | `owner/repo-name` |
| `GITHUB_OWNER` | Yes* | Organization for org-level runner | `my-organization` |
| `RUNNER_NAME` | No | Custom runner name | `my-docker-runner` |
| `RUNNER_LABELS` | No | Comma-separated labels | `docker,ubuntu,custom` |

*Either `GITHUB_REPOSITORY` or `GITHUB_OWNER` is required, not both.

### Docker Volume Mounts

- `/var/run/docker.sock:/var/run/docker.sock` - Enables Docker-in-Docker for workflows that build containers

## Usage in GitHub Actions Workflows

Use your self-hosted runner in workflows:

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: [self-hosted, ubuntu, docker]  # Use your runner labels
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: echo "Running on self-hosted runner!"
```

## Management Commands

### View logs
```cmd
docker logs github-actions-runner -f
```

### Stop runner
```cmd
docker-compose down
```

### Restart runner
```cmd
docker-compose restart
```

### Update runner
```cmd
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Security Considerations

1. **Token Security**: Store your GitHub token securely, consider using Docker secrets in production
2. **Network Security**: The runner has access to your Docker daemon via the mounted socket
3. **Resource Limits**: Consider setting CPU/memory limits in production environments
4. **Regular Updates**: Keep the runner image updated with latest security patches

## Troubleshooting

### Runner not appearing in GitHub
- Check that your GitHub token has the correct permissions
- Verify the repository/organization name is correct
- Check container logs: `docker logs github-actions-runner`

### Docker commands fail in workflows
- Ensure Docker socket is mounted: `-v /var/run/docker.sock:/var/run/docker.sock`
- Check that the runner user has access to Docker

### Container exits immediately
- Check environment variables are set correctly
- Review container logs for error messages
- Ensure GitHub token is valid and has required permissions

## Advanced Configuration

### Resource Limits
Add resource limits to `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 4G
    reservations:
      cpus: '1.0'
      memory: 2G
```

### Multiple Runners
To run multiple runners, modify the service name and container name in `docker-compose.yml`:

```yaml
services:
  github-runner-1:
    # ... configuration
  github-runner-2:
    # ... configuration
```
