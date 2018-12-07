# Use the official Python image.
# https://hub.docker.com/_/python
FROM python

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . .

# Install production dependencies.
RUN pip install Flask

# Configure the service HTTP port.
ENV PORT 8080

# Run the web service on container startup.
CMD ["python", "app.py"]
