

#kopieert de exchange iso naar c schijf zodat deze gemount kan worden.
Copy-Item "Z:\Exchange_2019\exchange.iso" -Destination "C:\exchange.iso" -recurse

# ISO image - replace with path to ISO to be mounted
$isoImg = "C:\exchange.iso"
# Drive letter - use desired drive letter
$driveLetter = "Y:"


# Mount the ISO, without having a drive letter auto-assigned
$diskImg = Mount-DiskImage -ImagePath $isoImg  -NoDriveLetter

# Get mounted ISO volume
$volInfo = $diskImg | Get-Volume

# Mount volume with specified drive letter (requires Administrator access)
mountvol $driveLetter $volInfo.UniqueId

Y: <# Drive waar iso mounted is (kan varieren per pc, moet E zijn) #>

#AD preparation voor exchange server
Write-Host "Prepare Schema - Started"
.\Setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms
Write-Host "Prepare Schema - Complete" -ForegroundColor Green

Write-Host

Write-Host "Prepare AD - Started"
.\Setup.exe /PrepareAD /OrganizationName:jorn /IAcceptExchangeServerLicenseTerms
Write-Host "Perpare AD - Complete" -ForegroundColor Green

Write-Host

Write-Host "Prepare All Domains - Started"
.\Setup.exe /PrepareAllDomains /IAcceptExchangeServerLicenseTerms
Write-Host "Prepare All Domains - Completed" -ForegroundColor Green

DisMount-DiskImage -ImagePath $isoImg  

#MX Record bij DNS voor mail
Add-DnsServerResourceRecordMX -Preference 10  -Name "." -TimeToLive 01:00:00 -MailExchange "WIN-EXC.jorn.corona" -ZoneName "jorn.corona"