# Verificar se um pool nao esta iniciado
# Ivo Dias

# Configuracoes
Import-Module WebAdministration
set-Location IIS:\AppPools

# Recebe todos os Pools
$ApplicationPools = Get-ChildItem

# Verifica na lista
foreach ($AppPool in $ApplicationPools) {
    $ApplicationPoolName = $AppPool.Name
    $ApplicationPoolStatus = $AppPool.state
    Write-Host "$ApplicationPoolName -> $ApplicationPoolStatus"

    if($ApplicationPoolStatus -ne "Started") {
        Write-Host "-----> $ApplicationPoolName esta parado."
        Start-WebAppPool -Name $ApplicationPoolName
        Write-Host "-----> $ApplicationPoolName foi reiniciado."
    }
}