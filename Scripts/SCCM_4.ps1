# de SCCM Powershell module importeren zodat deze binnen powershell uitgevoerd kunnen worden
Set-Location  "C:\SCCM\AdminConsole\bin"
Import-Module .\ConfigurationManager.psd1

# Maakt een psdrive aan. dit is nodig om de powershell commands uit te voeren binnen de juiste site
New-PSDrive -Name "TIN" -PSProvider "AdminUI.PS.Provider\CMSite" -Root "WIN-SCCM.jorn.corona" -Description "Primary site"
Set-location TIN:

# Dit maakt de boundary "default first site name" en voegt deze toe aan de boundarygroup ADSite
New-CMBoundary -DisplayName "Active Directory Site" -Value "Default-First-Site-Name" -Type ADSite | Add-CMBoundaryToGroup -BoundaryGroupName 'ADSite'

# Zet een discovery schedule (wanneer de discovery moet gerund worden) en zet alle discovery methods aan om apparaten te vinden binnen het domein en netwerk
$Schedule = New-CMSchedule -DurationInterval Days -DurationCount 0 -RecurInterval Days -RecurCount 0
Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -SiteCode "TIN" -EnableActiveDirectorySiteBoundaryCreation $True -Enabled $True  -EnableSubnetBoundaryCreation $True -PollingSchedule $Schedule
Set-CMDiscoveryMethod -NetworkDiscovery -SiteCode "TIN" -Enabled $true -NetworkDiscoveryType ToplogyAndClient
Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode "TIN" -Enabled $true -ActiveDirectoryContainer "LDAP://DC=JORN,DC=CORONA"
Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode "TIN" -Enabled $true -ActiveDirectoryContainer "LDAP://DC=JORN,DC=CORONA" 
$discoveryScope =New-CMADGroupDiscoveryScope -LDAPlocation "LDAP://DC=JORN,DC=CORONA" -Name"ADdiscoveryScope" -RecursiveSearch $true
Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode "TIN" -Enabled $true -AddGroupDiscoveryScope $discoveryScope

# Dit is geen goede of conventionele manier om wachtwoorden door te geven maar om alles unattended te houden doen we het in deze cursus
$pass = ConvertTo-SecureString -String "Admin2020" -AsPlainText -Force

# maakt een account aan
New-CMAccount -UserName "CMADmin" -Password $pass -SiteCode "TIN" 
# Zet het distribution component met de domain admin
Set-CMSoftwareDistributionComponent -SiteCode "TIN" -NetworkAccessAccount "JORN\Administrator"

# Enable PXE boot en laat alle nieuwe apparaten toe
Set-CMDistributionPoint -SiteSystemServerName "WIN-SCCM.JORN.CORONA" -enablePXE $true -AllowPxeResponse $true -EnableUnknownComputerSupport $true -RespondToAllNetwork

#Maakt de connectie met wsus
Add-CMSoftwareUpdatePoint -SiteCode "TIN" -SiteSystemServerName "WIN-SCCM.JORN.CORONA" -ClientConnectionType "Intranet"


# Maakt folders aan die nodig zijn voor de task sequence
New-Item -Path 'C:\MDT' -ItemType Directory
New-Item -Path 'C:\MDT\MDT Toolkit Package' -ItemType Directory
New-Item -Path 'C:\MDT\MDT Settings Package' -ItemType Directory
New-Item -Path 'C:\MDT\InstallImage' -ItemType Directory
New-Item -Path 'C:\MDT\Applicaties' -ItemType Directory

# Moet een networkshare zijn, dus maakt een networkshare van de net aangemaakte folder MDT
New-SmbShare -Name "MDT" -Path "C:\MDT" -ReadAccess "Everyone"

# Geeft iedereen read permissions voor de mdt folder
$sharepath = "C:\MDT"
$Acl = Get-ACL $SharePath
$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("everyone","FullControl","ContainerInherit,Objectinherit","none","Allow")
$Acl.AddAccessRule($AccessRule)
Set-Acl $SharePath $Acl