# Build with a maintained Gradle release and Java 25 LTS.
FROM gradle:9.8.2-jdk25 AS builder
WORKDIR /workspace

COPY build.gradle ./
COPY src ./src
RUN gradle clean build installDist --no-daemon --max-workers=2

# Keep the supported Eclipse Temurin runtime separate from the build tools.
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=builder /workspace/build/install/helloworld-kotlin/ ./

USER 10001:10001
EXPOSE 8080
ENTRYPOINT ["/app/bin/helloworld-kotlin"]
