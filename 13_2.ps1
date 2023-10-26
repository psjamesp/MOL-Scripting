Function Test-Me {
    [cmdletbinding()]
    Param()
    Write-Information "Starting $($MyInvocation.MyCommand) " -Tags Process
    Write-Information "PSVersion = $($PSVersionTable.PSVersion)" -Tags Meta
    Write-Information "OS = $((Get-CimInstance Win32_operatingsystem).Caption)"`
    -Tags Meta
    Write-Verbose "Getting top 5 processes by WorkingSet"
    Get-process | sort WS -Descending | select -first 5 -OutVariable s
    Write-Information ($s[0] | Out-String) -Tags Data
    Write-Information "Ending $($MyInvocation.MyCommand) " -Tags Process
    }
    