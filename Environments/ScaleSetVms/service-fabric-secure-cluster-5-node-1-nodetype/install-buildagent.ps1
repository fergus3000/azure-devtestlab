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

if (isNodeOne($ipAddress)) {
    $CurDir = get-location
    mkdir c:\agent
    Set-Location c:\agent
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$CurDir\vsts-agent-win-x64-2.139.1.zip", "$PWD")

    Set-Location $CurDir

    .\config.cmd --unattended --url $ServerUrl --auth PAT --token $PersonalAccessToken --pool $PoolName --agent $AgentName --runasservice
}