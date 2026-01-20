# Plugin Zabbix - Versão Incompatível

Ao instalar o plugin Zabbix no Grafana via grafana-cli ou variável de ambiente GF_INSTALL_PLUGINS, o Grafana pode instalar uma versão incompatível com sua instalação:

- Grafana 10.4.1 + Zabbix 7.0 → Requer plugin v5.2.1
- Plugin instalado automaticamente: v6.1.1 (requer Grafana >=11.6.0) ❌
- Ou: v4.6.1 (não suporta Zabbix 7.0) ❌

### Sintomas:

1. Erro React #130 ao acessar configuração do plugin
2. Plugin aparece com versão 6.1.1 ou 4.6.1
3. Datasource Zabbix não funciona corretamente
4. Grafana substitui versão manual automaticamente

## SOLUÇÃO PERMANENTE

### Método: Montagem Direta do Plugin (Read-Only)

Este método **impede** que o Grafana substitua o plugin automaticamente.

---

## PASSO A PASSO

### 1. Baixar Plugin Correto

```bash
cd ~/zabbix-grafana-docker

# Baixar versão 5.2.1 (compatível com Grafana 10.4.1 + Zabbix 7.0)
wget https://github.com/grafana/grafana-zabbix/releases/download/v5.2.1/alexanderzobnin-zabbix-app-5.2.1.zip

# Extrair
unzip alexanderzobnin-zabbix-app-5.2.1.zip

# Verificar extração
ls -la alexanderzobnin-zabbix-app/
```

### 2. Modificar docker-compose.yml

```bash
nano docker-compose.yml
```

**Localize a seção `grafana:` e modifique conforme abaixo:**

```yaml
  grafana:
    image: grafana/grafana:10.4.1
    container_name: grafana
    restart: unless-stopped
    
    environment:
      GF_SECURITY_ADMIN_USER: ${GRAFANA_ADMIN_USER:-admin}
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_ADMIN_PASSWORD:-admin_change_me}
      TZ: America/Sao_Paulo
      
      # ========================================
      # CONFIGURAÇÕES ESSENCIAIS DO PLUGIN
      # ========================================
      
      # Permitir plugin não assinado (obrigatório para v5.x)
      GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS: alexanderzobnin-zabbix-datasource
      
      # Desabilitar plugin marketplace (evita substituição automática)
      GF_PLUGIN_ADMIN_ENABLED: "false"
      GF_PLUGINS_ENABLE_ALPHA: "false"
      
      # ========================================
      
      GF_ANALYTICS_REPORTING_ENABLED: "false"
      GF_ANALYTICS_CHECK_FOR_UPDATES: "false"
      GF_SECURITY_ALLOW_EMBEDDING: "true"
      GF_SESSION_PROVIDER: file
      GF_SESSION_PROVIDER_CONFIG: sessions
    
    ports:
      - "3000:3000"
    
    volumes:
      - grafana-data:/var/lib/grafana
      
      # ========================================
      # MONTAGEM DIRETA DO PLUGIN (READ-ONLY)
      # ========================================
      # Monta plugin diretamente do diretório local
      # :ro = read-only (Grafana não pode modificar)
      - ./alexanderzobnin-zabbix-app:/var/lib/grafana/plugins/alexanderzobnin-zabbix-app:ro
    
    networks:
      - zabbix-network
    
    depends_on:
      zabbix-server:
        condition: service_started
    
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

**Salvar:** Ctrl+O, Enter, Ctrl+X

### 3. Aplicar Mudanças

```bash
# Recriar containers com nova configuração
docker compose down
docker compose up -d

# Aguardar inicialização
sleep 30
```

### 4. Verificar Versão

```bash
# Deve mostrar: "version": "5.2.1"
docker compose exec grafana cat /var/lib/grafana/plugins/alexanderzobnin-zabbix-app/plugin.json | grep version
```

## POR QUE ISSO ACONTECE?

### Problema 1: Repositório do grafana-cli

O comando `grafana-cli plugins install alexanderzobnin-zabbix-app` instala a **versão mais recente disponível no repositório oficial do Grafana**, que pode não ser compatível com sua versão do Grafana.

### Problema 2: Gerenciamento Automático

O Grafana possui um sistema de **gerenciamento automático de plugins** que pode:
- Atualizar plugins automaticamente
- Substituir versões manuais por versões do marketplace
- Instalar versões incompatíveis

### Solução: Montagem Read-Only

Ao montar o plugin diretamente do sistema de arquivos como **read-only** (`:ro`), o Grafana:
- **NÃO PODE** modificar o plugin
- **NÃO PODE** atualizá-lo automaticamente
- **NÃO PODE** substituí-lo por outra versão
- Mantém a versão **5.2.1** permanentemente

## TROUBLESHOOTING

### Plugin não carrega após restart

```bash
# Verificar se diretório existe
ls -la alexanderzobnin-zabbix-app/

# Verificar montagem
docker compose exec grafana ls -la /var/lib/grafana/plugins/

# Verificar logs
docker compose logs grafana | grep -i plugin
```

### Erro: "Plugin signature invalid"

Adicione ao docker-compose.yml (se ainda não tiver):

```yaml
GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS: alexanderzobnin-zabbix-datasource
```

### Plugin desaparece após recrear container

Certifique-se que:
1. Diretório `alexanderzobnin-zabbix-app/` está no mesmo local do `docker-compose.yml`

2. Volume está montado corretamente no docker-compose.yml:
   ```yaml
   - ./alexanderzobnin-zabbix-app:/var/lib/grafana/plugins/alexanderzobnin-zabbix-app:ro
   ```

### Versão ainda muda

Se mesmo com `:ro` a versão mudar:

```bash
# 1. Remover completamente plugins do volume
docker volume rm zabbix-grafana-docker_grafana-data

# 2. Recriar
docker compose up -d

# 3. Verificar
docker compose exec grafana cat /var/lib/grafana/plugins/alexanderzobnin-zabbix-app/plugin.json | grep version
```

## REFERÊNCIAS

- Plugin Zabbix GitHub: https://github.com/grafana/grafana-zabbix
- Documentação Oficial: https://grafana.com/grafana/plugins/alexanderzobnin-zabbix-app/
- Issue Zabbix 7.0 Support: https://github.com/grafana/grafana-zabbix/issues/1914
