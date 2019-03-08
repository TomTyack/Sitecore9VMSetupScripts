# Date:         11/01/14
# Author:       John Sansom
# Description:  PS script to change a SQL Login password for a provided server list.
#           The script accepts an input file of server names.
# Version:  1.0
#
# Example Execution: .\setSqlServerAdmin.ps1 SQLEXPRESS SA Password1!
 
param([String]$ServerName, [String]$login, [String]$password)
 
#Load the input file into an Object array
#$ServerNameList = get-content -path $serverListPath
 
#Load the SQL Server SMO Assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
 
#Create a new SqlConnection object
Try
{
	$objSQLConnection = New-Object System.Data.SqlClient.SqlConnection
	$objSQLConnection.ConnectionString = "Server=$env:COMPUTERNAME\$ServerName;Integrated Security=SSPI;"
		Write-Host "Trying to connect to SQL Server instance on $env:COMPUTERNAME\$ServerName..." -NoNewline
		$objSQLConnection.Open() | Out-Null
		Write-Host "Success."
	$objSQLConnection.Close()
}
Catch
{
	Write-Host -BackgroundColor Red -ForegroundColor White "Fail"
	$errText =  $Error[0].ToString()
		if ($errText.Contains("network-related"))
	{Write-Host "Connection Error. Check server name, port, firewall."}

	Write-Host $errText
	continue
}

#Create a new SMO instance for this $ServerName
$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $env:COMPUTERNAME\$ServerName

$nm = $srv.Name
$mode = $srv.Settings.LoginMode
Write-Host "Instance Name: $nm"
Write-Host "Login Mode: $mode"
#Change to Mixed Mode
$srv.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
# Make the changes
$srv.Alter()

#Find the SQL Server Login and Change the Password
$SQLUser = $srv.Logins | ? {$_.Name -eq "$login"};

$SQLUser.Enable();
$SQLUser.Alter();
$SQLUser.Refresh();

$SQLUser.PasswordPolicyEnforced = 0;
$SQLUser.Alter();
$SQLUser.Refresh();
Write-Host "server:'$env:COMPUTERNAME\$ServerName' set to mixed mode logins and weak password policy for development"

$SQLUser.ChangePassword($password);
$SQLUser.Alter();
$SQLUser.Refresh();
Write-Host "Password for Login:'$login' changed successfully on server:'$env:COMPUTERNAME\$ServerName' to -> $password"

