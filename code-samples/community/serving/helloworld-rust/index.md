# Hello World - Rust

A simple web app written in Rust that you can use for testing. It reads in an
env variable `TARGET` and prints "Hello \${TARGET}!". If

TARGET is not specified, it will use "World" as the TARGET.

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [Knative installation instructions](https://knative.dev/docs/install/) if you need to create
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
   edition = "2018"
   publish = false

   [dependencies]
   hyper = { version = "0.14.7", features = ["full"]}
   tokio = { version = "1.5.0", features = ["macros", "rt-multi-thread"] }
   pretty_env_logger = "0.4.0"
   ```

1. Create a `src` folder, then create a new file named `main.rs` in that folder
   and paste the following code. This code creates a basic web server which
   listens on port 8080:

   ```rust
   use hyper::{
    server::conn::AddrStream,
    service::{make_service_fn, service_fn},
    Body, Request, Response, Server,
   };
   use std::convert::Infallible;
   use std::env;

   #[tokio::main]
   async fn main() {
      pretty_env_logger::init();

      let mut port: u16 = 8080;
      match env::var("PORT") {
         Ok(p) => {
               match p.parse::<u16>() {
                  Ok(n) => {
                     port = n;
                  }
                  Err(_e) => {}
               };
         }
         Err(_e) => {}
      };
      let addr = ([0, 0, 0, 0], port).into();

      let make_svc = make_service_fn(|_socket: &AddrStream| async move {
         Ok::<_, Infallible>(service_fn(move |_: Request<Body>| async move {
               let mut hello = "Hello ".to_string();
               match env::var("TARGET") {
                  Ok(target) => {
                     hello.push_str(&target);
                  }
                  Err(_e) => hello.push_str("World"),
               };
               Ok::<_, Infallible>(Response::new(Body::from(hello)))
         }))
      });

      let server = Server::bind(&addr).serve(make_svc);

      println!("Listening on http://{}", addr);
      if let Err(e) = server.await {
         eprintln!("server error: {}", e);
      }
   }
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it.

   ```docker
   # Use the official Rust image.
   # https://hub.docker.com/_/rust
   FROM rust:1.51.0

   # Copy local code to the container image.
   WORKDIR /usr/src/app
   COPY . .

   # Install production dependencies and build a release artifact.
   RUN cargo install --path .

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

   ```bash
   # Build the container on your local machine
   docker build -t {username}/helloworld-rust .

   # Push the container to docker registry
   docker push {username}/helloworld-rust
   ```

1. After the build has completed and the container is pushed to Docker Hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```bash
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, enter:

   ```bash
   kubectl get ksvc helloworld-rust  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-rust     http://helloworld-rust.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```bash
   curl http://helloworld-rust.default.1.2.3.4.sslip.io
   Hello World!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
