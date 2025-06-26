@echo off
REM ELADMIN Docker Environment Startup Script for Windows
REM This script sets up and starts the complete ELADMIN application stack

echo 🚀 Starting ELADMIN Application Stack...
echo ==================================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose version >nul 2>&1
    if errorlevel 1 (
        echo ❌ Error: Docker Compose is not available.
        pause
        exit /b 1
    )
    set COMPOSE_CMD=docker-compose
) else (
    set COMPOSE_CMD=docker compose
)

REM Clean up any existing containers (optional)
echo 🧹 Cleaning up existing containers...
%COMPOSE_CMD% down -v >nul 2>&1

REM Build and start all services
echo 🔨 Building and starting services...
echo This may take a few minutes on first run...

%COMPOSE_CMD% up --build -d

REM Wait for services to be healthy
echo ⏳ Waiting for services to be ready...
echo Checking MySQL health...

set /a timeout=300
set /a counter=0

:wait_mysql
if %counter% geq %timeout% (
    echo ❌ MySQL failed to start within %timeout% seconds
    echo 📋 Checking logs...
    %COMPOSE_CMD% logs mysql
    pause
    exit /b 1
)

%COMPOSE_CMD% ps mysql | findstr "healthy" >nul 2>&1
if not errorlevel 1 (
    echo ✅ MySQL is ready!
    goto check_redis
)

echo    MySQL starting... (%counter%/%timeout% seconds)
timeout /t 5 /nobreak >nul
set /a counter+=5
goto wait_mysql

:check_redis
echo ⏳ Checking Redis health...
set /a counter=0

:wait_redis
if %counter% geq 60 (
    echo ⚠️  Redis check timeout, continuing...
    goto check_backend
)

%COMPOSE_CMD% ps redis | findstr "healthy" >nul 2>&1
if not errorlevel 1 (
    echo ✅ Redis is ready!
    goto check_backend
)

echo    Redis starting... (%counter%/60 seconds)
timeout /t 2 /nobreak >nul
set /a counter+=2
goto wait_redis

:check_backend
echo ⏳ Waiting for backend to start...
set /a counter=0

:wait_backend
if %counter% geq 180 (
    echo ⚠️  Backend check timeout, continuing...
    goto check_frontend
)

curl -s http://localhost:8080/ >nul 2>&1
if not errorlevel 1 (
    echo ✅ Backend is ready!
    goto check_frontend
)

echo    Backend starting... (%counter%/180 seconds)
timeout /t 5 /nobreak >nul
set /a counter+=5
goto wait_backend

:check_frontend
echo ⏳ Waiting for frontend to start...
set /a counter=0

:wait_frontend
if %counter% geq 60 (
    echo ⚠️  Frontend check timeout, but services should be running...
    goto show_info
)

curl -s http://localhost:8013/ >nul 2>&1
if not errorlevel 1 (
    echo ✅ Frontend is ready!
    goto show_info
)

echo    Frontend starting... (%counter%/60 seconds)
timeout /t 3 /nobreak >nul
set /a counter+=3
goto wait_frontend

:show_info
echo.
echo 🎉 ELADMIN Application Stack Started Successfully!
echo ==================================
echo 📱 Frontend (Vue.js):     http://localhost:8013
echo 🔧 Backend API:           http://localhost:8080
echo 📊 API Documentation:     http://localhost:8080/doc.html
echo 🗄️  Database Monitor:      http://localhost:8080/druid
echo 🔍 MySQL:                 localhost:3306
echo 💾 Redis:                 localhost:6379
echo.
echo 🔐 Default Login Credentials:
echo    Username: admin
echo    Password: 123456
echo.
echo 📋 Useful Commands:
echo    View logs:     %COMPOSE_CMD% logs -f [service_name]
echo    Stop all:      %COMPOSE_CMD% down
echo    Restart:       %COMPOSE_CMD% restart [service_name]
echo    Status:        %COMPOSE_CMD% ps
echo.
echo 🔧 Troubleshooting:
echo    If services fail to start, check logs with:
echo    %COMPOSE_CMD% logs [mysql^|redis^|java-eladmin-system^|js-eladmin-web]
echo.
echo Press any key to open the application in your browser...
pause >nul

REM Open the application in default browser
start http://localhost:8013