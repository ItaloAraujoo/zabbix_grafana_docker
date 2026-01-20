# Zabbix + Grafana + Docker

Ambiente containerizado profissional para monitoramento com Zabbix e visualização com Grafana.

# IMPORTANTE: Plugin Zabbix
### ATENÇÃO: O Grafana pode instalar automaticamente uma versão incompatível do plugin Zabbix.

- Grafana 10.4.1 + Zabbix 7.0 → Requer plugin v5.2.1
- Instalação automática pode instalar v6.1.1 ou v4.6.1 (incompatíveis)
- Método correto: Montagem direta do plugin (já incluído no docker-compose.yml)

## Pré-requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Mínimo 4GB RAM
- Mínimo 20GB espaço em disco

## Arquitetura
<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/197780e9-ed91-4687-bd11-9ac74b8907fc" />

### 1. Clone ou baixe este repositório

```bash
git clone <repositorio>
cd zabbix-grafana-docker
```

```bash
# Edite o arquivo .env e altere as senhas
nano .env
```

### 3. Execute o preparar-volumes.sh

```bash
# Dar permissão de execução
chmod +x preparar-volumes.sh

# Executar
./preparar-volumes.sh
```

### 4. Aguarde a inicialização (2-3 minutos)

```bash
# Acompanhar logs
docker compose logs -f
```
## Acessos

### Zabbix Web Interface
- **URL**: http://SEU_IP:8080
- **Usuário**: Admin
- **Senha**: zabbix
- **ALTERE A SENHA após primeiro login!**

### Grafana
- **URL**: http://SEU_IP:3000
- **Usuário**: admin
- **Senha**: (definida no arquivo .env)

### Zabbix Server (para agentes)
- **Porta**: 10051
- **Host**: SEU_IP

## Configuração do Grafana

### Adicionar Zabbix como Data Source

1. Acesse Grafana (http://SEU_IP:3000)
2. Vá em **Connections** → **Data Sources**
3. Clique em **Add new data source**
4. Selecione **Zabbix**
5. Configure:
   - **URL**: `http://zabbix-web:8080/api_jsonrpc.php`
   - **Username**: Admin (ou seu usuário Zabbix)
   - **Password**: (senha do usuário Zabbix)
   - **Skip TLS Verify**: (marque se não usar HTTPS)
6. Clique em **Save & Test**

## Estrutura de Volumes

```
volumes/
├── mysql-data/      # Dados do MySQL
├── zabbix-server/      # Dados do Zabbix Server
└── grafana-data/       # Dashboards e configurações Grafana
```

### Comunicação entre Containers

Os containers se comunicam via DNS interno do Docker:
- `mysql` → MySQL
- `zabbix-server` → Zabbix Server  
- `zabbix-web` → Zabbix Frontend
- `grafana` → Grafana

## Licença

Este projeto utiliza componentes open source:
- Zabbix 
- Grafana
- MySQL

