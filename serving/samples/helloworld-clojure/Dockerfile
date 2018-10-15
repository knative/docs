# Start from a Debian image with the latest version of Clojure installed.
FROM clojure

# Create the project and download dependencies.
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY project.clj /usr/src/app/
RUN lein deps

# Copy the local package files inside the container.
COPY . /usr/src/app

# Build the app as an uberjar.
RUN mv "$(lein uberjar | sed -n 's/^Created \(.*standalone\.jar\)/\1/p')" app-standalone.jar

# Run the app by default when the container starts.
CMD ["java", "-jar", "app-standalone.jar"]

# Document that the service listens on port 8080.
EXPOSE 8080