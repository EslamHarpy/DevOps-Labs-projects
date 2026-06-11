# Stage 1: Build application using Maven and OpenJDK 17
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /build

COPY backend/pom.xml .
RUN mvn dependency:go-offline -B

COPY backend/src ./src
RUN mvn package -DskipTests -B

# Stage 2: Lightweight and secure runtime using JRE 17 Alpine
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S springgroup && adduser -S springuser -G springgroup

COPY --from=builder /build/target/*.jar app.jar
RUN chown -R springuser:springgroup /app

USER springuser
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
