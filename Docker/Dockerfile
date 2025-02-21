# Usar imagem Python leve
FROM python:3.9-slim

# Definir diretório de trabalho dentro do container
WORKDIR /app

# Copiar arquivos necessários
COPY requirements.txt .
COPY main.py .

# Instalar dependências
RUN pip install --no-cache-dir -r requirements.txt

# Expor porta 8000 para FastAPI
EXPOSE 8000

# Comando para rodar a API
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]