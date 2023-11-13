# Use Microsoft's official build .NET image.
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env

# Add a user so the server will run as a non-root user.
RUN addgroup -g 1000 appuser && \
    adduser -S -u 1000 -G appuser appuser

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0

# Add a user so the server will run as a non-root user.
RUN addgroup -g 1000 appuser && \
    adduser -S -u 1000 -G appuser appuser

WORKDIR /app
COPY --from=build-env /app/out .

USER appuser

# Run the web service on container startup.
ENTRYPOINT ["dotnet", "helloworld-csharp.dll"]
