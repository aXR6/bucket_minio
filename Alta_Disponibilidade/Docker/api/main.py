import os
from fastapi import FastAPI, File, UploadFile, HTTPException, Query
import boto3
import logging
from datetime import datetime
from celery import Celery
from io import BytesIO

# Configuração do logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

app = FastAPI()

# Configurações do MinIO via variáveis de ambiente (são padronizadas para o docker-compose)
MINIO_URL = os.getenv("MINIO_URL", "http://minio:9000")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY", "admin")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY", "strongpassword")
BUCKET_NAME = os.getenv("BUCKET_NAME", "uploads")

# Configuração do Celery (broker Redis)
redis_url = os.getenv("REDIS_URL", "redis://redis:6379/0")
celery_app = Celery("minio_tasks", broker=redis_url)

@celery_app.task
def process_upload(file_bytes, bucket, file_key, minio_config):
    try:
        s3_client = boto3.client(
            "s3",
            endpoint_url=minio_config['MINIO_URL'],
            aws_access_key_id=minio_config['MINIO_ACCESS_KEY'],
            aws_secret_access_key=minio_config['MINIO_SECRET_KEY']
        )
        file_obj = BytesIO(file_bytes)
        s3_client.upload_fileobj(file_obj, bucket, file_key)
        return f"{minio_config['MINIO_URL']}/{bucket}/{file_key}"
    except Exception as e:
        logging.error(f"Erro no processamento do upload: {e}")
        raise e

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    try:
        file_bytes = await file.read()
        file_key = f"{datetime.now().strftime('%Y%m%d%H%M%S')}_{file.filename}"
        # Enfileira a tarefa para o Celery processar o upload
        task = process_upload.delay(
            file_bytes,
            BUCKET_NAME,
            file_key,
            {
                "MINIO_URL": MINIO_URL,
                "MINIO_ACCESS_KEY": MINIO_ACCESS_KEY,
                "MINIO_SECRET_KEY": MINIO_SECRET_KEY,
            }
        )
        return {"message": "Upload enfileirado", "task_id": task.id}
    except Exception as e:
        logging.error(f"Erro ao enfileirar upload: {e}")
        raise HTTPException(status_code=500, detail=f"Erro: {str(e)}")

@app.get("/get-url/{file_name}")
async def get_image_url(file_name: str, temporary: bool = Query(False), expires_in: int = Query(3600)):
    try:
        s3_client = boto3.client(
            "s3",
            endpoint_url=MINIO_URL,
            aws_access_key_id=MINIO_ACCESS_KEY,
            aws_secret_access_key=MINIO_SECRET_KEY
        )
        if temporary:
            url = s3_client.generate_presigned_url(
                "get_object",
                Params={"Bucket": BUCKET_NAME, "Key": file_name},
                ExpiresIn=expires_in
            )
        else:
            url = f"{MINIO_URL}/{BUCKET_NAME}/{file_name}"
        return {"url": url}
    except Exception as e:
        logging.error(f"Erro ao gerar URL: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao gerar URL: {str(e)}")