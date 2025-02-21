#!/bin/sh
sh /root/.minio/certs/generate_cert.sh
exec minio server --console-address ":9090" /data