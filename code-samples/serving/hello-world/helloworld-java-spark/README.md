# Hello World - Spark Java Framework

A simple web app written in Java using Spark Java Framework that you can use for
testing.
This guide describes the steps required to to create the `helloworld-java` sample app and deploy it to your cluster.

## Prerequisites

You will need:

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured.
- [Java SE 8 or later JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html).

## Develop

The sample app reads a `TARGET` environment variable, and prints `Hello ${TARGET}!`.
If `TARGET` is not specified, `World` is used as the default value.
You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-java
```

1. Run the application locally:

   ```bash
   mvn wrapper:wrapper
   ./mvnw package && java -jar target/helloworld-0.0.1-SNAPSHOT-jar-with-dependencies.jar
   ```

   Go to `http://localhost:8080/` to see your `Hello World!` message.

1. In your project directory, create a file named `Dockerfile` and copy the following code
   block into it. For detailed instructions on dockerizing a Spark Java
   app, see [Spark with Docker](http://sparkjava.com/tutorials/docker). For
   additional information on multi-stage docker builds for Java see
   [Creating Smaller Java Image using Docker Multi-stage Build](https://github.com/arun-gupta/docker-java-multistage). Navigate to your project directory and copy the following code into a new file named `Dockerfile`:

   ```docker
    FROM maven:3.5-jdk-8-alpine as builder

    # Copy local code to the container image.
    WORKDIR /app
    COPY pom.xml .
    COPY src ./src

    RUN mvn package -DskipTests

    FROM openjdk:8-jre-alpine

    # Copy the jar to the production image from the builder stage.
    COPY --from=builder /app/target/helloworld-0.0.1-SNAPSHOT-jar-with-dependencies.jar helloworld.jar

    ENV PORT 8080
    EXPOSE 8080
    # Run the web service on container startup.
    CMD ["java","-jar","helloworld.jar"]
   ```

1. To build the sample code into a container, and push using Docker Hub, enter the following commands and replace `{username}` with your Docker Hub username:

   ```bash
   # Build the container on your local machine
   docker build -t {username}/helloworld-java .
   # Push the container to docker registry
   docker push {username}/helloworld-java
   ```

## Deploy

After the build has completed and the container is pushed to Docker Hub, you can deploy the app into your cluster. Choose one of the following methods:

### kn

 1. Use `kn` to deploy the service, make sure to replace `{username}` with your Docker Hub username:

 ```bash
 kn service create helloworld-java --image=docker.io/{username}/helloworld-java --env TARGET="SparkJava Sample v1"
 ```

       This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.


### kubectl

 1. Create a new file, `service.yaml` and copy the following service definition into the file. Make sure to replace `{username}` with your Docker Hub username.

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
              env:
                - name: TARGET
                  value: "SparkJava Sample v1"
 ```

 1. Ensure that the container image value in `service.yaml` matches the container you built in the previous step. Apply the configuration using `kubectl`:

 ```bash
 kubectl apply --filename service.yaml
 ```

After your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

## Verify

 1. Run one of the followings commands to find the domain URL for your service.

 ### kn

 ```bash
 kn service describe helloworld-java -o url
  ```

 Example:

 ```bash
 http://helloworld-java.default.1.2.3.4.xip.io
  ```

 ### kubectl
 ```bash
  kubectl get ksvc helloworld-java  --output=custom-columns=NAME:.metadata.name,URL:.status.url
 ```

 Example:

 ```bash
 NAME                      URL
 helloworld-java    http://helloworld-java.default.1.2.3.4.xip.io
 ```

2. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

 Example:

 ```bash
 curl http://helloworld-java.default.1.2.3.4.sslip.io
 Hello SparkJava Sample v1!
 # Even easier with kn:
 curl $(kn service describe helloworld-java -o url)
 ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Delete

To remove the sample app from your cluster, delete the service record:

### kn
 ```bash
 kn service delete helloworld-java
 ```

### kubectl
 ```bash
 kubectl delete --filename service.yaml
 ```
