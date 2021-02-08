#Disable de scheduled task aangezien deze maar 1x nodig is 
Disable-ScheduledTask -TaskName Start_DC_3

#maakt een primary dns zone met het network id 
Add-DnsServerPrimaryZone -NetworkID "192.168.100.0/24" -ReplicationScope "Forest"

# Runt de preparation van het ad voor exchange (mx-records etc)
Z:\Scripts\DC_4.ps1