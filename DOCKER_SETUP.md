# ELADMIN Docker Setup Guide

This guide will help you set up and run the complete ELADMIN application stack using Docker with MySQL 5.7.

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Docker Compose available
- At least 4GB RAM available for containers
- Ports 8013, 8080, 3306, 6379 available on localhost

### Option 1: Using Startup Scripts (Recommended)

**Windows:**
```cmd
start-eladmin.bat
```

**Linux/macOS:**
```bash
chmod +x start-eladmin.sh
./start-eladmin.sh
```

### Option 2: Manual Docker Compose

```bash
# Build and start all services
docker compose up --build -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

## 📋 Services Overview

| Service | Container | Port | Description |
|---------|-----------|------|-------------|
| Frontend | js-eladmin-web | 8013 | Vue.js application |
| Backend | java-eladmin-system | 8080 | Spring Boot API |
| Database | mysql | 3306 | MySQL 5.7 database |
| Cache | redis | 6379 | Redis cache |

## 🔐 Security Features

### Network Security
- All services run in isolated Docker network `eladmin-net`
- MySQL and Redis ports only exposed to localhost (127.0.0.1)
- No external access to database services

### Database Security
- MySQL 5.7 with optimized configuration
- Dedicated database user with limited privileges
- Data persistence with Docker volumes
- Health checks for service reliability

### Application Security
- Non-root users in all containers
- JWT-based authentication
- RSA password encryption
- CAPTCHA protection
- Role-based access control (RBAC)

## 🔧 Configuration

### MySQL Configuration
Custom MySQL configuration in `mysql-config/my.cnf`:
- UTF8MB4 character set
- Optimized buffer settings
- Query cache enabled
- Slow query logging
- Security hardening

### Environment Variables
The backend service uses these environment variables:
```yaml
DB_HOST: mysql
DB_PORT: 3306
DB_NAME: eladmin
DB_USER: eladmin
DB_PWD: eladmin
REDIS_HOST: redis
REDIS_PORT: 6379
REDIS_DB: 0
```

## 📊 Access Points

After successful startup, access these URLs:

- **Frontend Application**: http://localhost:8013
- **Backend API**: http://localhost:8080
- **API Documentation (Swagger)**: http://localhost:8080/doc.html
- **Database Monitor (Druid)**: http://localhost:8080/druid
- **MySQL**: localhost:3306 (local access only)
- **Redis**: localhost:6379 (local access only)

### Default Credentials
- **Username**: admin
- **Password**: 123456

## 🗄️ Database Initialization

The database is automatically initialized with:
- Main application schema (`sql/eladmin.sql`)
- Quartz scheduler tables (`sql/quartz.sql`)
- Default admin user and permissions
- Sample data for testing

## 📈 Monitoring & Logs

### View Service Status
```bash
docker compose ps
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f mysql
docker compose logs -f java-eladmin-system
docker compose logs -f js-eladmin-web
docker compose logs -f redis
```

### Health Checks
All services include health checks:
- MySQL: `mysqladmin ping`
- Redis: `redis-cli ping`
- Backend: HTTP endpoint check
- Frontend: HTTP endpoint check

## 🔄 Management Commands

### Start Services
```bash
docker compose up -d
```

### Stop Services
```bash
docker compose down
```

### Restart Specific Service
```bash
docker compose restart java-eladmin-system
```

### Rebuild and Start
```bash
docker compose up --build -d
```

### Clean Up (Remove all data)
```bash
docker compose down -v
docker system prune -f
```

## 🐛 Troubleshooting

### Common Issues

**1. Port Already in Use**
```bash
# Check what's using the port
netstat -tulpn | grep :8080
# or on Windows
netstat -ano | findstr :8080

# Kill the process or change the port in compose.yaml
```

**2. MySQL Connection Issues**
```bash
# Check MySQL logs
docker compose logs mysql

# Connect to MySQL container
docker compose exec mysql mysql -u eladmin -p eladmin
```

**3. Backend Not Starting**
```bash
# Check backend logs
docker compose logs java-eladmin-system

# Check if database is ready
docker compose ps mysql
```

**4. Frontend Build Issues**
```bash
# Check frontend logs
docker compose logs js-eladmin-web

# Rebuild frontend only
docker compose up --build js-eladmin-web
```

### Performance Issues

**1. Slow Database Performance**
- Increase MySQL buffer pool size in `mysql-config/my.cnf`
- Monitor slow queries in MySQL logs

**2. High Memory Usage**
- Adjust JVM settings in backend Dockerfile
- Reduce MySQL buffer sizes if needed

**3. Slow Frontend Loading**
- Check if static files are being served correctly
- Verify network connectivity between containers

### Data Issues

**1. Database Not Initialized**
```bash
# Check if SQL files are mounted correctly
docker compose exec mysql ls -la /docker-entrypoint-initdb.d/

# Manually run initialization
docker compose exec mysql mysql -u root -p eladmin < /docker-entrypoint-initdb.d/eladmin.sql
```

**2. Redis Connection Issues**
```bash
# Test Redis connectivity
docker compose exec redis redis-cli ping

# Check Redis logs
docker compose logs redis
```

## 🔧 Development Mode

For development, you can run services individually:

```bash
# Start only database services
docker compose up -d mysql redis

# Run backend locally (with IDE)
# Run frontend locally (with npm run dev)
```

## 📦 Production Deployment

For production deployment:

1. Change default passwords in `compose.yaml`
2. Use environment files for sensitive data
3. Enable SSL/TLS termination
4. Set up proper backup strategies
5. Configure monitoring and alerting
6. Use Docker secrets for sensitive data

## 🔄 Updates and Maintenance

### Update Application
```bash
# Pull latest code
git pull

# Rebuild and restart
docker compose up --build -d
```

### Backup Database
```bash
# Create backup
docker compose exec mysql mysqldump -u eladmin -p eladmin > backup.sql

# Restore backup
docker compose exec -i mysql mysql -u eladmin -p eladmin < backup.sql
```

### Update Dependencies
```bash
# Update base images
docker compose pull

# Rebuild with latest dependencies
docker compose build --no-cache
```

## 📞 Support

If you encounter issues:

1. Check the logs using the commands above
2. Verify all prerequisites are met
3. Ensure ports are not in use by other applications
4. Check Docker Desktop is running and has sufficient resources
5. Review the troubleshooting section

For additional help, refer to the main project documentation or create an issue in the project repository.