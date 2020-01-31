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

# Verifica se o IIS esta instalado
$iisStatus = (Get-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole).State
if ($iisStatus -eq "Enabled") {
    Write-Host "IIS esta configurado"
} else {
    Enable-WindowsOptionalFeature –online –featurename IIS-WebServerRole
}

# Configurando modulos necessarios
Configurar-Modulo "WebAdministration"
Configurar-Modulo "AzureRM.LogicApp"

# Define a localizacao
if (Test-Path "IIS:\AppPools") {
    set-Location IIS:\AppPools   
} else {
    Write-Host "Pasta do IIS nao disponivel"
}

# Faz login no Azure RM
Connect-AzureRmAccount

# Configuracoes do Azure RM
$nomeRG = "partsunlimited"
$nomeLogApp = "Monitor500"
$nomeTrigger = "RECURRENCE"

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
            try {
                Start-AzureRmLogicApp -ResourceGroupName "$nomeRG" -Name "$nomeLogApp" -TriggerName "$nomeTrigger" # Inicia o Logical App
                Start-WebAppPool -Name $ApplicationPoolName
                Write-Host "-----> $ApplicationPoolName foi reiniciado."
            }
            catch {
                $ErrorMessage = $_.Exception.Message # Recebe o erro
                Write-Host "Ocorreu um erro ao reiniciar o Pool $ApplicationPoolName"
                Write-Host "Error: $ErrorMessage"
            }    
        } 
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Write-Host "Ocorreu um erro ao verificar $ApplicationPoolName"
        Write-Host "Error: $ErrorMessage"
    }
}