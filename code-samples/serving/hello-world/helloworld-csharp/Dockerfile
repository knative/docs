# Use Microsoft's official build .NET image.
FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build-env

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create and change to the app directory.
WORKDIR "/home/${USER}/app"

# Add a user so the server will run as a non-root user.
RUN addgroup -g $USER_GID $USER && \
    adduser -u $USER_UID -G $USER -D $USER

COPY --from=build-env /app/out .

# Set the non-root user as current.
USER $USER

# Run the web service on container startup.
ENTRYPOINT ["dotnet", "helloworld-csharp.dll"]
