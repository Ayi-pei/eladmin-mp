# syntax=docker/dockerfile:1

# --- Build Stage ---
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Copy Maven wrapper and pom files first for dependency caching
COPY --link pom.xml ./
COPY --link mvnw ./
COPY --link .mvn ./.mvn

# Download dependencies (leverages Docker cache)
RUN chmod +x mvnw && ./mvnw dependency:go-offline

# Copy the rest of the source code
COPY --link . ./

# Build the application (skip tests for faster build)
RUN ./mvnw package -DskipTests

# --- Runtime Stage ---
FROM eclipse-temurin:17-jre
WORKDIR /app

# Create a non-root user and group
RUN addgroup --system eladmin && adduser --system --ingroup eladmin eladmin

# Copy the built jar from the build stage
COPY --from=build /app/eladmin-system/target/*.jar /app/app.jar

# Set permissions
RUN chown eladmin:eladmin /app/app.jar
USER eladmin

# Expose the default Spring Boot port
EXPOSE 8080

# JVM options for container awareness and memory limits
ENV JAVA_OPTS="-XX:MaxRAMPercentage=80.0 -Djava.security.egd=file:/dev/./urandom"

# Use exec form for proper signal handling
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar --spring.profiles.active=${SPRING_PROFILE:-prod}"]
