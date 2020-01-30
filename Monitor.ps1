# Reinicar Pools parados
# Ivo Dias

# Verifica se o modulo esta instalado
function Configurar-Modulo {
    param (
        $nomeModulo
    )
    # Caso ele exista, faz apenas a importacao
    if (Get-Module -ListAvailable -Name $nomeModulo) {
        Write-Host "Importando modulos"
        Import-Module $nomeModulo -Force
    } else {
        Write-Host "Instalando modulos necessarios"
        Install-Module $nomeModulo -Force
        Import-Module $nomeModulo -Force
    }
}

# Configurando modulos necessarios
Configurar-Modulo "WebAdministration"
# Define a localizacao
set-Location IIS:\AppPools

# Recebe todos os Pools
$ApplicationPools = Get-ChildItem

# Verifica na lista
foreach ($AppPool in $ApplicationPools) {
    try {
        $ApplicationPoolName = $AppPool.Name
        $ApplicationPoolStatus = $AppPool.state
        Write-Host "$ApplicationPoolName -> $ApplicationPoolStatus"
    
        if($ApplicationPoolStatus -ne "Started") {
            Write-Host "-----> $ApplicationPoolName esta parado."
            Start-WebAppPool -Name $ApplicationPoolName
            Write-Host "-----> $ApplicationPoolName foi reiniciado."
        } 
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Write-Host "Ocorreu um erro ao verificar $ApplicationPoolName"
        Write-Host "Error: $ErrorMessage"
    }
}