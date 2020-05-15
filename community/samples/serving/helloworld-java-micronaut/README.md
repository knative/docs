Learn how to deploy a simple web app that is written in Java and uses Micronaut.

This samples uses Docker to build locally. The app reads in a `TARGET` env
variable and then prints "Hello World: \${TARGET}!". If a value for `TARGET` is
not specified, the "NOT SPECIFIED" default value is used.

Use this sample to walk you through the steps of creating and modifying the
sample app, building and pushing your container image to a registry, and then
deploying your app to your Knative cluster.

## Before you begin

You must meet the following requirements to complete this sample:

- A version of the Knative Serving component installed and DNS configured. Follow the
  [Knative installation instructions](../../../../docs/install/README.md) if you need
  to create a Knative cluster.
- The following software downloaded and install on your loacal machine:
  - [Java SE 8 or later JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html).
  - [Micronaut 1.1](https://micronaut.io/).
  - [Docker](https://www.docker.com) for building and pushing your container
    image.
  - [curl](https://curl.haxx.se/) to test the sample app after deployment.
- A [Docker Hub](https://hub.docker.com/) account where you can push your
  container image.

**Tip**: You can clone the [Knatve/docs repo](https://github.com/knative/docs)
and then modify the source files. Alternatively, learn more by manually creating
the files youself.

## Creating and configuring the sample code

To create and configure the source files in the root of your working directory:

1. Create the `pom.xml` file:

   ```xml
     <modelVersion>4.0.0</modelVersion>
        <groupId>com.example.micronaut</groupId>
        <artifactId>helloworld</artifactId>
        <version>1.0.0-SNAPSHOT</version>
        <properties>
            <micronaut.version>1.1.0</micronaut.version>
            <jdk.version>1.8</jdk.version>
            <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
            <exec.mainClass>com.example.helloworld.Application</exec.mainClass>
        </properties>
        <dependencyManagement>
            <dependencies>
            <dependency>
                <groupId>io.micronaut</groupId>
                <artifactId>micronaut-bom</artifactId>
                <version>${micronaut.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            </dependencies>
        </dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>io.micronaut</groupId>
                <artifactId>micronaut-inject</artifactId>
                <scope>compile</scope>
            </dependency>
            <dependency>
                <groupId>io.micronaut</groupId>
                <artifactId>micronaut-validation</artifactId>
                <scope>compile</scope>
            </dependency>
            <dependency>
                <groupId>io.micronaut</groupId>
                <artifactId>micronaut-runtime</artifactId>
                <scope>compile</scope>
            </dependency>
            <dependency>
                <groupId>io.micronaut</groupId>
                <artifactId>micronaut-http-client</artifactId>
                <scope>compile</scope>
            </dependency>
            <dependency>
                <groupId>io.micronaut</groupId>
                <artifactId>micronaut-http-server-netty</artifactId>
                <scope>compile</scope>
            </dependency>
                <dependency>
                <groupId>ch.qos.logback</groupId>
                <artifactId>logback-classic</artifactId>
                <version>1.2.3</version>
                <scope>runtime</scope>
            </dependency>
        </dependencies>

   <build>
       <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.1.0</version>
                <executions>
                <execution>
                    <phase>package</phase>
                    <goals>
                    <goal>shade</goal>
                    </goals>
                    <configuration>
                    <transformers>
                        <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <mainClass>${exec.mainClass}</mainClass>
                        </transformer>
                        <transformer implementation="org.apache.maven.plugins.shade.resource.ServicesResourceTransformer"/>
                    </transformers>
                    </configuration>
                </execution>
                </executions>
            </plugin>
       </plugins>
   </build>
   </project>
   ```

1. Create the `HelloWorldController.java` file in the
   `src/main/java/com/example/helloworld` directory. The
   `[ROOT]/src/main/java/com/example/helloworld/HelloWorldController.java` file
   handles requests to the root URI `/`.

   ```java
    package com.example.helloworld;

    import io.micronaut.http.MediaType;
    import io.micronaut.http.annotation.Controller;
    import io.micronaut.http.annotation.Get;

    @Controller("/")
    public class HelloWorldController {

        @Get(value = "/", produces = MediaType.TEXT_PLAIN)
        public String index() {
            String target = System.getenv("TARGET");
            if (target == null) {
                target = "NOT SPECIFIED";
            }
            return "Hello World: " + target;
        }
    }
   ```

1. The Micronaut application is configured via
   `src/main/resources/application.yml`:

   ```yaml
   micronaut:
     application:
       name: helloworld-java-micronaut
     server:
       port: ${PORT:8080}
   ```

1. Create the `Dockerfile` file:

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
   COPY --from=builder /app/target/helloworld-1.0.0-SNAPSHOT.jar /helloworld.jar

   # Run the web service on container startup.
   CMD ["java","-jar","/helloworld.jar"]
   ```

1. Create the `service.yaml` file. You must specify your Docker Hub username in
   `{username}`. You can also configure the `TARGET`, for example you can modify
   the `Micronaut Sample v1` value.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-java-micronaut
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-java-micronaut
             env:
               - name: TARGET
                 value: "Micronaut Sample v1"
   ```

## Building and deploying the sample

To build a container image, push your image to the registry, and then deploy
your sample app to your cluster:

1. Use Docker to build your container image and then push that image to your
   Docker Hub registry. You must replace the `{username}` variables in the
   following commands with your Docker Hub username.

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-java-micronaut .

   # Push the container to docker registry
   docker push {username}/helloworld-java-micronaut
   ```

1. Now that your container image is in the registry, you can deploy it to your
   Knative cluster by running the `kubectl apply` command:

   ```shell
   kubectl apply --filename service.yaml
   ```

   Result: A service name `helloworld-java-micronaut` is created in your cluster
   along with the following resources:

   - A new immutable revision for the version of the app that you just deployed.
   - The following networking resources are created for your app:
     - route
     - ingress
     - service
     - load balancer
   - Auto scaling is enable to allow your pods to scale up to meet traffic, and
     also back down to zero when there is no traffic.

## Testing the sample app

To verify that your sample app has been successfully deployed:

1. Retrieve the URL for your service, by running the following `kubectl get`
   command:

   ```shell
   kubectl get ksvc helloworld-java-micronaut  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example result:

   ```shell
   NAME                          URL
   helloworld-java-micronaut     http://helloworld-java-micronaut.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-java-micronaut.default.1.2.3.4.xip.io
   ```

   Example result:

   ```shell
    Hello World: Micronaut Sample v1
   ```

Congratulations on deploying your sample Java app to Knative!

## Removing the sample app deployment

To remove the sample app from your cluster, run the following `kubectl delete`
command:

```shell
kubectl delete --filename service.yaml
```
