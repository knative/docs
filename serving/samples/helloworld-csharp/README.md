# .NET Core Hello World sample

This sample application shows how to create a hello world application in C# using .NET Core 2.0.

## Steps to recreate the sample

1. Install the [.NET Core SDK 2.1](https://www.microsoft.com/net/core).
1. Install [docker](https://www.docker.com).
1. From the console, create a new empty web project:

    ```shell
    dotnet new web -o helloworld-csharp
    ```

1. Update `CreateWebHostBuilder` in `Program.cs` to use port 8080 as the serving port:

    ```csharp
    public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
        WebHost.CreateDefaultBuilder(args)
            .UseStartup<Startup>().UseUrls("http://0.0.0.0:8080");
    ```
1. Create a new file named `Dockerfile` and copy the block below into the file. For detailed instructions see [dockerizing a .NET core app](https://docs.microsoft.com/en-us/dotnet/core/docker/docker-basics-dotnet-core#dockerize-the-net-core-application).

    ```docker
    FROM microsoft/dotnet:2.1-sdk
    WORKDIR /app

    # copy csproj and restore as distinct layers
    COPY *.csproj ./
    RUN dotnet restore

    # copy and build everything else
    COPY . ./
    RUN dotnet publish -c Release -o out
    ENTRYPOINT ["dotnet", "out/helloworld-csharp.dll"]
    ```

1. Run `docker build . -t helloworld-csharp` to build a container image.
1. Run `docker tag helloworld-csharp gcr.io/${PROJECT_ID}/helloworld-csharp` then `docker push gcr.io/${PROJECT_ID}/helloworld-csharp` to publish your container image to Google Container Registry.
1. 