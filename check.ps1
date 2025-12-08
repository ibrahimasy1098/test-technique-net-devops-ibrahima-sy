# PowerShell equivalent of check.sh
# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# Function to check if a command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Install commitlint if not available
if (-not (Test-Command "npx")) {
    Write-Host "npx not found, installing Node.js dependencies..."
    npm init -y | Out-Null
    npm i -D @commitlint/cli @commitlint/config-conventional | Out-Null
}

# Check conventional commits
Write-Host "Checking conventional commits..."
npm init -y | Out-Null
npm i -D @commitlint/cli @commitlint/config-conventional | Out-Null

try {
    $commitlintResult = npx commitlint --extends @commitlint/config-conventional --from HEAD~3 --to HEAD
    Write-Host "✅ All commit messages follow conventional commit format"
}
catch {
    Write-Host "commitlint failed"
    exit 1
}

# Build + tests
Write-Host "Building and testing..."
dotnet build -c Release
dotnet test -c Release --no-build

# Run app (background)
Write-Host "Starting application..."
$appProcess = Start-Process -FilePath "dotnet" -ArgumentList "run", "--project", "Api/Api.csproj", "-c", "Release", "--no-build" -PassThru

# Wait for app to start
Write-Host "Waiting for application to start..."
$maxAttempts = 30
$attempt = 0
$appReady = $false

while ($attempt -lt $maxAttempts -and -not $appReady) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5080/health" -UseBasicParsing -TimeoutSec 1
        if ($response.StatusCode -eq 200) {
            $appReady = $true
        }
    }
    catch {
        # App not ready yet, continue waiting
    }
    
    if (-not $appReady) {
        Start-Sleep -Seconds 1
        $attempt++
    }
}

if (-not $appReady) {
    Write-Host "Application failed to start within timeout period"
    Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

# Health check
Write-Host "Performing health check..."
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:5080/health" -UseBasicParsing
    $healthContent = $healthResponse.Content
    if ($healthContent -notmatch '"status"') {
        Write-Host "health failed"
        Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue
        exit 1
    }
}
catch {
    Write-Host "health check failed"
    Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

# POST test
Write-Host "Testing POST endpoint..."
try {
    $postBody = @{
        date = "2025-10-07"
        durationMinutes = 90
        project = "QimTime"
    } | ConvertTo-Json

    $postResponse = Invoke-WebRequest -Uri "http://localhost:5080/time-entries" -Method POST -Body $postBody -ContentType "application/json" -UseBasicParsing
    $postContent = $postResponse.Content
    if ($postContent -notmatch '"id"') {
        Write-Host "post failed"
        Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue
        exit 1
    }
}
catch {
    Write-Host "POST test failed"
    Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

# GET test
Write-Host "Testing GET endpoint..."
try {
    $getResponse = Invoke-WebRequest -Uri "http://localhost:5080/time-entries?from=2025-10-01&to=2025-10-31" -UseBasicParsing
    $getContent = $getResponse.Content
    if ($getContent -notmatch 'QimTime') {
        Write-Host "get failed"
        Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue
        exit 1
    }
}
catch {
    Write-Host "GET test failed"
    Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

# Clean up
Write-Host "Stopping application..."
Stop-Process -Id $appProcess.Id -Force -ErrorAction SilentlyContinue

Write-Host "OK"
