# Hello World - Eclipse Vert.x sample

A simple web app written in Java using Eclipse Vertx. that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello World: ${TARGET}!". If
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/docs/blob/master/install/README.md) if you need
  to create one.
* [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
* You have installed [Java SE 8 or later JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html).

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Create a new file named `pom.xml` and paste the following code:

    ```xml
    <project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                      http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example.vertx</groupId>
    <artifactId>helloworld</artifactId>
    <version>1.0.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>io.vertx</groupId>
            <artifactId>vertx-core</artifactId>
            <version>${version.vertx}</version>
        </dependency>
        <dependency>
            <groupId>io.vertx</groupId>
            <artifactId>vertx-rx-java2</artifactId>
            <version>${version.vertx}</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.2.0</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <transformers>
                                <transformer
                                        implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <manifestEntries>
                                        <Main-Class>io.vertx.core.Launcher</Main-Class>
                                        <Main-Verticle>com.example.helloworld.HelloWorld</Main-Verticle>
                                    </manifestEntries>
                                </transformer>
                            </transformers>
                            <artifactSet/>
                        </configuration>
                    </execution>
                </executions>
            </plugin>

        </plugins>
    </build>
    <properties>
        <version.vertx>3.5.4</version.vertx>
    </properties>
    </project>
    ```

1. Create a `src/main/java/com/example/helloworld` folder, then create a new file named `HelloWorld.java` in that folder
   and paste the following code. This code creates a basic web server which
   listens on port 8080:

   ```java
    package com.example.helloworld;

    import io.reactivex.Flowable;
    import io.vertx.reactivex.core.AbstractVerticle;
    import io.vertx.reactivex.core.http.HttpServer;
    import io.vertx.reactivex.core.http.HttpServerRequest;

    public class HelloWorld extends AbstractVerticle {

        public void start() {

            final HttpServer server = vertx.createHttpServer();
            final Flowable<HttpServerRequest> requestFlowable = server.requestStream().toFlowable();

            requestFlowable.subscribe(httpServerRequest -> {

                String target = System.getenv("TARGET");
                if (target == null) {
                    target = "NOT SPECIFIED";
                }

                httpServerRequest.response().setChunked(true)
                        .putHeader("content-type", "text/plain")
                        .setStatusCode(200) // OK
                        .end("Hello World: " + target);
            });

            server.listen(8080);
        }
    }
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it:

    ```docker
    FROM fabric8/s2i-java:2.0
    ENV JAVA_APP_DIR=/deployments
    EXPOSE 8080
    COPY target/helloworld-1.0.0-SNAPSHOT.jar /deployments/
    ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub username.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: helloworld-vertx
      namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: docker.io/{username}/helloworld-vertx
                env:
                - name: TARGET
                  value: "Eclipse Vert.x Sample v1"
    ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your
   Docker Hub username:

    ```shell
    # Build the container on your local machine
    docker build -t {username}/helloworld-vertx .

    # Push the container to docker registry
    docker push {username}/helloworld-vertx
    ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in
   the previous step. Apply the configuration using `kubectl`:

    ```shell
    kubectl apply --filename service.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balancer for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the IP address for your service, use
   `kubectl get svc knative-ingressgateway -n istio-system` to get the ingress IP for your
   cluster. If your cluster is new, it may take sometime for the service to get asssigned
   an external IP address.

    ```shell
    kubectl get svc knative-ingressgateway --namespace istio-system

    NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
    knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

    ```

1. To find the URL for your service, use
    ```
    kubectl get services.serving.knative.dev helloworld-vertx  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
    NAME                DOMAIN
    helloworld-vertx     helloworld-vertx.default.example.com
    ```

1. Now you can make a request to your app to see the result. Replace
   `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-vertx.default.example.com" http://{IP_ADDRESS}
    Hello World: Eclipse Vert.x Sample v1
    ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
