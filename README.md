PowerShell Sensu Checks
=======================
Sensu checks written in PowerShell.

Usage
-----
On the Sensu client, add the PowerShell scripts to ```C:\opt\sensu\plugins\```.

On the Sensu server, add a JSON checks calling the scripts to ```/etc/sensu/conf.d/```.

Example ```checks-windows.json```:
```
{
  "checks": {
    "disk_free_windows": {
      "command": "powershell.exe -ExecutionPolicy Unrestricted -f /opt/sensu/plugins/check_disk_all.ps1 -warn 20 -critical 10",
      "interval": 1200,
      "subscribers": [ "windows" ]
    },
    "cpu_usage_check_windows": {
      "command": "powershell.exe -ExecutionPolicy Unrestricted -f /opt/sensu/plugins/check_cpu.ps1",
      "interval": 60,
      "subscribers": [ "windows" ],
      "occurrences": 3
    },
    "memory_pcnt_check_windows": {
      "command": "powershell.exe -ExecutionPolicy Unrestricted -f /opt/sensu/plugins/check_memory.ps1 -warn 90 -critical 98",
      "interval": 60,
      "subscribers": [ "windows" ],
      "occurrences": 3
    },
    "services_check_windows": {
      "command": "powershell.exe -ExecutionPolicy Unrestricted -f /opt/sensu/plugins/check_windows_services.ps1",
      "interval": 60,
      "subscribers": [ "windows" ]
    }
  }
}
```
