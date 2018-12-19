# Hello World - Eclipse Vert.x sample

Learn how to deploy a simple web app that is written in Java and uses Eclipse
Vert.x. This samples uses Docker to build locally. The app reads in a `TARGET`
env variable and then prints "Hello World: \${TARGET}!". If a value for `TARGET`
is not specified, the "NOT SPECIFIED" default value is used.

Use this sample to walk you through the steps of creating and modifying the
sample app, building and pushing your container image to a registry, and then
deploying your app to your Knative cluster.

## Before you begin

You must meet the following requirements to complete this sample:

- A version of the Knative Serving component installed and running on your
  Kubernetes cluster. Follow the
  [Knative installation instructions](https://github.com/knative/docs/blob/master/install/README.md)
  if you need to create a Knative cluster.
- The following software downloaded and install on your loacal machine:
  - [Java SE 8 or later JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html).
  - [Eclipse Vert.x v3.5.4](https://vertx.io/).
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

1. Create the `HelloWorld.java` file in the
   `src/main/java/com/example/helloworld` directory. The
   `[ROOT]/src/main/java/com/example/helloworld/HelloWorld.java` file creates a
   basic web server that listens on port `8080`.

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

1. Create the `Dockerfile` file:

   ```docker
   FROM fabric8/s2i-java:2.0
   ENV JAVA_APP_DIR=/deployments
   EXPOSE 8080
   COPY target/helloworld-1.0.0-SNAPSHOT.jar /deployments/
   ```

1. Create the `service.yaml` file. You must specify your Docker Hub username in
   `{username}`. You can also configure the `TARGET`, for example you can modify
   the `Eclipse Vert.x Sample v1` value.

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

To build a container image, push your image to the registry, and then deploy
your sample app to your cluster:

1. Use Docker to build your container image and then push that image to your
   Docker Hub registry. You must replace the `{username}` variables in the
   following commands with your Docker Hub username.

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-vertx .

   # Push the container to docker registry
   docker push {username}/helloworld-vertx
   ```

1. Now that your container image is in the registry, you can deploy it to your
   Knative cluster by running the `kubectl apply` command:

   ```shell
   kubectl apply --filename service.yaml
   ```

   Result: A service name `helloworld-vertx` is created in your cluster along
   with the following resources:

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

1. View your the ingress IP address of your service by running the following
   `kubectl get` command. Note that it may take sometime for the new service to
   get asssigned an external IP address, especially if your cluster was newly
   created.

   ```shell
   kubectl get svc knative-ingressgateway --namespace istio-system
   ```

   Example result:

   ```shell
   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
   ```

1. Retrieve the URL for your service, by running the following `kubectl get`
   command:

   ```shell
   kubectl get services.serving.knative.dev helloworld-vertx  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
   ```

   Example result:

   ```shell
   NAME                DOMAIN
   helloworld-vertx     helloworld-vertx.default.example.com
   ```

1. Run the following `curl` command to test your deployed sample app. You must
   replace the `{IP_ADDRESS}` variable the URL that your retrieve in the
   previous step.

   ```shell
   curl -H "Host: helloworld-vertx.default.example.com" http://{IP_ADDRESS}
   ```

   Example result:

   ```shell
    Hello World: Eclipse Vert.x Sample v1
   ```

Congtratualations on deploying your sample Java app to Knative!

## Removing the sample app deployment

To remove the sample app from your cluster, run the following `kubectl delete`
command:

```shell
kubectl delete --filename service.yaml
```
