# ELADMIN Docker Setup Validation Script

Write-Host "🔍 Validating ELADMIN Docker Setup..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check Docker installation
Write-Host "`n📦 Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "✅ Docker found: $dockerVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker not found or not running" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Docker not available" -ForegroundColor Red
    exit 1
}

# Check Docker Compose
Write-Host "`n🔧 Checking Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker compose version 2>$null
    if ($composeVersion) {
        Write-Host "✅ Docker Compose found: $composeVersion" -ForegroundColor Green
        $script:composeCmd = "docker compose"
    } else {
        $composeVersion = docker-compose version 2>$null
        if ($composeVersion) {
            Write-Host "✅ Docker Compose (legacy) found: $composeVersion" -ForegroundColor Green
            $script:composeCmd = "docker-compose"
        } else {
            Write-Host "❌ Docker Compose not found" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "❌ Docker Compose not available" -ForegroundColor Red
    exit 1
}

# Check required files
Write-Host "`n📁 Checking required files..." -ForegroundColor Yellow
$requiredFiles = @(
    "compose.yaml",
    "eladmin/eladmin-system/Dockerfile",
    "eladmin-web/Dockerfile",
    "sql/eladmin.sql",
    "sql/quartz.sql",
    "mysql-config/my.cnf"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
    }
}

# Check port availability
Write-Host "`n🔌 Checking port availability..." -ForegroundColor Yellow
$ports = @(8013, 8080, 3306, 6379)

foreach ($port in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Host "⚠️  Port $port is already in use" -ForegroundColor Yellow
        } else {
            Write-Host "✅ Port $port is available" -ForegroundColor Green
        }
    } catch {
        Write-Host "✅ Port $port is available" -ForegroundColor Green
    }
}

# Validate Docker Compose configuration
Write-Host "`n🔍 Validating Docker Compose configuration..." -ForegroundColor Yellow
try {
    $configCheck = & $script:composeCmd config 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker Compose configuration is valid" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker Compose configuration has errors:" -ForegroundColor Red
        Write-Host $configCheck -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Failed to validate Docker Compose configuration" -ForegroundColor Red
}

Write-Host "`n🎯 Setup Validation Complete!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "`n🚀 To start the application, run:" -ForegroundColor Cyan
Write-Host "   .\start-eladmin.bat" -ForegroundColor White
Write-Host "`n   Or manually:" -ForegroundColor Cyan
Write-Host "   $script:composeCmd up --build -d" -ForegroundColor White

Write-Host "`n📋 After startup, access:" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:8013" -ForegroundColor White
Write-Host "   Backend:  http://localhost:8080" -ForegroundColor White
Write-Host "   API Docs: http://localhost:8080/doc.html" -ForegroundColor White