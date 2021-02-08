# zet de intnet adapter instellingen juist

$netadapter = Get-NetAdapter -Name "Ethernet"

$netadapter | Set-NetIPInterface -Dhcp Disabled

$netadapter | New-NetIPAddress -IPAddress 192.168.100.40  -PrefixLength 24

Set-DnsClientServerAddress -InterfaceIndex $(Get-NetAdapter | Where-object {$_.Name -like "Ethernet" } | Select-Object -ExpandProperty InterfaceIndex)-ServerAddresses ("192.168.100.10")
$netadapter | New-NetRoute -NextHop "192.168.100.10" -DestinationPrefix 0.0.0.0/0

$netadapter | Disable-NetAdapterBinding -ComponentID ms_tcpip6

<# #dit is bad practice MAAR is volledig unattended, kan ook get-credential doen om dit probleem te voorkomen
$username = "JORNCORONA\Administrator"
$password = "Admin2020"
$credential = New-Object System.Management.Automation.PSCredential $username,$password #>
$credential = Get-Credential JORN\Administrator

add-computer -domainname jorn.corona -Credential $credential

# Auto login na restart
$hklmpath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUser = "JORN\Administrator"
$DefaultPassword = "Admin2020"
Set-ItemProperty $hklmpath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $hklmpath "DefaultUserName" -Value "$DefaultUser" -type String
Set-ItemProperty $hklmpath "DefaultPassword" -Value "$DefaultPassword" -type String

Restart-Computer