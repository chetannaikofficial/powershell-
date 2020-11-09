#import-module ActiveDirectory
$username = Read-Host "Enter user name: "
$validate = Get-ADUser -LDAPFilter "(samaccountname=$username)"

if ($validate -eq $null)
{
    Write-Host "User Not Found" -ForegroundColor Red
} else {

    Get-ADUser -Identity $username -Properties * | Select-Object name, PasswordExpired, passwordlastset, pwdlastset                   
}


Set-ADUser -Identity $username -Replace @{pwdLastSet = 0} 
Set-ADUser -Identity $username -Replace @{pwdLastSet = -1} 


Write-Host `n "Validate Password Expiry Extended in ZOCDOC.NET Domain" -ForegroundColor Yellow `n
Get-ADUser -Identity $username -Properties * | Select-Object name, PasswordExpired, passwordlastset, pwdlastset

Write-Host `n
Write-Host "Password extend in Local Domain started..." -ForegroundColor Cyan `n

$localusername = $username
$validate = Get-ADUser -server zocdoc.local -LDAPFilter "(samaccountname=$localusername)"

if ($validate -eq $null)
{
    Write-Host "User Not Found" -ForegroundColor Red `n 
} else {

    Get-ADUser -Identity $localusername -Properties * -Server zocdoc.local | Select-Object name, PasswordExpired, passwordlastset, pwdlastset   
                        
}

Set-ADUser -Identity $localusername -Server zocdoc.local  -Replace @{pwdLastSet = 0} 
Set-ADUser -Identity $localusername -Server zocdoc.local -Replace @{pwdLastSet = -1} 

Write-Host `n  "Validate Password Expiry Extended in ZOCDOC.LOCAL Domain" -ForegroundColor Yellow `n
Get-ADUser -Identity $localusername -Properties * -Server zocdoc.local | Select-Object name, PasswordExpired, passwordlastset, pwdlastset`n

Write-Host `n  "************************* Password expiry extended on both domains **********************" -ForegroundColor Yellow -BackgroundColor DarkMagenta


