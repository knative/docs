# Use the official gradle image to create a build artifact.
# https://hub.docker.com/_/gradle
FROM gradle:6.7 as builder

# Copy local code to the container image.
COPY build.gradle .
COPY src ./src

# Build a release artifact.
RUN gradle clean build --no-daemon

# Use the Official OpenJDK image for a lean production stage of our multi-stage build.
# https://hub.docker.com/_/openjdk
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM openjdk:8-jre-alpine

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create and change to the app directory.
WORKDIR "/home/${USER}/app"

# Add a user so the server will run as a non-root user.
RUN addgroup -g $USER_GID $USER && \
    adduser -u $USER_UID -G $USER -D $USER

# Copy the jar to the production image from the builder stage.
COPY --from=builder /home/gradle/build/libs/gradle.jar ./helloworld.jar

# Set the non-root user as current.
USER $USER

# Run the web service on container startup.
CMD [ "java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "./helloworld.jar" ]
