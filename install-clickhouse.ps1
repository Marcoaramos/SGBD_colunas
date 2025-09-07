# ClickHouse Installation Script for Windows 11
# Autor: Script de instalação automatizada
# Versão: 1.0

Write-Host "=== ClickHouse Installation Script ===" -ForegroundColor Green
Write-Host "Iniciando instalação do ClickHouse..." -ForegroundColor Yellow

# Verificar privilégios de administrador
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Este script precisa ser executado como Administrador!"
    Write-Host "Clique com botão direito no PowerShell e selecione 'Executar como Administrador'" -ForegroundColor Red
    pause
    exit 1
}

# Configurações
$InstallDir = "C:\ClickHouse"
$DownloadUrl = "https://builds.clickhouse.com/master/windows/clickhouse.exe"
$ServiceName = "ClickHouse"

try {
    # Criar diretório de instalação
    Write-Host "Criando diretório de instalação: $InstallDir" -ForegroundColor Blue
    if (Test-Path $InstallDir) {
        Write-Host "Diretório já existe, removendo versão anterior..." -ForegroundColor Yellow
        Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

    # Criar subdiretórios
    Write-Host "Criando estrutura de diretórios..." -ForegroundColor Blue
    $subDirs = @("data", "logs", "config", "backup")
    foreach ($dir in $subDirs) {
        New-Item -ItemType Directory -Path "$InstallDir\$dir" -Force | Out-Null
    }

    # Baixar ClickHouse
    Write-Host "Baixando ClickHouse..." -ForegroundColor Blue
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $DownloadUrl -OutFile "$InstallDir\clickhouse.exe"
    Write-Host "Download concluído!" -ForegroundColor Green

    # Criar arquivo de configuração
    Write-Host "Criando arquivo de configuração..." -ForegroundColor Blue
    $configXml = @"
<?xml version="1.0"?>
<clickhouse>
    <logger>
        <level>information</level>
        <log>logs/clickhouse-server.log</log>
        <errorlog>logs/clickhouse-server.err.log</errorlog>
        <size>1000M</size>
        <count>10</count>
    </logger>
    
    <http_port>8123</http_port>
    <tcp_port>9000</tcp_port>
    
    <listen_host>0.0.0.0</listen_host>
    
    <max_connections>4096</max_connections>
    <keep_alive_timeout>3</keep_alive_timeout>
    <max_concurrent_queries>100</max_concurrent_queries>
    <uncompressed_cache_size>8589934592</uncompressed_cache_size>
    <mark_cache_size>5368709120</mark_cache_size>
    
    <path>data/</path>
    <tmp_path>data/tmp/</tmp_path>
    <user_files_path>data/user_files/</user_files_path>
    <format_schema_path>data/format_schemas/</format_schema_path>
    
    <users_config>users.xml</users_config>
    <default_profile>default</default_profile>
    <default_database>default</default_database>
    <timezone>America/Sao_Paulo</timezone>
    
    <mlock_executable>false</mlock_executable>
</clickhouse>
"@
    
    $configXml | Out-File -FilePath "$InstallDir\config\config.xml" -Encoding UTF8

    # Criar arquivo de usuários
    Write-Host "Criando configuração de usuários..." -ForegroundColor Blue
    $usersXml = @"
<?xml version="1.0"?>
<clickhouse>
    <profiles>
        <default>
            <max_memory_usage>10000000000</max_memory_usage>
            <use_uncompressed_cache>0</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
        </default>
    </profiles>
    
    <users>
        <default>
            <password></password>
            <networks incl="networks" replace="replace">
                <ip>::/0</ip>
            </networks>
            <profile>default</profile>
            <quota>default</quota>
        </default>
    </users>
    
    <quotas>
        <default>
            <interval>
                <duration>3600</duration>
                <queries>0</queries>
                <errors>0</errors>
                <result_rows>0</result_rows>
                <read_rows>0</read_rows>
                <execution_time>0</execution_time>
            </interval>
        </default>
    </quotas>
</clickhouse>
"@
    
    $usersXml | Out-File -FilePath "$InstallDir\config\users.xml" -Encoding UTF8

    # Criar script de inicialização
    Write-Host "Criando scripts de controle..." -ForegroundColor Blue
    $startScript = @"
@echo off
cd /d "C:\ClickHouse"
echo Iniciando ClickHouse Server...
clickhouse.exe server --config-file=config\config.xml
pause
"@
    
    $startScript | Out-File -FilePath "$InstallDir\start-server.bat" -Encoding ASCII

    $clientScript = @"
@echo off
cd /d "C:\ClickHouse"
echo Conectando ao ClickHouse...
clickhouse.exe client
pause
"@
    
    $clientScript | Out-File -FilePath "$InstallDir\start-client.bat" -Encoding ASCII

    # Configurar variáveis de ambiente
    Write-Host "Configurando variáveis de ambiente..." -ForegroundColor Blue
    $env:PATH += ";$InstallDir"
    [Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$InstallDir", [EnvironmentVariableTarget]::Machine)

    # Configurar regras do firewall
    Write-Host "Configurando firewall..." -ForegroundColor Blue
    try {
        New-NetFirewallRule -DisplayName "ClickHouse HTTP" -Direction Inbound -Port 8123 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName "ClickHouse TCP" -Direction Inbound -Port 9000 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue
        Write-Host "Regras de firewall criadas com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "Aviso: Não foi possível configurar o firewall automaticamente" -ForegroundColor Yellow
    }

    # Criar banco de dados de exemplo
    Write-Host "Criando estrutura inicial..." -ForegroundColor Blue
    Start-Process -FilePath "$InstallDir\clickhouse.exe" -ArgumentList "server --config-file=config\config.xml --daemon" -WorkingDirectory $InstallDir -WindowStyle Hidden

    Start-Sleep -Seconds 5

    # Testar conexão e criar exemplo
    try {
        $testQuery = "SELECT version()"
        $result = & "$InstallDir\clickhouse.exe" client --query $testQuery 2>$null
        if ($result) {
            Write-Host "Servidor iniciado com sucesso!" -ForegroundColor Green
            
            # Criar banco de exemplo
            & "$InstallDir\clickhouse.exe" client --query "CREATE DATABASE IF NOT EXISTS exemplo"
            & "$InstallDir\clickhouse.exe" client --query "CREATE TABLE IF NOT EXISTS exemplo.vendas (data Date, produto String, quantidade UInt32, valor Float32) ENGINE = MergeTree() ORDER BY data"
            & "$InstallDir\clickhouse.exe" client --query "INSERT INTO exemplo.vendas VALUES ('2024-01-01', 'Produto A', 10, 100.50), ('2024-01-02', 'Produto B', 15, 75.25)"
            
            Write-Host "Banco de exemplo 'exemplo.vendas' criado com dados de teste!" -ForegroundColor Green
        }
    } catch {
        Write-Host "Servidor instalado, mas não foi possível criar o banco de exemplo" -ForegroundColor Yellow
    }

    # Criar atalhos no desktop
    Write-Host "Criando atalhos..." -ForegroundColor Blue
    $WshShell = New-Object -comObject WScript.Shell
    
    # Atalho para servidor
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\ClickHouse Server.lnk")
    $Shortcut.TargetPath = "$InstallDir\start-server.bat"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Save()
    
    # Atalho para cliente
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\ClickHouse Client.lnk")
    $Shortcut.TargetPath = "$InstallDir\start-client.bat"
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Save()

    Write-Host ""
    Write-Host "=== INSTALAÇÃO CONCLUÍDA COM SUCESSO! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "ClickHouse foi instalado em: $InstallDir" -ForegroundColor White
    Write-Host ""
    Write-Host "Como usar:" -ForegroundColor Yellow
    Write-Host "1. Interface Web: http://localhost:8123/play" -ForegroundColor White
    Write-Host "2. Cliente: Execute 'ClickHouse Client' no desktop" -ForegroundColor White
    Write-Host "3. Servidor: Execute 'ClickHouse Server' no desktop" -ForegroundColor White
    Write-Host ""
    Write-Host "Usuário padrão: default (sem senha)" -ForegroundColor Cyan
    Write-Host "Banco de exemplo: exemplo.vendas" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Para testar, execute:" -ForegroundColor Yellow
    Write-Host "SELECT * FROM exemplo.vendas;" -ForegroundColor White

} catch {
    Write-Error "Erro durante a instalação: $($_.Exception.Message)"
    Write-Host "Por favor, execute o script novamente ou instale manualmente" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Gray
pause
