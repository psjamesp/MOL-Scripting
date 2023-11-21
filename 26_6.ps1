function Import-DiskInfoFromSQL {
    [CmdletBinding()]
    Param()
        $conn = New-Object System.Data.SqlClient.SqlConnection
        $conn.ConnectionString = $DiskInfoSqlConnection
        $conn.Open()
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $conn
        $sql = @"
            SELECT ComputerName,DiskSize,DriveType,FreeSpace,
            DriveID,DateAdded
            FROM DiskInfo
            ORDER BY DateAdded ASC
"@
        $cmd.CommandText = $sql
        $reader = $cmd.ExecuteReader()
        # spin through the results
        while ($reader.read()) {                          #A
            $props = @{'ComputerName' = $reader['ComputerName']
                       'Size' = $reader['DiskSize']
                       'DriveType' = $reader['DriveType']
                       'FreeSpace' = $reader['FreeSpace']
                       'Drive' = $reader['DriveId']
                       'DateAdded' = $reader['DateAdded']}
            New-Object -TypeName PSObject -Property $props
        }
        $conn.Close()
}
#A Loops through the results, and creates a custom object
