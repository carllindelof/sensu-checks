# Test-Automatic-Services.ps1 
# 
# Written by Aaron Wurthmann (aaron (AT) wurthmann (DOT) com) 
#        http://irl33t.com 
# 
# If you edit please keep my name as an original author and 
# keep me apprised of the changes, see email address above. 
# This code may not be used for commercial purposes. 
# You the executor, runner, user accept all liability. 
# This code comes with ABSOLUTELY NO WARRANTY. 
# You may redistribute copies of the code under the terms of the GPL v2. 
# ----------------------------------------------------------------------- 
# 2010.11.09 ver 2.0 
# 
# Summary: 
# Checks services set to Automatic and insures they are running. 
# Ignores an array of services such as Performance Logs and Alerts  
# which are set to Automatic but turns themselves off. 
# 
# If an Automatic service is not Running and not in the Ignore array 
# an attempt to restart the service is made. If the service is restarted 
# a Warning is returned. If the service could not be restarted a 
# Critical error is returned. 
# ----------------------------------------------------------------------- 
# Usage: 
# This script does not require any input parameters. 
#    For Nagios NRPE/NSClient++ usage add the following line to the  
#    NSC.ini file after placing this script in Scripts subdirectory. 
#    check_services=cmd /c echo scripts\Test-Automatic-Services.ps1 | powershell.exe -command - 
#    NOTE: The trailing - is required. 
# ----------------------------------------------------------------------- 
# Orgin: 
# This script (or one like it) was originally written by ronald van vugt 
#     (ronald.van.vugt@vanderlet.nl) 
# I took the vbscript\wsf version that he wrote and converted it to  
# PowerShell while adding an array of ignored services and making other 
# slight improvements such as adjusting the WMI query to only return  
# stopped services. 
# ----------------------------------------------------------------------- 
# Notes:  
# Unlike the majority of my scripts this script has rather verbose 
# comments in it. This is both to pay homage to the original author as  
# well as to aid others with learning PowerShell. The original version 
# of this script, the vbscript/wsf version was a vbscript learning 
# experience for myself and the basis of my vbscripts to follow. 
# ----------------------------------------------------------------------- 
 
 
# Varibles used to caluclate number and type of errors if any. 
[int]$intResultWarning = 0 
[int]$intResultError = 0 
[int]$intResultTotal = 0 
 
# List of Services to Ignore. 
$Ignore=@( 
    'Microsoft .NET Framework NGEN v4.0.30319_X64', 
    'Microsoft .NET Framework NGEN v4.0.30319_X86', 
    'Multimedia Class Scheduler', 
    'Performance Logs and Alerts', 
    'SBSD Security Center Service', 
    'Shell Hardware Detection', 
    'Remote Registry',
    'Windows Modules Installer',
    'Software Protection', 
    'TPM Base Services'; 
) 
 
# Get list of services that are not running, not in the ignore list and set to automatic 
$Services=Get-WmiObject Win32_Service | Where {$_.StartMode -eq 'Auto' -and $Ignore -notcontains $_.DisplayName -and $_.State -ne 'Running'} 
 
# If any services were found fitting the above description... 
if ($Services) { 
    # Loop through each service in services 
    ForEach ($Service in $Services) { 
        # Attempt to restart the service 
        #$err = $Service.StartService() 
        # Pause for 1 second 
        #Start-Sleep -s 1 
        # Re-Get the Service information in order to recheck its status 
        $StoppedService=Get-Service -Displayname $Service.Displayname 
        # If the service failed to restart... 
        If ($StoppedService.Status -ne 'Running') { 
            # Set the error level to 2 (critical) 
            $intResultError = 2 
            # If this is not the first recorded error amend the error text 
            if ($strResultError) { 
                $strResultError=$strResultError + ', ' + $Service.Displayname 
            } 
            # If this is the first or only error set error text 
            ELSE { 
                $strResultError = 'Services failed: ' + $Service.Displayname 
            } 
        } 
        ELSE { 
            # If the service restarted set the warning error level to 1 (warning) 
            $intResultWarning = 1 
            # If this is not the first recorded error amend the error text 
            if ($strResultWarning) { 
            $strResultWarning=$strResultWarning + ', ' + $Service.Displayname 
            } 
            # If this is the first or only error set error text 
            ELSE { 
                $strResultWarning = 'Services restarted: ' + $Service.Displayname 
            } 
        } 
        # Clear the StoppedService varible 
        if ($StoppedService) {Clear-Variable StoppedService} 
    } 
} 
 
# Add the warning error (0 or 1) to the critical error (0 or 2) 
$intResultTotal=$intResultWarning + $intResultError 
 
# Using the sum of the warning errors to the critical errors select the appropriate response 
Switch ($intResultTotal) { 
    # Default/no errors 
    default { 
        write-host 'All automatic started services are running' 
        exit 0 
    } 
    # Warning error(s) only 
    1 { 
        write-host $strResultWarning 
        exit 1 
    } 
    # Critical error(s) only 
    2 { 
        write-host $strResultError 
        exit 2 
    }  
    # Critical and Warning errors 
    3 { 
        write-host $strResultError 
        write-host $strResultWarning 
        exit 2 
    }  
}