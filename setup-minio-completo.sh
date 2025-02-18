#!/bin/bash

set -e  # Para a execução em caso de erro

echo "🚀 Atualizando pacotes e instalando dependências..."
sudo apt update && sudo apt install -y wget curl nano python3 python3-pip unzip

echo "📂 Criando diretórios necessários..."
sudo mkdir -p /home/minio-data/uploads
sudo mkdir -p /home/minio-api

echo "📥 Baixando e instalando MinIO..."
wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
chmod +x /usr/local/bin/minio

echo "👤 Criando usuário do MinIO..."
sudo useradd -r minio-user -s /sbin/nologin || echo "Usuário já existe, ignorando."
sudo chown minio-user:minio-user /usr/local/bin/minio

echo "⚙️ Configurando permissões do diretório MinIO..."
sudo chown -R minio-user:minio-user /home/minio-data
sudo chmod -R 775 /home/minio-data

echo "📝 Criando configuração do MinIO..."
echo 'MINIO_VOLUMES="/home/minio-data"
MINIO_ROOT_USER="admin"
MINIO_ROOT_PASSWORD="strongpassword"
MINIO_ADDRESS=":9500"
MINIO_CONSOLE_ADDRESS=":9501"' | sudo tee /etc/minio/minio.conf

echo "🔧 Criando serviço Systemd para MinIO..."
sudo tee /etc/systemd/system/minio.service <<EOF
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

echo "📥 Baixando e configurando o cliente MinIO (mc)..."
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
chmod +x /usr/local/bin/mc

echo "🔗 Configurando cliente MinIO..."
mc alias set localminio http://127.0.0.1:9000 admin strongpassword

echo "🪣 Criando bucket 'uploads'..."
mc mb localminio/uploads

echo "🌍 Definindo permissão pública para os arquivos..."
mc anonymous set public localminio/uploads

echo "🐍 Instalando dependências do Python para API..."
pip3 install fastapi uvicorn boto3 python-multipart --break-system-packages

echo "📜 Criando API Python para salvar arquivos diretamente no bucket..."
cat << 'EOF' | sudo tee /home/minio-api/main.py
from fastapi import FastAPI, File, UploadFile
import os
from datetime import datetime

app = FastAPI()

# Caminho do bucket no servidor
UPLOAD_DIR = "/home/minio-data/uploads"

# Criar diretório se não existir
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    # Criar nome único para o arquivo
    file_key = f"{datetime.now().strftime('%Y%m%d%H%M%S')}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, file_key)

    # Salvar o arquivo no diretório
    with open(file_path, "wb") as buffer:
        buffer.write(await file.read())

    # Retornar URL de acesso
    file_url = f"http://{os.getenv('SERVER_IP', '192.7.0.34')}:9000/uploads/{file_key}"
    
    return {"filename": file.filename, "url": file_url}
EOF

echo "🔧 Criando serviço Systemd para API FastAPI..."
sudo tee /etc/systemd/system/minio-api.service <<EOF
[Unit]
Description=FastAPI MinIO Upload API
After=network.target

[Service]
User=$USER
WorkingDirectory=/home/minio-api
#ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 8000
ExecStart=/usr/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "⚙️ Corrigindo permissões da API..."
sudo chown -R $USER:$USER /home/minio-api
sudo chmod -R 755 /home/minio-api

echo "♻️ Recarregando e iniciando o serviço da API..."
sudo systemctl daemon-reload
sudo systemctl enable minio-api
sudo systemctl restart minio-api

echo "✅ Instalação concluída!"
echo "📂 Uploads podem ser feitos via API em: http://$(hostname -I | awk '{print $1}'):8000/upload/"
echo "🌍 Arquivos enviados podem ser acessados em: http://$(hostname -I | awk '{print $1}'):9000/uploads/"
