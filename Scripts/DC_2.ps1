#Disable de scheduled task om dit script te starten aangezien het niet meer nodig is 
Disable-ScheduledTask -TaskName Start_DC_2

#Hernoemt het apparaat, restart moet na dit script nog gebeuren 
$User = "JORN\Administrator"
$Password = ConvertTo-SecureString "Admin2020" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PassWord
Rename-Computer -NewName "WIN-DC-ALFA" -DomainCredential $Credential


#installeert de dhcp rol
Install-WindowsFeature DHCP -IncludeManagementTools

#zet parameters voor dhcp
$scopename = "Hogent-corona"
$startrange = "192.168.100.1"
$endrange = "192.168.100.254"
$subnetmask = "255.255.255.0"
$scopeID = "192.168.100.0"
$router = "192.168.100.10"
$dns = "192.168.100.10"

# Creating scope
Add-DHCPServerv4Scope -EndRange $endrange -Name $scopename -StartRange $startrange -SubnetMask $subnetmask -State Active
# Adding router
Set-DHCPServerv4OptionValue -ScopeId $scopeID -Router $router -Dnsserver $dns -DnsDomain "jorn.corona"
# Zet de dhcp options voor pxeboot die nodig zijn voor de sccm machine later
Set-DHCPServerv4OptionValue -ScopeId $scopeID -OptionId 66 -Value 192.168.100.40
Set-DHCPServerv4OptionValue -ScopeId $scopeID -OptionId 67 -Value boot\x64\wdsnbp.com

# Adding exclusion addresses
Add-Dhcpserverv4ExclusionRange -ScopeId 192.168.100.0 -StartRange 192.168.100.10 -EndRange 192.168.100.10
Add-Dhcpserverv4ExclusionRange -ScopeId 192.168.100.0 -StartRange 192.168.100.20 -EndRange 192.168.100.20
Add-Dhcpserverv4ExclusionRange -ScopeId 192.168.100.0 -StartRange 192.168.100.30 -EndRange 192.168.100.30
Add-Dhcpserverv4ExclusionRange -ScopeId 192.168.100.0 -StartRange 192.168.100.40 -EndRange 192.168.100.40
Restart-service dhcpserver
#authoriseer de dhcp server
Add-DhcpServerInDC -DnsName jorn.corona -IPAddress 192.168.100.10

#installeer remote access
Install-WindowsFeature RemoteAccess -IncludeManagementTools
Install-WindowsFeature Routing -IncludeManagementTools

#Dit commando dient om NAT routing in te stellen. dit werkt echter niet binnen de vm aangezien het telkens 1x geopend moet worden om de adapters te herkennen. wordt in de documentatie ook besproken.
Install-RemoteAccess -DAInstallType FullInstall -ConnectToAddress jorn.corona -InternalInterface 'Ethernet 2' -InternetInterface 'Ethernet' -DeployNat


# Dit creëert een scheduled task, met als doel om het volgende script in de sequence te starten na de restart. de restart is nodig om het domein te joinen.
$A = New-ScheduledTaskAction -Execute "powershell" -Argument "-File Z:\Scripts\DC_3.ps1"
$T = New-ScheduledTaskTrigger -AtLogOn
$P = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask Start_DC_3 -InputObject $D



# Herstart de server voor de pc-rename
Restart-Computer
