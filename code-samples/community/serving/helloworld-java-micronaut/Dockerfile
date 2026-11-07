# Public multi-architecture Maven / Java 25 LTS build image.
# https://hub.docker.com/_/maven
FROM maven:3.10.0-eclipse-temurin-25-noble AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build the shaded executable JAR.
RUN mvn -B -ntp verify

# Java 25 LTS runtime; no Maven or compiler in the production image.
# https://hub.docker.com/_/eclipse-temurin
FROM eclipse-temurin:25-jre-noble
WORKDIR /app
COPY --from=builder /app/target/helloworld-1.0.0-SNAPSHOT.jar /app/helloworld.jar
USER 10001:10001
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/helloworld.jar"]
