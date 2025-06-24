
#### Docker 部署指南

本项目已支持基于 Docker 的一键部署，方便快速启动和本地开发。以下为项目专属的 Docker 使用说明：

##### 依赖与版本要求
- **JDK 版本**：17（基于 `eclipse-temurin:17-jdk` 和 `eclipse-temurin:17-jre`）
- **Node.js 版本**：22.13.1（基于 `node:22.13.1-slim`）
- **MySQL**：latest（默认 root 密码和数据库见下方）
- **Redis**：latest

##### 端口映射
- 后端（Spring Boot）：`8080`（容器内外均为 8080）
- 前端（Vue 静态服务）：`8013`（容器内外均为 8013）
- MySQL：`3306`
- Redis：`6379`

##### 环境变量
- MySQL 服务：
  - `MYSQL_ROOT_PASSWORD=eladmin123`
  - `MYSQL_DATABASE=eladmin`
  - `MYSQL_USER=eladmin`
  - `MYSQL_PASSWORD=eladmin123`
- Spring Boot 后端：
  - `SPRING_PROFILE`（可选，默认 prod）
- 其他服务可通过 `.env` 文件自定义环境变量（如有需要，取消 compose.yaml 中的注释）

##### 构建与运行
1. **准备 Docker 环境**：确保已安装 Docker 和 Docker Compose。
2. **构建并启动服务**：在项目根目录下执行：
   ```bash
   docker compose up --build
   ```
   该命令会自动构建并启动所有服务，包括后端、前端、MySQL 和 Redis。
3. **访问服务**：
   - 后端接口：http://localhost:8080
   - 前端页面：http://localhost:8013
   - MySQL：localhost:3306
   - Redis：localhost:6379

##### 特殊说明
- **数据持久化**：MySQL 默认未配置数据持久化，如需持久化请取消 compose.yaml 中 `volumes` 的注释。
- **自定义配置**：如需自定义环境变量，可在对应服务目录下添加 `.env` 文件，并在 compose.yaml 中取消 `env_file` 注释。
- **首次构建较慢**：首次构建会下载依赖，后续构建会更快。

如需更多 Docker 相关配置，可参考项目根目录下的 `compose.yaml` 及各模块的 Dockerfile。
