A simple web app written in Swift that you can use for testing. The app reads in
an env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET is not
specified, the app uses "World" as the TARGET.

## Prerequisites

- You must have a Kubernetes cluster with Knative installed and DNS configured.
  If you need to create a cluster, follow the
  [installation instructions](../../../../docs/install/README.md).
- You must have [Docker](https://www.docker.com) installed and running on your
  local machine, and a Docker Hub account configured (used for container
  registry).

## Recreating the sample code

While you can clone all of the code from this directory, it might be more useful
if you build this app step-by-step. The following instructions recreate the
source files from this folder.

1. Create a the `Package.swift` to declare your package and its dependencies.
   This app uses [Swifter](https://github.com/httpswift/swifter), a tiny http
   server engine for Swift.

   ```swift
    // swift-tools-version:4.0

    import PackageDescription

    let package = Package(
        name: "HelloSwift",
        dependencies: [
            .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.4.5"))
        ],
        targets: [
            .target(
            name: "HelloSwift",
            dependencies: ["Swifter"],
            path: "./Sources")
        ]
    )
   ```

1. Add the web server code to a file named `main.swift` in a
   `Sources/HelloSwift/` folder:

   ```swift
    import Swifter
    import Dispatch
    import Foundation

    let server = HttpServer()
    server["/"] = { r in
        let target = ProcessInfo.processInfo.environment["TARGET"] ?? "World"
        return HttpResponse.ok(.html("Hello \(target)"))
    }

    let semaphore = DispatchSemaphore(value: 0)
    do {
        let port = UInt16(ProcessInfo.processInfo.environment["PORT"] ?? "8080")
        try server.start(port!, forceIPv4: true)
        print("Server has started ( port = \(try server.port()) ). Try to connect now...")
        semaphore.wait()
    } catch {
        print("Server start error: \(error)")
        semaphore.signal()
    }
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it.

   ```Dockerfile
    # Use the official Swift image.
    # https://hub.docker.com/_/swift
    FROM swift:4.2

    # Copy local code to the container image.
    WORKDIR /app
    COPY . .

    # Install dependencies and build.
    RUN swift build -c release

    # Run the web service on container startup.
    CMD [ ".build/release/HelloSwift"]
   ```

1. Create a new file, `service.yaml`, and copy the following service definition
   into the file. Replace `{username}` with your Docker Hub username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-swift
     namespace: default
   spec:
     template:
       spec:
       containers:
         - image: docker.io/{username}/helloworld-swift
           env:
             - name: TARGET
           value: "Swift"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands, replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-swift .

   # Push the container to docker registry
   docker push {username}/helloworld-swift
   ```

1. After the build has completed and the container is pushed to Docker Hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in the `service.yaml` file matches the container you built in the previous
   step. Apply the configuration using the `kubectl` command:

   ```shell
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative performs the following steps:

   - Creates a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balancing
     for your app.
   - Automatically scales your pods up and down (including to zero active pods).

1. To find the URL for your service, use the following command:

   ```
   kubectl get ksvc helloworld-swift  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME               URL
   helloworld-swift   http://helloworld-swift.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-swift.default.1.2.3.4.xip.io
   Hello Swift
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
