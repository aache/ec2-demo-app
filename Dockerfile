# syntax=docker/dockerfile:1

# ---- Build Stage ----
FROM gradle:8.7-jdk21-jammy AS build
WORKDIR /workspace
COPY . .
RUN gradle bootJar --no-daemon

# ---- Runtime Stage ----
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /workspace/build/libs/*SNAPSHOT*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]