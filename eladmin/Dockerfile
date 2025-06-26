FROM eclipse-temurin:17-jre

WORKDIR /app

# 复制构建好的 JAR（改成你实际 JAR 路径）
COPY ./eladmin-system/target/eladmin-system-1.1.jar app.jar

ENV TZ=Asia/Shanghai

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

