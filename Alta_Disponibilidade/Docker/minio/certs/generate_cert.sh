#!/bin/sh

CERTS_DIR="/etc/nginx/certs"

mkdir -p $CERTS_DIR

if [ ! -f "$CERTS_DIR/public.crt" ] || [ ! -f "$CERTS_DIR/private.key" ]; then
    echo "🔐 Gerando certificados SSL..."
    openssl req -newkey rsa:2048 -nodes -keyout $CERTS_DIR/private.key \
        -x509 -days 365 -out $CERTS_DIR/public.crt \
        -subj "/CN=minio"

    echo "✅ Certificados SSL gerados!"
else
    echo "🔐 Certificados já existem, pulando geração..."
fi