A simple [JAX-RS REST API](https://github.com/jax-rs) application that is
written in Java and uses [Quarkus](https://quarkus.io/).

This samples uses Docker to build locally. The app reads in a `TARGET` env
variable and then prints "Hello World: \${TARGET}!". If a value for `TARGET` is
not specified, the "NOT SPECIFIED" default value is used.

## Before you begin

You must meet the following requirements to run this sample:

- Have a Kubernetes cluster running with the Knative Serving component
  installed. For more information, see the
  [Knative instruction guides](https://github.com/knative/docs/blob/master/docs/install/README.md).
- An installed version of the following tools:
  - [Docker](https://www.docker.com)
  - [Java SE 8 or later JDK](https://www.eclipse.org/openj9/)
  - [Maven](https://maven.apache.org/download.cgi)
- A [Docker Hub account](https://hub.docker.com/) to which you are able to
  upload your sample's container image.

## Getting the code

You can either clone a working copy of the sample code from the repository, or
following the steps in the
[Recreating the sample code](#recreating-the-sample-code) to walk through the
steps of updating all the files.

### Cloning the sample code

Use this method to clone and then immediate run the sample. To clone the sample
code, run the following commands:

```
git clone -b "{{< branch >}}" https://github.com/knative/docs.git knative/docs
cd knative/docs/community/samples/serving/helloworld-java-quarkus
```

You are now ready to [run the sample locally](#locally-testing-your-sample).

### Recreating the sample code

Use the following steps to obtain an incomplete copy of the sample code for
which you update and create the necessary build and configuration files:

1. From the console, create a new empty web project using the Maven archetype
   commands:

   ```shell
   mvn io.quarkus:quarkus-maven-plugin:0.13.3:create \
    -DprojectGroupId=com.redhat.developer.demos \
    -DprojectArtifactId=helloworld-java-quarkus \
    -DclassName="com.redhat.developer.demos.GreetingResource" \
    -Dpath="/"
   ```

1. Update the `GreetingResource` class in
   `src/main/java/com/redhat/developer/demos/GreetingResource.java` to handle
   the "/" mapping and also add a `@ConfigProperty` field to provide the TARGET
   environment variable:

   ```java
   package com.redhat.developer.demos;

   import javax.ws.rs.GET;
   import javax.ws.rs.Path;
   import javax.ws.rs.Produces;
   import javax.ws.rs.core.MediaType;
   import org.eclipse.microprofile.config.inject.ConfigProperty;

   @Path("/")
   public class GreeterResource {
     @ConfigProperty(name = "TARGET", defaultValue="World")
     String target;

     @GET
     @Produces(MediaType.TEXT_PLAIN)
     public String greet() {
       return "Hello " + target + "!";
     }
   }
   ```

1. Update `src/main/resources/application.properties` to configuration the
   application to default to port 8080, but allow the port to be overriden by
   the `PORT` environmental variable:

   ```
   # Configuration file
   # key = value

   quarkus.http.port=${PORT:8080}
   ```

1. Update `src/test/java/com/redhat/developer/demos/GreetingResourceTest.java`
   test to reflect the change:

   ```java
   package com.redhat.developer.demos;

   import io.quarkus.test.junit.QuarkusTest;
   import org.junit.jupiter.api.Test;

   import static io.restassured.RestAssured.given;
   import static org.hamcrest.CoreMatchers.is;

   @QuarkusTest
   public class GreetingResourceTest {

     @Test
     public void testHelloEndpoint() {
         given()
           .when().get("/")
           .then()
             .statusCode(200)
             .body(is("Hello World!"));
     }
   }

   ```

1. Remove `src/main/resources/META-INF/resources/index.html` file since it's
   unncessary for this example.

   ```shell
   rm src/main/resources/META-INF/resources/index.html
   ```

1. Remove `.dockerignore` file since it's unncessary for this example.

   ```shell
   rm .dockerignore
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it.

   ```docker
   FROM quay.io/rhdevelopers/quarkus-java-builder:graal-1.0.0-rc15 as builder
   COPY . /project
   WORKDIR /project
   # uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
   # ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
   # e.g.
   #ARG MAVEN_MIRROR_URL=http://192.168.64.1:8081/nexus/content/groups/public

   RUN /usr/local/bin/entrypoint-run.sh mvn -DskipTests clean package

   FROM fabric8/java-jboss-openjdk8-jdk:1.5.4
   USER jboss
   ENV JAVA_APP_DIR=/deployments

   COPY --from=builder /project/target/lib/* /deployments/lib/
   COPY --from=builder /project/target/*-runner.jar /deployments/app.jar

   ENTRYPOINT [ "/deployments/run-java.sh" ]
   ```

   If you want to build Quarkus native image, then copy the following code block
   in to file called `Dockerfile.native`

   ```docker
   FROM quay.io/rhdevelopers/quarkus-java-builder:graal-1.0.0-rc15 as builder
   COPY . /project
   # uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
   # ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
   # e.g.
   # ARG MAVEN_MIRROR_URL=http://192.168.64.1:8081/nexus/content/groups/public

   RUN /usr/local/bin/entrypoint-run.sh mvn -DskipTests clean package -Pnative

   FROM registry.fedoraproject.org/fedora-minimal

   COPY --from=builder /project/target/helloworld-java-quarkus-runner /app

   ENTRYPOINT [ "/app" ]
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-java-quarkus
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-java-quarkus
             env:
               - name: TARGET
                 value: "Quarkus Sample v1"
   ```

## Locally testing your sample

1. Run the application locally:

   ```shell
   ./mvnw compile quarkus:dev
   ```

   Go to `http://localhost:8080/` to see your `Hello World!` message.

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-java-quarkus .

   # (OR)
   # Build the container on your local machine - Quarkus native mode
   docker build -t {username}/helloworld-java-quarkus -f Dockerfile.native .

   # Push the container to docker registry
   docker push {username}/helloworld-java-quarkus
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
   kubectl get ksvc helloworld-java-quarkus

   NAME                     URL
   helloworld-java-quarkus  http://helloworld-java-quarkus.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-java-quarkus.default.1.2.3.4.xip.io

   Namaste Knative World!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
