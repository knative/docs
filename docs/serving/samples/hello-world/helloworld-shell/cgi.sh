#!/bin/sh

# Print out CGI header
# See https://tools.ietf.org/html/draft-robinson-www-interface-00
# for the full CGI specification
echo -e "Content-Type: text/plain\n"

# Welcome message tagen from the environment or a default value
echo "Welcome to the ${TAGET:=hello-world example}!"

# Some CGI Info
cat <<EOT

Localtime:           $(date)
CGI Environment:
  Query String:      $QUERY_STRING
  Remote Address:    $REMOTE_ADDR
  Server Software:   $SERVER_SOFTWARE

EOT

# Print all Knative relevant environment variables
echo "Knative Environment:"
env | grep "^K_" | sed -e 's/^K_/  K_/'
