# Author Jorn Creten FOR Windows Server @ HOGENT
# zet de intnet adapter instellingen juist

# neemt de adapter met naam "ethernet 2". Dit is normaal gezien de tweede adapter die aangemaakt is voro het internal netwerk van virtualbox.
$netadapter = Get-NetAdapter -Name "Ethernet 2"

# Zet Dhcp uit aangezien we een static ip zetten
$netadapter | Set-NetIPInterface -Dhcp Disabled

# Static ip zoals hierboven vermeld, met 255.255.255.0 subnetmask
$netadapter | New-NetIPAddress -IPAddress 192.168.100.10  -PrefixLength 24

# zet ipv6 uit
$netadapter | Disable-NetAdapterBinding -ComponentID ms_tcpip6

#installeert Active directory domain services, start een forest
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
# prompt voor paswoord zodat dit voor elke gebruiker uniek is en er geen hard coded values zijn 
	
$Password = Read-Host -Prompt   'Enter SafeMode Admin Password' -AsSecureString
$Params = @{
    CreateDnsDelegation = $false
    DatabasePath = 'C:\Windows\NTDS'
    DomainMode = 'WinThreshold'
    DomainName = 'jorn.corona'
    DomainNetbiosName = 'JORN'
    ForestMode = 'WinThreshold'
    InstallDns = $true
    LogPath = 'C:\Windows\NTDS'
    NoRebootOnCompletion = $true
    SafeModeAdministratorPassword = $Password
    SysvolPath = 'C:\Windows\SYSVOL'
    Force = $true
}

#Install-ADDSForest -DomainName "Jorn.Corona" -DomainNetbiosName "JORN" -InstallDNS -DomainMode 'WinThreshold' -ForestMode 'WinThreshold' -DatabasePath "C:\NTDS" -SysvolPath "C:\SYSVOL" -LogPath "C:\Logs" -Force

# Maakt een ADDS Forest met de hierboven ingevulde opties
Install-ADDSForest @Params
# Promote tot domeincontroller
#Install-ADDSDomainController -DomainName "jorn.corona" -InstallDns:$true -Credential ($Password) -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "Admin2020" -Force)
# zet het pad naar de domain admin
$User = "JORN\Administrator"
$Password = ConvertTo-SecureString "Admin2020" -AsPlainText -Force
# maakt een admin-credential aan met het pad dat hierboven werd meegegeven en het paswoord in $password
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PassWord

# Gebruikt het aangemaakte credential om een domain controller te maken van de huidige pc. Hierna is een restart nodig
# Dit is niet nodig aangezien de computer automatisch DC wordt bij het maken van een nieuwe zone
# Install-ADDSDomainController -DomainName "jorn.corona" -InstallDns:$true -Credential $Credential -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "Admin2020" -Force) -Force


# Auto login na restart
$hklmpath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUser = "JORN\Administrator"
$DefaultPassword = "Admin2020"
Set-ItemProperty $hklmpath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $hklmpath "DefaultUserName" -Value "$DefaultUser" -type String
Set-ItemProperty $hklmpath "DefaultPassword" -Value "$DefaultPassword" -type String


# Dit creëert een scheduled task, met als doel om het volgende script in de sequence te starten na de restart. de restart is nodig om het domein te joinen.
$A = New-ScheduledTaskAction -Execute "powershell" -Argument "-File Z:\Scripts\DC_2.ps1"
$T = New-ScheduledTaskTrigger -AtLogOn
$P = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask Start_DC_2 -InputObject $D

#Restart-Computer