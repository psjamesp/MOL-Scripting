function Set-ComputerState {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$True)]
        [ValidateSet('Restart','Shutdown')]
        [string]$Action,
        [switch]$Force
    )
    BEGIN {}
    PROCESS {
        ForEach ($comp in $ComputerName) {
            $params = @{'Computername' = $comp}
            # force?
            if ($force) {
                $params.Add('Force',$true)
            }
            # which action?
            If ($Action -eq 'Restart') {
                Write-Verbose "Restarting $comp (Force: $force)"
                Restart-Computer @params
            } else {
                Write-Verbose "Stopping $comp (Force: $force)"
                Stop-Computer @params
            }
        }
    } #PROCESS
    END {}
}
