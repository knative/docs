# Use an SBT image matching the Scala and JDK version.
FROM hseeberger/scala-sbt:8u265_1.4.2_2.13.3 as builder

# Add a user so the server will run as a non-root user.
RUN addgroup -g 1000 appuser && \
    adduser -S -u 1000 -G appuser appuser

# Copy local code to the container image.
WORKDIR /app
COPY build.sbt .
COPY project ./project
COPY src ./src

# Build a release artifact.
RUN sbt assembly

# Use the Official OpenJDK image for a lean production stage of our multi-stage build.
# https://hub.docker.com/_/openjdk
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM openjdk:8-jre-alpine

# Add a user so the server will run as a non-root user.
RUN addgroup -g 1000 appuser && \
    adduser -S -u 1000 -G appuser appuser

# Copy the jar to the production image from the builder stage.
COPY --from=builder /app/target/scala-2.13/helloworld-*.jar /helloworld.jar

USER appuser

# Run the web service on container startup.
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/helloworld.jar"]
