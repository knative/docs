# Hello World - Spring Boot Java sample

A simple web app written in Java using Spring Boot 2.0 that you can use for testing Knative.
It reads in an env variable `TARGET` and prints "Hello World: ${TARGET}!". If
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* A Kubernetes Engine cluster with Knative installed. Follow the
[installation instructions](https://github.com/knative/docs/tree/master/install) if you need to create one.
* The [Google Cloud SDK](https://cloud.google.com/sdk/docs/) is installed and initalized.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative. If you created your cluster using the Google Cloud SDK, this has already be done. If you created your cluster from the Google Cloud Console, run the following command, replacing `CLUSTER_NAME` with the name of your cluster:
    ```bash
    gcloud containers clusters get-credentials CLUSTER_NAME
    ```
* You have installed [Java SE 8 or later JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html).

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. From the console, create a new empty web project using the curl and unzip commands:

    ```shell
    curl https://start.spring.io/starter.zip \
        -d dependencies=web \
        -d name=helloworld \
        -d artifactId=helloworld \
        -o helloworld.zip
    unzip helloworld.zip
    ```

    If you don't have curl installed, you can accomplish the same by visiting the
    [Spring Initializr](https://start.spring.io/) page. Specify Artifact as `helloworld`
    and add the `Web` dependency. Then click `Generate Project`, download and unzip the
    sample archive.

1. Update the `@SpringBootApplication` class in
   `src/main/java/com/example/helloworld/HelloworldApplication.java` by adding
   a `@RestController` to handle the "/" mapping and also add a `@Value` field to
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

    	@Value("${TARGET:NOT SPECIFIED}")
    	String target;

    	@RestController
    	class HelloworldController {
    		@GetMapping("/")
    		String hello() {
    			return "Hello World: " + target;
    		}
    	}

    	public static void main(String[] args) {
    		SpringApplication.run(HelloworldApplication.class, args);
    	}
    }
    ```

1. In your project directory, create a file named `Dockerfile` and copy the code
block below into it. For detailed instructions on dockerizing a Spring Boot app,
see [Spring Boot with Docker](https://spring.io/guides/gs/spring-boot-docker/).
For additional information on multi-stage docker builds for Java see
[Creating Smaller Java Image using Docker Multi-stage Build](http://blog.arungupta.me/smaller-java-image-docker-multi-stage-build/).

    ```docker
    FROM maven:3.5-jdk-8-alpine as build
    ADD pom.xml ./pom.xml
    ADD src ./src
    RUN mvn package -DskipTests

    FROM openjdk:8-jre-alpine
    COPY --from=build /target/helloworld-*.jar /helloworld.jar
    VOLUME /tmp
    ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/helloworld.jar"]
    ```

1. Create a new file, `service.yaml` and copy the following service definition
into the file. Make sure to replace `{PROJECT_ID}` with the ID of your Google
Cloud project. If you are using docker or another container registry instead,
replace the entire image path.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: helloworld-java
      namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: gcr.io/{PROJECT_ID}/helloworld-java
                env:
                - name: TARGET
                  value: "Spring Boot Sample v1"
    ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. For this example, we'll use Google Cloud Container Builder to build the
sample into a container. To use container builder, execute the following gcloud
command:

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-java
    ```

1. After the build has completed, you can deploy the app into your cluster. Ensure
that the container image value in `service.yaml` matches the container you built in
the previous step. Apply the configuration using `kubectl`:

    ```shell
    kubectl apply -f service.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the URL and IP address for your service, use `kubectl get ing` to
list the ingress points in the cluster. It may take a few seconds for the
ingress point to be created.

    ```shell
    kubectl get ing

    NAME                        HOSTS                                       ADDRESS        PORTS     AGE
    helloworld-java-ingress     helloworld-java.default.demo-domain.com     35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result. Replace
`{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-java.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World: Spring Boot Sample v1
    ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```
