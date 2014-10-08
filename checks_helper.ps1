function Perform-Counter-Check([string] $counterPath,[string]$outputstring,[int] $warn, [int] $critical)
{

    $counterValue = [System.Math]::Round(((Get-counter  -Counter $counterPath ).countersamples | select -property CookedValue).cookedvalue,2)
    $outvalue = [string]::Format($outputstring,$counterValue)
    Write-Host $outvalue

    if ($counterValue -gt $critical)
    { 
        exit 2
    }
    elseif ($counterValue -gt $warn)
    {
        exit 1
    }
    else 
    { 
        exit 0
    } 
}
