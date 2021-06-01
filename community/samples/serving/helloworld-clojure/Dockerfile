# Use the official Clojure image.
# https://hub.docker.com/_/clojure
FROM clojure

# Create the project and download dependencies.
WORKDIR /usr/src/app
COPY project.clj .
RUN lein deps

# Copy local code to the container image.
COPY . .

# Build an uberjar release artifact.
RUN mv "$(lein uberjar | sed -n 's/^Created \(.*standalone\.jar\)/\1/p')" app-standalone.jar

# Run the web service on container startup.
CMD ["java", "-jar", "app-standalone.jar"]
