Param
(
    [String]
    $ServerUrl,

    [String]
    $PersonalAccessToken,

    [String]
    $PoolName,

    [String]
    $AgentName
)


function isNodeOne($ipAddress) {
    return $ipAddress -eq "10.0.0.4"
}

Start-Transcript -Path 'c:\logs\run-scripts-ps1-transcript.txt'

Write-Host "running install-buildagent.ps1 "
Get-Date

& ($PSScriptRoot + "\install-buildagent.ps1") -ServerUrl $ServerUrl -PersonalAccessToken $PersonalAccessToken -PoolName $PoolName -AgentName $AgentName
#Start-Process -FilePath "$PSScriptRoot\install-buildagent.ps1" -ArgumentList "-ServerUrl $ServerUrl -PersonalAccessToken $PersonalAccessToken -PoolName $PoolName -AgentName $AgentName" -PassThru -Wait
Write-Host "running install-couchbase.ps1"
Get-Date

& ($PSScriptRoot + "\install-couchbase.ps1")

$ipAddress = (Get-NetIPAddress | ? { $_.AddressFamily -eq "IPv4" -and ($_.IPAddress -match "10.0.0") }).IPAddress
if (isNodeOne($ipAddress)) {

    Write-Host "Installing .net core sdk "
    Get-Date

    ./dotnet-sdk-2.1.401-win-x64.exe /install /norestart /quiet /log "c:\logs\Dotnet Core SDK 2.1.105.log"
    #Start-Process -FilePath "./dotnet-sdk-2.1.401-win-x64.exe" -ArgumentList "/install /norestart /quiet /log 'c:\logs\Dotnet Core SDK 2.1.105.log'" -PassThru -Wait

    Write-Host "Done installing .net core sdk "
    Get-Date
}
Write-Host "done"

Stop-Transcript