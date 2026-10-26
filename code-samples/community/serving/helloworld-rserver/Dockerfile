# The official R base image
# https://hub.docker.com/_/r-base
FROM r-base:4.6.1

WORKDIR /usr/src/app

# Match the official image's Debian sid runtime libraries when installing headers.
RUN apt-get update \
    && apt-get install -y -t unstable --no-install-recommends libcurl4-openssl-dev libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# Install the web framework using R's standard package installer.
RUN Rscript -e 'install.packages("plumber", repos = "https://cloud.r-project.org")'

# Copy the sample after dependency installation for efficient rebuilds.
COPY HelloWorld.R server.R ./

# Run the web service on container startup.
CMD ["Rscript", "server.R"]
