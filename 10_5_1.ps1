Set-TMServiceLogon -ServiceName LOBApp 
                   -NewPassword "P@ssw0rd" 
                   -ComputerName SERVER1,SERVER2
                   -ErrorLogFilePath failed.txt
                   -Verbose
