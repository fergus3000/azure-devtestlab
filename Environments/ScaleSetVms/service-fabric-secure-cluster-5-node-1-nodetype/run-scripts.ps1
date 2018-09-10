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

#& ($PSScriptRoot + "\install-buildagent.ps1") -ServerUrl $ServerUrl -PersonalAccessToken $PersonalAccessToken -PoolName $PoolName -AgentName $AgentName
Start-Process -FilePath "$PSScriptRoot\install-buildagent.ps1" -ArgumentList "-ServerUrl $ServerUrl -PersonalAccessToken $PersonalAccessToken -PoolName $PoolName -AgentName $AgentName" -PassThru -Wait
& ($PSScriptRoot + "\install-couchbase.ps1")
