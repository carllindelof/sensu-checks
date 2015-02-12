param([int] $warn = 20, [int] $critical = 10)

. (Join-Path $PSScriptRoot checks_helper.ps1)

$countervaluearray = (Get-counter  -Counter "\LogicalDisk(*)\% Free Space").countersamples | where {$_.InstanceName -ne “_total”} | Sort-Object InstanceName

$minvalue = 100
$message = ""

foreach ($countervalue in $countervaluearray) {
    $message += $countervalue.InstanceName + " " + [System.Math]::Round($countervalue.CookedValue,2) + "%; "

    if($t.CookedValue -lt $minvalue)
    {
        $minvalue = $t.CookedValue
    }
}

Report-Check-Reverse -outvalue $message -counterValue $minvalue -warn $warn -critical $critical
