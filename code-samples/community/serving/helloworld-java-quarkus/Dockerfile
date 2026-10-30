# Build with a supported Java LTS and Maven release.
FROM maven:3.9.16-eclipse-temurin-25 AS build
WORKDIR /workspace
ENV MAVEN_OPTS="-Xmx768m -XX:ActiveProcessorCount=2"
COPY pom.xml ./
COPY src ./src
RUN mvn -B -ntp clean verify

# Quarkus fast-jar: copy the entire directory, not only quarkus-run.jar.
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build --chown=1001:0 /workspace/target/quarkus-app/ ./
USER 1001
EXPOSE 8080
ENTRYPOINT ["/bin/sh", "-c", "export PORT=\"${PORT:-8080}\"; exec java -XX:MaxRAMPercentage=75.0 -XX:ActiveProcessorCount=2 -jar /app/quarkus-run.jar"]
