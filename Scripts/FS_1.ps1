#Add-WindowsFeature Net-Framework-Features, Web-Server,Web-WebServer, Web-CommonHttp, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-App-Dev, WebAsp-Net, Web-Net-Ext, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Health, Web-Http-Logging, Web-LogLibraries, Web-Request-Monitor, Web-Http-Tracing, Web-Security, Web-Basic-Auth, Web-WindowsAuth, Web-Filtering, Web-Digest-Auth, Web-Performance, Web-Stat-Compression, Web-DynCompression, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, ApplicationServer, AS-Web-Support, AS-TCP-Port-Sharing, AS-WAS-Support, AS-HTTP-Activation, AS-TCPActivation, AS-Named-Pipes, AS-Net-Framework, WAS, WAS-Process-Model, WAS-NETEnvironment, WAS-Config-APIs, Web-Lgcy-Scripting, Windows-Identity-Foundation, Server-MediaFoundation, Xps-Viewer


Copy-Item "Z:\SharePoint\officeserver.img" -Destination "C:\officeserver.img" -recurse
# ISO image - replace with path to ISO to be mounted
$isoImg = "C:\officeserver.img"
# Drive letter - use desired drive letter
$driveLetter = "Y:"

# Mount the ISO, without having a drive letter auto-assigned
$diskImg = Mount-DiskImage -ImagePath $isoImg  -NoDriveLetter

# Get mounted ISO volume
$volInfo = $diskImg | Get-Volume

# Mount volume with specified drive letter (requires Administrator access)
mountvol $driveLetter $volInfo.UniqueId


#Y:\PrerequisiteInstaller.exe /unattended

Read-Host "Run the prerequisite installer and press any key when done"


Y:\Setup.exe /config Z:\SharePoint\config.xml


DisMount-DiskImage -ImagePath $isoImg  

Z:\Scripts\FS_2.ps1
