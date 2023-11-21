<#
.SYNOPSIS
   Connects to the Microsoft Graph API with the provided client ID and tenant ID.
.DESCRIPTION
   This function establishes a connection to the Microsoft Graph API using the provided client ID and tenant ID.
.PARAMETER ClientId
   The client ID for your application.
.PARAMETER TenantId
   The tenant ID associated with your organization.
#>
function Connect-MyMgGraph {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ClientId,
        [Parameter(Mandatory = $true)]
        [string]$TenantId
    )

    # Connect to Microsoft Graph here with the given credentials
    Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -NoWelcome

    Write-Host "Connected to Microsoft Graph"
}

<#
.SYNOPSIS
   Retrieves the password expiration window for a specific domain.
.DESCRIPTION
   This function retrieves the password expiration window (in days) for a specified domain.
.PARAMETER DomainId
   The ID of the domain for which you want to get the password expiration window.
#>
function Get-PasswordExpirationWindow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DomainId
    )

    $PasswordValidDay = Get-MgDomain -DomainId $DomainId | Select-Object -ExpandProperty PasswordNotificationWindowInDays
    return $PasswordValidDay
}

<#
.SYNOPSIS
   Checks and notifies users of password expiration.
.DESCRIPTION
   This function checks the password expiration for all users and sends notifications to those whose passwords are about to expire.
.PARAMETER NotificationThreshold
   The number of days before password expiration to send notifications.
#>
function Check-PasswordExpiration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$NotificationThreshold,
        [Parameter(Mandatory = $true)]
        [string]$DomainId
    )

    $today = Get-Date
    $allUsers = Get-MgUser -All -Property lastPasswordChangeDateTime, mail | Where-Object {$_.PasswordPolicies -contains "DisablePasswordExpiration"}

    foreach ($user in $allUsers) {
        $passwordExpirationDate = $user.LastPasswordChangeDateTime + [System.TimeSpan]::FromDays((Get-PasswordExpirationWindow -DomainId $DomainId))

        $daysUntilExpiration = ($passwordExpirationDate - $today).Days

        if ($daysUntilExpiration -le $NotificationThreshold) {
            Send-PasswordExpirationNotification -User $user -ExpirationDate $passwordExpirationDate
        }
        else {
            Write-Host "Password is not yet expired. Days until expiration: $daysUntilExpiration"
        }
    }
}

<#
.SYNOPSIS
   Sends a password expiration notification email to a user.
.DESCRIPTION
   This function sends an email notification to a user whose password is about to expire.
.PARAMETER User
   The user object for whom the notification is intended.
.PARAMETER ExpirationDate
   The date on which the user's password will expire.
#>
function Send-PasswordExpirationNotification {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$User,
        [Parameter(Mandatory = $true)]
        [datetime]$ExpirationDate
    )

    $params = @{
        Message         = @{
            Subject      = "Your Password is About to Expire"
            Body         = @{
                ContentType = 'HTML'
                Content     = "Your password will expire on $ExpirationDate. Please update your password."
            }
            ToRecipients = @(
                @{
                    EmailAddress = @{
                        Address = $User.mail
                    }
                }
            )
        }
        SaveToSentItems = $true
    }

    # Send the email using the Graph API
    Send-MgUserMail -UserId $from -BodyParameter $params
}

Connect-MyMgGraph -ClientId 'YOUR_CLIENT_ID' -TenantId 'YOUR_TENANT_ID'
Check-PasswordExpiration -NotificationThreshold 7 -DomainID "Your_Domain"