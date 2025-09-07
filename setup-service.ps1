# ClickHouse Windows Service Setup
# Este script configura o ClickHouse para rodar como serviço do Windows

Write-Host "=== ClickHouse Service Setup ===" -ForegroundColor Green

# Verificar privilégios
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Este script precisa ser executado como Administrador!"
    exit 1
}

$InstallDir = "C:\ClickHouse"
$ServiceName = "ClickHouse"
$ServiceDisplayName = "ClickHouse Database Server"

try {
    # Parar serviço se existir
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "Parando serviço existente..." -ForegroundColor Yellow
        Stop-Service -Name $ServiceName -Force
        & sc.exe delete $ServiceName
        Start-Sleep -Seconds 2
    }

    # Criar script wrapper para o serviço
    $serviceWrapper = @"
@echo off
cd /d "C:\ClickHouse"
clickhouse.exe server --config-file=config\config.xml
"@
    
    $serviceWrapper | Out-File -FilePath "$InstallDir\service.bat" -Encoding ASCII

    # Criar o serviço usando NSSM (Non-Sucking Service Manager)
    Write-Host "Baixando NSSM (Service Manager)..." -ForegroundColor Blue
    
    $nssmUrl = "https://nssm.cc/release/nssm-2.24.zip"
    $nssmZip = "$env:TEMP\nssm.zip"
    $nssmDir = "$env:TEMP\nssm"
    
    Invoke-WebRequest -Uri $nssmUrl -OutFile $nssmZip
    Expand-Archive -Path $nssmZip -DestinationPath $nssmDir -Force
    
    # Copiar NSSM para o diretório do ClickHouse
    $nssmExe = Get-ChildItem -Path $nssmDir -Name "nssm.exe" -Recurse | Select-Object -First 1
    $nssmPath = "$nssmDir\$($nssmExe.Directory)\nssm.exe"
    Copy-Item -Path $nssmPath -Destination "$InstallDir\nssm.exe"

    # Configurar serviço com NSSM
    Write-Host "Configurando serviço..." -ForegroundColor Blue
    
    & "$InstallDir\nssm.exe" install $ServiceName "$InstallDir\clickhouse.exe"
    & "$InstallDir\nssm.exe" set $ServiceName Parameters "server --config-file=config\config.xml"
    & "$InstallDir\nssm.exe" set $ServiceName AppDirectory $InstallDir
    & "$InstallDir\nssm.exe" set $ServiceName DisplayName $ServiceDisplayName
    & "$InstallDir\nssm.exe" set $ServiceName Description "ClickHouse OLAP Database Management System"
    & "$InstallDir\nssm.exe" set $ServiceName Start SERVICE_AUTO_START
    & "$InstallDir\nssm.exe" set $ServiceName AppStdout "$InstallDir\logs\service.log"
    & "$InstallDir\nssm.exe" set $ServiceName AppStderr "$InstallDir\logs\service.err"

    # Iniciar o serviço
    Write-Host "Iniciando serviço..." -ForegroundColor Blue
    Start-Service -Name $ServiceName
    
    # Verificar status
    $service = Get-Service -Name $ServiceName
    if ($service.Status -eq 'Running') {
        Write-Host ""
        Write-Host "=== SERVIÇO CONFIGURADO COM SUCESSO! ===" -ForegroundColor Green
        Write-Host ""
        Write-Host "O ClickHouse agora roda como serviço do Windows" -ForegroundColor White
        Write-Host "Status: $($service.Status)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Comandos úteis:" -ForegroundColor Yellow
        Write-Host "  Start-Service ClickHouse    # Iniciar" -ForegroundColor White
        Write-Host "  Stop-Service ClickHouse     # Parar" -ForegroundColor White
        Write-Host "  Restart-Service ClickHouse  # Reiniciar" -ForegroundColor White
        Write-Host ""
        Write-Host "O serviço inicia automaticamente com o Windows!" -ForegroundColor Cyan
    } else {
        throw "Falha ao iniciar o serviço"
    }

    # Limpeza
    Remove-Item $nssmZip -Force -ErrorAction SilentlyContinue
    Remove-Item $nssmDir -Recurse -Force -ErrorAction SilentlyContinue

} catch {
    Write-Error "Erro ao configurar serviço: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Alternativa: Use os atalhos do desktop para iniciar manualmente" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..."
pause
