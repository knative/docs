---
title: "Hello World - Spring Boot Java"
linkTitle: "Java (Spring)"
weight: 1
type: "docs"
---

This guide describes the steps required to create the `helloworld-java-spring` sample app and deploy it to your cluster.

The sample app reads a TARGET environment variable, and prints Hello ${TARGET}!. If TARGET is not specified, World is used as the default value.

You can also download a working copy of the sample, by running the following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-java-spring
```

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured.
- (optional) The Knatice CLI client [kn](https://github.com/knative/client/releases) that simplifies the deployment. Alternative you can also use `kubectl` and apply resource files directly.

## Build

1. From the console, create a new empty web project using the curl and unzip
   commands:

   ```shell
   curl https://start.spring.io/starter.zip \
       -d dependencies=web \
       -d name=helloworld \
       -d artifactId=helloworld \
       -o helloworld.zip
   unzip helloworld.zip
   ```

   If you don't have curl installed, you can accomplish the same by visiting the
   [Spring Initializr](https://start.spring.io/) page. Specify Artifact as
   `helloworld` and add the `Web` dependency. Then click `Generate Project`,
   download and unzip the sample archive.

1. Update the `SpringBootApplication` class in
   `src/main/java/com/example/helloworld/HelloworldApplication.java` by adding a
   `@RestController` to handle the "/" mapping and also add a `@Value` field to
   provide the TARGET environment variable:

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

   ```shell
   ./mvnw package && java -jar target/helloworld-0.0.1-SNAPSHOT.jar
   ```

   Go to `http://localhost:8080/` to see your `Hello World!` message.

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing a Spring Boot
   app, see
   [Spring Boot with Docker](https://spring.io/guides/gs/spring-boot-docker/).
   For additional information on multi-stage docker builds for Java see
   [Creating Smaller Java Image using Docker Multi-stage Build](http://blog.arungupta.me/smaller-java-image-docker-multi-stage-build/).

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

   # Use AdoptOpenJDK for base image.
   # It's important to use OpenJDK 8u191 or above that has container support enabled.
   # https://hub.docker.com/r/adoptopenjdk/openjdk8
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM adoptopenjdk/openjdk8:jdk8u202-b08-alpine-slim

   # Copy the jar to the production image from the builder stage.
   COPY --from=builder /app/target/helloworld-*.jar /helloworld.jar

   # Run the web service on container startup.
   CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/helloworld.jar"]
   ```
Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-java-spring .

   # Push the container to docker registry
   docker push {username}/helloworld-java-spring
   ```
## Deploying

1. After the build has completed and the container is pushed to Docker Hub, you
   can deploy the app into your cluster.

   {{< tabs name="helloworld_java_spring" default="kn" >}}
   {{% tab name="yaml" %}}

   1. Create a new file, `service.yaml` and copy the following service definition
      into the file. Make sure to replace `{username}` with your Docker Hub
      username.

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
                    value: "Java Spring Sample v1"
      ```

   Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```shell
   kubectl apply --filename service.yaml
   ```

   {{< /tab >}}
   {{% tab name="kn" %}}

   With `kn` you can deploy the service with

   ```shell
   kn service create helloworld-java-spring --image=docker.io/{username}/helloworld-java-spring --env TARGET="Java Spring Sample v1"
   ```

   This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.

   {{< /tab >}}
   {{< /tabs >}}

   During the creation of your service, Knative performs the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

## Verification

1. Run one of the followings commands to find the domain URL for your service.

   {{< tabs name="service_url" default="kn" >}}
   {{% tab name="kubectl" %}}
   ```shell
   kubectl get ksvc helloworld-java-spring  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```shell
   NAME                      URL
   helloworld-java-spring    http://helloworld-java-spring.default.1.2.3.4.xip.io
   ```

   {{< /tab >}}
   {{% tab name="kn" %}}

   ```shell
   kn service describe helloworld-java-spring -o url
   ```

   Example:

   ```shell
   http://helloworld-java-spring.default.1.2.3.4.xip.io
   ```
   {{< /tab >}}
   {{< /tabs >}}

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   Example:

   ```shell
   curl http://helloworld-java-spring.default.1.2.3.4.xip.io
   Hello Java Spring Sample v1!

   # Even easier with kn:
   curl $(kn service describe helloworld-java-spring -o url)
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing

To remove the sample app from your cluster, delete the service record.

{{< tabs name="service_url" default="kn" >}}
{{% tab name="kubectl" %}}
```shell
kubectl delete --filename service.yaml
```
{{< /tab >}}
{{% tab name="kn" %}}
```shell
kn service delete helloworld-java-spring
```
{{< /tab >}}
{{< /tabs >}}
