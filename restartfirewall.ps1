# Fonctionne seulement avec powershell v7+.
if(!($PSVersionTable.PSVersion.Major -eq "7")){ Write-Host "Script use only PwSH v7"; exit 1 }

$IP = "192.168.10.254"
$Port = "4443"
$Username = "admin"
$Password = "monsupermdp"


$Uri = "https://"+$Ip+":"+$Port+"/api/sonicos"
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))


# Ouverture de la session RestAPI, recuperation d'un cookie d'authentification.
$Session = Invoke-RestMethod -Uri "$Uri/auth" -Method POST -ContentType 'application/json' -SessionVariable 'Cookie' -SkipCertificateCheck -Authentication Basic -Credential $Credential
Remove-Variable -Name Username, Password, Credential

try
{
    $CloudBackup = Invoke-RestMethod -Uri "$Uri/cloud-backup/name/RMM_Reboot" -Method 'POST' -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck 
}
catch
{
    #Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
    $rCloudBackup = ($_.ErrorDetails.Message | ConvertTo-Json)
}

Start-Sleep -Seconds 15

try
{
    $FirewallRestart = Invoke-RestMethod -Uri "$Uri/restart/now" -Method 'POST' -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck 
}
catch
{
    #Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
    $rFirewallREstart = ($_.ErrorDetails.Message | ConvertTo-Json)
}


# Fermeture de la session RestAPI, suppression du cookie d'authentification.
$Session = Invoke-RestMethod -Uri "$Uri/auth" -Method DELETE -ContentType 'application/json' -WebSession $Cookies -SkipCertificateCheck

Do {
    Write-Host "En attente de redemarrage"
    Start-Sleep -Seconds 1
} While (Test-Connection $IP -count 1)
