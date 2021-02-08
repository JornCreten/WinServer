Disable-ScheduledTask -TaskName Start_SQL_2

#server hernoemen
$User = "JORN\Administrator"
$Password = ConvertTo-SecureString "Admin2020" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PassWord
Rename-Computer -NewName "WIN-SQL" -DomainCredential $credential


# installeert al de benodigde features voor sql
Write-Host "Starting .NET 3.5 Features Installation"
Install-WindowsFeature -name NET-Framework-Features
Write-Host ".NET 3.5 Features have successfully been installed" -ForegroundColor Green
Write-Host
Write-Host "Starting Remote Differential Compression Installation"
Install-WindowsFeature -name RDC
Write-Host "Installaction Complete" -ForegroundColor Green

# kopieer de iso naar C folder zodat deze gemount kan worden
Copy-Item "Z:\SQL\SQL2017.iso" -Destination "C:\SQL2017.iso" -recurse
# ISO image - replace with path to ISO to be mounted
$isoImg = "C:\SQL2017.iso"
# Drive letter - use desired drive letter
$driveLetter = "Y:"

# Mount the ISO, without having a drive letter auto-assigned
$diskImg = Mount-DiskImage -ImagePath $isoImg  -NoDriveLetter

# Get mounted ISO volume
$volInfo = $diskImg | Get-Volume

# Mount volume with specified drive letter (requires Administrator access)
mountvol $driveLetter $volInfo.UniqueId

#$credential = Get-Credential "JORN\Administrator"

# downloadt de configuratiefile voor sql installatie 
Copy-Item "Z:\SQL\ConfigurationFile.ini" -Destination "C:\ConfigurationFile.ini" -recurse

# Voert de setup uit met de bijgevoegde configuration file die ook gedownload werd
Y:\setup.exe /ConfigurationFile=C:\ConfigurationFile.ini /SQLSVCPASSWORD="Admin2020" /AGTSVCPASSWORD="Admin2020" 

Copy-Item "Z:\SQL\SSMS-Setup-ENU.exe" -Destination "C:\SSMS.exe" -recurse

Write-Host "Starting SQL Server Mgmt Studio Installation"

Start-Process "C:\SSMS.exe" /quiet
Write-Host "Installation Complete" -ForegroundColor Green

Install-WindowsFeature -name GPMC

# een gpo downloaden voor firewall rules
Copy-Item "Z:\SQL\{9C529C81-2723-4CC1-8863-17E0EE801904}" -Destination "C:\{9C529C81-2723-4CC1-8863-17E0EE801904}" -recurse

# Nieuwe gpo aanmaken voor sql
New-GPO -Name "SQLGPO"

# Een gpo importeren voor firewall rules
import-gpo -BackupId "9C529C81-2723-4CC1-8863-17E0EE801904" -Path "C:" -TargetName "SQLGPO"
