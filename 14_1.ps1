function Get-MachineInfo {
    <#
    .SYNOPSIS
    Retrieves specific information about one or more computers using WMI or 
    CIM.
    .DESCRIPTION
    This command uses either WMI or CIM to retrieve specific information about 
    one or more computers. You must run this command as a user with 
    permission to query CIM or WMI on the machines involved remotely. You can 
    specify a starting protocol (CIM by default), and specify that, in the 
    event of a failure, the other protocol be used on a per-machine basis.
    .PARAMETER ComputerName
    One or more computer names. When using WMI, this can also be IP addresses. 
    IP addresses may not work for CIM.
    .PARAMETER LogFailuresToPath
    A path and filename to write failed computer names to. If omitted, no log 
    will be written.
    .PARAMETER Protocol
    Valid values: Wsman (uses CIM) or Dcom (uses WMI). It will be used for all 
    machines. "Wsman" is the default.
    .PARAMETER ProtocolFallback
    Specify this to try the other protocol if a machine fails automatically.
    .EXAMPLE
    Get-MachineInfo -ComputerName ONE,TWO,THREE
    This example will query three machines.
    .EXAMPLE
    Get-ADUser -filter * | Select -Expand Name | Get-MachineInfo
    This example will attempt to query all machines in AD.
    #>
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
            if ($protocol -eq 'Dcom') {
                $option = New-CimSessionOption -Protocol Dcom
            } else {
                $option = New-CimSessionOption -Protocol Wsman
            }
            Write-Verbose "Connecting to $computer over $protocol"
            $session = New-CimSession -ComputerName $computer `
                                      -SessionOption $option
            Write-Verbose "Querying from $computer"
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
            Write-Verbose "Closing session to $computer"
            $session | Remove-CimSession
            Write-Verbose "Outputting for $computer"
            $obj = [pscustomobject]@{'ComputerName'=$computer
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
            Write-Output $obj
        } #foreach
    } #PROCESS
    END {}
    } #function
    