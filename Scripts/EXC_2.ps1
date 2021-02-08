Disable-ScheduledTask -TaskName Start_EXC_2

Rename-Computer -NewName "WIN-EXC" -DomainCredential JORN\Administrator

# Installeert al de prereqs
cd Z:\WIN-EXC_Files
Write-Host "Starting Installation"
.\UcmaRuntimeSetup.exe /passive /norestart
Write-Host "Installation Complete" -ForegroundColor Green
Write-Host

Write-Host "Starting Microsoft Visual C++ 2013 Redistributable Installation"
.\vcredist_x64.exe /passive /norestart
Write-Host "Installation Complete" -ForegroundColor Green
Write-Host

Write-Host "Starting Windows Features Installation"
Install-WindowsFeature RSAT-ADDS
Install-WindowsFeature RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation
Install-WindowsFeature NET-WCF-HTTP-Activation45
Install-WindowsFeature ADLDS
Write-Host "Installation Complete" -ForegroundColor Green

Copy-Item "Z:\Exchange_2019\exchange.iso" -Destination "C:\exchange.iso" -recurse

# ISO image - replace with path to ISO to be mounted
$isoImg = "C:\exchange.iso"
# Drive letter - use desired drive letter
$driveLetter = "Y:"

# Mount the ISO, without having a drive letter auto-assigned
$diskImg = Mount-DiskImage -ImagePath $isoImg  -NoDriveLetter

# Get mounted ISO volume
$volInfo = $diskImg | Get-Volume

# Mount volume with specified drive letter (requires Administrator access)
mountvol $driveLetter $volInfo.UniqueId

# CODE HERE


Y: <# Drive waar iso mounted is #>
#Start de exchange install met mailbox rol
.\Setup.exe /IAcceptExchangeServerLicenseTerms /mode:Install /r:MB

DisMount-DiskImage -ImagePath $isoImg  

cd ~

./EXC_Startup

# Start de exchange mailbox server powershell environment. kan eventueel nog aangepast worden met een scheduled task of zoals gedaan in SCCM_4 met installatie plugin TODO
launchems