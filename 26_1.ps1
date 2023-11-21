$conn_string = 
å "Server=localhost\SQLEXPRESS;Database=master;Trusted_Connection=True;"  #A
$conn = New-Object System.Data.SqlClient.SqlConnection         #B
$conn.ConnectionString = $conn_string                          #C
$conn.Open()
$sql = @"                              #D
CREATE DATABASE Scripting; 
"@
$cmd = New-Object System.Data.SqlClient.SqlCommand          #E
$cmd.CommandText = $sql                                      #F
$cmd.Connection = $conn                    #G
$cmd.ExecuteNonQuery()      #H
$conn.close()     #I
#A Defines the connection string
#B Creates the connection object
#C Configures the connection object
#D Defines a SQL query
#E Creates a SQL Command object
#F Configures the command to use the query
#G Configures the command to use the connection
#H Executes the command
#I Closes the database connection
