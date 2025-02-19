# 🚀 MinIO Local Bucket com API FastAPI

## 📖 Descrição
Este projeto configura um **bucket de armazenamento local MinIO** para armazenar **imagens e arquivos gerais enviados pelo backend de uma aplicação**. Os arquivos são armazenados em `/home/minio-data/uploads` e acessíveis via **API FastAPI**.

### 🔥 Principais Recursos
- ✅ **Armazenamento eficiente de arquivos grandes**  
- ✅ **Upload via API e acesso por URL pública ou temporária**  
- ✅ **Fila de processamento assíncrona para evitar sobrecarga do servidor**  
- ✅ **Configuração automática com um único script de instalação**  
- ✅ **Execução local, sem necessidade de serviços externos**  

---

## 📦 Tecnologias Utilizadas
- **MinIO**: Armazenamento de objetos compatível com S3  
- **FastAPI**: API para recebimento e manipulação de arquivos  
- **Uvicorn**: Servidor ASGI para execução do FastAPI  
- **Boto3**: SDK Python para comunicação com MinIO  
- **Shell Script**: Automação da instalação e configuração  

---

## 🛠 Pré-requisitos
Antes de iniciar, certifique-se de ter:
- **Debian 12** ou outra distribuição Linux compatível  
- **Usuário com permissões sudo**  
- **Conexão com a internet** para instalação dos pacotes necessários  

---

## 🚀 Instalação e Configuração
1. **Clone o repositório**:
    ```bash
    git clone https://github.com/seu-usuario/minio-fastapi-bucket.git
    cd minio-fastapi-bucket
    ```
2. **Torne o script de instalação executável**:
    ```bash
    chmod +x setup-minio-completo.sh
    ```
3. **Execute o script para configurar tudo automaticamente**:
    ```bash
    ./setup-minio-completo.sh
    ```
    Esse script irá:
    - Instalar **MinIO, `mc` (cliente MinIO), Python3, FastAPI, Uvicorn, Boto3**
    - Criar e configurar um bucket MinIO em `/home/minio-data/uploads`
    - Configurar permissões corretas para garantir acesso aos arquivos
    - Criar **serviços systemd** para manter o MinIO e o FastAPI rodando automaticamente  

---

## 📤 Como Fazer Uploads
Agora que a API está rodando, você pode fazer **uploads de arquivos via API**.

### Upload via cURL
```bash
curl -X POST "http://192.7.0.34:8000/upload/" -F "file=@imagem.jpg"
```
✅ Resposta esperada:
```json
{
  "filename": "imagem.jpg",
  "url": "http://192.7.0.34:9000/uploads/20250218123045_imagem.jpg"
}
```

---

## 📥 Como Acessar os Arquivos
Os arquivos enviados são salvos no diretório do bucket:
```bash
ls /home/minio-data/uploads/
```
Os arquivos podem ser acessados publicamente via URL:
```
http://192.7.0.34:9000/uploads/NOME_DO_ARQUIVO
```
Para gerar links temporários, use:
```bash
curl -X GET "http://192.7.0.34:8000/get-url/NOME_DO_ARQUIVO?temporary=true&expires_in=300"
```
✅ Resposta esperada:
```json
{
  "url": "http://192.7.0.34:9000/uploads/NOME_DO_ARQUIVO?X-Amz-Algorithm=AWS4-HMAC-SHA256..."
}
```

---

## 🛠 Comandos Úteis
Verificar status do MinIO:
```bash
sudo systemctl status minio
```
Reiniciar o MinIO:
```bash
sudo systemctl restart minio
```
Verificar status da API FastAPI:
```bash
sudo systemctl status minio-api
```
Reiniciar a API:
```bash
sudo systemctl restart minio-api
```

---

## 🚑 Solução de Problemas (Troubleshooting)
### 🔴 Erro: "Connection refused" ao tentar acessar o MinIO
✅ Causa: O MinIO pode não estar rodando ou a porta pode estar bloqueada.  
✅ Solução:
```bash
sudo systemctl restart minio
sudo ss -tulnp | grep 9000
sudo ufw allow 9000/tcp
```

### 🔴 Erro: "404 Not Found" ao fazer upload
✅ Causa: O endpoint correto para upload é POST /upload/, mas PUT foi usado.  
✅ Solução: Use POST para upload:
```bash
curl -X POST "http://192.7.0.34:8000/upload/" -F "file=@imagem.jpg"
```

### 🔴 Erro: "Permission Denied" ao iniciar o MinIO
✅ Causa: O diretório de armazenamento não tem permissões corretas.  
✅ Solução: Ajuste as permissões:
```bash
sudo chown -R minio-user:minio-user /home/minio-data/uploads
sudo chmod -R 775 /home/minio-data/uploads
sudo systemctl restart minio
```

---

## 🚀 Melhorias Recentes
### 🟢 Fila de Processamento
Agora os uploads são processados em segundo plano para evitar sobrecarga no servidor.

📌 Antes: O upload era bloqueante, o servidor ficava travado até finalizar.  
📌 Agora: O upload é inserido em uma fila (BackgroundTasks), e o MinIO processa em paralelo.

### 🟢 Links Temporários Personalizados
Agora o usuário pode solicitar links temporários personalizados diretamente via API.

📌 Padrão (link permanente):
```bash
curl -X GET "http://192.7.0.34:8000/get-url/imagem.jpg"
```
✅ Resposta:
```json
{
  "url": "http://192.7.0.34:9000/uploads/imagem.jpg"
}
```
📌 Gerar um link temporário de 5 minutos (300 segundos):
```bash
curl -X GET "http://192.7.0.34:8000/get-url/imagem.jpg?temporary=true&expires_in=300"
```
✅ Resposta:
```json
{
  "url": "http://192.7.0.34:9000/uploads/imagem.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256..."
}
```

---

## 📜 Licença
Este projeto está licenciado sob a MIT License. Sinta-se livre para modificar e usar conforme necessário.

---

## 🤝 Contribuição
Contribuições são bem-vindas!

1. Faça um fork do projeto
2. Crie um branch com sua feature (`git checkout -b minha-feature`)
3. Faça um commit (`git commit -m 'Minha nova feature'`)
4. Faça um push (`git push origin minha-feature`)
5. Abra um Pull Request

---

## 💬 Dúvidas ou Sugestões?
Sinta-se à vontade para abrir uma issue ou entrar em contato! 🚀🔥

---

## 🌟 Gostou do projeto?
⭐ Deixe um star no repositório!

---

Agora o README.md está completo e otimizado! 🚀🔥
Se precisar de mais ajustes ou quiser personalizar algo, me avise! 😊
