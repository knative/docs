# Hello World - Rust Nightly sample

A simple web app written in Rust (nightly version) that you can use for testing. 
It reads in an env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET 
is not specified, it will use "World" as the TARGET. It uses [Rocket](https://rocket.rs) 
for the webserver, which currently only works with 
[Rust Nightly](https://doc.rust-lang.org/1.5.0/book/nightly-rust.html). 
When you're done following these instructions, you will have a very small production-ready container based on the Docker scratch image, only containing what's needed to run 
the application.

## Prerequisites

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/docs/blob/master/install/README.md)
  if you need to create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Create a new folder for the example, go inside it, and initialize a new empty Rust binary         project:
   
   ```shell
   mkdir helloworld-rust-nightly
   cd helloworld-rust-nightly
   cargo init
   ```
   
1. The folder will now have the following two important files in it which you need to modify:
   
   `Cargo.toml`  
   `src/main.rs`  
   
1. Add the following to the `[dependencies]` section of the `Cargo.toml` file:
   
   ```toml
   [dependencies]
   rocket = "0.4"
   ```
   
1. Edit the `src/main.rs` file so that it contains the following:
   
   ```rust
   #![feature(proc_macro_hygiene, decl_macro)]
   #[macro_use] extern crate rocket;
   use std::env;
   
   #[get("/")]
   fn hello() -> String {
     let mut res = String::from("Hello ");
     
     match env::var("TARGET") {
       Ok(target) => {res.push_str(&target);},
       Err(_e) => {res.push_str("World")},
     };
     
     res
   }
   
   fn main() {
     rocket::ignite()
       .mount("/", routes![hello])
       .launch();
   }
   ```
   
1. Create a new file called `Rocket.toml`, and add the following content to it:
   
   ```toml
   [development]
   address = "localhost"
   port = 8080
   keep_alive = 5
   log = "normal"
   limits = { forms = 32768 }
   
   [staging]
   address = "0.0.0.0"
   port = 8080
   keep_alive = 5
   log = "normal"
   limits = { forms = 32768 }

   [production]
   address = "0.0.0.0"
   port = 8080
   keep_alive = 5
   log = "critical"
   limits = { forms = 32768 }
   ```

1. Now you can try running the example locally if you want to see if it works:
   
   ```shell
   cargo run
   ```
   
1. Next make two Dockerfiles. The first one builds and caches the
   Rust dependencies, and the second one is a multi-stage build to get the
   smallest possible container capable of running the example application. 
   Create a file named `Dockerfile-deps` and copy the following 
   into it:
   
   ```docker
   # ---------- Dependencies Container ----------
   # This container uses rust nightly with the 
   # x86_64-unknown-linux-musl target, and it
   # includes some necessary C libraries that
   # we can statically link against.
   FROM clux/muslrust AS deps
   
   # Set working directory.
   WORKDIR /
   
   # Create a new empty shell project.
   RUN USER=root cargo init --bin --name helloworld-rust-nightly
   
   # Copy over the manifests.
   COPY Cargo* ./
   
   # Build and cache the dependencies, then remove 
   # hello world file.
   RUN cargo build --release && \
     rm src/*.rs
   # --------------------
   ```
   
1. Create a file named `Dockerfile` and copy following into it, making
   sure to replace `{username}` with your Docker Hub username, in the 
   `FROM` line:
   
   ```docker
   # ---------- Build Container ----------
   # This uses our prebuilt dependencies
   # container as a base to speed up builds.
   # It is used to build our app.
   FROM docker.io/{username}/helloworld-rust-nightly:deps AS build
   
   # Set working directory.
   WORKDIR /
   
   # Copy the source code.
   COPY ./src ./src
   
   # Create a user account to run the app with, 
   # remove files from the shell project,
   # build the app, and strip the binary to make
   # it smaller.
   RUN adduser --disabled-password --gecos "" appuser && \
     rm target/x86_64-unknown-linux-musl/release/deps/helloworld_rust_nightly* && \
     cargo build --release && \
     strip target/x86_64-unknown-linux-musl/release/helloworld-rust-nightly
   # --------------------
   
   # ---------- Production Container ----------
   # Uses the smallest docker container as a base.
   # This container only holds what's strictly
   # needed to run our app.
   FROM scratch
   
   # Set working directory.
   WORKDIR /
   
   # Enable the user account we created in the other
   # container.
   COPY --from=build /etc/passwd /etc/
   
   # Use the ca-certs from the other container,
   # which we need if we want to be able to put
   # an https proxy in front of the service.
   COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
   
   # Copy over the app we built in the other container.
   COPY --from=build target/x86_64-unknown-linux-musl/release/helloworld-rust-nightly ./
   
   # Copy the rocket config file.
   COPY Rocket.toml ./
   
   # Become a regular user.
   USER appuser
   
   # Specify the server environment by setting
   # this environment variable to one of:
   # development, staging, or production
   # If unset, it will default to production.
   ENV ROCKET_ENV ${ROCKET_ENV:-production}
   
   # Specify the port the server should listen
   # on by setting this environment variable.
   # We must honour the $PORT environment variable
   # if it is set, otherwise we must fall back
   # to port 8080.
   ENV ROCKET_PORT ${PORT:-8080}
   
   # Expose the server on the world on the 
   # specified port.
   EXPOSE $ROCKET_PORT
   
   # Run our app.
   CMD ["./helloworld-rust-nightly"]
   # --------------------
   ```
   
1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: Service
   metadata:
   name: helloworld-rust-nightly
   namespace: default
   spec:
   runLatest:
     configuration:
     revisionTemplate:
       spec:
       container:
         image: docker.io/{username}/helloworld-rust-nightly:latest
         env:
           - name: TARGET
         value: "Rust Nightly Sample v1"
   ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, enter these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the dependencies container on your local machine
   docker build -t {username}/helloworld-rust-nightly:deps -f Dockerfile-deps .

   # Push the dependencies container to docker registry
   docker push {username}/helloworld-rust-nightly:deps

   # Build the production container on your local machine
   docker build -t {username}/helloworld-rust-nightly:latest .

   # Push the production container to docker registry
   docker push {username}/helloworld-rust-nightly:latest
   ```

1. From now on you can just build and push the production container, and it will
   build really fast. The builds will get slower over time as more dependencies 
   become out-of-date, so when it gets too slow, you can rebuild and push the 
   dependencies container again, and then the production container builds will get 
   fast again. After the build has completed and the container is pushed to Docker 
   Hub, you can deploy the app into your cluster. Ensure that the container image 
   value in `service.yaml` matches the container you built in the previous step. 
   Apply the configuration using `kubectl`:

   ```shell
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the IP address for your service, enter
   `kubectl get svc knative-ingressgateway --namespace istio-system` to get the
   ingress IP for your cluster. If your cluster is new, it may take sometime for
   the service to get asssigned an external IP address.

   ```shell
   kubectl get svc knative-ingressgateway --namespace istio-system

   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

   ```

1. To find the URL for your service, enter:

   ```
   kubectl get ksvc helloworld-rust-nightly  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
   NAME                        DOMAIN
   helloworld-rust-nightly     helloworld-rust-nightly.default.example.com
   ```

1. Now you can make a request to your app and see the result. Replace
   `{IP_ADDRESS}` with the address you see returned in the previous step.

   ```shell
   curl -H "Host: helloworld-rust-nightly.default.example.com" http://{IP_ADDRESS}
   Hello World!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
