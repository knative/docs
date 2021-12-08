# The official R base image
# https://hub.docker.com/_/r-base
FROM r-base:3.6.0

# Copy local code to the container image.
WORKDIR /usr/src/app
COPY . .

# Install R packages
RUN Rscript -e "install.packages('plumber', repos='http://cran.us.r-project.org/')"

# Run the web service on container startup.
CMD ["Rscript", "server.R"]
