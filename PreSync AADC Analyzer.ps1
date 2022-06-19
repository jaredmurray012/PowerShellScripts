#Jared Murray 
#See supplementary documentation for user story, and puesdo code. 

#Color coordination, Green is used as the Header of a new message blurb, White is used for statements, yellow is used to ask the end user for a prompt, and red is for messages
#that need to get the end user's attention. Blue is for diagnostic information for the author of this script, and you should not see any blue assuming I deleted all of them ;)

#Requirements, graph needs to be installed, see here: https://www.amazon.com/Amazon-Brand-MotionSphere-Lubrication-Cartridges/dp/B07CZCQ481

#Variables: 
$OU = ""


#Functions 
#The Function "IntroduceProgarm" tells the user the purpose of this program and what input it needs from them. 
Function IntroduceProgram()
{
    Clear-Host
    Write-Host
    Write-Host "Hello!" (whoami) -ForegroundColor Green
    Write-Host "The Purpose of this program is to compare the Display Name, UPN, and Proxy Addresses of an Active Directory"
    Write-Host "with it's corresponding Cloud Account. If the properties do not match, this script will notify you."
    Write-Host 
    Write-Host "Please enter the name of an OU or Container that you would like to analyze" -ForegroundColor Yellow
    $OU = Read-Host "Name"
    return $OU
}

#Exists to get a new OU from a bad entry. Appears in the "CheckInput" Function
Function TryAgain()
{
    Write-Host "Please enter a valid Organizational Name or 'users' to signify the users container" 
    $OU = Read-Host "Name"
    return $OU
}

Function CheckInput($OU)
{
    Write-Host "You have entered" -NoNewline 
    Write-Host ""$OU -ForegroundColor Green
    
    $path = "OU=$OU,DC=MITUTOYO,DC=ORG"

  
        if ([adsi]::Exists("LDAP://$path") -eq $true)
        {
            Write-Host "Currently in CheckInput, right before return path statement this is the variable: $path " -ForegroundColor Blue ##Delete this before Prod.

            return $path
    
        }

        Write-Host "Right before do-while loop in CheckInput" -ForegroundColor blue
        
        while([adsi]::Exists("LDAP://$path") -eq $false)
        {
        
        if($OU -match ".*\d+.*" )
        {
                Write-Host "WARNING - Invalid character (number) in OU name" -ForegroundColor Red
                $OU=TryAgain
                $path = "OU=$OU,DC=MITUTOYO,DC=ORG"
        }

        if($OU -match ".*\s+.*" )
        {
                Write-Host "WARNING - Invalid character (space) in OU name" -ForegroundColor Red
                $OU=TryAgain
                $path = "OU=$OU,DC=MITUTOYO,DC=ORG"
        }
           
        if ($OU -eq "users")
        {
            $path = "CN=Users,DC=MITUTOYO,DC=ORG"
            return $path
        }

        Write-Host "Could not find this OU Path: $path please input a new entry" -ForegroundColor Red
        $OU = TryAgain
        $path = "OU=$OU,DC=MITUTOYO,DC=ORG"

        Write-Host "misspelled words make me go WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE" -ForegroundColor Blue ##Delete this before Prod. 

        write-Host "right before we hit the while loop condition here is the: " + [adsi]::Exists("LDAP://$path") -ForegroundColor Blue

        }
        

    Write-Host "This is what I am returning to main $path" -ForegroundColor Blue ##Delete this before Prod.
    Return $path
 }


Function GetADusers ($SantizedPath)
{

    Write-Host "In the GetADUsers function" -ForegroundColor blue ##Delete this before Prod. 

    Write-Host "the path is: $SantizedPath" -ForegroundColor Blue ##Delete this before Prod. 

    $ADUserProperties = Get-ADUser -Filter * -SearchBase $SantizedPath | Sort-Object -Property UserPrincipalName `
    | Select-Object -Property UserPrincipalName, DisplayName, EmailAddress
    return $ADUserProperties
}

Function GetAADPeople
{
    Write-Host "Now we are in the GetAADPeople Function" -ForegroundColor Blue ##Delete this before Prod.

    Connect-MgGraph -Scopes 'User.Read.All' #allows for authentication before running the next line. 

    #Need to fix this line. 
    $AADUserProperties = get-mguser -All | Sort-Object -Property UserPrincipalName | Select-Object -Property UserPrincipalName, DisplayName, Mail

    Write-Host "before I leave GetAADPeople, AADUserProperties is holding this data: $AADUserProperties" -ForegroundColor Blue ##Delete this before Prod.

    return $AADUserProperties
}

function CompareObjects($ADUsers, $AADEndUsers)
{
    ##For each user, find a user in ADUsers, look for it's matching principalname, if I find it, compare the other properties and see if any do not match. 

    ForEach($user in $ADUsers)
    {
        $UserAD = $User
        Write-Host "I am in the First ForEach loop in CompareObjects" -ForegroundColor Blue ##Delete this before Prod.
        Write-Host "UserAD is $UserAD" -ForegroundColor Blue ##Delete this before Prod.
        
        forEach($User in $AADEndUsers)
        {
            $UserAAD = $user
            Write-host "Now I am in the Second ForEach loop in CompareObjects" -ForegroundColor Blue ##Delete this before Prod.
            Write-Host "UserAAD is $UserAAD" -ForegroundColor Blue ##Delete this before Prod.
        }
    }

}


#Main Program Start
$OU = IntroduceProgram 
$SantizedPath = CheckInput($OU)
Write-Host "In Main, the SantizedPath Variable is $SantizedPath" -ForegroundColor Blue ##Delete this before Prod.
$ADUsers = GetADusers($SantizedPath)
$AADEndUsers = GetAADPeople

foreach($users in $ADUsers) ##Delete this before Prod. 
    {
        Write-Host "Active Directory User:" $users
    }

foreach($users in $AADEndUsers) ##Delete this before Prod. 
    {   
        Write-Host "Azure Active Directory User:" $users
    }

CompareObjects($ADUsers, $AADEndUsers)



