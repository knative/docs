# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.9-slim

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True
ENV PORT=8080
ENV APP_HOME=app

# Create and change to the app directory.
WORKDIR "/home/${USER}/${APP_HOME}"

# Copy local code to the container image.
COPY . ./

# Add a user so the server will run as a non-root user.
# Install production dependencies.
RUN addgroup --gid $USER_GID $USER && \
    adduser -u $USER_UID --ingroup $USER --disabled-password $USER && \
    pip install Flask gunicorn

# Set the non-root user as current.
USER $USER

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
