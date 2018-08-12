
param([string]$ipAddress, [string]$nodeName)


function CreateLogsFolder {
    #make sure we have a log folder
    $LogFolder = 'c:\logs'
    if (!(Test-Path -Path $LogFolder )) {
        New-Item -ItemType directory -Path $LogFolder
    }
}
function InstallCouchbase {

    #assume msi downloaded from in current folder
    #https://packages.couchbase.com/releases/5.1.1/couchbase-server-community_5.1.1-windows_amd64.msi
    $logFile = "c:\logs\cb-install.log"
    $MSIArguments = @(
        "/i"
        "couchbase-server-community_5.1.1-windows_amd64.msi"
        "/qn"
        "/norestart"
        "/L*v"
        $logFile
    )
    Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
}

function isNodeOne($ipAddress)
{
    if ($ipAddress -eq "10.0.0.4"){
        return true
    } else {
        return false
    }
}

function ConfigureCouchbase ($ipAddress){

    $user = "Administrator"
    $pass = "password"
    $pair = "${user}:${pass}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{ Authorization = $basicAuthValue }

    # Initialize disk paths for Node
    # curl -u Administrator:password -v -X POST http://[localhost]:8091/nodes/self/controller/settings
    #   -d path=[location]
    #   -d index_path=[location]
    #Invoke-WebRequest -Method POST `
    #    -Headers $headers `
    #    -Uri http://127.0.0.1:8091/nodes/self/controller/settings `
    #    -Body "path=[location]&index_path=[location]" `
    #    -ContentType application/x-www-form-urlencoded

    # Rename Node
    # curl -u Administrator:password -v -X POST http://[localhost]:8091/node/controller/rename 
    #   -d hostname=[localhost]
    Invoke-WebRequest -Method POST `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/node/controller/rename `
        -Body "hostname=[localhost]" `
        -ContentType application/x-www-form-urlencoded

    #echo Configuring Couchbase cluster
    #curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=1024 -d indexMemoryQuota=512
    Invoke-WebRequest -Method POST `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/pools/default `
        -Body "memoryQuota=1024&indexMemoryQuota=512" `
        -ContentType application/x-www-form-urlencoded

    #echo Configuring Couchbase indexes
    #curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2cn1ql%2Cindex
    Invoke-WebRequest -Method POST `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/node/controller/setupServices `
        -Body "services=kv%2cn1ql%2Cindex" `
        -ContentType application/x-www-form-urlencoded

    #echo Creating Couchbase admin user
    #curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password
    Invoke-WebRequest -Method POST `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/settings/web `
        -Body "port=8091&username=Administrator&password=password" `
        -ContentType application/x-www-form-urlencoded

    #echo Creating Couchbase buckets
    #curl -v -u Administrator:password -X POST http://127.0.0.1:8091/pools/default/buckets -d name=wfms -d replicaIndex=0 -d flushEnabled=1 -d bucketType=couchbase -d ramQuotaMB=256 -d authType=sasl -d saslPassword=password
    Invoke-WebRequest -Method POST `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/pools/default/buckets `
        -Body "name=wfms&replicaIndex=0&flushEnabled=1&bucketType=couchbase&ramQuotaMB=256&authType=sasl&saslPassword=password" `
        -ContentType application/x-www-form-urlencoded `
        #curl -v -u Administrator:password -X POST http://127.0.0.1:8091/pools/default/buckets -d name=timeseries -d replicaIndex=0 -d flushEnabled=1 -d bucketType=couchbase -d ramQuotaMB=512 -d authType=sasl -d saslPassword=password
    Invoke-WebRequest -Method POST `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/pools/default/buckets `
        -Body "name=timeseries&replicaIndex=0&flushEnabled=1&bucketType=couchbase&ramQuotaMB=512&authType=sasl&saslPassword=password" `
        -ContentType application/x-www-form-urlencoded
    #curl -v -u Administrator:password -X POST http://127.0.0.1:8091/pools/default/buckets -d name=events -d replicaIndex=0 -d flushEnabled=1 -d bucketType=couchbase -d ramQuotaMB=256 -d authType=sasl -d saslPassword=password
    Invoke-WebRequest -Method POST `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/pools/default/buckets `
        -Body "name=events&replicaIndex=0&flushEnabled=1&bucketType=couchbase&ramQuotaMB=256&authType=sasl&saslPassword=password" `
        -ContentType application/x-www-form-urlencoded

    #echo Creating Couchbase bucket users
    #curl -X PUT --data "name=wfms&roles=bucket_full_access[wfms]&password=wfmswfms" -H "Content-Type: application/x-www-form-urlencoded" http://Administrator:password@127.0.0.1:8091/settings/rbac/users/local/wfms
    Invoke-WebRequest -Method PUT `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/settings/rbac/users/local/wfms `
        -Body "name=wfms&roles=bucket_full_access[wfms]&password=wfmswfms" `
        -ContentType application/x-www-form-urlencoded
    #curl -X PUT --data "name=timeseries&roles=bucket_full_access[timeseries]&password=timeseries" -H "Content-Type: application/x-www-form-urlencoded" http://Administrator:password@127.0.0.1:8091/settings/rbac/users/local/timeseries
    Invoke-WebRequest -Method PUT `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/settings/rbac/users/local/timeseries `
        -Body "name=timeseries&roles=bucket_full_access[timeseries]&password=timeseries" `
        -ContentType application/x-www-form-urlencoded
    #curl -X PUT --data "name=events&roles=bucket_full_access[events]&password=events" -H "Content-Type: application/x-www-form-urlencoded" http://Administrator:password@127.0.0.1:8091/settings/rbac/users/local/events         
    Invoke-WebRequest -Method PUT `
        -Headers $headers `
        -Uri http://127.0.0.1:8091/settings/rbac/users/local/events `
        -Body "name=events&roles=bucket_full_access[events]&password=events" `
        -ContentType application/x-www-form-urlencoded


    # TODO: how to decide if we are leader or wait for leader and add ourselves to that
    # And do we need to configure everything if we add to clsuter
    # Add node to cluster
    #    curl -u Administrator:password \
    #    10.2.2.60:8091/controller/addNode \
    #    -d 'hostname=10.2.2.64&user=Administrator&password=password&services=n1ql'

    # if is leader, setup the buckets etc
    # else add to cluster
}

CreateLogsFolder

$hello = "Installing couchbase"

$hello >> 'c:/pipeline/install-couhbase.txt'
$ipAddress >> 'c:/pipeline/install-couhbase.txt'
$nodeName >> 'c:/pipeline/install-couhbase.txt'

InstallCouchbase

# TODO: configure for all nodes
if(isNodeOne($ipAddress)){
    ConfigureCouchbase  
}