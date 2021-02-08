Z:\Scripts\EXC_Startup.ps1

# Maakt een nieuwe send connector om mails t e versturen
$args = @{
    Name = 'Outbound'
    AddressSpaces = '*'
    Internet = $true

}
New-SendConnector @args


# maakt een mailbox aan voor elke user in het domein
Get-User -RecipientTypeDetails User -Filter "UserPrincipalName -ne `$null" -ResultSize unlimited | Enable-Mailbox