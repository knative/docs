A simple web app written in Rust that you can use for testing. It reads in an
env variable `TARGET` and prints "Hello \${TARGET}!". If

TARGET is not specified, it will use "World" as the TARGET.

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../docs/install/README.md) if you need to create
  one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Create a new file named `Cargo.toml` and paste the following code:

   ```toml
   [package]
   name = "hellorust"
   version = "0.0.0"
   publish = false

   [dependencies]
   hyper = "0.12.3"
   pretty_env_logger = "0.2.3"
   ```

1. Create a `src` folder, then create a new file named `main.rs` in that folder
   and paste the following code. This code creates a basic web server which
   listens on port 8080:

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

       let mut port: u16 = 8080;
       match env::var("PORT") {
           Ok(p) => {
               match p.parse::<u16>() {
                   Ok(n) => {port = n;},
                   Err(_e) => {},
               };
           }
           Err(_e) => {},
       };
       let addr = ([0, 0, 0, 0], port).into();

       let new_service = || {
           service_fn_ok(|_| {

               let mut hello = "Hello ".to_string();
               match env::var("TARGET") {
                   Ok(target) => {hello.push_str(&target);},
                   Err(_e) => {hello.push_str("World")},
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

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it.

   ```docker
   # Use the official Rust image.
   # https://hub.docker.com/_/rust
   FROM rust:1.27.0

   # Copy local code to the container image.
   WORKDIR /usr/src/app
   COPY . .

   # Install production dependencies and build a release artifact.
   RUN cargo install

   # Run the web service on container startup.
   CMD ["hellorust"]
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-rust
     namespace: default
   spec:
     template:
       spec:
       containers:
         - image: docker.io/{username}/helloworld-rust
           env:
             - name: TARGET
           value: "Rust Sample v1"
   ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, enter these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-rust .

   # Push the container to docker registry
   docker push {username}/helloworld-rust
   ```

1. After the build has completed and the container is pushed to Docker Hub, you
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

1. To find the URL for your service, enter:

   ```
   kubectl get ksvc helloworld-rust  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-rust     http://helloworld-rust.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-rust.default.1.2.3.4.xip.io
   Hello World!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
