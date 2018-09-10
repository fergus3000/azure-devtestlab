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

Start-Transcript -Path 'c:\logs\install-buildagent-ps1-transcript.txt'

$ipAddress = (Get-NetIPAddress | ? { $_.AddressFamily -eq "IPv4" -and ($_.IPAddress -match "10.0.0") }).IPAddress

if (isNodeOne($ipAddress)) {

    ./dotnet-sdk-2.1.401-win-x64.exe /install /norestart /quiet /log "c:\logs\Dotnet Core SDK 2.1.105.log"
    #& ($PSScriptRoot + "\dotnet-install.ps1") -InstallDir c:/dotnet
    #$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
    #$newpath = "$oldpath;c:\dotnet"
    #setx /M PATH $newpath

    $CurDir = get-location
    mkdir c:\agent
    Set-Location c:\agent
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$CurDir\vsts-agent-win-x64-2.139.1.zip", "$PWD")

    .\config.cmd --unattended --url $ServerUrl --auth PAT --token $PersonalAccessToken --pool $PoolName --agent $AgentName --runasservice

    Set-Location $CurDir
}

Stop-Transcript