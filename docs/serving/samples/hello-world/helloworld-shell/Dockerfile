# Use the official Alpine image for a lean production container.
# https://hub.docker.com/_/alpine
FROM alpine:3

# Update & install netcat (nc)
RUN apk update \
 && apk add netcat-openbsd

# Copy over the service script
COPY script.sh /

# Start up the webserver
CMD [ "/bin/sh", "/script.sh" ]
