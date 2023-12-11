# Use the official maven/Java 8 image to create a build artifact.
# https://hub.docker.com/_/maven
FROM maven:3.5-jdk-8-alpine as builder

# Copy local code to the container image.
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build a release artifact.
RUN mvn package -DskipTests

# Use the Official OpenJDK image for a lean production stage of our multi-stage build.
# https://hub.docker.com/_/openjdk
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM openjdk:8-jre-alpine

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

ENV PORT=8080

# Create and change to the app directory.
WORKDIR "/home/${USER}/app"

# Add a user so the server will run as a non-root user.
RUN addgroup -g $USER_GID $USER && \
    adduser -u $USER_UID -G $USER -D $USER

# Copy the jar to the production image from the builder stage.
COPY --from=builder /app/target/helloworld-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./helloworld.jar

EXPOSE $PORT

# Set the non-root user as current.
USER $USER

# Run the web service on container startup.
CMD ["java","-jar","./helloworld.jar"]

