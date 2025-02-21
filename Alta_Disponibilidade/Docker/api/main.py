from fastapi import FastAPI, File, UploadFile, HTTPException, Query
import boto3
import redis
import os
import logging
from datetime import datetime
from dotenv import load_dotenv

# Configuração do logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Carregar variáveis do .env
load_dotenv()

app = FastAPI()

# Configuração do MinIO (S3)
MINIO_URL = os.getenv("MINIO_URL")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY")
BUCKET_NAME = os.getenv("BUCKET_NAME")
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")

# Inicializar MinIO
minio_client = boto3.client(
    "s3",
    endpoint_url=MINIO_URL,
    aws_access_key_id=MINIO_ACCESS_KEY,
    aws_secret_access_key=MINIO_SECRET_KEY
)

# Inicializar Redis
redis_client = redis.Redis(host=REDIS_HOST, port=6379, db=0)

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    """Faz upload do arquivo e retorna a URL pública"""
    try:
        file_key = f"{datetime.now().strftime('%Y%m%d%H%M%S')}_{file.filename}"
        minio_client.upload_fileobj(file.file, BUCKET_NAME, file_key)
        file_url = f"{MINIO_URL}/{BUCKET_NAME}/{file_key}"

        # Cachear URL no Redis
        redis_client.setex(file_key, 3600, file_url)

        return {"filename": file.filename, "url": file_url}
    except Exception as e:
        logging.error(f"❌ Erro ao salvar o arquivo: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao salvar o arquivo: {str(e)}")

@app.get("/get-url/{file_name}")
async def get_image_url(file_name: str, temporary: bool = Query(False), expires_in: int = Query(3600)):
    """Gera uma URL para acessar a imagem com cache em Redis."""
    cached_url = redis_client.get(file_name)
    if cached_url:
        return {"url": cached_url.decode("utf-8")}

    try:
        if temporary:
            url = minio_client.generate_presigned_url(
                "get_object",
                Params={"Bucket": BUCKET_NAME, "Key": file_name},
                ExpiresIn=expires_in
            )
        else:
            url = f"{MINIO_URL}/{BUCKET_NAME}/{file_name}"

        redis_client.setex(file_name, 3600, url)

        return {"url": url}
    except Exception as e:
        logging.error(f"❌ Erro ao gerar URL: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao gerar URL: {str(e)}")