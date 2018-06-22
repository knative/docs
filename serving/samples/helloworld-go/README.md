# Hello World - Go

A simple web app written in Go that you can use for testing.
It reads in an env variable 'TARGET' and prints "Hello World: ${TARGET}!" if
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* You have a Kubernetes cluster with Knative installed. Follow the [installation instructions](https://github.com/knative/install/) if you need to do this. 
* You have installed and initalized [Google Cloud SDK](https://cloud.google.com/sdk/docs/) and have created a project in Google Cloud.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative.

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world
apps are generally more useful if you build them step-by-step. The
following instructions recreate the source files from this folder.

1. Create a new file named `helloworld.go` and paste the following code. This code creates a basic web server which listens on port 8080:

    ```go
    package main

    import (
      "flag"
      "fmt"
      "log"
      "net/http"
      "os"
    )

    func handler(w http.ResponseWriter, r *http.Request) {
      log.Print("Hello world received a request.")
      target := os.Getenv("TARGET")
      if target == "" {
        target = "NOT SPECIFIED"
      }
      fmt.Fprintf(w, "Hello World: %s!\n", target)
    }

    func main() {
      flag.Parse()
      log.Print("Hello world sample started.")

      http.HandleFunc("/", handler)
      http.ListenAndServe(":8080", nil)
    }
    ```

1. In your project directory, create a file named `Dockerfile` and copy the code block below into it. For detailed instructions on dockerizing a Go app, see [Deploying Go servers with Docker](https://blog.golang.org/docker).

    ```docker
    # Start from a Debian image with the latest version of Go installed
    # and a workspace (GOPATH) configured at /go.
    FROM golang

    # Copy the local package files to the container's workspace.
    ADD . /go/src/github.com/knative/docs/helloworld

    # Build the helloworld command inside the container.
    # (You may fetch or manage dependencies here,
    # either manually or with a tool like "godep".)
    RUN go install github.com/knative/docs/helloworld

    # Run the helloworld command by default when the container starts.
    ENTRYPOINT /go/bin/helloworld

    # Document that the service listens on port 8080.
    EXPOSE 8080
    ```

1. Create a new file, `service.yaml` and copy the following service definition into the file. Make sure to replace `{PROJECT_ID}` with the ID of your Google Cloud project. If you are using docker or another container registry instead, replace the entire image path.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: gcr.io/{PROJECT_ID}/helloworld-go
                env:
                - name: TARGET
                  value: "Go Sample v1"
    ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample folder) you're ready to build and deploy the sample app.

1. For this example, we'll use Google Cloud Container Builder to build the sample into a container. To use container builder, execute the following gcloud command:

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-go
    ```

1. After the build has completed, you can deploy the app into your cluster. Ensure that the container image value in `service.yaml` matches the container you build in the previous step. Apply the configuration using kubectl:

    ```shell
    kubectl apply -f service.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the URL and IP address for your service, use kubectl to list the ingress points in the cluster. You may need to wait a few seconds for the ingress point to be created, if you don't see it right away.

    ```shell
    kubectl get ing --watch

    NAME                        HOSTS                                                                                   ADDRESS        PORTS     AGE
    helloworld-go-ingress   helloworld-go.default.demo-domain.com,*.helloworld-go.default.demo-domain.com   35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-go.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World: NOT SPECIFIED
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```
