function Get-DiskInfo {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True)]
        [string[]]$ComputerName
    )
    BEGIN {
        Set-StrictMode -Version 2.0
    }
    PROCESS {
        ForEach ($comp in $ComputerName) {
            $params = @{'ComputerName' = $comp
                        'ClassName' = 'Win32_LogicalDisk'}
            $disks = Get-CimInstance @params
            ForEach ($disk in $disks) {
                $props = @{'ComputerName' = $comp
                           'Size' = $disk.size
   'Drive' = $disk.deviceid
                           'FreeSpace' = $disk.freespace
                           'DriveType' = $disk.drivetype}
                New-Object -TypeName PSObject -Property $props
            } #foreach disk
        } #foreach computer
    } #PROCESS
    END {}
}
