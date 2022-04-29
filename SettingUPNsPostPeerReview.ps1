#Author: Jared Murray 
#Purpose: Takes an employee's UPN and changes it to Firstname.lastname@Mitutoyo.com. 

$OUPath = "OU=UserAccounts,DC=MITUTOYO,DC=ORG"

#looking at modifying the User Container? Try: "CN=Users,DC=MITUTOYO,DC=ORG"

$GetUser = Get-ADUser -Filter * -SearchBase $OUPath -Properties UserPrincipalName,Surname,GivenName
$ListofUsers = Get-ADUser -Filter * -SearchBase $OUPath -Properties UserPrincipalName,Surname,GivenName | Select-Object UserPrincipalName
#$GetUser = Get-ADUser Simpsonm -Properties UserPrincipalName,Surname,GivenName

$TotalCounter = 0 
$ActualCounter = 0 
$LogPath = "C:\Temp\UPNLog\UPNS.csv"

#Determines if the file path already exists. 
#If file exists, sends warning to console.  
If (-not(test-path -Path $LogPath -PathType Leaf))
    {
        $null = New-Item $LogPath -ItemType File -Force
    }else{
        Write-Host "CAUTION - Log Folder was not created (May Already Exist)" -ForegroundColor Yellow
        Write-Output "++++++++++++++++++++++++++++++++++++++++++"
    }

#Goes through list of users, does a little bit of information validation, takes the GivenName and Surname vairables to create a new logname for the UPN
#Then creates a new UPN and sets that to the user's AD account.
$GetUser | foreach {
    $TotalCounter++ 
    
    $Name = $_.Name
    $Firstname = $_.GivenName
    $Lastname = $_.Surname
    $Suffix = "@Mitutoyo.com"

    if($Name, $Firstname, $Lastname -match ".*\d+.*" )
    {
        Write-Host "WARNING - $Name was not modified, due to numbers being found in one of 3 locations Name, GivenName, Surname" -ForegroundColor Red
        Write-Output "++++++++++++++++++++++++++++++++++++++++++"
        return
    }

    if($Firstname, $Lastname -match ".*\s+.*" )
    {
        Write-Host "WARNING - $Name was not modified, due to white space being found in either thier GivenName or Surname" -ForegroundColor Red
        Write-Output "++++++++++++++++++++++++++++++++++++++++++"
        return
    }

    if ($Firstname -and $Lastname) {
        $LogonName = ($Firstname + "." + $Lastname).ToLower()
        Write-Output "User's name: $Name"
        Write-Output "User's GivenName: $Firstname"
        Write-Output "User's Surname: $Lastname"
        Write-Output "User's LogonName for UPN: $LogonName"
        Write-Output "User's UPN: $LogonName$Suffix"
        Write-Output "++++++++++++++++++++++++++++++++++++++++++"
        $ActualCounter++

    } else {
    Write-Host "WARNING - $Name's UPN was not modified due to a missing GivenName or Surname." -ForegroundColor Red
    Write-Output "++++++++++++++++++++++++++++++++++++++++++"
    return
    }

    $NewUPN = ($LogonName + $Suffix)
    $_ | Set-ADUser -UserPrincipalName $NewUPN
    
     
} 

#Writes the usernames to console 
#Write-Output $GetUser.UserPrincipalName

#Creates an array of variables for exporting to the CSV log file

 
 Try 
{
    $ListofUsers | Export-CSV -Path $LogPath -NoType -Append
} 
Catch 
{
    Write-Host "Unable to write to Logfile location" -ForegroundColor Red
    Write-Host "Make sure file is closed before running script, file can be found here: " $LogPath -ForegroundColor Red
} 

Write-Output "$ActualCounter of $TotalCounter UPNs changed."