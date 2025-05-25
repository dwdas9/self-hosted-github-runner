# 🚀 GitHub Actions Self-Hosted Runner

A containerized GitHub Actions self-hosted runner that automatically registers with your GitHub repository and provides a secure, isolated environment for running CI/CD workflows.

## 🔧 Prerequisites

Before you begin, ensure you have:
- **Docker Desktop** installed and running on your machine
- **Git** installed for cloning this repository
- A **GitHub account** with access to the repository where you want to add the runner

## 📥 Step 1: Clone the Repository

Open your terminal/command prompt and run:

```bash
git clone https://github.com/YOUR-USERNAME/self-hosted-github-runner.git
cd self-hosted-github-runner
```

## 🔑 Step 2: Create GitHub Personal Access Token (PAT)

1. **Go to GitHub Settings**:
   - Navigate to [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)

2. **Generate New Token**:
   - Click "Generate new token (classic)"
   - Give it a descriptive name like "Self-Hosted Runner Token"

3. **Set Token Permissions**:
   - For **repository runners**: Select `repo` scope (Full control of private repositories)
   - For **organization runners**: Select `admin:org` scope (Full control of orgs and teams)

4. **Generate and Copy**:
   - Click "Generate token"
   - **⚠️ Important**: Copy the token immediately - you won't see it again!

## ⚙️ Step 3: Configure the Runner

1. **Navigate to the github-runner directory**:
   ```cmd
   cd github-runner
   ```

2. **Copy the environment template**:
   ```cmd
   copy .env.example .env
   ```

3. **Edit the .env file** with your details:
   ```bash
   # Open .env in your favorite text editor (Notepad, VSCode, etc.)
   notepad .env
   ```

4. **Fill in your configuration**:
   ```bash
   # Required: Your GitHub Personal Access Token
   GITHUB_TOKEN=ghp_your_actual_token_here
   
   # For Repository Runner (choose this OR organization below)
   GITHUB_REPOSITORY=your-username/your-repository-name
   
   # For Organization Runner (alternative to repository)
   # GITHUB_OWNER=your-organization-name
   
   # Optional: Custom runner name
   RUNNER_NAME=my-docker-runner
   
   # Optional: Custom labels
   RUNNER_LABELS=docker,ubuntu,self-hosted,windows-host
   ```

## 🚀 Step 4: Start the Runner

Run the setup script:

```powershell
# Open PowerShell as Administrator
PowerShell -ExecutionPolicy Bypass -File setup-agent.ps1 -AgentType github
```

Or manually start with Docker Compose:

```cmd
# In the github-runner directory
docker-compose up -d
```

## ✅ Step 5: Verify the Runner

1. **Check Docker Container**:
   ```cmd
   docker-compose logs -f
   ```
   You should see registration success messages.

2. **Check GitHub Dashboard**:
   - Go to your repository → Settings → Actions → Runners
   - Or for organizations: Organization Settings → Actions → Runners
   - Your runner should appear as "Online" with a green dot

## 🛠️ Management Commands

```cmd
# View runner logs
docker-compose logs -f

# Stop the runner
docker-compose down

# Restart the runner
docker-compose restart

# Update the runner
docker-compose pull
docker-compose up -d
```

## 🔑 Key Features

- **🐳 Docker-in-Docker**: Full containerization support for your workflows
- **🔄 Auto-Registration**: Automatically registers/deregisters with GitHub
- **🛡️ Security**: Runs as non-root user with security best practices
- **📊 Logging**: Comprehensive logging and error handling
- **🔄 Auto-Restart**: Container restarts automatically on failure
- **⚡ Pre-installed Tools**: 
  - .NET SDK
  - Node.js & npm
  - Docker CLI
  - Git
  - Common build tools

## 🔧 Troubleshooting

### Runner Not Appearing in GitHub
- Verify your PAT token has correct permissions
- Check that `GITHUB_REPOSITORY` or `GITHUB_OWNER` is correctly set
- Review container logs: `docker-compose logs`

### Permission Errors
- Ensure Docker Desktop is running
- On Windows, run PowerShell as Administrator
- Verify the PAT token hasn't expired

### Container Won't Start
- Check Docker Desktop is running
- Verify the .env file exists and has correct values
- Run: `docker-compose down && docker-compose up -d`

## 📞 Support

If you encounter issues:
1. Check the container logs: `docker-compose logs`
2. Verify your .env configuration
3. Ensure your PAT token has the required permissions
4. Check that Docker Desktop is running and accessible

---

**🎉 Congratulations!** Your self-hosted GitHub Actions runner is now ready to execute workflows from your repository.