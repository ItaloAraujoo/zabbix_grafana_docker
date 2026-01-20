#!/bin/bash

# ========================================
# Script de Preparação de Volumes
# ========================================

echo "=========================================="
echo "Preparando Diretórios de Volumes"
echo "=========================================="

# Criar estrutura de diretórios
echo ""
echo "Criando estrutura de diretórios..."

mkdir -p volumes/mysql-data
mkdir -p volumes/zabbix-server
mkdir -p volumes/grafana-data

echo "Diretórios criados:"
tree -L 2 volumes/ 2>/dev/null || ls -lR volumes/

# ========================================
# Ajustar Permissões
# ========================================

echo ""
echo "Ajustando permissões..."

# MySQL precisa de permissões específicas
# UID/GID padrão do MySQL no container: 999:999
sudo chown -R 999:999 volumes/mysql-data
chmod -R 755 volumes/mysql-data

# Zabbix Server
# UID/GID padrão: 1997:1997
sudo chown -R 1997:1997 volumes/zabbix-server
chmod -R 755 volumes/zabbix-server

# Grafana
# UID/GID padrão: 472:472
sudo chown -R 472:472 volumes/grafana-data
chmod -R 755 volumes/grafana-data

echo "Permissões ajustadas"

# Verificar
echo ""
echo "Estrutura final:"
ls -lah volumes/

echo ""
echo "=========================================="
echo "Volumes preparados com sucesso!"
echo "=========================================="
echo ""
echo "Para usar VOLUMES NOMEADOS:"
echo "docker compose up -d"
echo ""
echo "=========================================="
