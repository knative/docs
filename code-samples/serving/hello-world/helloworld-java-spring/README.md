# Hello World - Spring Boot Java

This guide describes the steps required to create the `helloworld-java-spring` sample app and deploy it to your cluster.

The sample app reads a `TARGET` environment variable, and prints `Hello ${TARGET}!`. If `TARGET` is not specified, `World` is used as the default value. An explicitly empty `TARGET` produces `Hello !`.

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

Use the working copy downloaded above, including its `pom.xml`. This sample uses
Java 25 LTS, Spring Boot 4.1.2 and Maven 3.9.16. Local builds require a Java 25 JDK
and Maven 3.9.16 installed. The included Dockerfile supplies both tools, so Docker
builds do not require a local Java or Maven installation.

Version and support information: [Spring Boot requirements](https://docs.spring.io/spring-boot/4.1/system-requirements.html),
[Spring support policy](https://spring.io/support-policy),
[Temurin support](https://adoptium.net/support), and
[Maven release history](https://maven.apache.org/docs/history.html).

The source and configuration are already checked in. Continue with **Run the
application locally**, or build the included Dockerfile directly.

1. The [application](src/main/java/com/example/helloworld/HelloworldApplication.java)
   uses a `@RestController` to handle the "/" mapping and a `@Value` field to
   read the `TARGET` environment variable.

1. The HTTP port is configured in
   [application.properties](src/main/resources/application.properties):

    ```properties
    server.port = ${PORT:8080}
    ```

   Knative supplies `PORT` at runtime. When running locally without `PORT`, the
   application listens on port 8080.

1. **Run the application locally**:

    ```bash
    mvn package && java -jar target/helloworld-0.0.1-SNAPSHOT.jar
    ```

   Go to `http://localhost:8080/` to see your `Hello World!` message.

   To try a custom greeting and port, stop the application and run:

    ```bash
    TARGET="Spring Boot Sample v1" PORT=8085 java -jar target/helloworld-0.0.1-SNAPSHOT.jar
    ```

   In another terminal, `curl http://localhost:8085/` returns
   `Hello Spring Boot Sample v1!`.

1. The included [Dockerfile](Dockerfile) builds the executable JAR in
   a Maven/Java 25 stage, then runs it in a Temurin Java 25 JRE image.
   For detailed instructions on dockerizing a Spring Boot app, see [Spring Boot with Docker](https://spring.io/guides/gs/spring-boot-docker/).

   For additional information on multi-stage docker builds for Java see [Creating Smaller Java Image using Docker Multi-stage Build](http://blog.arungupta.me/smaller-java-image-docker-multi-stage-build/).

1. Use Docker to build the sample code into a container, then push the container to the Docker registry:

    ```bash
    # Build and push the container on your local machine.
    docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-java-spring" --push .
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

1. Edit the included [service.yaml](service.yaml), replacing `{username}` in
   the container image with your Docker Hub username. The manifest sets
   `TARGET` to `Spring Boot Sample v1`.

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
    helloworld-java-spring    http://helloworld-java-spring.default.1.2.3.4.sslip.io
    ```

    - For kn, run:

    ```bash
    kn service describe helloworld-java-spring -o url
    ```

    Example:

    ```bash
    http://helloworld-java-spring.default.1.2.3.4.sslip.io
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
