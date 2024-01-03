function Get-MachineInfo {
    Param(
     [string[]]$ComputerName,
     [string]$LogFailuresToPath,
     [string]$Protocol = "Wsman",
     [switch]$ProtocolFallback
    )
    foreach ($computer in $computername) {
     # Establish session protocol
     if ($protocol -eq 'Dcom') {
      $option = New-CimSessionOption -Protocol Dcom
     } else {
      $option = New-CimSessionOption -Protocol Wsman
     }
     $session = New-CimSession -ComputerName $computer -SessionOption $option   #A
     # Query data
     $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession    #B
   ➥ $session
     # Close session
     $session | Remove-CimSession
     # Output data
     $os | Select-Object -Prop @{n='ComputerName';e={$computer}},
                               Version,ServicePackMajorVersion     #C
    } #foreach
   } #function
   #A Connects the session
   #B Queries for operating system data
   #C Writes the output using Select-Object
   