FROM clojure:temurin-25-lein-2.13.0-noble AS builder
WORKDIR /app
COPY project.clj .
RUN lein deps
COPY src ./src
RUN lein uberjar

FROM eclipse-temurin:25-jre-noble
WORKDIR /app
COPY --from=builder /app/target/helloworld.jar .
CMD ["java", "-jar", "helloworld.jar"]
