Function Test-Me2 {
    [cmdletbinding()]
    Param()
    Write-Host "Starting $($MyInvocation.MyCommand) " -foreground green
    Write-Host "PSVersion = $($PSVersionTable.PSVersion)" -foreground green
    Write-Host "OS = $((Get-CimInstance Win32_operatingsystem).Caption)" 
     -foreground green
    Write-Verbose "Getting top 5 processes by WorkingSet"
    Get-Process | sort WS -Descending | select -first 5 -OutVariable s
    Write-Host ($s[0] | Out-String) -foreground green
    Write-Host "Ending $($MyInvocation.MyCommand) " -foreground green
    }
    