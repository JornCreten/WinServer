# Start al de services die nodig zijn voor exchange


Get-Service MSExchangeADTopology | Start-Service
Get-Service MSExchangeDiagnostics | Start-Service
Get-Service MSExchangeEdgeSync | Start-Service
Get-Service MSExchangeMailboxReplication | Start-Service
Get-Service MSExchangeDelivery | Start-Service
Get-Service MSExchangeRepl | Start-Service
Get-Service MSExchangeRPC | Start-Service
Get-Service MSExchangeServiceHost | Start-Service
Get-Service MSExchangeThrottling | Start-Service
Get-Service MSExchangeTransport | Start-Service
Get-Service MSExchangeTransportLogSearch | Start-Service
Get-Service MSExchangeSubmission | Start-Service
Get-Service MSExchangeIS | Start-Service

Write-Host "Script Completed - Services Started successfully" -ForegroundColor Green

<# Get-Service *Exchange* | Start-Service  --> Voor alle Exchange Services te starten
    NOTE: Kan sneller zijn, maar ten koste van performantie (meer RAM nodig#>