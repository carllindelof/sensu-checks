$counters = @(            
   "\MSMQ Service\MSMQ Outgoing Messages",
   "\MSMQ Service\Outgoing Messages/sec",
   "\MSMQ Service\MSMQ Incoming Messages",
   "\MSMQ Service\Incoming Messages/sec"
);


 
$unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
$nowInSecconds = [int]([DateTime]::UtcNow - $unixEpochStart).TotalSeconds

(Get-counter -Counter $counters -MaxSamples 1).CounterSamples | 
foreach {
    ($_.Path.substring(2) -replace '[\)]', '' -replace '[\. ]','_' -replace '[\\\(]', '.' -replace '%', 'pct' -replace '/', '_per_' -replace '#', 'number')  + "`t" + [System.Math]::Round($_.CookedValue,2) + "`t" +  [int][double]::Parse($nowInSecconds)
}
