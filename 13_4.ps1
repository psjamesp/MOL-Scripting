Function Test-Me3 {
    [cmdletbinding()]
    Param()
    if ($PSBoundParameters.ContainsKey("InformationVariable")) { 
     $Info = $True 
     $infVar = $PSBoundParameters["InformationVariable"]
    }
    if ($info) {
     Write-Host "Starting $($MyInvocation.MyCommand) " -foreground green
     (Get-Variable $infVar).value[-1].Tags.Add("Process")
     Write-Host "PSVersion = $($PSVersionTable.PSVersion)" -foreground green
     (Get-Variable $infVar).value[-1].Tags.Add("Meta")
     Write-Host "OS = $((Get-CimInstance Win32_operatingsystem).Caption)" 
     -foreground green
     (Get-Variable $infVar).value[-1].Tags.Add("Meta")
    }
    Write-Verbose "Getting top 5 processes by WorkingSet"
    Get-process | sort WS -Descending | select -first 5 -OutVariable s
    if ($info) {
     Write-Host ($s[0] | Out-String) -foreground green
     (Get-Variable $infVar).value[-1].Tags.Add("Data")
     Write-Host "Ending $($MyInvocation.MyCommand) " -foreground green
     (Get-Variable $infVar).value[-1].Tags.Add("Process")
    }
    }
    