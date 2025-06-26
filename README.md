## Running the Project with Docker

This project provides a full Docker-based setup for both the backend (Java Spring Boot) and frontend (Vue.js), along with MySQL and Redis services. The configuration is managed via the included `compose.yaml` file.

### Project-Specific Requirements

- **Java Backend**: Uses Eclipse Temurin JDK 17 (see `eladmin/eladmin-system/Dockerfile`).
- **Frontend**: Uses Node.js version 22.13.1 (see `eladmin-web/Dockerfile`).
- **MySQL**: Uses the official `mysql:latest` image, with custom configuration and initialization SQL scripts.
- **Redis**: Uses the official `redis:latest` image.

### Environment Variables

- **MySQL** (set in `compose.yaml`):
  - `MYSQL_ROOT_PASSWORD=eladmin`
  - `MYSQL_DATABASE=eladmin`
  - `MYSQL_USER=eladmin`
  - `MYSQL_PASSWORD=eladmin`
- **Backend and Frontend**: No required environment variables by default, but you can uncomment and set `env_file` in the compose file for custom configuration.

### Build and Run Instructions

1. **Ensure Docker and Docker Compose are installed.**
2. **Build and start all services:**
   ```sh
   docker compose up --build
   ```
   This will build the backend and frontend images and start all services (backend, frontend, MySQL, Redis) as defined in `compose.yaml`.

3. **Access the services:**
   - **Backend (Spring Boot API):** http://localhost:8080
   - **Frontend (Vue.js app):** http://localhost:8013
   - **MySQL:** localhost:3306 (credentials as above)
   - **Redis:** localhost:6379

### Special Configuration

- **MySQL**:
  - Uses a custom configuration file: `./mysql-config/my.cnf`
  - Initializes with SQL scripts: `./sql/eladmin.sql` and `./sql/quartz.sql`
- **Frontend**:
  - The Vue.js app is built and served as static files using the `serve` package on port 8013.
- **Backend**:
  - Runs as a non-root user for security.
  - JVM is configured for container environments with `JAVA_OPTS`.

### Ports Exposed

| Service                | Host Port | Container Port | Description                |
|------------------------|-----------|---------------|----------------------------|
| Java Backend           | 8080      | 8080          | Spring Boot API            |
| Frontend (Vue.js)      | 8013      | 8013          | Static web app             |
| MySQL                  | 3306      | 3306          | Database                   |
| Redis                  | 6379      | 6379          | Cache/Session store        |

### Notes

- If you need to customize environment variables for the backend or frontend, create `.env` or `.env.production` files and uncomment the `env_file` lines in `compose.yaml`.
- Data for MySQL and Redis is persisted using Docker volumes (`mysql_data`, `redis_data`).
- Health checks are configured for MySQL and Redis to ensure service readiness.

For more details on Docker setup, see `DOCKER_SETUP.md` in the project root.
