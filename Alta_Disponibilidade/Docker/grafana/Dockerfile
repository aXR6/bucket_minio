# Usar a imagem oficial do Grafana (baseada no Alpine)
FROM grafana/grafana:latest

# Alternar para o usuário root para instalar pacotes
USER root

# Atualizar e instalar SQLite no Alpine Linux
RUN apk update && apk add sqlite

# Voltar para o usuário padrão do Grafana
USER grafana

# Definir diretório de trabalho
WORKDIR /usr/share/grafana