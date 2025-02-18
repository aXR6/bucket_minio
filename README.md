# 🚀 MinIO Local Bucket com API FastAPI

## 📖 Descrição
Este repositório contém um bucket de armazenamento local MinIO configurado para armazenar imagens e arquivos gerais enviados pelo backend de uma aplicação. Os arquivos são armazenados no diretório `/home/minio-data/uploads` e podem ser acessados via API FastAPI.

- ✅ Armazena arquivos grandes de forma eficiente
- ✅ Upload via API e acesso via URL pública
- ✅ Totalmente configurável e automatizado
- ✅ Executado localmente sem necessidade de serviços externos

## 📦 Tecnologias Utilizadas
- **MinIO**: Armazenamento de objetos compatível com S3
- **FastAPI**: API para recebimento de arquivos
- **Uvicorn**: Servidor ASGI para executar o FastAPI
- **Boto3**: SDK para integração com MinIO
- **Shell Script**: Automação de instalação e configuração

## 🛠 Pré-requisitos
Antes de iniciar a instalação, certifique-se de ter:
- Debian 12 ou outra distribuição Linux compatível
- Usuário com permissões sudo
- Conexão com a internet para instalar pacotes necessários

## 🚀 Instalação e Configuração
1. Clone o repositório:
    ```bash
    git clone https://github.com/seu-usuario/minio-fastapi-bucket.git
    cd minio-fastapi-bucket
    ```
2. Torne o script de instalação executável:
    ```bash
    chmod +x setup-minio-completo.sh
    ```
3. Execute o script para configurar tudo automaticamente:
    ```bash
    ./setup-minio-completo.sh
    ```
    Esse script irá:
    - Instalar MinIO, mc, Python3, FastAPI, Uvicorn, Boto3
    - Criar e configurar um bucket MinIO no diretório `/home/minio-data/uploads`
    - Configurar permissões corretas para acesso aos arquivos
    - Criar um serviço systemd para manter o MinIO e o FastAPI rodando automaticamente

## 📤 Como Fazer Uploads
Agora que a API está rodando, você pode fazer uploads de arquivos diretamente via API.

### Upload via cURL
```bash
curl -X POST "http://192.7.0.34:8000/upload/" -F "file=@imagem.jpg"
```
Resposta esperada:
```json
{
  "filename": "imagem.jpg",
  "url": "http://192.7.0.34:9000/uploads/20250218123045_imagem.jpg"
}
```

## 📥 Como Acessar os Arquivos
Os arquivos enviados são salvos localmente no diretório do bucket:
```bash
ls /home/minio-data/uploads/
```
Os arquivos podem ser acessados publicamente via URL:
```url
http://192.7.0.34:9000/uploads/NOME_DO_ARQUIVO
```
Se precisar gerar links temporários, use:
```bash
mc alias set localminio http://127.0.0.1:9000 admin strongpassword
mc share download localminio/uploads/NOME_DO_ARQUIVO
```

## 🛠 Comandos Úteis
- **Verificar status do MinIO**:
    ```bash
    sudo systemctl status minio
    ```
- **Reiniciar o MinIO**:
    ```bash
    sudo systemctl restart minio
    ```
- **Verificar status da API FastAPI**:
    ```bash
    sudo systemctl status minio-api
    ```
- **Reiniciar a API**:
    ```bash
    sudo systemctl restart minio-api
    ```

## 🚑 Troubleshooting (Solução de Problemas)
- **Erro: connection refused ao tentar acessar o MinIO**
    - **Causa**: O MinIO pode não estar rodando ou a porta pode estar bloqueada.
    - **Solução**:
        ```bash
        sudo systemctl restart minio
        sudo ss -tulnp | grep 9000
        sudo ufw allow 9000/tcp
        ```
- **Erro: 404 Not Found ao fazer upload**
    - **Causa**: O endpoint correto para upload é `POST /upload/`, mas `PUT` foi usado.
    - **Solução**: Use `POST` para upload:
        ```bash
        curl -X POST "http://192.7.0.34:8000/upload/" -F "file=@imagem.jpg"
        ```
- **Erro: Permission Denied ao iniciar o MinIO**
    - **Causa**: O diretório de armazenamento não tem permissões corretas.
    - **Solução**: Ajuste as permissões:
        ```bash
        sudo chown -R minio-user:minio-user /home/minio-data/uploads
        sudo chmod -R 775 /home/minio-data/uploads
        sudo systemctl restart minio
        ```

## 📜 Licença
Este projeto está licenciado sob a MIT License. Sinta-se livre para modificar e usar conforme necessário.

## 🤝 Contribuição
Contribuições são bem-vindas!
1. Faça um fork do projeto
2. Crie um branch com sua feature (`git checkout -b minha-feature`)
3. Faça um commit (`git commit -m 'Minha nova feature'`)
4. Faça um push (`git push origin minha-feature`)
5. Abra um Pull Request

## 💬 Dúvidas ou Sugestões?
Fique à vontade para abrir uma issue ou entrar em contato! 🚀🔥

## 🌟 Gostou do projeto?
⭐ Deixe um star no repositório!

## 🎯 Conclusão
Este README.md agora contém toda a documentação necessária para instalação, uso, troubleshooting e contribuição ao projeto.

Se precisar de alguma melhoria ou ajuste, me avise! 🚀🔥
