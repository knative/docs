# Hello world - .NET Core

A simple web app written in C# using .NET 6.0 that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET
is not specified, it will use "World" as the TARGET.

Do the following steps to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-csharp
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- You have installed [.NET Core SDK 6.0](https://www.microsoft.com/net/).

## Recreating the sample code

1. First, make sure you have
   [.NET SDK 6.0](https://www.microsoft.com/net/) installed:

   ```bash
   dotnet --version
   6.0.101
   ```

1. From the console, create a new empty web project using the dotnet command:

   ```bash
   dotnet new web -o helloworld-csharp
   ```

1. Update the `Program.cs` to read the port and define the serving url:

   ```csharp
   var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
   var url = $"http://0.0.0.0:{port}";

   app.Run(url);
   ```

1. Update the `Program.cs` to read and return the `TARGET` environment variable:

   ```csharp
   var target = Environment.GetEnvironmentVariable("TARGET") ?? "World";

   app.MapGet("/", () => $"Hello {target}!");
   ```

1. In your project directory, create a file named `Dockerfile` and copy the following code
   block into it. For detailed instructions on dockerizing an ASP.NET Core
   app, see
   [Docker images for ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/building-net-docker-images).

   ```docker
   # Use Microsoft's official build .NET image.
   FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
   WORKDIR /app

   # Copy csproj and restore as distinct layers
   COPY *.csproj ./
   RUN dotnet restore

   # Copy everything else and build
   COPY . ./
   RUN dotnet publish -c Release -o out

   # Build runtime image
   FROM mcr.microsoft.com/dotnet/aspnet:6.0
   WORKDIR /app
   COPY --from=build-env /app/out .

   # Run the web service on container startup.
   ENTRYPOINT ["dotnet", "helloworld-csharp.dll"]
   ```

1. Create a `.dockerignore` file to ensure that any files related to a local
   build do not affect the container that you build for deployment.

   ```ignore
   Dockerfile
   README.md
   **/obj/
   **/bin/
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-csharp
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-csharp
             env:
               - name: TARGET
                 value: "C# Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build the container on your local machine
   docker build -t {username}/helloworld-csharp .

   # Push the container to docker registry
   docker push {username}/helloworld-csharp
   ```

1. After the build has completed and the container is pushed to docker hub, you
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

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-csharp  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-csharp   http://helloworld-csharp.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

   ```bash
   curl http://helloworld-csharp.default.1.2.3.4.sslip.io
   Hello C# Sample v1!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
