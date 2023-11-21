Connect-MgGraph -ClientId 'YOUR_CLINET_ID' -TenantId 'YOUR_TENANT_ID'


#Domain's password experation in Days
$PasswordValidDay = get-mgdomain -DomainId PowerShell.org | select-object -ExpandProperty PasswordNotificationWindowInDays

# Check the user's password expiration date
$today = Get-Date
$allUsers = get-mguser -All -Property lastPasswordChangeDateTime,mail,passwordProfile | Where-Object {$_.PasswordPolicies -contains "DisablePasswordExpiration"}

foreach ($user in $allUsers) {
    $passwordExpirationDate = $user.LastPasswordChangeDateTime + [System.TimeSpan]::FromDays($PasswordValidDay)

    # Define the notification threshold (e.g., 7 days before password expires)
    $notificationThreshold = 7

    # Calculate the number of days until password expiration
    $daysUntilExpiration = ($passwordExpirationDate - $today).Days

    if ($daysUntilExpiration -le $notificationThreshold) {
        #Send Email using Graph API
        $params = @{
            Message         = @{
                Subject       = "Your Passord is About to Expire"
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
        Send-MgUserMail -UserId $from -BodyParameter $params
    } else {
        Write-Host "Password is not yet expired. Days until expiration: $daysUntilExpiration"
    }
    
}