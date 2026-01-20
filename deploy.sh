#!/bin/bash

# ========================================
# Script de Deploy - Zabbix + Grafana
# ========================================

set -e  # Parar em caso de erro

echo "=========================================="
echo "Deploy Zabbix + Grafana Docker"
echo "=========================================="

# Verificar se Docker e Docker Compose estão instalados
if ! command -v docker &> /dev/null; then
    echo "Docker não está instalado!"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "Docker Compose não está instalado!"
    exit 1
fi

echo "Docker e Docker Compose detectados"

# Criar estrutura de diretórios
echo ""
echo "Criando estrutura de diretórios..."
mkdir -p volumes/{postgres-data,zabbix-server,grafana-data,grafana-provisioning}
chmod -R 755 volumes/

# Verificar arquivo .env
if [ ! -f .env ]; then
    echo "Arquivo .env não encontrado!"
    echo "Criando .env com valores padrão..."
    echo "IMPORTANTE: Altere as senhas antes de usar em produção!"
    cat > .env << 'EOF'
POSTGRES_PASSWORD=zabbix_strong_password_123
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin_change_me
EOF
fi

# Baixar imagens
echo ""
echo "Baixando imagens Docker..."
docker compose pull

# Subir containers
echo ""
echo "Iniciando containers..."
docker compose up -d

# Aguardar inicialização
echo ""
echo "Aguardando inicialização dos serviços..."
sleep 10

# Verificar status
echo ""
echo "Status dos containers:"
docker compose ps

# Verificar logs para erros
echo ""
echo "Verificando logs (últimas 20 linhas)..."
docker compose logs --tail=20

# Informações de acesso
echo ""
echo "=========================================="
echo "Deploy concluído!"
echo "=========================================="
echo ""
echo "Acesso aos serviços:"
echo "   - Zabbix Web: http://$(hostname -I | awk '{print $1}'):8080"
echo "   - Grafana:    http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo "Credenciais Zabbix Web:"
echo "   - Usuário: Admin"
echo "   - Senha: zabbix"
echo "   - ALTERE após primeiro login!"
echo ""
echo "Credenciais Grafana:"
echo "   - Usuário: admin"
echo "   - Senha: (definida no .env)"
echo ""
echo "Comandos úteis:"
echo "   - Ver logs: docker compose logs -f [serviço]"
echo "   - Parar: docker compose down"
echo "   - Reiniciar: docker compose restart"
echo "   - Status: docker compose ps"
echo ""
echo "Aguarde 2-3 minutos para completa inicialização do Zabbix"
echo "=========================================="
