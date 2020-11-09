#Import-Module activedirectory
$admaccount = Read-Host "Enter your ADM Account for Change Group: ";
Add-ADGroupMember -Identity ChangeGroup -Members $admaccount
$admuser = Get-ADUser -identity adm-chetan.naik | Select-Object GivenName

$user= Read-Host "Enter User Name to Disable: ";
$validate = Get-ADUser -LDAPFilter "(samaccountname=$user)"

if($validate -eq $null)
{
      Write-Host "User Not Found"
}else{
        Get-ADUser -Identity $user -Properties DisplayName, Enabled}

    Write-Host = "*************************  Removing from Group Members **********************"

    $RemoveGroupMember = Get-ADPrincipalGroupMembership -Identity $user | Where-Object -Property Name -NE -Value 'Domain Users' | Remove-ADGroupMember -Members $user
    $RemoveGroupMember

    Write-Host = "*************************  Set Proxy **********************"
    
    $ManagerID = (get-aduser (get-aduser $user -Properties manager).manager).samaccountName
    $smtp = $user+"@zocdoc.com"
    Set-ADUser $ManagerID -Add @{ProxyAddresses="SMTP:$smtp"}
    Set-ADUser -Identity $user -Clear ProxyAddresses


    Write-Host = "*************************  Set Description with Termination Date **********************"
        
        $date = Get-Date -Format "MM/dd/yyyy"
        #$currentuser = (get-wmiobject -class Win32_ComputerSystem).UserName.Split('\')[1]
        $description = "Terminated " + $date + " by " + $admuser
        Get-aduser $user | Set-ADUser -description $Description
    

    Write-Host = "*************************  Set VFE **********************"


     $AdUser = Get-ADUser -Identity $user -Properties * | Select-Object GivenName, Name, EmailAddress;
     $vfe_Name = Set-ADUser -Identity $user -DisplayName "VFE_$($AdUser.Name)";
     $vfe_GivenName = Set-ADUser -Identity $user -GivenName "VFE_$($AdUser.GivenName)";
     $vfe_Mail = Set-ADUser -Identity $user -EmailAddress "VFE_$($AdUser.EmailAddress)";



     Write-Host = "*************************  Disable AD Account **********************"
     Disable-ADAccount $user


     Write-Host = "*************************  Validate Terminated Account **********************"     
     Get-ADUser -Identity $user -Properties * | Select-Object DisplayName, GivenName, Mail, Description, Enabled


     Write-Host = "*************************  Move Users to Disabled Users OU  **********************"
    
     $DisabledOU = "OU=Disabled Users, DC=zocdoc,DC=net”
     Get-ADUser $user | Move-ADObject -TargetPath $DisabledOU

     
     Write-Host = "*************************  Disable Computer Move to Disabled OU **********************"
     
     $query = Get-ADUser -Identity $user -Properties *

     [string]$FirstName = $user.Substring(0,1)
     $LastName = $query.Surname

    $combine = $FirstName + $LastName
    
    Write-Host "************** COMPUTER DETAILS **************"

    $computer = Get-ADComputer -Filter "Name -like '$combine*'" -ErrorAction Stop
    
    if($computer){
          Write-Output "Computer exists"
          # Uncomment below line if you want to disable user computer
          Set-ADComputer -Identity $computer -Enabled $false  
      
     }else{
        Write-Output "Computer Not found"
 
     }

 
    Write-Host "************** VALIDATE COMPUTER DISABLED **************"

    Get-ADComputer -Identity $computer -Properties * | Select-Object name, objectclass, enabled


    Write-Host = "*************************  Move Computer to Disabled Computers OU  **********************"

    $DisabledComputerOU = "OU=Disabled Computers, DC=zocdoc,DC=net”
    Get-ADComputer $computer | Move-ADObject -TargetPath $DisabledComputerOU

    Write-Host = "*************************  User offboarding completed on .NET domain  **********************" -ForegroundColor Yellow
    Write-Host = "*************************  Starting offboarding process on .LOCAL domain. Wait for 10 seconds  **********************" -ForegroundColor Yellow
    Start-Sleep -s 10


    $localuser = $user 
    $validate = Get-ADUser -LDAPFilter "(samaccountname=$localuser)"

    if($validate -eq $null)
    {
          Write-Host "User Not Found"
    }else{
            Get-ADUser -Identity $localuser -Properties DisplayName, Enabled -Server zocdoc.local}

        Write-Host = "*************************  Removing from Group Members **********************"

        $RemoveGroupMember = Get-ADPrincipalGroupMembership -Identity $localuser -Server zocdoc.local | Where-Object -Property Name -NE -Value 'Domain Users' | Remove-ADGroupMember -Members $localuser
        $RemoveGroupMember

        
        Write-Host = "*************************  Set Proxy **********************"
    
        $ManagerID = (get-aduser (get-aduser $localuser -Properties manager).manager).samaccountName
        $localsmtp = $user+"@zocdoc.com"
        Set-ADUser $ManagerID -Add @{ProxyAddresses="SMTP:$localsmtp"} -Server zocdoc.local
        Set-ADUser -Identity $localuser -Clear ProxyAddresses -Server zocdoc.local
       
        Write-Host = "*************************  Set Description with Termination Date **********************"
        
        $date = Get-Date -Format "MM/dd/yyyy"
        #$currentuser = (get-wmiobject -class Win32_ComputerSystem).UserName.Split('\')[1]
        $description = "Terminated " + $date + " by " + $admuser
        Get-aduser $localuser -Server zocdoc.local | Set-ADUser -description $Description
        
               
        
         Write-Host = "*************************  Set VFE **********************"


         $AdUser = Get-ADUser -Identity $localuser -Properties * -Server zocdoc.local | Select-Object GivenName, Name, EmailAddress;
         $vfe_Name = Set-ADUser -Identity $localuser -Server zocdoc.local -DisplayName  "VFE_$($AdUser.Name)";
         $vfe_GivenName = Set-ADUser -Identity $localuser -Server zocdoc.local -GivenName "VFE_$($AdUser.GivenName)";
         $vfe_Mail = Set-ADUser -Identity $localuser -Server zocdoc.local -EmailAddress "VFE_$($AdUser.EmailAddress)";



         Write-Host = "*************************  Disable AD Account **********************"
         Disable-ADAccount $localuser -Server zocdoc.local


         Write-Host = "*************************  Validate Terminated Account **********************"     
         Get-ADUser -Identity $localuser -Properties * -Server zocdoc.local | Select-Object DisplayName, GivenName, Mail, Enabled


         Write-Host = "*************************  Move Users to Disabled Users OU  **********************"
         $DisabledOU = "OU=zzzzz-Disabled Users, DC=zocdoc,DC=local”
         Get-ADUser $localuser -Server zocdoc.local | Move-ADObject -TargetPath $DisabledOU         


         Write-Host "************************* USER OFFBOARDING COMPLETED **********************" -ForegroundColor Yellow -BackgroundColor DarkMagenta
          