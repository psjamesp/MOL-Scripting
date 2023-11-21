function Export-DiskInfoToSQL {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True)]
        [object[]]$DiskInfo
    )
    BEGIN {
        New-DiskInfoSQLTable
        $conn = New-Object System.Data.SqlClient.SqlConnection
        $conn.ConnectionString = $DiskInfoSqlConnection
        $conn.Open()
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $conn
        $checks = 0
    }
    PROCESS {
        if ($checks -eq 0) {            #A
            $checks++
            $props = $DiskInfo[0] |
                     Get-Member -MemberType Properties |
                     Select-Object -Expand name
            if ($props -contains 'Computername' -and 
                $props -contains 'Drive' -and
                $props -contains 'DriveType' -and
                $props -contains 'FreeSpace' -and
                $props -contains 'Size') {
                    Write-Verbose "Input object passes check"
                } else {
                    Write-Error "Illegal input object"
                    Break
                }
        }
        ForEach ($object in $DiskInfo) {
            if ($object.size -eq $null) { 
                $size = 0 
            } else { 
                $size = $object.size 
            }
            if ($object.freespace -eq $null) { 
                $freespace = 0 
            } else { 
                $freespace = $object.freespace 
            }
            $sql = @"
                INSERT INTO DiskInfo (ComputerName,
                    DiskSize,DriveType,FreeSpace,DriveID,DateAdded)
                VALUES('$($object.ComputerName)',
                       $size,
                       $($object.DriveType),
                       $freespace,
                       '$($object.Drive)',
                       '$(Get-Date)')
"@
            $cmd.CommandText = $sql
            Write-Verbose "EXECUTING QUERY `n $sql"
            $cmd.ExecuteNonQuery() | Out-Null
        } #ForEach
    } #PROCESS
    END {
        $conn.Close()
    }
}
#A Checks the first input object
