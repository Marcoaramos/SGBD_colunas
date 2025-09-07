🦆 DuckDB - SGBD Orientado a Colunas para Windows 11

Sistema de Banco de Dados Orientado a Colunas com instalação automatizada para Windows 11.
DuckDB é um SGBD orientado a colunas, ideal para análises de dados, com instalação simples e alta performance em consultas analíticas.
📋 Pré-requisitos

✅ Windows 11
✅ PowerShell (já incluído no Windows)
✅ Conexão com internet
✅ Privilégios de administrador

🚀 Instalação Rápida
Método 1: Clone do Repositório
powershell# 1. Clonar repositório
git clone https://github.com/seu-usuario/duckdb-windows.git
cd duckdb-windows

# 2. Executar como Administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install-duckdb.ps1
Método 2: Download Direto

Baixe o arquivo install-duckdb.ps1
Abra PowerShell como Administrador
Execute: .\install-duckdb.ps1

📊 O que você ganha

🦆 DuckDB instalado e configurado
📁 Banco de exemplo com 10 registros de vendas
🖥️ Atalhos no desktop para fácil acesso
📈 Consultas analíticas pré-configuradas
📝 Scripts de exemplo inclusos

💻 Como Usar
Iniciar DuckDB:

Desktop: Clique em "DuckDB - SGBD Colunas"
PowerShell: Execute C:\DuckDB\start-duckdb.bat
Direto: C:\DuckDB\duckdb.exe exemplo.db

Comandos Básicos:
sql.tables                  -- Listar tabelas
SELECT * FROM vendas;    -- Ver dados de exemplo
.help                    -- Ajuda
.exit                    -- Sair
📈 Dados de Exemplo
A instalação cria automaticamente uma tabela vendas com:
CampoTipoExemploidINTEGER1dataDATE2024-01-01produtoVARCHARNotebook DellcategoriaVARCHAREletrônicosquantidadeINTEGER2valor_unitarioDECIMAL2500.00descontoDECIMAL5.00vendedorVARCHARJoão SilvaregiaoVARCHARSul
10 registros simulando vendas de uma loja de informática.
🔍 Consultas Analíticas de Exemplo
1. Faturamento por Categoria:
sqlSELECT 
    categoria,
    COUNT(*) as total_vendas,
    SUM(quantidade) as total_quantidade,
    SUM(quantidade * valor_unitario * (1 - desconto/100)) as faturamento,
    ROUND(AVG(valor_unitario), 2) as ticket_medio
FROM vendas 
GROUP BY categoria 
ORDER BY faturamento DESC;
2. Performance por Vendedor:
sqlSELECT 
    vendedor,
    COUNT(*) as vendas_realizadas,
    SUM(quantidade * valor_unitario * (1 - desconto/100)) as total_faturado,
    ROUND(AVG(quantidade * valor_unitario * (1 - desconto/100)), 2) as venda_media
FROM vendas 
GROUP BY vendedor 
ORDER BY total_faturado DESC;
3. Análise Regional:
sqlSELECT 
    regiao,
    COUNT(DISTINCT produto) as produtos_vendidos,
    SUM(quantidade) as total_unidades,
    SUM(quantidade * valor_unitario * (1 - desconto/100)) as receita_total
FROM vendas 
GROUP BY regiao 
ORDER BY receita_total DESC;
4. Ranking de Produtos:
sqlSELECT 
    produto,
    categoria,
    SUM(quantidade) as unidades_vendidas,
    SUM(quantidade * valor_unitario) as receita_bruta,
    RANK() OVER (ORDER BY SUM(quantidade * valor_unitario) DESC) as ranking
FROM vendas 
GROUP BY produto, categoria 
ORDER BY receita_bruta DESC;
🛠️ Comandos Úteis DuckDB
sql-- SISTEMA
.help                           -- Ajuda completa
.tables                         -- Listar tabelas
.schema vendas                  -- Estrutura da tabela
.databases                      -- Bancos conectados

-- FORMATAÇÃO
.mode table                     -- Formato tabela
.mode csv                       -- Formato CSV  
.headers on                     -- Mostrar cabeçalhos

-- ARQUIVOS
.read arquivo.sql               -- Executar SQL de arquivo
.output resultado.csv           -- Exportar próxima consulta
.backup backup.db               -- Backup do banco
📁 Estrutura Instalada
C:\DuckDB\
├── duckdb.exe                  # Executável principal
├── exemplo.db                  # Banco com dados de exemplo
├── start-duckdb.bat           # Script de inicialização
├── novo-banco.bat             # Criar novo banco
├── scripts\
│   ├── dados_exemplo.sql      # SQL dos dados de exemplo
│   └── comandos_uteis.sql     # Comandos e consultas úteis
├── logs\                      # Logs do sistema
└── backup\                    # Diretório para backups
🔧 Resolução de Problemas
Erro: "não é reconhecido como cmdlet"
powershell# Verificar localização
pwd
cd "caminho/correto"

# OU executar com caminho completo
& "C:\caminho\install-duckdb.ps1"
Erro: "arquivo não pode ser carregado"
powershell# Liberar execução de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# OU forçar
PowerShell.exe -ExecutionPolicy Bypass -File ".\install-duckdb.ps1"
Erro: "Tabela vendas não existe"
sql-- Recriar dados de exemplo
.read C:\DuckDB\scripts\dados_exemplo.sql
DuckDB travado/ocupado
powershell# Parar processos
Get-Process -Name "duckdb" | Stop-Process -Force
⚡ Por que DuckDB?
✅ Vantagens:

Instalação simples: Um único arquivo executável
Zero configuração: Funciona imediatamente
SQL padrão: Compatível com SQL que você já conhece
Alta performance: Otimizado para análises
Leve: Baixo uso de memória e CPU
Embarcado: Não precisa de servidor separado

🎯 Ideal para:

Análise de dados locais
Prototipagem de analytics
Relatórios e dashboards
ETL e processamento de dados
Aprendizado de SQL analítico

📊 Performance:

Datasets: Até alguns GB facilmente
Consultas: Segundos para milhões de registros
Memória: Otimizada automaticamente
Compressão: Dados comprimidos automaticamente

📚 Recursos Adicionais

📖 Documentação Oficial DuckDB
🎓 Tutorial SQL Analytics
🔗 Conectores e APIs
📈 Funções Analíticas

🔄 Próximos Passos
Após a instalação:

Explorar dados: SELECT * FROM vendas LIMIT 5;
Testar agregações: Use as consultas de exemplo acima
Criar suas tabelas: .read seus_dados.sql
Fazer backup: .backup meu_backup.db

🤝 Contribuindo

Fork este repositório
Crie sua branch: git checkout -b feature/melhoria
Commit: git commit -am 'Adiciona nova funcionalidade'
Push: git push origin feature/melhoria
Abra um Pull Request

📄 Licença
Este projeto está sob a licença MIT. Veja LICENSE para detalhes.

🚀 Comece Agora!
powershell# Download e execução em uma linha:
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/seu-usuario/duckdb-windows/main/install-duckdb.ps1" -OutFile "install-duckdb.ps1"; .\install-duckdb.ps1
✨ Status: Testado e Funcionando

✅ Windows 11 compatível
✅ Instalação automatizada
✅ Dados de exemplo funcionais
✅ Consultas analíticas testadas

Última atualização: Setembro 2025 | Versão DuckDB: v1.3.2
