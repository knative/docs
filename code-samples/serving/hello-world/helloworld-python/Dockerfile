# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.14.9-slim-trixie

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED=1

# Knative supplies PORT; default to 8080 for local runs.
ENV PORT=8080
WORKDIR /app

# Install pinned production dependencies before copying application code.
COPY requirements.txt ./
RUN python -m pip install --no-cache-dir -r requirements.txt

COPY app.py ./

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
CMD ["sh", "-c", "exec gunicorn --bind \"0.0.0.0:${PORT:-8080}\" --workers 1 --threads 8 --timeout 0 app:app"]
