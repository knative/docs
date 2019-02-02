
A simple web app written in Kotlin using [Ktor](https://ktor.io/) that you can
use for testing. It reads in an env variable `TARGET` and prints "Hello
\${TARGET}". If TARGET is not specified, it will use "World" as the TARGET.

## Prerequisites

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../install/)
  if you need to create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Create a new directory and cd into it:

   ```shell
   mkdir hello
   cd hello
   ```

2. Create a file named `Main.kt` at `src/main/kotlin/com/example/hello` and copy
   the code block below into it:

   ```shell
   mkdir -p src/main/kotlin/com/example/hello
   ```

   ```kotlin
   package com.example.hello

   import io.ktor.application.*
   import io.ktor.http.*
   import io.ktor.response.*
   import io.ktor.routing.*
   import io.ktor.server.engine.*
   import io.ktor.server.netty.*

   fun main(args: Array<String>) {
       val target = System.getenv("TARGET") ?: "World"
       val port = System.getenv("PORT") ?: "8080"
       embeddedServer(Netty, port.toInt()) {
           routing {
               get("/") {
                   call.respondText("Hello $target", ContentType.Text.Html)
               }
           }
       }.start(wait = true)
   }
   ```

3. Switch back to `hello` directory

4. Create a new file, `build.gradle` and copy the following setting

   ```groovy
   buildscript {
       ext.kotlin_version = '1.2.61'
       ext.ktor_version = '0.9.4'

       repositories {
           mavenCentral()
       }
       dependencies {
           classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
       }
   }

   apply plugin: 'java'
   apply plugin: 'kotlin'
   apply plugin: 'application'

   sourceCompatibility = 1.8
   compileKotlin {
       kotlinOptions.jvmTarget = "1.8"
   }

   compileTestKotlin {
       kotlinOptions.jvmTarget = "1.8"
   }

   repositories {
       jcenter()
       maven { url "https://dl.bintray.com/kotlin/ktor" }
   }

   mainClassName = 'com.example.hello.MainKt'

   jar {
       manifest {
           attributes 'Main-Class': mainClassName
       }
       from { configurations.compile.collect { it.isDirectory() ? it : zipTree(it) } }
   }

   dependencies {
       compile "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version"
       compile "io.ktor:ktor-server-netty:$ktor_version"
       testCompile group: 'junit', name: 'junit', version: '4.12'
   }
   ```

5. Create a file named `Dockerfile` and copy the code block below into it.

   ```docker
   # Use the official gradle image to create a build artifact.
   # https://hub.docker.com/_/gradle
   FROM gradle as builder

   # Copy local code to the container image.
   COPY build.gradle .
   COPY src ./src

   # Build a release artifact.
   RUN gradle clean build --no-daemon

   # Use the Official OpenJDK image for a lean production stage of our multi-stage build.
   # https://hub.docker.com/_/openjdk
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM openjdk:8-jre-alpine

   # Copy the jar to the production image from the builder stage.
   COPY --from=builder /home/gradle/build/libs/gradle.jar /helloworld.jar

   # Service must listen to $PORT environment variable.
   # This default value facilitates local development.
   ENV PORT 8080

   # Run the web service on container startup.
   CMD [ "java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "/helloworld.jar" ]
   ```

6. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: Service
   metadata:
     name: helloworld-kotlin
     namespace: default
   spec:
     runLatest:
       configuration:
         revisionTemplate:
           spec:
             container:
               image: docker.io/{username}/helloworld-kotlin
               env:
                 - name: TARGET
                   value: "Kotlin Sample v1"
   ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-kotlin .

   # Push the container to docker registry
   docker push {username}/helloworld-kotlin
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
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the IP address for your service, use
   `kubectl get service knative-ingressgateway --namespace istio-system` to get
   the ingress IP for your cluster. If your cluster is new, it may take sometime
   for the service to get assigned an external IP address.

   ```shell
   kubectl get service knative-ingressgateway --namespace istio-system

   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

   # Now you can assign the external IP address to the env variable.
   export IP_ADDRESS=<EXTERNAL-IP column from the command above>

   # Or just execute:
   export IP_ADDRESS=$(kubectl get svc $INGRESSGATEWAY \
     --namespace istio-system \
     --output jsonpath="{.status.loadBalancer.ingress[*].ip}")
   ```

1. To find the URL for your service, use

   ```shell
   kubectl get ksvc helloworld-kotlin  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain

   NAME                DOMAIN
   helloworld-kotlin   helloworld-kotlin.default.example.com
   ```

1. Now you can make a request to your app to see the result. Presuming,
   the IP address you got in the step above is in the `${IP_ADDRESS}`
   env variable:

   ```shell
   curl -H "Host: helloworld-kotlin.default.example.com" http://${IP_ADDRESS}
   ```

   ```terminal
   Hello Kotlin Sample v1
   ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
