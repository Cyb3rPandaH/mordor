# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References:

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$LocalAdminPassword
)

Write-Host "Updating Local Administrator Password.."
([adsi]"WinNT://$env:computername/Administrator").SetPassword("$LocalAdminPassword")

# Stop Windows Update
Write-Host "Disabling Windows Updates and Windows Module Services"
Set-Service wuauserv -StartupType Disabled
Stop-Service wuauserv
Set-Service TrustedInstaller -StartupType Disabled
Stop-Service TrustedInstaller

# Firewall Changes
Write-Host "Allow ICMP Traffic through firewall"
& netsh advfirewall firewall add rule name="ALL ICMP V4" protocol=icmpv4:any,any dir=in action=allow

Write-Host "Enable File and Printer Sharing"
& netsh firewall set service type = fileandprint mode = enable

# Set Performance
Write-Host "Setting Best Performance"
new-itemproperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -name VisualFXSetting -propertyType DWord -value 2 -force

# Power Settings
Write-Host "Setting Power Performance"
$HPGuid = (Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "ElementName='High performance'").InstanceID.tostring()
$regex = [regex]"{(.*?)}$"
$PowerConfig = $regex.Match($HPGuid).groups[1].value 
& powercfg -S $PowerConfig