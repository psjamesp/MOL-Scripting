<#            #A
This script will connect to Azure AD via Microsoft Graph and notify users if their password is set to expire in the next 7 days. It will then send them an email.     
#>
Connect-MgGraph -ClientId 'YOUR_CLINET_ID' -TenantId 'YOUR_TENANT_ID' #B


#Domain's password experation in Days      #C
$PasswordValidDay = get-mgdomain -DomainId PowerShell.org | select-object -ExpandProperty PasswordNotificationWindowInDays

# Check the user's password expiration date
$today = Get-Date
$allUsers = get-mguser -All -Property lastPasswordChangeDateTime,mail | #D
Where-Object {$_.PasswordPolicies -contains "DisablePasswordExpiration"}   

foreach ($user in $allUsers) {          #E
    $passwordExpirationDate = $user.LastPasswordChangeDateTime + [System.TimeSpan]::FromDays($PasswordValidDay)

    # Define the notification threshold (e.g., 7 days before the password expires)
    $notificationThreshold = 7

    # Calculate the number of days until password expiration
    $daysUntilExpiration = ($passwordExpirationDate - $today).Days

    if ($daysUntilExpiration -le $notificationThreshold) {
        #Send Email using Graph API            #F
        $params = @{
            Message         = @{
                Subject       = "Your Password is About to Expire"
                Body          = @{
                    ContentType = 'HTML'
                    Content     = "Your password will expire on $passwordExpirationDate. Please update your password."
                }
                ToRecipients  = @(
                    @{
                        EmailAddress = @{
                            Address = $user.mail
                        }
                    }
                )
            }
            SaveToSentItems = $true
        }
        # Send message
        Send-MgUserMail -UserId $from -BodyParameter $params       #G
    } else {
        Write-Host "Password is not yet expired. Days until expiration: $daysUntilExpiration"
    }
    
}
#A – Comment help block (but notice its not very helpful)
#B – Connect to Graphi API
#C – A few lines of code to calculate the date
#D - Collect all users into an Array
#E - Loop through the Array
#F - Gather all things needed to send email
#G - Send Email via Graph API
