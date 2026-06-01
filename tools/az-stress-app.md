```bash
$rgName = 'az104-rg9'
$webapp = Get-AzWebApp -ResourceGroupName $rgName

while ($true) { Invoke-WebRequest -Uri $webapp.DefaultHostName }
```
