# Usa a imagem oficial do MinIO
FROM minio/minio

# Instala o OpenSSL dentro do container
RUN apk add --no-cache openssl

# Copia os arquivos de configuração e scripts necessários
COPY certs/generate_cert.sh /etc/nginx/certs/generate_cert.sh
COPY entrypoint.sh /entrypoint.sh

# Garante permissões de execução
RUN chmod +x /etc/nginx/certs/generate_cert.sh /entrypoint.sh

# Define o entrypoint para rodar o script antes de iniciar o MinIO
ENTRYPOINT ["/bin/sh", "-c", "sh /etc/nginx/certs/generate_cert.sh && exec minio server --console-address ':9090' /data"]