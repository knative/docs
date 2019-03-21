# Hello World - Quarkus Java sample

A simple JAX-RS REST API application written in Java using [QuarkusIO](https://quarkus.io/).

It uses an ENV variable `MESSAGE_PREFIX`(defaults to value `Hello`) and prints a message of format
`${MESSAGE_PREFIX} Knative World!`.

## Prerequisites

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/docs/blob/master/docs/install/README.md)
  if you need to create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- You have installed
  [Java SE 8 or later JDK](https://www.eclipse.org/openj9/).

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. From the console, create a new empty web project using the maven archetype
   commands:

   ```shell
   mvn io.quarkus:quarkus-maven-plugin:0.13.1:create \
    -DprojectGroupId=com.redhat.developer.demos \
    -DprojectArtifactId=helloworld-java-quarkus \
    -DclassName="com.redhat.developer.demos.GreetingResource" \
    -Dpath="/"
   ```

1. Update the `GreetingResource` class in
   `src/main/java/com/redhat/developers/demo/GreetingResource.java` with content as:

   ```java
   package com.redhat.developer.demos;

   import javax.inject.Inject;
   import javax.ws.rs.GET;
   import javax.ws.rs.Path;
   import javax.ws.rs.Produces;
   import javax.ws.rs.core.MediaType;
   import org.eclipse.microprofile.config.inject.ConfigProperty;

   @Path("/")
   public class GreeterResource {

     @Inject
     GreetingService greetingService;

     @ConfigProperty(name = "message.prefix")
     String messagePrefix;

     @GET
     @Produces(MediaType.TEXT_PLAIN)
     @Path("/")
     public String greet() {
       return greetingService.greet(messagePrefix);
     }

     @GET
     @Produces(MediaType.TEXT_PLAIN)
     @Path("/healthz")
     public String health() {
       return "OK";
     }
   }

   ```

1. Add a new class the `GreetingService` class in
   `src/main/java/com/redhat/developers/demo/GreetingService.java` with content as:

   ```java
    package com.redhat.developer.demos;

    import javax.enterprise.context.ApplicationScoped;

    @ApplicationScoped
    public class GreetingService {

      private static final String RESPONSE_STRING_FORMAT = "%s Knative World!";

      public String greet(String prefix) {
        return String.format(RESPONSE_STRING_FORMAT, prefix);
      }

    }

   ```

1. Update the pom.xml with the following content:

```xml
  <?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.redhat.developer.demos</groupId>
  <artifactId>helloworld-java-quarkus</artifactId>
  <version>1.0-SNAPSHOT</version>
  <name>Quarkus Hello World</name>
  <description>A helloworld based on https://quarkus.io</description>
  <properties>
    <quarkus.version>0.13.1</quarkus.version>
    <surefire.version>2.22.0</surefire.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.8</maven.compiler.source>
    <maven.compiler.target>1.8</maven.compiler.target>
    <rest-assured.version>3.3.0</rest-assured.version>
    <build-helper-maven-plugin.version>3.0.0</build-helper-maven-plugin.version>
  </properties>
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-bom</artifactId>
        <version>${quarkus.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
  <build>
    <finalName>${project.artifactId}</finalName>
    <plugins>
      <plugin>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>${surefire.version}</version>
        <configuration>
          <systemPropertyVariables>
            <quarkus.http.test-port>8080</quarkus.http.test-port>
          </systemPropertyVariables>
          <systemProperties>
            <java.util.logging.manager>org.jboss.logmanager.LogManager</java.util.logging.manager>
          </systemProperties>
        </configuration>
      </plugin>
      <plugin>
        <artifactId>maven-failsafe-plugin</artifactId>
        <version>${surefire.version}</version>
        <executions>
          <execution>
            <goals>
              <goal>integration-test</goal>
              <goal>verify</goal>
            </goals>
            <configuration>
              <systemProperties>
                <native.image.path>${project.build.directory}/${project.build.finalName}-runner</native.image.path>
                <quarkus.http.test-port>8080</quarkus.http.test-port>
              </systemProperties>
            </configuration>
          </execution>
        </executions>
      </plugin>
      <plugin>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-maven-plugin</artifactId>
        <version>${quarkus.version}</version>
        <executions>
          <execution>
            <goals>
              <goal>build</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>build-helper-maven-plugin</artifactId>
        <version>${build-helper-maven-plugin.version}</version>
        <executions>
          <execution>
            <id>add-resource</id>
            <phase>generate-resources</phase>
            <goals>
              <goal>add-resource</goal>
            </goals>
            <configuration>
              <resources>
                <resource>
                  <directory>${project.basedir}/src/main/knative</directory>
                  <targetPath>${project.build.directory}/knative</targetPath>
                  <filtering>true</filtering>
                </resource>
              </resources>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
  <dependencies>
    <dependency>
      <groupId>io.quarkus</groupId>
      <artifactId>quarkus-resteasy</artifactId>
    </dependency>
    <dependency>
      <groupId>io.quarkus</groupId>
      <artifactId>quarkus-junit5</artifactId>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>io.rest-assured</groupId>
      <artifactId>rest-assured</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <profiles>
    <profile>
      <id>native</id>
      <build>
        <plugins>
          <plugin>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-maven-plugin</artifactId>
            <version>${quarkus.version}</version>
            <executions>
              <execution>
                <goals>
                  <goal>native-image</goal>
                </goals>
                <configuration>
                  <enableHttpUrlHandler>true</enableHttpUrlHandler>
                </configuration>
              </execution>
            </executions>
          </plugin>
        </plugins>
      </build>
    </profile>
  </profiles>
</project>
```

1. Run the application locally:

   ```shell
   ./mvnw compile quarkus:dev
   ```

   Go to `http://localhost:8080/` to see your `Hello World!` message.

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it.

   ```docker

   FROM quay.io/quarkus/centos-quarkus-maven:graalvm-1.0.0-rc13 as nativebuilder
   COPY . /work

   # uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
   # ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
   # e.g.
   #ARG MAVEN_MIRROR_URL=http://192.168.64.1:8081/nexus/content/groups/public

   RUN cd /workspace && /usr/local/bin/entrypoint-run.sh mvn -DskipTests clean package -Pnative

   COPY --from=nativebuilder /workspace/helloworld-java-quarkus-runner /application
   EXPOSE 8080
   ENTRYPOINT ["/application"]
   CMD ["-Dquarkus.http.host=0.0.0.0"]

   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: Service
   metadata:
     name: helloworld-java-quarkus
     namespace: default
   spec:
     runLatest:
       configuration:
         revisionTemplate:
           spec:
             container:
               image: docker.io/{username}/helloworld-java-quarkus
               env:
                 - name: MESSAGE_PREFIX
                   value: "Namaste"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

We will be using hub.docker.com as the container registry, if you dont have an account yet have one created before proceeding further.

### Using Docker

Use Docker to build the sample code into a container. To build and push with
Docker Hub, run these commands replacing `{username}` with your Docker Hub
username:

```shell

# We will use the docker daemon of the minikube
eval $(minikube docker-env)

# Build the container on your local machine
docker build -t {username}/helloworld-java-quarkus .

# Push the container to docker registry
docker push {username}/helloworld-java-quarkus
```

After the build has completed and the container is pushed to docker hub, you
can deploy the app into your cluster. Ensure that the container image value
in `service.yaml` matches the container you built in the previous step. Apply
the configuration using `kubectl`:

```shell
kubectl apply --filename service.yaml
```

### Using Knative Build

The sources also has a knative build file called `quarkus-build.yaml`, that will perform docker less container image build using [buildah](https://buildah.io)

Run the following command replacing `{username}` with your Docker Hub username and `{password}` with Docker Hub password:

```shell
mvn -Dcontainer.registry.url='https://index.docker.io' \
    -Dcontainer.registry.user='{username}' \
    -Dcontainer.registry.password='{password}' \
    -Dgit.source.revision='master' \
    -Dgit.source.repo.url='https://github.com/knative/docs.git' \
    -Dapp.container.image='docker.io/${container.registry.user}/helloworld-java-quarkus' \
    -Dapp.context.dir='docs/serving/samples/helloworld-java-quarkus' \
    clean process-resources
# create all the resources
kubectl apply -f target/knative
```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balancer
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the IP address for your service, use. If your cluster is new, it may
   take sometime for the service to get assigned an external IP address.

   ```shell
   # In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
   INGRESSGATEWAY=knative-ingressgateway

   # The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
   # Use `istio-ingressgateway` instead, since `knative-ingressgateway`
   # will be removed in Knative v0.4.
   if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
   fi

   kubectl get svc $INGRESSGATEWAY --namespace istio-system

   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

   # Now you can assign the external IP address to the env variable.
   export IP_ADDRESS=<EXTERNAL-IP column from the command above>

   # Or just execute:
   export IP_ADDRESS=$(kubectl get svc $INGRESSGATEWAY \
     --namespace istio-system \
     --output jsonpath="{.status.loadBalancer.ingress[*].ip}")
   ```

1. To find the URL for your service, use

   ```shell
   kubectl get ksvc helloworld-java-quarkus

   NAME                DOMAIN
   helloworld-java-quarkus     helloworld-java-quarkus.default.example.com

   # Or simply:
   export DOMAIN_NAME=$(kubectl get ksvc helloworld-java-quarkus \
     --output jsonpath={.status.domain}
   ```

1. Now you can make a request to your app to see the result. Presuming,
   the IP address you got in the step above is in the `${IP_ADDRESS}`
   env variable:

   ```shell
   curl -H "Host: ${DOMAIN_NAME}" http://${IP_ADDRESS}

   Namaste Knative World!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```

If you have used Knative build technique to build the container image
then run the following commands to clean up:

```shell
kubectl delete --filename target/knative
```
