# Use the official gradle image to create a build artifact.
# https://hub.docker.com/_/gradle
FROM gradle as builder

# Copy local code to the container image.
COPY build.gradle .
COPY src ./src

# Build a release artifact.
RUN gradle clean build --no-daemon

# Use the Official OpenJDK image for a lean production stage of our multi-stage build.
# https://hub.docker.com/_/openjdk
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM openjdk:8-jre-alpine

# Copy the jar to the production image from the builder stage.
COPY --from=builder /home/gradle/build/libs/gradle.jar /helloworld.jar

# Configure the service HTTP port.
ENV PORT 8080

# Run the web service on container startup.
CMD [ "java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "/helloworld.jar" ]
