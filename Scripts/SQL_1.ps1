# zet de intnet adapter instellingen juist

$netadapter = Get-NetAdapter -Name "Ethernet"

# zet dhcp uit
$netadapter | Set-NetIPInterface -Dhcp Disabled

# zet het ip adres
$netadapter | New-NetIPAddress -IPAddress 192.168.100.20  -PrefixLength 24

# zet het dns adres
Set-DnsClientServerAddress -InterfaceIndex $(Get-NetAdapter | Where-object {$_.Name -like "Ethernet" } | Select-Object -ExpandProperty InterfaceIndex)-ServerAddresses ("192.168.100.10")
# zet default gateway
$netadapter | New-NetRoute -NextHop "192.168.100.10" -DestinationPrefix 0.0.0.0/0

# zet ipv6 uit
$netadapter | Disable-NetAdapterBinding -ComponentID ms_tcpip6

# #dit is bad practice MAAR is volledig unattended, kan ook get-credential doen om dit probleem te voorkomen
$User = "JORN\Administrator"
$Password = ConvertTo-SecureString "Admin2020" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PassWord
# aan het domein toevoegen
add-computer -domainname jorn.corona -Credential $credential

# Auto login na restart
$hklmpath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUser = "JORN\Administrator"
$DefaultPassword = "Admin2020"
Set-ItemProperty $hklmpath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $hklmpath "DefaultUserName" -Value "$DefaultUser" -type String
Set-ItemProperty $hklmpath "DefaultPassword" -Value "$DefaultPassword" -type String

# zet de volgende task
$A = New-ScheduledTaskAction -Execute "powershell" -Argument "-File Z:\Scripts\SQL_2.ps1"
$T = New-ScheduledTaskTrigger -AtLogOn
$P = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask Start_SQL_2 -InputObject $D

Restart-Computer