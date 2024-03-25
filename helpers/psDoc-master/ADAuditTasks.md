---
Module Name: ADAuditTasks
Module Guid: '7ddb359a-e07f-4be0-b63a-a81f44c61fff'
Download Help Link: https://audittaskshelpfiles.blob.core.windows.net/helpfiles/
Help Version: 1.0.0.5
Locale: en-US
---

# ADAuditTasks Module
## Description
{{ Fill in the Description }}

## ADAuditTasks Cmdlets
### [Convert-NmapXMLToCSV](Convert-NmapXMLToCSV)
Converts an Nmap XML scan output file to a CSV file.

### [Get-ADActiveUserAudit](Get-ADActiveUserAudit)
Gets active but stale AD User accounts that haven't logged in within the last 90 days by default.

### [Get-ADHostAudit](Get-ADHostAudit)
Active Directory Server and Workstation Audit with Report export option (Can also be piped to CSV if Report isn't specified).

### [Get-ADUserLogonAudit](Get-ADUserLogonAudit)
Retrieves the most recent LastLogon timestamp for a specified Active Directory user
account from all domain controllers and outputs it as a DateTime object.

### [Get-ADUserPrivilegeAudit](Get-ADUserPrivilegeAudit)
Produces three object outputs: PrivilegedGroups, AdExtendedRights, and possible service accounts.

### [Get-ADUserWildCardAudit](Get-ADUserWildCardAudit)
Takes a search string to find commonly named accounts.

### [Get-HostTag](Get-HostTag)
Creates a host name or tag based on predetermined criteria for as many as 999 hosts at a time.

### [Get-NetworkAudit](Get-NetworkAudit)
Discovers the local network and runs port scans on all hosts found for specific or default sets of ports, displaying MAC ID vendor info.

### [Get-QuickPing](Get-QuickPing)
Performs a quick ping on a range of IP addresses and returns an array of IP addresses
that responded to the ping and an array of IP addresses that failed to respond.

### [Get-WebCertAudit](Get-WebCertAudit)
Retrieves the certificate information for a web server.

### [Join-CSVFile](Join-CSVFile)
Joins multiple CSV files with the same headers into a single CSV file.

### [Merge-ADAuditZip](Merge-ADAuditZip)
Combines multiple audit report files into a single compressed ZIP file.

### [Merge-NmapToADHostAudit](Merge-NmapToADHostAudit)
Merges Nmap network audit data with Active Directory host audit data.

### [Send-AuditEmail](Send-AuditEmail)
This is a wrapper function for Send-MailKitMessage and takes string arrays as input.

### [Submit-FTPUpload](Submit-FTPUpload)
Uploads a file to an FTP server using the WinSCP module.

