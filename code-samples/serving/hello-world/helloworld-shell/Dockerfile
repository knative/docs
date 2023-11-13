# Busybox image that contains the simple 'httpd'
# https://git.busybox.net/busybox/tree/networking/httpd.c
FROM busybox

# Add a user so the server will run as a non-root user.
RUN addgroup -g 1000 appuser && \
    adduser -S -u 1000 -G appuser appuser

# Serve from this directory
WORKDIR /var/www

# Prepare httpd command for being started via init
# This indirection is required for proper SIGTERM handling
RUN echo "::sysinit:httpd -vv -p 8080 -u daemon -h /var/www" > /etc/inittab

# Copy over our CGI script and make it executable
COPY --chown=daemon:daemon script.sh cgi-bin/index.cgi
RUN chmod 755 cgi-bin/index.cgi

USER appuser

# Startup init which in turn starts httpd
CMD init
