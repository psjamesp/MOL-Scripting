function Get-DnsHostByAddress {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string[]]$Address
    )
    BEGIN {}
    PROCESS {
        ForEach ($Addr in $Address) {
            $props = @{'Address'=$addr}
            Try {
                $result = [System.Net.Dns]::GetHostByAddress($addr)
                $props.Add('HostName',$result.HostName)
            } Catch {
                $props.Add('HostName',$null)
            }
            New-Object -TypeName PSObject -Property $props
        } #foreach
    } #PROCESS
    END {}
} #function
Get-DnsHostByAddress -Address '204.79.197.200','192.168.254.254', '35.166.24.88'
