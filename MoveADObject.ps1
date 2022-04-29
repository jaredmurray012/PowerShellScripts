#Author: Jared Murray
#Date: 4/25/2022
#Propose: Remove Prevent Accidentally Deletion, move the service account, apply Prevent Accidental Deletion. 

[CmdletBinding()]
param (
    [Parameter()]
    [String]$EmployeeAccount="test",
    [Parameter()]
    [string]$ComputerName="test",
    [Parameter()] 
    [String]$OUName="test")


try{
if ($EmployeeAccount -ne "test")
{
#Validate that the OU Path exists
[String]$Path = "OU=" + $OUName + ",DC=Mitutoyo,DC=ORG"    
try 
{
    $ou_exists = [adsi]::Exists("LDAP://$Path")
} 

catch 
{
    # If invalid format, error is thrown.
    Throw('ERROR - The OU may not exist, or been spelled incorrectly"')
}

if (-not $ou_exists) 
{
    Throw('ERROR - The OU may not exist, or been spelled incorrectly"')
} 
else 
{
    Write-Debug "Path Exists: $Path"
}

#Get Get User Account, Remove Protected From Accidental Protection, Move Account, Reapply Protection

$user=(Get-ADUser -Identity $EmployeeAccount).distinguishedName
Write-Host "The Employee Account Selected is: $EmployeeAccount" -ForegroundColor Yellow
Write-Host "The OU selected to move the employee to is: $OUName" -ForegroundColor Yellow
Write-Host "Active Directory location of the $EmployeeAccount BEFORE modifying is here: " $User -ForegroundColor Green
Set-ADObject $user -ProtectedFromAccidentalDeletion:$false
Move-ADObject $user -TargetPath "OU=$OUName,DC=Mitutoyo,DC=ORG"
$user=(Get-ADUser -Identity $EmployeeAccount).distinguishedName
Set-ADObject $user -ProtectedFromAccidentalDeletion:$true

Write-Host "Active Directory location of the $EmployeeAccount AFTER modifying is here: " $User -ForegroundColor Green
}
}
catch 
{
    Write-Host "ERROR, $EmployeeAccount was not succesfully moved to $OUName, check the spelling of the Computer Name and OU. Check document for additional information on the constraints of this script." -ForegroundColor Red
} 

Try{
if ($ComputerName -ne "test")
{ 

#Validate that the OU Path exists
[String]$Path = "OU=" + $OUName + ",OU=Client Computers,DC=Mitutoyo,DC=ORG"    
try 
{
    $ou_exists = [adsi]::Exists("LDAP://$Path")
} 
catch 
{
    #If invalid format, error is thrown.
    Throw('ERROR - The OU may not exist, or been spelled incorrectly"')
}

if (-not $ou_exists) 
{
    Throw('ERROR - The OU may not exist, or been spelled incorrectly"')
} 
else 
{
    Write-Debug "Path Exists: $Path"
}

#Get Computer Location, Remove Protected From Accidental Protection, Move Computer, Reapply Protection

$ComputerLoc = Get-ADComputer $ComputerName
Write-Host "The Employee Account Selected is: $ComputerName" -ForegroundColor Yellow
Write-Host "The OU selected to move the employee to is: $OUName" -ForegroundColor Yellow
Write-Host "Active Directory location of the Computer BEFORE modifying is here: " $ComputerLoc -ForegroundColor Green
$ComputerLoc | Set-ADObject -ProtectedFromAccidentalDeletion:$false 
Get-ADComputer $ComputerName | Move-ADObject -TargetPath "OU=$OUName,OU=Client Computers,DC=Mitutoyo,DC=ORG"
Get-ADComputer $ComputerName | Set-ADObject -ProtectedFromAccidentalDeletion:$true

$ComputerLoc = Get-ADComputer $ComputerName
Write-Host "Active Directory location of the Computer AFTER modifying is here: " $ComputerLoc -ForegroundColor Green
}

}
catch 
{
    Write-Host "ERROR, $ComputerName was not succesfully moved to $OUName, check the spelling of the Computer Name and OU. Check document for additional information on the constraints of this script." -ForegroundColor Red
} 

#if the end user did not add any param write the following warning messages to the console.
If ($EmployeeAccount -and $ComputerName -and $OUName -eq "test")
{
    Write-Host "WARNING - Missing Switches. Available switches are -computername, -employeeaccount, and -OUName (mandatory)" -ForegroundColor Red
    Write-Host "To move an Employee Object try this: .\moveADObject.ps1 -employeeaccount 'simpsonm' -OUName 'UserAccounts'" -ForegroundColor Blue
    Write-Host "To move a Computer Object try this: .\moveADObject.ps1 -computername 'NAME OF COMPUTER HERE' -OUName 'W10 Desktops'" -ForegroundColor Blue
}