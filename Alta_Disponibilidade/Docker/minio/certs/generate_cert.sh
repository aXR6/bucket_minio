#!/bin/sh

mkdir -p /root/.minio/certs

openssl req -newkey rsa:2048 -nodes -keyout /root/.minio/certs/private.key \
    -x509 -days 365 -out /root/.minio/certs/public.crt -subj "/CN=minio"

cp /root/.minio/certs/public.crt /etc/nginx/certs/
cp /root/.minio/certs/private.key /etc/nginx/certs/