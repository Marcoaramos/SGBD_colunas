# DuckDB Installation Script for Windows 11
# SGBD Orientado a Colunas - Instalação Automatizada
# Versão: 1.0 - Testado e Funcionando

Write-Host "🦆 DuckDB Installation Script" -ForegroundColor Green
Write-Host "SGBD Orientado a Colunas para Windows 11" -ForegroundColor Cyan
Write-Host "Iniciando instalação..." -ForegroundColor Yellow

# Verificar privilégios de administrador
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "⚠️  Este script precisa ser executado como Administrador!"
    Write-Host "👉 Clique com botão direito no PowerShell e selecione 'Executar como Administrador'" -ForegroundColor Red
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..." -ForegroundColor Gray
    pause
    exit 1
}

# Configurações
$InstallDir = "C:\DuckDB"
$DuckDBUrl = "https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-windows-amd64.zip"

try {
    # Parar processos do DuckDB se estiverem rodando
    Write-Host "🔍 Verificando processos em execução..." -ForegroundColor Blue
    Get-Process -Name "duckdb" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2

    # Criar diretório de instalação
    Write-Host "📁 Criando diretório: $InstallDir" -ForegroundColor Blue
    if (Test-Path $InstallDir) {
        Write-Host "   Diretório existe, atualizando..." -ForegroundColor Yellow
        # Remover apenas arquivos, manter dados
        Remove-Item "$InstallDir\*.exe" -Force -ErrorAction SilentlyContinue
        Remove-Item "$InstallDir\*.bat" -Force -ErrorAction SilentlyContinue
    } else {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    # Criar subdiretórios
    Write-Host "🗂️  Criando estrutura de pastas..." -ForegroundColor Blue
    $subDirs = @("scripts", "backup", "logs")
    foreach ($dir in $subDirs) {
        New-Item -ItemType Directory -Path "$InstallDir\$dir" -Force | Out-Null
    }

    # Baixar DuckDB
    Write-Host "⬇️  Baixando DuckDB..." -ForegroundColor Blue
    $ProgressPreference = 'SilentlyContinue'
    $zipFile = "$InstallDir\duckdb.zip"
    
    try {
        Invoke-WebRequest -Uri $DuckDBUrl -OutFile $zipFile -UseBasicParsing
        Write-Host "   ✅ Download concluído!" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Erro no download, tentando URL alternativa..." -ForegroundColor Yellow
        $altUrl = "https://github.com/duckdb/duckdb/releases/download/v1.0.0/duckdb_cli-windows-amd64.zip"
        Invoke-WebRequest -Uri $altUrl -OutFile $zipFile -UseBasicParsing
        Write-Host "   ✅ Download alternativo concluído!" -ForegroundColor Green
    }

    # Extrair DuckDB
    Write-Host "📦 Extraindo arquivos..." -ForegroundColor Blue
    Expand-Archive -Path $zipFile -DestinationPath $InstallDir -Force
    Remove-Item $zipFile -Force

    # Verificar instalação
    if (-not (Test-Path "$InstallDir\duckdb.exe")) {
        throw "❌ Erro: Executável do DuckDB não encontrado"
    }

    $fileSize = (Get-Item "$InstallDir\duckdb.exe").Length
    Write-Host "   ✅ DuckDB instalado! Tamanho: $([math]::round($fileSize/1MB,2)) MB" -ForegroundColor Green

    # Criar script de inicialização
    Write-Host "⚙️  Criando scripts..." -ForegroundColor Blue
    
    $startScript = @"
@echo off
title DuckDB - SGBD Orientado a Colunas
cd /d "C:\DuckDB"
cls
echo.
echo 🦆 ===============================================
echo    DuckDB - SGBD Orientado a Colunas  
echo ===============================================
echo.
echo 📊 Banco de exemplo: exemplo.db
echo 📋 Tabela de exemplo: vendas (10 registros)
echo.
echo 💡 Comandos úteis:
echo    .tables           # Listar tabelas
echo    .help            # Ajuda completa
echo    .exit            # Sair
echo.
echo    SELECT * FROM vendas;              # Ver dados
echo    SELECT categoria, COUNT(*) FROM vendas GROUP BY categoria;
echo.
echo 🔌 Conectando ao banco de exemplo...
echo.
duckdb.exe exemplo.db
echo.
echo 👋 Sessão DuckDB finalizada.
pause
"@
    
    $startScript | Out-File -FilePath "$InstallDir\start-duckdb.bat" -Encoding ASCII

    # Script para novo banco
    $newBankScript = @"
@echo off
title Novo Banco DuckDB
cd /d "C:\DuckDB"
cls
echo.
echo 🦆 Criar Novo Banco DuckDB
echo ========================
echo.
set /p dbname="📝 Digite o nome do banco (sem .db): "
if "%dbname%"=="" (
    echo ❌ Nome inválido!
    pause
    exit /b
)
echo.
echo 📊 Criando banco %dbname%.db...
echo 💡 Use .exit para sair quando terminar
echo.
duckdb.exe %dbname%.db
pause
"@
    
    $newBankScript | Out-File -FilePath "$InstallDir\novo-banco.bat" -Encoding ASCII

    # Dados de exemplo
    Write-Host "📊 Preparando dados de exemplo..." -ForegroundColor Blue
    $exemploSQL = @"
-- ====================================================
--  DUCKDB - DADOS DE EXEMPLO  
--  SGBD Orientado a Colunas
-- ====================================================

-- Remover tabela se existir
DROP TABLE IF EXISTS vendas;

-- Criar tabela de vendas
CREATE TABLE vendas (
    id INTEGER PRIMARY KEY,
    data DATE NOT NULL,
    produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    quantidade INTEGER NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(5,2) DEFAULT 0.00,
    vendedor VARCHAR(50),
    regiao VARCHAR(30)
);

-- Inserir dados de exemplo
INSERT INTO vendas VALUES 
    (1, '2024-01-01', 'Notebook Dell Inspiron', 'Eletrônicos', 2, 2500.00, 5.00, 'João Silva', 'Sul'),
    (2, '2024-01-02', 'Mouse Logitech MX', 'Periféricos', 15, 35.90, 0.00, 'Maria Santos', 'Nordeste'),
    (3, '2024-01-03', 'Teclado Mecânico RGB', 'Periféricos', 8, 150.00, 10.00, 'Pedro Costa', 'Sudeste'),
    (4, '2024-01-04', 'Monitor 24" Samsung', 'Eletrônicos', 5, 899.99, 15.00, 'Ana Oliveira', 'Sul'),
    (5, '2024-01-05', 'SSD 1TB Kingston', 'Componentes', 12, 299.90, 0.00, 'Carlos Lima', 'Centro-Oeste'),
    (6, '2024-01-06', 'Placa de Vídeo RTX 4070', 'Componentes', 3, 3200.00, 8.00, 'João Silva', 'Sul'),
    (7, '2024-01-07', 'Webcam Logitech C920', 'Periféricos', 20, 180.00, 5.00, 'Maria Santos', 'Nordeste'),
    (8, '2024-01-08', 'Smartphone Samsung S24', 'Eletrônicos', 7, 1200.00, 12.00, 'Pedro Costa', 'Sudeste'),
    (9, '2024-01-09', 'Tablet iPad Air', 'Eletrônicos', 4, 2800.00, 0.00, 'Ana Oliveira', 'Sul'),
    (10, '2024-01-10', 'Headset Gamer HyperX', 'Periféricos', 25, 89.90, 15.00, 'Carlos Lima', 'Centro-Oeste');

-- Verificar criação
SELECT '✅ DADOS CRIADOS COM SUCESSO!' as status;
SELECT '📊 Total de registros: ' || COUNT(*) as info FROM vendas;
SELECT '📈 Categorias: ' || COUNT(DISTINCT categoria) as info FROM vendas;
SELECT '👥 Vendedores: ' || COUNT(DISTINCT vendedor) as info FROM vendas;
"@
    
    $exemploSQL | Out-File -FilePath "$InstallDir\scripts\dados_exemplo.sql" -Encoding UTF8

    # Consultas de exemplo
    $consultasSQL = @"
-- ====================================================
--  CONSULTAS ANALÍTICAS - DUCKDB
--  Exemplos de uso do SGBD Orientado a Colunas
-- ====================================================

-- 1. FATURAMENTO POR CATEGORIA
SELECT '🏷️ ANÁLISE POR CATEGORIA' as titulo;
SELECT 
    categoria,
    COUNT(*) as vendas,
    SUM(quantidade) as unidades,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento,
    ROUND(AVG(valor_unitario), 2) as preco_medio
FROM vendas 
GROUP BY categoria 
ORDER BY faturamento DESC;

-- 2. PERFORMANCE POR VENDEDOR  
SELECT '👤 PERFORMANCE VENDEDORES' as titulo;
SELECT 
    vendedor,
    COUNT(*) as vendas_realizadas,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as total_faturado,
    ROUND(AVG(quantidade * valor_unitario * (1 - desconto/100)), 2) as venda_media
FROM vendas 
GROUP BY vendedor 
ORDER BY total_faturado DESC;

-- 3. ANÁLISE REGIONAL
SELECT '🗺️ ANÁLISE POR REGIÃO' as titulo;
SELECT 
    regiao,
    COUNT(DISTINCT produto) as produtos_diferentes,
    SUM(quantidade) as total_unidades,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as receita_total
FROM vendas 
GROUP BY regiao 
ORDER BY receita_total DESC;

-- 4. RANKING DE PRODUTOS
SELECT '🏆 TOP PRODUTOS' as titulo;
SELECT 
    produto,
    categoria,
    SUM(quantidade) as unidades_vendidas,
    ROUND(SUM(quantidade * valor_unitario), 2) as receita_bruta,
    RANK() OVER (ORDER BY SUM(quantidade * valor_unitario) DESC) as ranking
FROM vendas 
GROUP BY produto, categoria 
ORDER BY receita_bruta DESC;

-- 5. ANÁLISE TEMPORAL (por data)
SELECT '📅 VENDAS POR DIA' as titulo;
SELECT 
    data,
    COUNT(*) as vendas_do_dia,
    SUM(quantidade) as unidades_vendidas,
    ROUND(SUM(quantidade * valor_unitario * (1 - desconto/100)), 2) as faturamento_dia
FROM vendas 
GROUP BY data 
ORDER BY data;
"@
    
    $consultasSQL | Out-File -FilePath "$InstallDir\scripts\consultas_exemplo.sql" -Encoding UTF8

    # Executar criação do banco
    Write-Host "🗃️  Criando banco de exemplo..." -ForegroundColor Blue
    
    # Remover banco anterior se existir
    if (Test-Path "$InstallDir\exemplo.db") {
        Remove-Item "$InstallDir\exemplo.db" -Force
    }
    
    # Executar SQL
    $result = & "$InstallDir\duckdb.exe" "$InstallDir\exemplo.db" ".read $InstallDir\scripts\dados_exemplo.sql" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Banco de exemplo criado!" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Aviso: Possível erro na criação do banco" -ForegroundColor Yellow
        Write-Host "   Resultado: $result" -ForegroundColor Gray
    }

    # Configurar PATH
    Write-Host "🔗 Configurando variáveis de ambiente..." -ForegroundColor Blue
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
    if (-not $currentPath.Contains($InstallDir)) {
        [Environment]::SetEnvironmentVariable("PATH", $currentPath + ";$InstallDir", [EnvironmentVariableTarget]::User)
        $env:PATH += ";$InstallDir"
        Write-Host "   ✅ PATH configurado" -ForegroundColor Green
    }

    # Criar atalhos no desktop
    Write-Host "🖥️  Criando atalhos no desktop..." -ForegroundColor Blue
    $WshShell = New-Object -comObject WScript.Shell
    
    # Atalho principal
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\🦆 DuckDB - SGBD Colunas.lnk")
    $Shortcut.TargetPath = "$InstallDir\start-duckdb.bat"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "DuckDB - Sistema de Banco Orientado a Colunas"
    $Shortcut.Save()
    
    # Atalho para novo banco
    $Shortcut2 = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\📊 Novo Banco DuckDB.lnk")
    $Shortcut2.TargetPath = "$InstallDir\novo-banco.bat"
    $Shortcut2.WorkingDirectory = $InstallDir
    $Shortcut2.Description = "Criar novo banco DuckDB"
    $Shortcut2.Save()

    Write-Host ""
    Write-Host "🎉 ===========================================" -ForegroundColor Green
    Write-Host "    INSTALAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green  
    Write-Host "🎉 ===========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 DuckDB instalado em: $InstallDir" -ForegroundColor White
    Write-Host ""
    Write-Host "🚀 Como usar:" -ForegroundColor Yellow
    Write-Host "   1. 🖥️  Desktop: Clique em '🦆 DuckDB - SGBD Colunas'" -ForegroundColor White
    Write-Host "   2. 💻 PowerShell: $InstallDir\start-duckdb.bat" -ForegroundColor White
    Write-Host "   3. 📊 Novo banco: Clique em '📊 Novo Banco DuckDB'" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 Dados de exemplo:" -ForegroundColor Cyan
    Write-Host "   📁 Banco: exemplo.db" -ForegroundColor White
    Write-Host "   📋 Tabela: vendas (10 registros)" -ForegroundColor White
    Write-Host "   🏷️  Categorias: Eletrônicos, Periféricos, Componentes" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Teste agora:" -ForegroundColor Yellow
    Write-Host "   SELECT * FROM vendas;" -ForegroundColor White
    Write-Host "   SELECT categoria, COUNT(*) FROM vendas GROUP BY categoria;" -ForegroundColor White
    Write-Host ""
    Write-Host "📚 Arquivos úteis:" -ForegroundColor Magenta
    Write-Host "   📜 $InstallDir\scripts\consultas_exemplo.sql" -ForegroundColor White
    Write-Host "   📝 $InstallDir\scripts\dados_exemplo.sql" -ForegroundColor White

    # Teste final
    Write-Host ""
    Write-Host "🧪 Teste rápido da instalação..." -ForegroundColor Blue
    try {
        $testResult = & "$InstallDir\duckdb.exe" "$InstallDir\exemplo.db" "SELECT COUNT(*) as registros FROM vendas;" 2>$null
        if ($testResult -and $testResult -like "*10*") {
            Write-Host "   ✅ Teste passou! Banco funcionando perfeitamente." -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Teste parcial - verifique manualmente" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ⚠️  Teste automático falhou - teste manual recomendado" -ForegroundColor Yellow
    }

} catch {
    Write-Error "❌ Erro durante a instalação: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "🔧 Soluções:" -ForegroundColor Yellow
    Write-Host "   1. Execute como Administrador" -ForegroundColor White
    Write-Host "   2. Verifique conexão com internet" -ForegroundColor White
    Write-Host "   3. Desative antivírus temporariamente" -ForegroundColor White
    Write-Host "   4. Execute: Set-ExecutionPolicy RemoteSigned" -ForegroundColor White
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..." -ForegroundColor Gray
    pause
    exit 1
}

Write-Host ""
Write-Host "🏁 Instalação finalizada! Pressione qualquer tecla..." -ForegroundColor Green
pause
