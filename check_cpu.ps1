# Checks CPU & Memory and reports highest utililzation process if warn/crit
param([int] $warn = 80, [int] $critical = 90)

. (Join-Path $PSScriptRoot checks_helper.ps1)


Perform-Counter-Check -counterPath "\Processor(_Total)\% Processor Time" -outputstring "CPU at {0} %"  -warn $warn -critical $critical
