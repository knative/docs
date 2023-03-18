# Hello World - Spring Boot Java

This guide describes the steps required to create the `helloworld-java-spring` sample app and deploy it to your cluster.

The sample app reads a `TARGET` environment variable, and prints `Hello ${TARGET}!`. If `TARGET` is not specified, `World` is used as the default value.

You can also download a working copy of the sample, by running the following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-java-spring
```

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine, and a Docker Hub account configured.
- Optional. The Knative CLI client [`kn`](https://github.com/knative/client/releases) can be used to simplify the deployment. Alternatively, you can use `kubectl` to apply YAML resource files.

## Building the sample app

1. From the console, create a new, empty web project by using the `curl` and `unzip`
   commands:

    ```bash
    curl https://start.spring.io/starter.zip \
       -d dependencies=web \
       -d name=helloworld \
       -d artifactId=helloworld \
       -o helloworld.zip
    unzip helloworld.zip
    ```

   If you don't have `curl` installed, you can accomplish the same by visiting the
   [Spring Initializr](https://start.spring.io/) page. Specify Artifact as
   `helloworld` and add the `Web` dependency. Then click **Generate Project**,
   download and unzip the sample archive.

1. Update the `SpringBootApplication` class in
   `src/main/java/com/example/helloworld/HelloworldApplication.java` by adding a
   `@RestController` to handle the "/" mapping and also add a `@Value` field to
   provide the `TARGET` environment variable:

    ```java
    package com.example.helloworld;

    import org.springframework.beans.factory.annotation.Value;
    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    import org.springframework.web.bind.annotation.GetMapping;
    import org.springframework.web.bind.annotation.RestController;

    @SpringBootApplication
    public class HelloworldApplication {

     @Value("${TARGET:World}")
     String target;

     @RestController
     class HelloworldController {
       @GetMapping("/")
       String hello() {
         return "Hello " + target + "!";
       }
     }

     public static void main(String[] args) {
       SpringApplication.run(HelloworldApplication.class, args);
     }
    }
    ```

1. Run the application locally:

    ```bash
    mvn wrapper:wrapper
    ./mvnw package && java -jar target/helloworld-0.0.1-SNAPSHOT.jar
    ```

   Go to `http://localhost:8080/` to see your `Hello World!` message.

1. In your project directory, create a file named `Dockerfile` and copy the following code block into it:

    ```docker
    # Use the official maven/Java 8 image to create a build artifact: https://hub.docker.com/_/maven
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
    COPY --from=builder /app/target/helloworld-*.jar /helloworld.jar

    # Run the web service on container startup.
    CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/helloworld.jar"]

    ```
   For detailed instructions on dockerizing a Spring Boot app, see [Spring Boot with Docker](https://spring.io/guides/gs/spring-boot-docker/).

   For additional information on multi-stage docker builds for Java see [Creating Smaller Java Image using Docker Multi-stage Build](http://blog.arungupta.me/smaller-java-image-docker-multi-stage-build/).

1. Use Docker to build the sample code into a container, then push the container to the Docker registry:

    ```bash
    # Build the container on your local machine
    docker build -t {username}/helloworld-java-spring .

    # Push the container to docker registry
    docker push {username}/helloworld-java-spring
    ```
   Where `{username}` is your Docker Hub username.


## Deploying the app

After the build has completed and the container is pushed to Docker Hub, you can deploy the app into your cluster.

During the creation of a Service, Knative performs the following steps:

- Create a new immutable revision for this version of the app.
- Network programming to create a Route, ingress, Service, and load balancer for your app.
- Automatically scale your pods up and down, including scaling down to zero active pods.

Choose one of the following methods to deploy the app:

### yaml

1. Create a new file named `service.yaml` and copy the following service definition
   into the file:

    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-java-spring
      namespace: default
    spec:
      template:
        spec:
          containers:
            - image: docker.io/{username}/helloworld-java-spring
              env:
                - name: TARGET
                  value: "Spring Boot Sample v1"
    ```
    Where `{username}` is your Docker Hub username.

    **Note:** Ensure that the container image value in `service.yaml` matches the container you built in the previous step.

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f service.yaml
    ```

### kn

1. With `kn` you can deploy the service with

    ```bash
    kn service create helloworld-java-spring --image=docker.io/{username}/helloworld-java-spring --env TARGET="Spring Boot Sample v1"
    ```

    This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.

## Verification

1. Find the domain URL for your service:

    - For kubectl, run:

    ```bash
    kubectl get ksvc helloworld-java-spring  --output=custom-columns=NAME:.metadata.name,URL:.status.url
    ```

    Example:

    ```bash
    NAME                      URL
    helloworld-java-spring    http://helloworld-java-spring.default.1.2.3.4.xip.io
    ```

    - For kn, run:

    ```bash
    kn service describe helloworld-java-spring -o url
    ```

    Example:

    ```bash
    http://helloworld-java-spring.default.1.2.3.4.xip.io
    ```

1. Make a request to your app and observe the result. Replace
   the following URL with the URL returned in the previous command.

    Example:

    ```bash
    curl http://helloworld-java-spring.default.1.2.3.4.sslip.io
    Hello Spring Boot Sample v1!

    # Even easier with kn:
    curl $(kn service describe helloworld-java-spring -o url)
    ```

    **Tip:** Add `-v` option to get more detail if the `curl` command fails.

## Deleting the app

To remove the sample app from your cluster, delete the service:

### kubectl
```bash
kubectl delete -f service.yaml
```

### kn
```bash
kn service delete helloworld-java-spring
```
