#!/bin/sh

# Garantir que os certificados SSL sejam gerados
sh /etc/nginx/certs/generate_cert.sh

# Iniciar o MinIO
exec minio server --console-address ":9090" /data