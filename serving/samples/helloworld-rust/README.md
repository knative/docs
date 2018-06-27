# Hello World -Rust

A simple web app in Rust that you can use for testing.
It reads in an env variable 'TARGET' and prints "Hello World: ${TARGET}" if
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* You have a Kubernetes cluster with Knative installed. Follow the [installation instructions](https://github.com/knative/install/) if you need to do this.
* You have installed and initalized [Google Cloud SDK](https://cloud.google.com/sdk/docs/) and have created a project in Google Cloud.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative.

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world
apps are generally more useful if you build them step-by-step. The
following instructions recreate the source files from this folder.

1. Create a new file named `Cargo.toml` and paste the following code. This code 

    ```toml
    [package]
    name = "hellorust"
    version = "0.0.0"
    publish = false

    [dependencies]
    hyper = "0.12.3"
    pretty_env_logger = "0.2.3"
    ```

1. In an `src` folder, Create a new file named `main.rs` and paste the following code. This code creates a basic web server which listens on port 8080:

    ```rust
    #![deny(warnings)]
    extern crate hyper;
    extern crate pretty_env_logger;

    use hyper::{Body, Response, Server};
    use hyper::service::service_fn_ok;
    use hyper::rt::{self, Future};
    use std::env;

    fn main() {
        pretty_env_logger::init();

        let addr = ([0, 0, 0, 0], 8080).into();

        let new_service = || {
            service_fn_ok(|_| {

                let mut hello = "Hello world: ".to_string();
                match env::var("TARGET") {
                    Ok(target) => {hello.push_str(&target);},
                    Err(_e) => {hello.push_str("NOT SPECIFIED")},
                };

                Response::new(Body::from(hello))
            })
        };

        let server = Server::bind(&addr)
            .serve(new_service)
            .map_err(|e| eprintln!("server error: {}", e));

        println!("Listening on http://{}", addr);

        rt::run(server);
    }
    ```

1. In your project directory, create a file named `Dockerfile`.

    ```docker
    FROM rust:1.27.0

    WORKDIR /usr/src/app
    COPY . .

    RUN cargo install

    EXPOSE 8080

    CMD ["hellorust"]
    ```

1. Create a new file, `service.yaml` and copy the following service definition into the file. Make sure to replace `{PROJECT_ID}` with the ID of your Google Cloud project. If you are using docker or another container registry instead, replace the entire image path.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
    name: helloworld-rust
    namespace: default
    spec:
    runLatest:
        configuration:
        revisionTemplate:
            spec:
            container:
                image: gcr.io/{PROJECT_ID}/helloworld-rust
                env:
                - name: TARGET
                value: "Rust Sample v1"
    ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample folder) you're ready to build and deploy the sample app.

1. Clone this repository and navigate into the `serving/samples/helloworld-rust` directory.

1. For this example, we'll use Google Cloud Container Builder to build the sample into a container. To use container builder, execute the following gcloud command:

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-rust
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

    NAME                        HOSTS                                       ADDRESS        PORTS     AGE
    helloworld-rust-ingress   helloworld-rust.default.demo-domain.com   35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-rust.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World: NOT SPECIFIED
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```