function Get-MachineInfo {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True,
                   Mandatory=$True)]
        [Alias('CN','MachineName','Name')]
        [string[]]$ComputerName,
        [string]$LogFailuresToPath,
        [ValidateSet('Wsman','Dcom')]
        [string]$Protocol = "Wsman",
        [switch]$ProtocolFallback
    )
 BEGIN {}
 PROCESS {
    foreach ($computer in $computername) {
        # Establish session protocol
        if ($protocol -eq 'Dcom') {
            $option = New-CimSessionOption -Protocol Dcom
        } else {
            $option = New-CimSessionOption -Protocol Wsman
        }
        # Connect session
        $session = New-CimSession -ComputerName $computer `
                                  -SessionOption $option
        # Query data
        $os_params = @{'ClassName'='Win32_OperatingSystem'
                       'CimSession'=$session}
        $os = Get-CimInstance @os_params
        $cs_params = @{'ClassName'='Win32_ComputerSystem'
                       'CimSession'=$session}
        $cs = Get-CimInstance @cs_params
        $sysdrive = $os.SystemDrive
        $drive_params = @{'ClassName'='Win32_LogicalDisk'
                          'Filter'="DeviceId='$sysdrive'"
                          'CimSession'=$session}
        $drive = Get-CimInstance @drive_params
        $proc_params = @{'ClassName'='Win32_Processor'
                         'CimSession'=$session}
        $proc = Get-CimInstance @proc_params |
                Select-Object -first 1
        # Close session
        $session | Remove-CimSession
        # Output data
        $props = @{'ComputerName'=$computer
                   'OSVersion'=$os.version
                   'SPVersion'=$os.servicepackmajorversion
                   'OSBuild'=$os.buildnumber
                   'Manufacturer'=$cs.manufacturer
                   'Model'=$cs.model
                   'Procs'=$cs.numberofprocessors
                   'Cores'=$cs.numberoflogicalprocessors
                   'RAM'=($cs.totalphysicalmemory / 1GB)
                   'Arch'=$proc.addresswidth
                   'SysDriveFreeSpace'=$drive.freespace}
        $obj = New-Object -TypeName PSObject -Property $props
        Write-Output $obj
    } #foreach
} #PROCESS
END {}
} #function
