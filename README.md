# Exchange Online Mailbox Permissions Auditor

A PowerShell script that audits **FullAccess**, **SendAs**, and **SendOnBehalf** permissions across specified Exchange Online mailboxes and exports the results to a clean CSV report.

---

## What It Does

- Connects to Exchange Online and queries each mailbox you specify
- Collects all three delegation permission types
- Filters out system accounts (`NT AUTHORITY*`) and inherited permissions
- Resolves Send On Behalf identities to their primary SMTP address
- Exports a sorted, UTF-8 encoded CSV ready for review or compliance reporting

---

## Prerequisites

- PowerShell 5.1+ or PowerShell 7+
- [ExchangeOnlineManagement](https://www.powershellgallery.com/packages/ExchangeOnlineManagement) module installed
- An account with Exchange Admin or at minimum View-Only Recipients role

```powershell
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
```

---

## Usage

**Step 1 — Connect to Exchange Online**
```powershell
Connect-ExchangeOnline -UserPrincipalName admin@yourdomain.com
```

**Step 2 — Edit the mailbox list** inside the script
```powershell
$mailboxes = @(
    "payroll@yourdomain.com",
    "finance@yourdomain.com"
)
```

**Step 3 — Run the script**
```powershell
.\Get-MailboxPermissionsReport.ps1
```

The report is saved as `MailboxPermissionsReport.csv` in the same directory.

---

## Output Example

| Mailbox | PermissionType | User |
|---|---|---|
| finance@xyz.com | FullAccess | john.doe@xyz.com |
| finance@xyz.com | SendAs | jane.smith@xyz.com |
| payroll@xyz.com | SendOnBehalf | manager@xyz.com |

---

## Use Cases

- Periodic access reviews and permission audits
- Offboarding checks — verify who still has access to sensitive mailboxes
- Compliance and security reporting
- Change management documentation
