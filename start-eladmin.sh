#!/bin/bash

# ELADMIN Docker Environment Startup Script
# This script sets up and starts the complete ELADMIN application stack

echo "🚀 Starting ELADMIN Application Stack..."
echo "=================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose > /dev/null 2>&1 && ! docker compose version > /dev/null 2>&1; then
    echo "❌ Error: Docker Compose is not available."
    exit 1
fi

# Clean up any existing containers (optional)
echo "🧹 Cleaning up existing containers..."
docker compose down -v 2>/dev/null || true

# Build and start all services
echo "🔨 Building and starting services..."
echo "This may take a few minutes on first run..."

# Use docker compose (newer) or docker-compose (legacy)
if docker compose version > /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Start the services
$COMPOSE_CMD up --build -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
echo "Checking MySQL health..."
timeout=300  # 5 minutes timeout
counter=0

while [ $counter -lt $timeout ]; do
    if $COMPOSE_CMD ps mysql | grep -q "healthy"; then
        echo "✅ MySQL is ready!"
        break
    fi
    echo "   MySQL starting... ($counter/$timeout seconds)"
    sleep 5
    counter=$((counter + 5))
done

if [ $counter -ge $timeout ]; then
    echo "❌ MySQL failed to start within $timeout seconds"
    echo "📋 Checking logs..."
    $COMPOSE_CMD logs mysql
    exit 1
fi

echo "⏳ Checking Redis health..."
counter=0
while [ $counter -lt 60 ]; do
    if $COMPOSE_CMD ps redis | grep -q "healthy"; then
        echo "✅ Redis is ready!"
        break
    fi
    echo "   Redis starting... ($counter/60 seconds)"
    sleep 2
    counter=$((counter + 2))
done

echo "⏳ Waiting for backend to start..."
counter=0
while [ $counter -lt 180 ]; do
    if curl -s http://localhost:8080/ > /dev/null 2>&1; then
        echo "✅ Backend is ready!"
        break
    fi
    echo "   Backend starting... ($counter/180 seconds)"
    sleep 5
    counter=$((counter + 5))
done

echo "⏳ Waiting for frontend to start..."
counter=0
while [ $counter -lt 60 ]; do
    if curl -s http://localhost:8013/ > /dev/null 2>&1; then
        echo "✅ Frontend is ready!"
        break
    fi
    echo "   Frontend starting... ($counter/60 seconds)"
    sleep 3
    counter=$((counter + 3))
done

echo ""
echo "🎉 ELADMIN Application Stack Started Successfully!"
echo "=================================="
echo "📱 Frontend (Vue.js):     http://localhost:8013"
echo "🔧 Backend API:           http://localhost:8080"
echo "📊 API Documentation:     http://localhost:8080/doc.html"
echo "🗄️  Database Monitor:      http://localhost:8080/druid"
echo "🔍 MySQL:                 localhost:3306"
echo "💾 Redis:                 localhost:6379"
echo ""
echo "🔐 Default Login Credentials:"
echo "   Username: admin"
echo "   Password: 123456"
echo ""
echo "📋 Useful Commands:"
echo "   View logs:     $COMPOSE_CMD logs -f [service_name]"
echo "   Stop all:      $COMPOSE_CMD down"
echo "   Restart:       $COMPOSE_CMD restart [service_name]"
echo "   Status:        $COMPOSE_CMD ps"
echo ""
echo "🔧 Troubleshooting:"
echo "   If services fail to start, check logs with:"
echo "   $COMPOSE_CMD logs [mysql|redis|java-eladmin-system|js-eladmin-web]"
echo ""