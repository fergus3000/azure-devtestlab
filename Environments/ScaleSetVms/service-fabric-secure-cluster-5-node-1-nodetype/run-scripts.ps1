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

& ($PSScriptRoot + "\install-couchbase.ps1")
& ($PSScriptRoot + "\install-buildagent.ps1") -ServerUrl $ServerUrl -PersonalAccessToken $PersonalAccessToken -PoolName $PoolName -AgentName $AgentName
