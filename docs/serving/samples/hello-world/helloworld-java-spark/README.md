A simple web app written in Java using Spark Java Framework that you can use for
testing.

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md)
  if you need to create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- You have installed
  [Java SE 8 or later JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html).

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Clone the repo from the following path:

   ```shell
   git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
   ```

2. Navigate to the helloworld-java-spark directory

   ```shell
   cd serving/samples/helloworld-java-spark
   ```

3. Run the application locally:

   ```shell
   ./mvnw package && java -jar target/helloworld-0.0.1-SNAPSHOT-jar-with-dependencies.jar
   ```

   Go to `http://localhost:8080/` to see your `Hello World!` message.

4. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing a Spark Java
   app, see [Spark with Docker](http://sparkjava.com/tutorials/docker). For
   additional information on multi-stage docker builds for Java see
   [Creating Smaller Java Image using Docker Multi-stage Build](https://github.com/arun-gupta/docker-java-multistage).

   ```docker
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

    # Copy the jar to the production image from the builder stage.
    COPY --from=builder /app/target/helloworld-0.0.1-SNAPSHOT-jar-with-dependencies.jar /helloworld.jar

    # Run the web service on container startup.
    CMD ["java","-Dserver.port=${PORT}","-jar","/helloworld.jar"]
   ```

5. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-java
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-java
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-java .

   # Push the container to docker registry
   docker push {username}/helloworld-java
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```shell
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balancer
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, use

   ```shell
   kubectl get ksvc helloworld-java \
       --output=custom-columns=NAME:.metadata.name,URL:.status.url

   NAME                URL
   helloworld-java     http://helloworld-java.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-java.default.1.2.3.4.xip.io
   Hello World!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
