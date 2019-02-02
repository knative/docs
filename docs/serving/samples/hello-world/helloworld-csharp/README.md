
A simple web app written in C# using .NET Core 2.1 that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET
is not specified, it will use "World" as the TARGET.

## Prerequisites

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../../install/)
  if you need to create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- You have installed [.NET Core SDK 2.1](https://www.microsoft.com/net/core).

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. From the console, create a new empty web project using the dotnet command:

   ```shell
   dotnet new web -o helloworld-csharp
   ```

1. Update the `CreateWebHostBuilder` definition in `Program.cs` by adding
   `.UseUrls()` to define the serving port:

   ```csharp
   public static IWebHostBuilder CreateWebHostBuilder(string[] args)
   {
       string port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
       string url = String.Concat("http://0.0.0.0:", port);

       return WebHost.CreateDefaultBuilder(args)
           .UseStartup<Startup>().UseUrls(url);
   }
   ```

1. Update the `app.Run(...)` statement in `Startup.cs` to read and return the
   TARGET environment variable:

   ```csharp
   app.Run(async (context) =>
   {
       var target = Environment.GetEnvironmentVariable("TARGET") ?? "World";
       await context.Response.WriteAsync($"Hello {target}\n");
   });
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing a .NET core
   app, see
   [dockerizing a .NET core app](https://docs.microsoft.com/en-us/dotnet/core/docker/docker-basics-dotnet-core#dockerize-the-net-core-application).

    ```docker
    # Use Microsoft's official .NET image.
    # https://hub.docker.com/r/microsoft/dotnet
    FROM microsoft/dotnet:2.1-sdk

    # Install production dependencies.
    # Copy csproj and restore as distinct layers.
    WORKDIR /app
    COPY *.csproj .
    RUN dotnet restore

    # Copy local code to the container image.
    COPY . .

    # Build a release artifact.
    RUN dotnet publish -c Release -o out

    # Service must listen to $PORT environment variable.
    # This default value facilitates local development.
    ENV PORT 8080

    # Run the web service on container startup.
    CMD ["dotnet", "out/helloworld-csharp.dll"]
    ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: Service
   metadata:
     name: helloworld-csharp
     namespace: default
   spec:
     runLatest:
       configuration:
         revisionTemplate:
           spec:
             container:
               image: docker.io/{username}/helloworld-csharp
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

1. To find the IP address for your service, use these commands to get the
   ingress IP for your cluster. If your cluster is new, it may take sometime for
   the service to get asssigned an external IP address.

   ```shell
   # In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
   INGRESSGATEWAY=knative-ingressgateway

   # The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
   # Use `istio-ingressgateway` instead, since `knative-ingressgateway`
   # will be removed in Knative v0.4.
   if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
   fi

   kubectl get svc $INGRESSGATEWAY --namespace istio-system

   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
   ```

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-csharp  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
   NAME                DOMAIN
   helloworld-csharp   helloworld-csharp.default.example.com
   ```

1. Now you can make a request to your app to see the result. Replace
   `{IP_ADDRESS}` with the address you see returned in the previous step.

   ```shell
   curl -H "Host: helloworld-csharp.default.example.com" http://{IP_ADDRESS}
   Hello World!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
