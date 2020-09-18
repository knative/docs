#!/bin/sh
while true ; do
  echo -e "HTTP/1.1 200\n\n Hello ${TARGET:=World}!\n" | nc -l -p 8080 -q 1;
done
