# zet de intnet adapter instellingen juist
# Zelfde instellingen als in DC_1 voor de adapter, enkel op de main interface
$netadapter = Get-NetAdapter -Name "Ethernet"

$netadapter | Set-NetIPInterface -Dhcp Disabled

$netadapter | New-NetIPAddress -IPAddress 192.168.100.30  -PrefixLength 24

Set-DnsClientServerAddress -InterfaceIndex $(Get-NetAdapter | Where-object {$_.Name -like "Ethernet" } | Select-Object -ExpandProperty InterfaceIndex) -ServerAddresses ("192.168.100.10")
$netadapter | New-NetRoute -NextHop "192.168.100.10" -DestinationPrefix 0.0.0.0/0

$netadapter | Disable-NetAdapterBinding -ComponentID ms_tcpip6
# domein joinen
$User = "JORN\Administrator"
$Password = ConvertTo-SecureString "Admin2020" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PassWord
# aan het domein toevoegen
add-computer -domainname jorn.corona -Credential $credential

$A = New-ScheduledTaskAction -Execute "powershell" -Argument "-File Z:\Scripts\EXC_2.ps1"
$T = New-ScheduledTaskTrigger -AtLogOn
$P = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask Start_EXC_2 -InputObject $D


# Auto login na restart
$hklmpath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUser = "JORN\Administrator"
$DefaultPassword = "Admin2020"
Set-ItemProperty $hklmpath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $hklmpath "DefaultUserName" -Value "$DefaultUser" -type String
Set-ItemProperty $hklmpath "DefaultPassword" -Value "$DefaultPassword" -type String

Restart-Computer
