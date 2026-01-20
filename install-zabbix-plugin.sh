#!/bin/bash

# ========================================
# Instalação Manual Plugin Zabbix v5.2.1
# Compatível com Zabbix 7.0 + Grafana 10.4.1
# ========================================

set -e

echo "=================================================="
echo "Instalação Manual - Grafana Zabbix Plugin v5.2.1"
echo "=================================================="

# Versão do plugin (última compatível com Zabbix 7.0)
PLUGIN_VERSION="5.2.1"
PLUGIN_URL="https://github.com/grafana/grafana-zabbix/releases/download/v${PLUGIN_VERSION}/alexanderzobnin-zabbix-app-${PLUGIN_VERSION}.zip"

echo ""
echo "Baixando plugin versão ${PLUGIN_VERSION}..."
wget -O plugin.zip "${PLUGIN_URL}"

echo ""
echo "Extraindo plugin..."
unzip -q plugin.zip
rm plugin.zip

echo ""
echo "Parando Grafana..."
docker compose stop grafana

echo ""
echo "Removendo plugin antigo (se existir)..."
docker run --rm \
  -v zabbix-grafana-docker_grafana-data:/data \
  alpine sh -c "rm -rf /data/plugins/alexanderzobnin-zabbix-app"

echo ""
echo "Copiando plugin para volume do Grafana..."
docker run --rm \
  -v $(pwd)/alexanderzobnin-zabbix-app:/plugin \
  -v zabbix-grafana-docker_grafana-data:/data \
  alpine sh -c "cp -r /plugin /data/plugins/"

echo ""
echo "Ajustando permissões..."
docker run --rm \
  -v zabbix-grafana-docker_grafana-data:/data \
  alpine sh -c "chown -R 472:472 /data/plugins/alexanderzobnin-zabbix-app"

echo ""
echo "Limpando arquivos temporários..."
rm -rf alexanderzobnin-zabbix-app

echo ""
echo "Iniciando Grafana..."
docker compose start grafana

echo ""
echo "Aguardando Grafana inicializar..."
sleep 30

echo ""
echo "Verificando instalação..."
docker compose exec grafana ls -la /var/lib/grafana/plugins/ | grep zabbix

echo ""
echo "=================================================="
echo "Plugin instalado com sucesso!"
echo "=================================================="
echo ""
echo "Próximos passos:"
echo ""
echo "1. Acesse Grafana: http://$(hostname -I | awk '{print $1}'):3000"
echo "2. Login: admin / sua_senha"
echo "3. Menu → Configuration → Plugins"
echo "4. Procure 'Zabbix' → Clique em 'Enable'"
echo "5. Configuration → Data Sources → Add data source"
echo "6. Selecione 'Zabbix'"
echo "7. Configure:"
echo "   URL: http://zabbix-web:8080/api_jsonrpc.php"
echo "   Username: Admin"
echo "   Password: zabbix"
echo "8. Save & Test"
echo ""
echo "=================================================="
