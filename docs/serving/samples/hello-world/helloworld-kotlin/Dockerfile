# Use the official gradle image to create a build artifact.
# https://hub.docker.com/_/gradle
FROM gradle:4.10 as builder

# Copy local code to the container image.
COPY build.gradle .
COPY src ./src

# Build a release artifact.
RUN gradle clean build --no-daemon

# Use AdoptOpenJDK for base image.
# It's important to use OpenJDK 8u191 or above that has container support enabled.
# https://hub.docker.com/r/adoptopenjdk/openjdk8
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM adoptopenjdk/openjdk8:jdk8u202-b08-alpine-slim

# Copy the jar to the production image from the builder stage.
COPY --from=builder /home/gradle/build/libs/gradle.jar /helloworld.jar

# Run the web service on container startup.
CMD [ "java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "/helloworld.jar" ]
