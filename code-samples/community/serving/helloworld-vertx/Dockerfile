# Build the application without requiring Maven or Java on the host.
FROM maven:3.9.16-eclipse-temurin-25 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn --batch-mode clean package

FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build /app/target/helloworld-1.0.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
