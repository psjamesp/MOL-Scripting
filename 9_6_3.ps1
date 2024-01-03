$CimMethodParameters = @{
    Query = "SELECT * FROM Win32_Service WHERE Name='BITS'"
    Method = "Change"
    Arguments = @{
        'StartName'     = 'DOMAIN\User'
        'StartPassword' = 'P@ssw0rd'
    }
    ComputerName = $env:computername
}
Invoke-CimMethod @CimMethodParameters
