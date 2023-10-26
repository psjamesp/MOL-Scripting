function Add-ADComputerWindowsBuild {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True)]
        [object[]]$InputObject
    )
    PROCESS {
        ForEach ($comp in $inputobject) {
            $os = Get-CimInstance -ComputerName $comp.name `
                                  -Class Win32_OperatingSystem
            $comp | Add-Member -MemberType NoteProperty `
                               -Name OSBuild `
                               -Value $os.BuildNumber
        } #foreach
    } #process
} #function
