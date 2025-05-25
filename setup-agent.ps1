# GitHub Actions Self-Hosted Runner Setup Script
# This script helps you set up a GitHub Actions self-hosted runner quickly

param(
    [Parameter(Mandatory=$false)]
    [string]$WorkingDirectory = $PWD
)

Write-Host "🚀 GitHub Actions Self-Hosted Runner Setup" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check if Docker is running
Write-Host "`n📋 Checking prerequisites..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running or not installed" -ForegroundColor Red
    Write-Host "Please install Docker Desktop and ensure it's running" -ForegroundColor Yellow
    exit 1
}

# Navigate to github-runner directory
$runnerDir = Join-Path $WorkingDirectory "github-runner"
if (!(Test-Path $runnerDir)) {
    Write-Host "❌ github-runner directory not found!" -ForegroundColor Red
    Write-Host "Please run this script from the repository root directory" -ForegroundColor Yellow
    exit 1
}

Set-Location $runnerDir
Write-Host "📁 Working in: $runnerDir" -ForegroundColor Cyan

# Check if .env file exists
if (!(Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Write-Host "`n📝 Creating .env file from template..." -ForegroundColor Yellow
        Copy-Item ".env.example" ".env"
        Write-Host "✅ .env file created" -ForegroundColor Green
        
        Write-Host "`n⚠️  IMPORTANT: You need to edit the .env file with your details!" -ForegroundColor Red
        Write-Host "Required configuration:" -ForegroundColor Yellow
        Write-Host "  1. GITHUB_TOKEN - Your GitHub Personal Access Token" -ForegroundColor White
        Write-Host "  2. GITHUB_REPOSITORY - Your repository (e.g., username/repo-name)" -ForegroundColor White
        Write-Host "`nOpening .env file for editing..." -ForegroundColor Yellow
        
        # Try to open with different editors
        if (Get-Command "code" -ErrorAction SilentlyContinue) {
            code .env
        } elseif (Get-Command "notepad" -ErrorAction SilentlyContinue) {
            notepad .env
        } else {
            Write-Host "Please edit .env file manually with your preferred text editor" -ForegroundColor Yellow
        }
        
        Write-Host "`nAfter editing .env file, press Enter to continue..." -ForegroundColor Yellow
        Read-Host
    } else {
        Write-Host "❌ .env.example file not found!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Start the runner
Write-Host "`n🚀 Starting GitHub Actions Runner..." -ForegroundColor Green
try {
    docker-compose up -d
    Write-Host "✅ Runner started successfully!" -ForegroundColor Green
    
    Write-Host "`n📊 Checking runner status..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    docker-compose logs --tail=20
    
    Write-Host "`n🎉 Setup Complete!" -ForegroundColor Green
    Write-Host "Your runner should now appear in your GitHub repository:" -ForegroundColor Cyan
    Write-Host "  Repository → Settings → Actions → Runners" -ForegroundColor White
    
    Write-Host "`n📋 Useful Commands:" -ForegroundColor Yellow
    Write-Host "  View logs:      docker-compose logs -f" -ForegroundColor White
    Write-Host "  Stop runner:    docker-compose down" -ForegroundColor White
    Write-Host "  Restart runner: docker-compose restart" -ForegroundColor White
    
} catch {
    Write-Host "❌ Failed to start runner: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check your .env configuration and try again" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nFor detailed instructions, see the README.md file" -ForegroundColor Magenta
