# Use the official Maven/Java 25 LTS image to build: https://hub.docker.com/_/maven
FROM maven:3.9.16-eclipse-temurin-25 AS builder

# Copy local code to the container image.
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build the executable jar.
RUN mvn --batch-mode --no-transfer-progress package

# Use the Eclipse Temurin Java 25 LTS runtime for the production stage.
# https://hub.docker.com/_/eclipse-temurin
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM eclipse-temurin:25-jre-noble

# Copy the jar to the production image from the builder stage.
COPY --from=builder /app/target/helloworld-*.jar /helloworld.jar

# Run the web service on container startup.
CMD ["java", "-jar", "/helloworld.jar"]
