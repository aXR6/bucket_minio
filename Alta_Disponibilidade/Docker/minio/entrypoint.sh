#!/bin/sh
sh /etc/nginx/certs/generate_cert.sh
exec minio server --console-address ":9090" /data