#!/bin/sh

# Print out CGI header
# See https://tools.ietf.org/html/draft-robinson-www-interface-00
# for the full CGI specification
echo -e "Content-Type: text/plain\n"

# Use environment variable TARGET or "World" if not set
echo "Hello ${TARGET:=World}!"

# In this script you can perform more dynamic actions, too.
# Like printing the date, checking CGI environment variables, ...
