#!/bin/sh

# Print out CGI header
# See https://tools.ietf.org/html/draft-robinson-www-interface-00
# for the full CGI specification
printf 'Content-Type: text/plain\r\n\r\n'

# Use environment variable TARGET or "World" if unset or empty
printf 'Hello %s!\n' "${TARGET:-World}"

# In this script you can perform more dynamic actions, too.
# Like printing the date, checking CGI environment variables, ...
