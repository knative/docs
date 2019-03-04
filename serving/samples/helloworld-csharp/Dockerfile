# Use Microsoft's official .NET image.
# https://hub.docker.com/r/microsoft/dotnet
FROM microsoft/dotnet:2.2-sdk

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

# Make sure the app binds to $PORT
ENV ASPNETCORE_URLS http://*:${PORT}

# Run the web service on container startup.
CMD ["dotnet", "out/helloworld-csharp.dll"]
