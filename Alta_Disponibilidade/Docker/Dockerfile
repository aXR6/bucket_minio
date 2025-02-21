# Usa uma imagem base oficial do Python
FROM python:3.11

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Copia os arquivos necessários
COPY minio-api/ /app
COPY requirements.txt /app

# Instala dependências
RUN pip install --no-cache-dir -r requirements.txt

# Expõe a porta da API
EXPOSE 8000

# Comando para rodar a API
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]