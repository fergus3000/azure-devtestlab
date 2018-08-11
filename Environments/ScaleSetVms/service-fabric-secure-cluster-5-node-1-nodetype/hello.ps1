$folder = 'c:\pipeline'
$text = Get-Date -Format "o"
$text = ($text + '   Hello World')

if(!(Test-Path -Path $folder )){
    New-Item -ItemType directory -Path $folder
}

$text >> 'c:/pipeline/file.txt'