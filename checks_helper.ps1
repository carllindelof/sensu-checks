
function Get-CookedValue([string] $counterPath)
{
      [System.Math]::Round(((Get-counter  -Counter $counterPath ).countersamples | select -property CookedValue).cookedvalue,2)
}


function Report-Check([string]$outvalue,[int] $counterValue, [int] $warn, [int] $critical)
{

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

function Report-Check-Reverse([string]$outvalue,[int] $counterValue, [int] $warn, [int] $critical)
{

     Write-Host $outvalue

    if ($counterValue -lt $critical)
    {
        exit 2
    }
    elseif ($counterValue -lt $warn)
    {
        exit 1
    }
    else 
    {  
         exit 0
    } 
}

function Perform-Counter-Check([string] $counterPath,[string]$outputstring,[int] $warn, [int] $critical)
{
    $counterValue = Get-CookedValue -counterPath $counterPath
    $outvalue = [string]::Format($outputstring,$counterValue)
    Report-Check -outvalue $outvalue -counterValue $counterValue -warn $warn -critical $critical
}


function Perform-Counter-Check-Reverse([string] $counterPath,[string]$outputstring,[int] $warn, [int] $critical)
{
    $counterValue = Get-CookedValue -counterPath $counterPath
    $outvalue = [string]::Format($outputstring,$counterValue)
    Report-Check-Reverse -outvalue $outvalue -counterValue $counterValue -warn $warn -critical $critical
}


function Check-HTTP-Status{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Uri,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
        $Body = $null
    )

    
    $returnvalue = New-Object PSObject -Property @{
             Result = $false
             Statuscode=500
             StatusDescription=''
             TotalSeconds =$null
             Milliseconds =$null
             ExceptionMessage=''
             Content=''
        }

    Try{
        $timeTaken =  Measure-Command {$response = Invoke-WebRequest -Method $Method -Uri $Uri -Body $Body -ErrorAction SilentlyContinue} 
           
        $returnvalue.TotalSeconds = $timeTaken.TotalSeconds
        $returnvalue.Milliseconds= $timeTaken.Milliseconds
        $returnvalue.StatusCode = $response.StatusCode
        $returnvalue.StatusDescription = $response.StatusDescription
        $returnvalue.Content = Select-Object -InputObject $response -ExpandProperty Content
        
        Write-Verbose ("Timetaken: {0} S" -f $timeTaken.TotalSeconds)
        Write-Verbose ("Timetaken: {0} MS" -f $timeTaken.Milliseconds)
        Write-Verbose ("{0} {1}" -f $response.StatusCode, $response.StatusDescription) 
    }
    Catch
    {
      $returnvalue.ExceptionMessage = $_.Exception.Message
      return $returnvalue 
      break
    }
   return $returnvalue 
}

function Check-HTTP-StatusCodeOK{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Uri,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
        $Body = $null
    )
    
    $returnvalue = Check-HTTP-Status -Uri $Uri -Method $Method -Body $Body

    if($returnvalue.StatusCode -eq 200)
     {
        $returnvalue.Result = $true
     }

     return $returnvalue 
}

function Check-HTTP-StatusCodeOK-ContentLengthMatch{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Uri,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
        $ContentLength = 1000
    )
    
    $returnvalue = Check-HTTP-Status -Uri $Uri -Method $Method -Body $Body
    
    if($returnvalue.StatusCode -eq 200 -and $returnvalue.content.Length -eq $ContentLength)
     {
        $returnvalue.Result = $true
     }

     return $returnvalue 
}

function Check-HTTP-StatusCodeOK-ContentLengthOK{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Uri,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
        $ContentLength = 1000
    )
    
    $returnvalue = Check-HTTP-Status -Uri $Uri -Method $Method -Body $Body
    
    if($returnvalue.StatusCode -eq 200 -and $returnvalue.content.Length -gt $ContentLength)
     {
        $returnvalue.Result = $true
     }

     return $returnvalue 
}


function Check-HTTP-StatusCodeOK-ContentLengthAndContentOK{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Uri,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'Get',
        $ContentLength = 1000,
        $ContentText = '' 
    )
    
    
    $returnvalue = Check-HTTP-Status -Uri $Uri -Method $Method -Body $Body
    if($returnvalue.StatusCode -eq 200 -and $returnvalue.Content.Length -gt $ContentLength -and $content -match $ContentText)
     {
        $returnvalue.Result = $true
     }

     return $returnvalue 
}


function Write-GraphiteMetric([string]$key,[string] $value)
{
    $unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
    $nowInSecconds = [int]([DateTime]::UtcNow - $unixEpochStart).TotalSeconds
    
    $key + "`t" + $value + "`t" + [int][double]::Parse($nowInSecconds)
}

function Write-GraphiteMetricList([Hashtable]$list)
{
    $unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
    $nowInSecconds = [int]([DateTime]::UtcNow - $unixEpochStart).TotalSeconds
    
    foreach ($metric in $list.GetEnumerator()) {
        $metric.Name + "`t" + $metric.Value + "`t" + [int][double]::Parse($nowInSecconds)        
    }
}