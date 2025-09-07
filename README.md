# SGBD_colunas
repositorio criado para instalação do ClickHouse
ClickHouse - SGBD Orientado a Colunas
Este repositório contém scripts e instruções para instalação do ClickHouse no Windows 11.
📋 Pré-requisitos

Windows 11
PowerShell (já incluído no Windows)
Conexão com internet
Privilégios de administrador

🚀 Instalação Rápida
Opção 1: Script Automático (Recomendado)

Baixe o script install-clickhouse.ps1
Abra o PowerShell como Administrador
Execute o script:

powershell# Permitir execução de scripts (apenas uma vez)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Executar o script de instalação
.\install-clickhouse.ps1
Opção 2: Instalação Manual

Baixar o ClickHouse:
powershell# Criar diretório
mkdir C:\ClickHouse
cd C:\ClickHouse

# Baixar executáveis
Invoke-WebRequest -Uri "https://builds.clickhouse.com/master/windows/clickhouse.exe" -OutFile "clickhouse.exe"

Configurar o Banco:
powershell# Criar diretórios necessários
mkdir data
mkdir logs
mkdir config

# Copiar configuração padrão
copy config.xml config\

Iniciar o Servidor:
powershell.\clickhouse.exe server --config-file=config\config.xml


⚙️ Configuração
Arquivo de Configuração (config.xml)
O arquivo config.xml já está configurado com:

Porta padrão: 8123 (HTTP) e 9000 (TCP)
Diretório de dados: ./data
Logs: ./logs
Usuário padrão sem senha (para desenvolvimento)

Conectar ao Banco

Via Cliente (Terminal):
powershell.\clickhouse.exe client

Via Interface Web:

Acesse: http://localhost:8123/play
Usuário: default
Senha: (deixe em branco)


Via HTTP API:
bashcurl "http://localhost:8123/?query=SELECT version()"


🗃️ Comandos Básicos
Criar Database
sqlCREATE DATABASE exemplo_db;
USE exemplo_db;
Criar Tabela (Exemplo)
sqlCREATE TABLE vendas (
    data Date,
    produto String,
    categoria String,
    quantidade UInt32,
    valor Float32
) ENGINE = MergeTree()
ORDER BY data;
Inserir Dados
sqlINSERT INTO vendas VALUES 
    ('2024-01-01', 'Notebook', 'Eletrônicos', 10, 2500.00),
    ('2024-01-02', 'Mouse', 'Periféricos', 50, 25.00),
    ('2024-01-03', 'Teclado', 'Periféricos', 30, 80.00);
Consultas Analíticas
sql-- Total de vendas por categoria
SELECT 
    categoria,
    sum(quantidade * valor) as total_vendas
FROM vendas
GROUP BY categoria
ORDER BY total_vendas DESC;

-- Média de vendas por dia
SELECT 
    data,
    avg(valor) as valor_medio
FROM vendas
GROUP BY data;
🔧 Scripts Úteis
Iniciar Servidor como Serviço
Execute setup-service.ps1 para configurar o ClickHouse como serviço do Windows:
powershell.\setup-service.ps1
Backup de Dados
powershell# Criar backup
.\clickhouse.exe client --query "BACKUP DATABASE exemplo_db TO 'backup_$(Get-Date -Format 'yyyyMMdd').tar'"
📊 Monitoramento

System Queries: SELECT * FROM system.processes
Métricas: SELECT * FROM system.metrics
Logs: Verifique a pasta logs/

🔍 Troubleshooting
Problemas Comuns

Porta já em uso:
powershellnetstat -ano | findstr :8123

Permissões de arquivo:
powershell# Dar permissões completas ao diretório
icacls C:\ClickHouse /grant Everyone:F /t

Firewall do Windows:

Adicione exceção para as portas 8123 e 9000
Ou execute: New-NetFirewallRule -DisplayName "ClickHouse" -Direction Inbound -Port 8123,9000 -Protocol TCP -Action Allow



Verificar Status
sqlSELECT 
    name,
    value
FROM system.settings 
WHERE name LIKE '%version%';
