#Configuration Settings 
$DatabaseServer = "WIN-SQL"
$ConfigDatabase = "SharePoint_Config"
$AdminContentDB = "SharePoint_Admin"
$Passphrase = "Admin2020"
$FarmAccountName = "JORNCORONA\Administrator"
$ServerRole="SingleServerFarm"
 
#Get the Farm Account Credentials
$FarmAccount = Get-Credential $FarmAccountName
$Passphrase = (ConvertTo-SecureString $Passphrase -AsPlainText -force)
   
#Create SharePoint Farm
Write-Host "Creating Configuration Database and Central Admin Content Database..."
New-SPConfigurationDatabase -DatabaseServer $DatabaseServer -DatabaseName $ConfigDatabase -AdministrationContentDatabaseName $AdminContentDB -Passphrase $Passphrase -FarmCredentials $FarmAccount -LocalServerRole $ServerRole
 
$Farm = Get-SPFarm -ErrorAction SilentlyContinue -ErrorVariable err  
if ($Farm -ne $null) 
{
Write-Host "Installing SharePoint Resources..."
Initialize-SPResourceSecurity
  
Write-Host "Installing Farm Services ..."
Install-SPService
  
Write-Host "Installing SharePoint Features..."
Install-SPFeature -AllExistingFeatures
  
Write-Host "Creating Central Administration..."             
New-SPCentralAdministration -Port 2016 -WindowsAuthProvider NTLM
   
Write-Host "Installing Help..."
Install-SPHelpCollection -All 
  
Write-Host "Installing Application Content..."
Install-SPApplicationContent
   
Write-Host "SharePoint 2019 Farm Created Successfully!"
}

# Maakt een webapplication voor het intranet aan

New-SPWebApplication -Name "SPIntranet" -Port 80 -HostHeader intranet.JORNCORONA -URL "http://intranet.jorncorona.local/" -ApplicationPool "SharePointPool" -ApplicationPoolAccount (Get-SPManagedAccount "JORNCORONA\Administrator")