# =============================================================================
# Script  : Get-MailboxPermissionsReport.ps1
# Purpose : Audits FullAccess, SendAs, and SendOnBehalf permissions
#           for specified Exchange Online mailboxes and exports to CSV.
# Requires: ExchangeOnlineManagement module
#           Connect-ExchangeOnline must be run before executing this script.
# =============================================================================

# --------------------------------------------------------------------------
# Configuration — add or remove mailboxes here
# --------------------------------------------------------------------------
$mailboxes = @(
    "payroll@xyz.com",
    "finance@xyz.com"
)

$exportPath = ".\MailboxPermissionsReport.csv"

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
$results = @()

foreach ($mb in $mailboxes) {

    Write-Host "Processing mailbox: $mb" -ForegroundColor Cyan

    # Retrieve the mailbox object (required for Send on Behalf resolution)
    $mailboxObj = Get-Mailbox -Identity $mb

    # ------------------------------------------------------------------
    # Full Access
    # ------------------------------------------------------------------
    $fullAccess = Get-MailboxPermission -Identity $mb |
        Where-Object {
            $_.AccessRights -contains "FullAccess" -and
            $_.User         -notlike "NT AUTHORITY*" -and
            $_.IsInherited  -eq $false
        }

    foreach ($fa in $fullAccess) {
        $results += [PSCustomObject]@{
            Mailbox        = $mb
            PermissionType = "FullAccess"
            User           = $fa.User.ToString()
        }
    }

    # ------------------------------------------------------------------
    # Send As
    # ------------------------------------------------------------------
    $sendAs = Get-RecipientPermission -Identity $mb |
        Where-Object {
            $_.AccessRights -contains "SendAs" -and
            $_.Trustee      -notlike "NT AUTHORITY*"
        }

    foreach ($sa in $sendAs) {
        $results += [PSCustomObject]@{
            Mailbox        = $mb
            PermissionType = "SendAs"
            User           = $sa.Trustee.ToString()
        }
    }

    # ------------------------------------------------------------------
    # Send On Behalf
    # ------------------------------------------------------------------
    if ($mailboxObj.GrantSendOnBehalfTo) {

        foreach ($sob in $mailboxObj.GrantSendOnBehalfTo) {
            try {
                $resolvedUser = Get-Recipient -Identity $sob -ErrorAction Stop

                $results += [PSCustomObject]@{
                    Mailbox        = $mb
                    PermissionType = "SendOnBehalf"
                    User           = $resolvedUser.PrimarySmtpAddress
                }
            }
            catch {
                # Fallback: store the raw identity if resolution fails
                $results += [PSCustomObject]@{
                    Mailbox        = $mb
                    PermissionType = "SendOnBehalf"
                    User           = $sob
                }
            }
        }
    }
}

# --------------------------------------------------------------------------
# Export
# --------------------------------------------------------------------------
$results |
    Sort-Object Mailbox, PermissionType |
    Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8

Write-Host "Report exported to $exportPath" -ForegroundColor Green
