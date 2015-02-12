$counters = @(            
    "\Processor(_Total)\% Processor Time",
    "\Processor(_Total)\% User Time",
    "\Processor(_Total)\% Privileged Time",
    "\Memory\Available KBytes",
    "\Memory\Available Bytes",
    "\Memory\Page Faults/sec",
    "\Network Interface(*)\Output Queue Length",
    "\Network Interface(*)\Bytes Total/sec",
    "\TCPv4\Connections Active",
    "\TCPv4\Connections Established",
    "\LogicalDisk(*:)\% Disk Read Time",
    "\LogicalDisk(*:)\% Free Space",
    "\LogicalDisk(*:)\% Disk Time",
    "\LogicalDisk(*:)\Current Disk Queue Length",
    "\LogicalDisk(*:)\Disk Bytes/sec",
    "\LogicalDisk(*:)\Disk Read Bytes/sec",
    "\LogicalDisk(*:)\Disk Reads/sec",
    "\LogicalDisk(*:)\Disk Transfers/sec",
    "\LogicalDisk(*:)\Disk Write Bytes/sec",
    "\LogicalDisk(*:)\Disk Writes/sec",
    "\LogicalDisk(*:)\Split IO/Sec"
);

 
$unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
$nowInSecconds = [int]([DateTime]::UtcNow - $unixEpochStart).TotalSeconds

(Get-counter -Counter $counters -MaxSamples 1).CounterSamples | 
    foreach {
        ($_.Path.substring(2) -replace '[\)]', '' -replace '[\. ]','_' -replace '[\\\(]', '.' -replace '%', 'pct' -replace '/', '_per_' -replace '#', 'number')  + "`t" + [System.Math]::Round($_.CookedValue,2) + "`t" +  [int][double]::Parse($nowInSecconds)
    }
