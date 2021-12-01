FROM eclipse-temurin:11-jdk-alpine

# Copy local code to the container image.
WORKDIR /app
COPY mvnw .
COPY .mvn ./.mvn
COPY pom.xml .
COPY src ./src

# Build a release artifact.
RUN ./mvnw package -DskipTests

ENV PORT 8080

EXPOSE 8080

# Run the web service on container startup.
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app/target/helloworld-*.jar"]
