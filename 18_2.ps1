function Set-TMServiceLogon {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string]$ServiceName,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        [string]$NewPassword,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        [string]$NewUser,
        [string]$ErrorLogFilePath
    )
BEGIN{}
                                                      #A
PROCESS{
    ForEach ($computer in $ComputerName) {
        Do {
            Write-Verbose "Connect to $computer on WS-MAN"
            $protocol = "Wsman"
            Try {
                $option = New-CimSessionOption -Protocol $protocol
                $session = New-CimSession -SessionOption $option – ComputerName $Computer -ErrorAction Stop
                If ($PSBoundParameters.ContainsKey('NewUser')) {
                    $args = @{'StartName'= $NewUser                #B
                              'StartPassword' = $NewPassword}
                } Else {
                    $args = @{'StartPassword' = $NewPassword}
                    Write-Warning "Not setting a new user name"
                }
                Write-Verbose "Setting $servicename on $computer"
                $params = @{'CimSession'=$session
                            'MethodName'='Change'
                            'Query'="SELECT * FROM Win32_Service WHERE Name = '$ServiceName'"
                            'Arguments'=$args}
                $ret = Invoke-CimMethod @params
                switch ($ret.ReturnValue) {
                    0  { $status = "Success" }
                    22 { $status = "Invalid Account" }
                    Default { $status = "Failed: $($ret.ReturnValue)" }
                }
                $props = @{'ComputerName'=$computer
                           'Status'=$status}
                $obj = New-Object -TypeName PSObject -Property $props
                Write-Output $obj
                Write-Verbose "Closing connection to $computer"
                $session | Remove-CimSession
            } Catch {
                # change protocol - if we've tried both
                # and logging was specified, log the computer
                Switch ($protocol) {
                    'Wsman' { $protocol = 'Dcom' }
                    'Dcom'  { 
                        $protocol = 'Stop'
                        if ($PSBoundParameters.ContainsKey('ErrorLogFilePath')) {
                            Write-Warning "$computer failed; logged to $ErrorLogFilePath"
                            $computer | Out-File $ErrorLogFilePath -Append
                        } # if logging
                     }            
                } #switch
            } # try/catch
        } Until ($protocol -eq 'Stop')
    } #foreach
} #PROCESS                          #C
END{} 
} #function
#A Spacing for readability
#B Neatly structured hash tables
#C Comments for closing braces
