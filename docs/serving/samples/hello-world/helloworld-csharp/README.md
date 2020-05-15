A simple web app written in C# using .NET Core 3.1 that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET
is not specified, it will use "World" as the TARGET.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-csharp
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- You have installed [.NET Core SDK 3.1](https://www.microsoft.com/net/core).

## Recreating the sample code

1. First, make sure you have
   [.NET Core SDK 3.1](https://www.microsoft.com/net/core) installed:

   ```shell
   dotnet --version
   3.1.100
   ```

1. From the console, create a new empty web project using the dotnet command:

   ```shell
   dotnet new web -o helloworld-csharp
   ```

1. Update the `CreateHostBuilder` definition in `Program.cs` by adding
   `.UseUrls()` to define the serving port:

   ```csharp
   public static IHostBuilder CreateHostBuilder(string[] args)
   {
       string port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
       string url = String.Concat("http://0.0.0.0:", port);

      return Host.CreateDefaultBuilder(args)
          .ConfigureWebHostDefaults(webBuilder =>
          {
              webBuilder.UseStartup<Startup>().UseUrls(url);
          });
   }
   ```

1. Update the `app.UseEndpoints(...)` statement in `Startup.cs` to read and return the
   TARGET environment variable:

   ```csharp
   app.UseEndpoints(endpoints =>
   {
      endpoints.MapGet("/", async context =>
      {
          var target = Environment.GetEnvironmentVariable("TARGET") ?? "World";
          await context.Response.WriteAsync($"Hello {target}!\n");
      });
   });
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing an ASP.NET Core
   app, see
   [Docker images for ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/building-net-docker-images).

   ```docker
   # Use Microsoft's official build .NET image.
   # https://hub.docker.com/_/microsoft-dotnet-core-sdk/
   FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS build
   WORKDIR /app
 
   # Install production dependencies.
   # Copy csproj and restore as distinct layers.
   COPY *.csproj ./
   RUN dotnet restore

   # Copy local code to the container image.
   COPY . ./
   WORKDIR /app

   # Build a release artifact.
   RUN dotnet publish -c Release -o out

   # Use Microsoft's official runtime .NET image.
   # https://hub.docker.com/_/microsoft-dotnet-core-aspnet/
   FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine AS runtime
   WORKDIR /app
   COPY --from=build /app/out ./

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

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-csharp .

   # Push the container to docker registry
   docker push {username}/helloworld-csharp
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

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-csharp  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-csharp   http://helloworld-csharp.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-csharp.default.1.2.3.4.xip.io
   Hello C# Sample v1!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
