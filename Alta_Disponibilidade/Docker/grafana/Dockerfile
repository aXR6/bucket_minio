# Usar a imagem oficial do Grafana
FROM grafana/grafana:latest

# Instalar SQLite dentro do container
USER root
RUN apt-get update && apt-get install -y sqlite3 && rm -rf /var/lib/apt/lists/*

# Voltar para o usuário padrão do Grafana
USER grafana

# Definir o diretório de trabalho
WORKDIR /usr/share/grafana