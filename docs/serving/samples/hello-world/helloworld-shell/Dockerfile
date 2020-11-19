# Busybox image that contains the simple 'httpd'
# https://git.busybox.net/busybox/tree/networking/httpd.c
FROM busybox

# Serve from this directory
WORKDIR /httpd

# Copy over the service script
COPY script.sh /httpd

# Start up the webserver
CMD [ "/bin/sh", "/httpd/script.sh" ]
