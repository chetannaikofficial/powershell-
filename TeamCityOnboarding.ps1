$UserList = Import-Csv "https://github.com/chetannaikofficial/powershell-/blob/52f96c98a04d06bcebfafa1675fd755cea5c7a86/onboarding.csv";


foreach($User in $UserList)
	{
    	$samAccount = $User.login
		$FirstName = $User.fname
		$LastName = $User.lname
		#$OU = $User.OU
		$DisplayName = $User.DisplayName
		$upn = $User.emailaddress
        $phone = $User.CellNumber
        $title = $User.JobTitle
        $dept = $User.DepartmentName
        $descr = $User.Description            
        $manager = Get-ADUser $User.Manager -Properties samaccountname
        $password = (ConvertTo-SecureString zocdoc@123 -AsPlainText -Force)
        $ModelUser = Get-ADUser $User.ModelUser -Properties MemberOf
      

		#Check if user already exists
		if(Get-AdUser -Filter {SamAccountName -eq $samAccount})
		{
		  Write-Warning "User $DisplayName already exists."
		}
		    else		   
		{
		    New-ADUser -SamAccountName $samAccount `
		    -UserPrincipalName $upn `
            -Name $DisplayName `
            -GivenName $FirstName `
            -Surname $LastName `
            -DisplayName $DisplayName `
		    -EmailAddress $upn `
			-Path $OU `
			-AccountPassword $password `
			-Enabled $true `
            -Title $title `
            -Description $descr `
            -Manager $manager `
            -Department $dept `
            -MobilePhone $phone `
            -StreetAddress "5th Floor, Onyx Towers, North Main Road, Koregaon Park" `
            -City "Pune" `
            -State "Maharashtra" `
            -PostalCode "411001" `
            -Company "Zocdoc"
                      
			 
		}   
            #Get-ADUser -Identity  $ModelUser -Properties memberof | Select-Object -ExpandProperty memberof |  Add-ADGroupMember -Members $samAccount
            
  }