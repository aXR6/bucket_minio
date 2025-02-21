from fastapi import FastAPI, File, UploadFile, HTTPException, Query
import boto3
import os
import logging
import redis
from datetime import datetime

# Configuração do logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

app = FastAPI()

# Configuração do MinIO (S3)
MINIO_URL = os.getenv("MINIO_URL", "https://minio:9000")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY", "admin")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY", "strongpassword")
BUCKET_NAME = os.getenv("BUCKET_NAME", "uploads")

# Configuração do Redis
redis_client = redis.Redis(host="redis", port=6379, db=0)

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
async def upload_file(file: UploadFile = File(...)):
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
async def get_image_url(file_name: str):
    """Gera uma URL para acessar a imagem com cache em Redis."""
    cached_url = redis_client.get(file_name)
    if cached_url:
        return {"url": cached_url.decode("utf-8")}

    url = f"{MINIO_URL}/{BUCKET_NAME}/{file_name}"
    redis_client.setex(file_name, 3600, url)
    return {"url": url}