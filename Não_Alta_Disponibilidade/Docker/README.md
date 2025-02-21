# 🚀 MinIO + FastAPI com Docker Compose

## 📖 Descrição
Este projeto configura um bucket de armazenamento MinIO e uma API FastAPI dentro de containers Docker, permitindo uploads de arquivos, acesso via API e geração de links permanentes ou temporários.

## 🔥 Principais Recursos
- ✅ MinIO rodando como armazenamento de objetos S3 compatível
- ✅ API FastAPI para uploads e geração de links de acesso
- ✅ Docker Compose para orquestração e fácil implantação
- ✅ Fila de processamento para uploads assíncronos
- ✅ Links públicos e temporários via API

## 🛠 Pré-requisitos
Antes de começar, certifique-se de ter os seguintes itens instalados:
- Docker
- Docker Compose

## ✅ Consulte a documentação para a instalação das ferramentas
- https://docs.docker.com/engine/install/debian/

Se precisar instalar no Debian 12, execute:
```bash
sudo apt update && sudo apt install -y docker.io docker-compose
```

## 🚀 Instalação e Configuração
1. Clone o repositório:
    ```bash
    git clone https://github.com/seu-usuario/minio-fastapi-docker.git
    cd minio-fastapi-docker
    ```
2. Crie os diretórios necessários:
    ```bash
    mkdir -p minio/data
    ```
3. Suba os containers do projeto:
    ```bash
    docker compose up -d --build
    ```
4. Verifique se os serviços estão rodando:
    ```bash
    docker ps
    ```

### ✅ Saída esperada:
```bash
CONTAINER ID   IMAGE          STATUS          PORTS
123abc456xyz   fastapi        Up 10 seconds   0.0.0.0:8000->8000/tcp
789def012ghi   minio/minio    Up 10 seconds   0.0.0.0:9000->9000/tcp, 0.0.0.0:9090->9090/tcp
```

## 📤 Como Fazer Uploads
Agora que a API está rodando, você pode fazer uploads de arquivos via API.

### Upload via cURL
```bash
curl -X POST "http://localhost:8000/upload/" -F "file=@imagem.jpg"
```

### ✅ Resposta esperada:
```json
{
  "filename": "imagem.jpg",
  "url": "http://localhost:9000/uploads/20250218123045_imagem.jpg"
}
```

## 📥 Como Acessar os Arquivos
Os arquivos podem ser acessados diretamente via URL pública:
```bash
http://localhost:9000/uploads/NOME_DO_ARQUIVO
```

### Gerando um Link Temporário
Se precisar de um link temporário (válido por um tempo específico):
```bash
curl -X GET "http://localhost:8000/get-url/NOME_DO_ARQUIVO?temporary=true&expires_in=300"
```

### ✅ Resposta esperada:
```json
{
  "url": "http://localhost:9000/uploads/NOME_DO_ARQUIVO?X-Amz-Algorithm=AWS4-HMAC-SHA256..."
}
```

## 🛠 Comandos Úteis
- Verificar logs da API:
    ```bash
    docker logs fastapi
    ```
- Verificar logs do MinIO:
    ```bash
    docker logs minio
    ```
- Parar os containers:
    ```bash
    docker compose down
    ```
- Reiniciar os containers:
    ```bash
    docker compose up -d
    ```
- Verificar status dos serviços:
    ```bash
    docker ps
    ```

## 🚑 Solução de Problemas (Troubleshooting)
### 🔴 Erro: "Connection refused" ao tentar acessar o MinIO
- ✅ Causa: O MinIO pode não estar rodando ou a porta pode estar bloqueada.
- ✅ Solução:
    ```bash
    docker compose restart
    docker logs minio
    ```

### 🔴 Erro: "404 Not Found" ao fazer upload
- ✅ Causa: O endpoint correto para upload é POST /upload/, mas PUT foi usado.
- ✅ Solução: Use POST para upload:
    ```bash
    curl -X POST "http://localhost:8000/upload/" -F "file=@imagem.jpg"
    ```

### 🔴 Erro: Permissão negada ao criar arquivos no MinIO
- ✅ Causa: O volume do MinIO pode estar com permissões erradas.
- ✅ Solução: Ajuste as permissões:
    ```bash
    sudo chown -R 1000:1000 minio/data
    docker compose restart
    ```

## 🚀 Melhorias Recentes
- 🟢 Uso de Docker Compose: Agora, MinIO e FastAPI rodam automaticamente via Docker Compose.
- 🟢 Upload Assíncrono: Agora, os uploads são processados em fila de background.
- 🟢 Links Temporários Configuráveis: Agora você pode definir a validade dos links temporários.

## 📜 Licença
Este projeto está licenciado sob a MIT License.

## 🤝 Contribuição
Contribuições são bem-vindas!
1. Faça um fork do projeto
2. Crie um branch com sua feature (`git checkout -b minha-feature`)
3. Faça um commit (`git commit -m 'Minha nova feature'`)
4. Faça um push (`git push origin minha-feature`)
5. Abra um Pull Request

## 💬 Dúvidas ou Sugestões?
Sinta-se à vontade para abrir uma issue ou entrar em contato! 🚀🔥

## 🌟 Gostou do projeto?
⭐ Deixe um star no repositório!
