<#
.SYNOPSIS
Sets service login name and password.
.DESCRIPTION
This command uses either CIM (default) or WMI to
set the service password, and optionally the logon
user name, for a service, which can be running on
one or more remote machines. You must run this command
as a user who has permission to perform this task,
remotely, on the computers involved.
.PARAMETER ServiceName
The name of the service. Query the Win32_Service class
to verify that you know the correct name.
.PARAMETER ComputerName
One or more computer names. Using IP addresses will
fail with CIM; they will work with WMI. CIM is always
attempted first. 
.PARAMETER NewPassword
A plain-text string of the new password.
.PARAMETER NewUser
Optional; the new logon user name, in DOMAIN\USER
format.
.PARAMETER ErrorLogFilePath
If provided, this is a path and filename of a text
file where failed computer names will be logged.
#>
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
PROCESS{
ForEach ($computer in $ComputerName) {
    Write-Verbose "Connect to $computer on WS-MAN"
    $option = New-CimSessionOption -Protocol Wsman
    $session = New-CimSession -SessionOption $option `
                              -ComputerName $Computer
    If ($PSBoundParameters.ContainsKey('NewUser')) {
        $args = @{'StartName'=$NewUser
                  'StartPassword'=$NewPassword}
    } Else {
        $args = @{'StartPassword'=$NewPassword}
        Write-Warning "Not setting a new user name"
    }
    Write-Verbose "Setting $servicename on $computer"
    $params = @{'CimSession'=$session
                'MethodName'='Change'
                'Query'="SELECT * FROM Win32_Service " +
                        "WHERE Name = '$ServiceName'"
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
} #foreach
} #PROCESS
END{} 
} #function
