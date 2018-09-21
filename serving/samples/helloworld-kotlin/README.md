# Hello World - Kotlin sample

A simple web app written in Kotlin using Ktor that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello World: ${TARGET}". If
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/docs/blob/master/install/README.md) if you need
  to create one.
* [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step.
The following instructions recreate the source files from this folder.

1. Create a new directory and cd into it:

    ```shell
    mkdir hello
    cd hello
    ```
2. Create a file named `Main.kt` at `src/main/kotlin/com/example/hello` and copy the code block below into it:

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
        val target = System.getenv("TARGET") ?: "NOT SPECIFIED"
        embeddedServer(Netty, 8080) {
            routing {
                get("/") {
                    call.respondText("Hello World: $target", ContentType.Text.Html)
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
    FROM openjdk:8-jdk-alpine
    CMD ["gradle"]

    ENV GRADLE_HOME /opt/gradle
    ENV GRADLE_VERSION 4.10

    ARG GRADLE_DOWNLOAD_SHA256=248cfd92104ce12c5431ddb8309cf713fe58de8e330c63176543320022f59f18
    RUN set -o errexit -o nounset \
        && echo "Installing build dependencies" \
        && apk add --no-cache --virtual .build-deps \
        ca-certificates \
        openssl \
        unzip \
        \
        && echo "Downloading Gradle" \
        && wget -O gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
        \
        && echo "Checking download hash" \
        && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
        \
        && echo "Installing Gradle" \
        && unzip gradle.zip \
        && rm gradle.zip \
        && mkdir /opt \
        && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
        && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
        \
        && apk del .build-deps \
        \
        && echo "Adding gradle user and group" \
        && addgroup -S -g 1000 gradle \
        && adduser -D -S -G gradle -u 1000 -s /bin/ash gradle \
        && mkdir /home/gradle/.gradle \
        && chown -R gradle:gradle /home/gradle \
        \
        && echo "Symlinking root Gradle cache to gradle Gradle cache" \
        && ln -s /home/gradle/.gradle /root/.gradle
        
    USER gradle
    VOLUME "/home/gradle/.gradle"
    WORKDIR /home/gradle

    ADD build.gradle ./build.gradle
    ADD src ./src
    RUN gradle clean build
    ENTRYPOINT ["java","-jar","-Djava.security.egd=file:/dev/./urandom","/home/gradle/build/libs/gradle.jar"]
    ```

6. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub username.

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
   Docker Hub, run these commands replacing `{username}` with your
   Docker Hub username:

    ```shell
    # Build the container on your local machine
    docker build -t {username}/helloworld-kotlin .

    # Push the container to docker registry
    docker push {username}/helloworld-kotlin
    ```

2. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in
   the previous step. Apply the configuration using `kubectl`:

    ```shell
    kubectl apply -f service.yaml
    ```

3. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

4. To find the IP address for your service, use
   `kubectl get svc knative-ingressgateway -n istio-system` to get the ingress IP for your
   cluster. If your cluster is new, it may take sometime for the service to get assigned
   an external IP address.

    ```shell
    kubectl get svc knative-ingressgateway -n istio-system
    ```
    ```shell
    NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
    knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
    ```

5. To find the URL for your service, use
    ```shell
    kubectl get ksvc helloworld-kotlin  -o=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
    ```
    ```shell
    NAME                DOMAIN
    helloworld-kotlin   helloworld-kotlin.default.example.com
    ```

    > Note: `ksvc` is an alias for `services.serving.knative.dev`. If you have
      an older version (version 0.1.0) of Knative installed, you'll need to use
      the long name until you upgrade to version 0.1.1 or higher. See
      [Checking Knative Installation Version](../../../install/check-install-version.md)
      to learn how to see what version you have installed.

6. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}`
   with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-kotlin.default.example.com" http://{IP_ADDRESS}
    ```
    ```shell
    Hello World: Kotlin Sample v1
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```
