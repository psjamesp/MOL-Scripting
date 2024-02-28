#You may need to run Enable-PSRemoting or Winrm QC to enable remoting
function Get-MachineInfo {
    Param(
        [string[]]$ComputerName,
        [string]$LogFailuresToPath,
        [string]$Protocol = "Wsman",
        [switch]$ProtocolFallback
    )
    foreach ($computer in $computername) {
        #A
        # Establish session protocol
        if ($protocol -eq 'Dcom') {
            #B
            $option = New-CimSessionOption -Protocol Dcom
        }
        else {
            $option = New-CimSessionOption -Protocol Wsman
        }
        # Connect session
        $session = New-CimSession -ComputerName $computer -SessionOption $option
        # Query data
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session
        # Close session
        $session | Remove-CimSession
        # Output data
        # TODO
    } #foreach
} #function      #C
#A Processes each computer
#B If construct
#C Closes the function
   