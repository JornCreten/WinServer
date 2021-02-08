
$User = "JORN\Administrator"
$Password = ConvertTo-SecureString "Admin2020" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PassWord
Rename-Computer -NewName "WIN-SCCM" -DomainCredential $credential



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



# Install windows ADK 2004, Windows PE Addon and WDS 

function TestPath($Path) {
    if ( $(Try { Test-Path $Path.trim() } Catch { $false }) ) {
        write-host "Path OK"
    } else {
        write-host "$Path not found, please fix and try again."
        break
    }
}

$SourcePath = "C:\Source"

    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        write-warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        break
    }

    # Create source folder if needed
    if (Test-Path $SourcePath) {
        write-host "The source folder already exists."
    } else {
        new-item -Path $SourcePath -ItemType Directory
    }

Write-Host "Installing Web Server (IIS)"
Install-WindowsFeature Web-Server, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Stat-Compression, Web-Dyn-Compression, Web-Windows-Auth, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-WMI, Web-Scripting-Tools
Write-Host "Installation Complete" -ForegroundColor Green
Write-Host
Write-Host "Installing Background intelligent Transfer Service (BITS)"
Install-WindowsFeature BITS
Write-Host "Installation Complete" -ForegroundColor Green
Write-Host
Write-Host "Installing Windows Internal Database"
Install-WindowsFeature Windows-Internal-Database
Write-Host "Installation Complete" -ForegroundColor Green
Write-Host
Write-Host "Installing Windows Deployment Services"
Install-WindowsFeature WDS, WDS-Deployment, WDS-Transport
Write-Host "Installation Complete" -ForegroundColor Green
write-Host

$ADKPath = '{0}\Windows Kits\10\ADK' -f $SourcePath;
$ADKPath2 = '{0}\Windows Kits\10\Installers\Windows PE x86 x64-x86_en-us.msi' -f $SourcePath;
$MDTPATH= '{0}\Program Files\Microsoft Deployment Toolkit' -f $SourcePath;
$ArgumentList1 = '/layout "{0}" /quiet' -f $ADKPath;

# Check if these files exist, if not, download
$file1 = $SourcePath+"\adksetup.exe"
$file2 = $SourcePath+"\adkwinpesetup.exe"
$file3 = $SourcePath+"\MicrosoftDeploymentToolkit_x64.msi"

    if (Test-Path $file1) {
        write-host "The file $file1 exists, skipping download"
    } else {
    # Download Windows Assessment and Deployment Kit
        write-host "Downloading adksetup.exe " -NoNewline
        $clnt = New-Object System.Net.WebClient
        $url = "https://go.microsoft.com/fwlink/?linkid=2120254"
        $clnt.DownloadFile($url,$file1)
        write-host "Done!" -ForegroundColor Green
    }

    if (Test-Path $ADKPath) {
        write-host "The folder $ADKPath exists, skipping download"
    } else {
        write-host "Downloading Windows ADK 10, please wait..." -NoNewline
        Start-Process -FilePath $file1 -Wait -ArgumentList $ArgumentList1
        write-host "Done!" -ForegroundColor Green
    }

Start-Sleep -s 3

# Download the ADK 10 version 2004 Windows PE Addon
write-host "Downloading adkwinpesetup.exe " -NoNewline
$clnt = New-Object System.Net.WebClient
$url = "https://go.microsoft.com/fwlink/?linkid=2120253"
$clnt.DownloadFile($url,$file2)
write-host "Done!" -ForegroundColor Green

    if (Test-Path $ADKPath2) {
        write-host "The file $ADKPath2 exists, skipping download"
    } else {
        write-host "Downloading the windows PE addon for Windows ADK 10, please wait..." -NoNewline
        Start-Process -FilePath $file2 -Wait -ArgumentList $ArgumentList1
        write-host "Done!" -ForegroundColor Green
    }

# Download the Microsoft Deployment Toolkit
write-host "Downloading MDT msi file " -NoNewline
$clnt = New-Object System.Net.WebClient
$url = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
$clnt.DownloadFile($url,$file3)
write-host "Done!" -ForegroundColor Green

    if (Test-Path $MDTPATH) {
        write-host "The file $ADKPath2 exists, skipping download"
    } else {
        write-host "Downloading the windows PE addon for Windows ADK 10, please wait..." -NoNewline
#        Start-Process -FilePath $file3 -Wait -ArgumentList $ArgumentList1
        write-host "Done!" -ForegroundColor Green
    }


Start-Sleep -s 10

# Install Windows Deployment Service
write-host "Installing Windows Deployment Services..." -NoNewline
Import-Module ServerManager
Install-WindowsFeature -Name WDS -IncludeManagementTools
Start-Sleep -s 10

# Install ADK Deployment Tools
write-host "Installing Windows ADK version 2004..."
Start-Process -FilePath "$ADKPath\adksetup.exe" -Wait -ArgumentList " /Features OptionId.DeploymentTools OptionId.ImagingAndConfigurationDesigner OptionId.UserStateMigrationTool /norestart /quiet /ceip off"
Start-Sleep -s 20
write-host "Done!"

# Install Windows Preinstallation Environment
write-host "Installing Windows Preinstallation Environment..."
Start-Process -FilePath "$ADKPath\adkwinpesetup.exe" -Wait -ArgumentList " /Features OptionId.WindowsPreinstallationEnvironment /norestart /quiet /ceip off"
Start-Sleep -s 20
write-host "Done!"

#Install van MDT
Write-Host "Installing MDT"
Start-Process "C:\Source\MicrosoftDeploymentToolkit_x64.msi" /qn -Wait 
Write-Host "Done!"

Write-Host "Installing WSUS"
Install-WindowsFeature UpdateServices-DB -IncludeManagementTools

&"C:\Program Files\Update Services\Tools\wsusutil.exe" postinstall SQL_INSTANCE_NAME="WIN-SCCM" CONTENT_DIR=C:\WSUS
