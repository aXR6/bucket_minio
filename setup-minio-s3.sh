#!/bin/bash

set -e  # Interrompe a execução em caso de erro

echo "🚀 Atualizando pacotes e instalando dependências..."
sudo apt update && sudo apt install -y wget curl nano python3 python3-pip unzip

echo "📂 Criando diretórios necessários..."
sudo mkdir -p /home/minio-data/uploads
sudo mkdir -p /home/minio-api
sudo mkdir -p /etc/minio

echo "📥 Baixando e instalando MinIO..."
wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
chmod +x /usr/local/bin/minio

echo "👤 Criando usuário do MinIO..."
sudo useradd -r minio-user -s /sbin/nologin || echo "Usuário já existe, ignorando."
sudo chown minio-user:minio-user /usr/local/bin/minio

echo "⚙️ Configurando permissões dos diretórios..."
sudo chown -R minio-user:minio-user /home/minio-data
sudo chmod -R 775 /home/minio-data
sudo chmod -R 775 /home/minio-api
sudo chmod -R 775 /etc/minio

echo "📝 Criando configuração do MinIO..."
cat <<EOF | sudo tee /etc/minio/minio.conf
MINIO_VOLUMES="/home/minio-data/uploads"
MINIO_ROOT_USER="admin"
MINIO_ROOT_PASSWORD="strongpassword"
MINIO_ADDRESS=":9500"
MINIO_CONSOLE_ADDRESS=":9501"
EOF

echo "🔧 Criando serviço Systemd para MinIO..."
cat <<EOF | sudo tee /etc/systemd/system/minio.service
[Unit]
Description=MinIO Object Storage
After=network-online.target
Wants=network-online.target

[Service]
User=minio-user
Group=minio-user
EnvironmentFile=-/etc/minio/minio.conf
ExecStart=/usr/local/bin/minio server \$MINIO_VOLUMES --console-address \$MINIO_CONSOLE_ADDRESS
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

echo "♻️ Recarregando e iniciando o serviço MinIO..."
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl restart minio

echo "⏳ Aguardando o MinIO iniciar..."
sleep 15  # Garante que o MinIO tenha tempo para subir completamente

echo "📥 Baixando e configurando o cliente MinIO (mc)..."
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
chmod +x /usr/local/bin/mc

echo "🔗 Configurando cliente MinIO..."
mc alias set localminio http://127.0.0.1:9500 admin strongpassword || {
    echo "Erro ao configurar o alias do MinIO. Tentando novamente em 10s..."
    sleep 10
    mc alias set localminio http://127.0.0.1:9500 admin strongpassword
}

echo "🪣 Criando bucket 'uploads'..."
mc mb localminio/uploads || echo "Bucket 'uploads' já existe."

echo "🌍 Definindo permissão pública para os arquivos..."
mc anonymous set public localminio/uploads
mc policy set public localminio/uploads

echo "🐍 Instalando dependências do Python para API..."
pip3 install fastapi uvicorn boto3 python-multipart --break-system-packages

echo "📜 Criando API Python para manipulação de arquivos..."
cat <<EOF | sudo tee /home/minio-api/main.py
from fastapi import FastAPI, File, UploadFile, HTTPException, Query, BackgroundTasks
import boto3
import logging
from datetime import datetime

# Configuração do logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

app = FastAPI()

# Configuração do MinIO (S3)
MINIO_URL = "http://127.0.0.1:9500"
MINIO_ACCESS_KEY = "admin"
MINIO_SECRET_KEY = "strongpassword"
BUCKET_NAME = "uploads"

# Inicializar cliente MinIO como S3
try:
    minio_client = boto3.client(
        "s3",
        endpoint_url=MINIO_URL,
        aws_access_key_id=MINIO_ACCESS_KEY,
        aws_secret_access_key=MINIO_SECRET_KEY
    )
    logging.info("✅ Conectado ao MinIO como S3 com sucesso.")
except Exception as e:
    logging.error(f"❌ Erro ao conectar no MinIO: {e}")

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...), background_tasks: BackgroundTasks = BackgroundTasks()):
    """Faz upload do arquivo e retorna a URL pública"""
    try:
        file_key = f"{datetime.now().strftime('%Y%m%d%H%M%S')}_{file.filename}"
        minio_client.upload_fileobj(file.file, BUCKET_NAME, file_key)
        file_url = f"{MINIO_URL}/{BUCKET_NAME}/{file_key}"
        return {"filename": file.filename, "url": file_url}
    except Exception as e:
        logging.error(f"❌ Erro ao salvar o arquivo: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao salvar o arquivo: {str(e)}")

@app.get("/get-url/{file_name}")
async def get_image_url(file_name: str, temporary: bool = Query(False), expires_in: int = Query(3600)):
    """Gera uma URL para acessar a imagem (padrão: permanente). Se `temporary=True`, gera uma URL temporária."""
    try:
        if temporary:
            url = minio_client.generate_presigned_url(
                "get_object",
                Params={"Bucket": BUCKET_NAME, "Key": file_name},
                ExpiresIn=expires_in
            )
        else:
            url = f"{MINIO_URL}/{BUCKET_NAME}/{file_name}"
        return {"url": url}
    except Exception as e:
        logging.error(f"❌ Erro ao gerar URL: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao gerar URL: {str(e)}")
EOF

echo "🔧 Criando serviço Systemd para API FastAPI..."
cat <<EOF | sudo tee /etc/systemd/system/minio-api.service
[Unit]
Description=FastAPI MinIO S3 Upload API
After=network.target

[Service]
User=$USER
WorkingDirectory=/home/minio-api
ExecStart=/usr/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "♻️ Corrigindo permissões da API..."
sudo chown -R $USER:$USER /home/minio-api
sudo chmod -R 755 /home/minio-api

echo "♻️ Recarregando e iniciando a API..."
sudo systemctl daemon-reload
sudo systemctl enable minio-api
sudo systemctl restart minio-api

echo "✅ Instalação concluída!"
echo "📂 Uploads podem ser feitos via API em: http://$(hostname -I | awk '{print $1}'):8000/upload/"
echo "🌍 Arquivos enviados podem ser acessados em: http://$(hostname -I | awk '{print $1}'):9500/uploads/"