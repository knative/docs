# BusyBox includes the httpd applet used by this sample.
FROM busybox:1.38

WORKDIR /var/www

COPY --chown=daemon:daemon script.sh cgi-bin/index.cgi
RUN chmod 755 cgi-bin/index.cgi

# BusyBox init handles SIGTERM and reaps CGI processes; httpd daemonizes.
# Configure the listener at startup so Knative's PORT is honored (default 8080).
CMD ["sh", "-c", "printf '::sysinit:httpd -vv -p %s -u daemon -h /var/www\\n' \"${PORT:-8080}\" > /etc/inittab; exec busybox init"]
