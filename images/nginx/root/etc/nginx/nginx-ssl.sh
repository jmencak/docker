#!/bin/sh

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $PWD/ssl/nginx.key \
  -out $PWD/ssl/nginx.crt \
  -subj "/CN=nginx-ssl/O=nginx-ssl"
