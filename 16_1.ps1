function Get-TMIPInfo {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True)]
        [string[]]$ComputerName
    )
    BEGIN {}
    PROCESS {
        ForEach ($comp in $computername) {
            Write-Verbose "Connecting to $comp"
            $s = New-CimSession -ComputerName $comp
            $adapters = Get-NetAdapter -CimSession $s |
                        Where Status -ne 'Disconnected'
            ForEach ($adapter in $adapters) {
                Write-Verbose "  Interface $($adapter.interfaceindex)"
                $addresses = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex `
                                              -CimSession $s
                ForEach ($address in $addresses) {
                    $props = @{'ComputerName'=$Comp
                               'Index'=$adapter.interfaceindex
                               'Name'=$adapter.interfacealias
                               'MAC'=$adapter.macaddress
                               'IPAddress'=$address.ipaddress}
                    New-Object -TypeName PSObject -Property $props
                } #foreach address
            } #adapter
            $s | Remove-CimSession
        } #foreach computer
    } #process
    END {}
} #function
