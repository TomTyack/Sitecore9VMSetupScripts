#function to stop all the sql server services on a given server


param([String]$ServerName)

function Stop-AllSQLServerServices
{
    [cmdletbinding()]
    Param([string]$Server
    , [bool]$StopSQL=$true
    , [bool]$StopAgent=$true
    , [bool]$StopSSRS=$true
    , [bool]$StopBrowser=$true
    , [bool]$StopSSIS=$true
    , [bool]$StopTextDaemon=$true
    , [bool]$StopSSAS=$true)
 
    #Get all the services on the server
    $Services = get-service -ComputerName $Server
 
    if($StopAgent -eq $true)
    {
        #check the SQL Server Agent services
        write-verbose "Checking Agent Services"
 
        #get all named agent instances and the default instance
        ForEach ($SQLAgentService in $Services | where-object {$_.Name -match "SQLSERVERAGENT" -or $_.Name -like "SQLAgent$*"})
        {
            #check the servcie running status
            if($SQLAgentService.status -eq "Running")
            {
                #if stopped, start the agent
                write-verbose "Stopping SQL Server Agent $($SQLAgentService.Name)"
                $SQLAgentService.Stop()
            }
            else
            {
                #write comfort message that the service is already running
                write-verbose "SQL Agent Service $($SQLAgentService.Name) is already stopped."
            }
        }
    }
    else
    {
        write-verbose "Skipping checking Agent services"
    }
 
    if($StopSSRS -eq $true)
    {
        #check the SSRS services
        write-verbose "Checking SSRS Services"
 
        #get all reporting service services
        ForEach ($SSRSService in $Services | where-object {$_.Name -match "ReportServer"})
        {
            #check the status of the service
            if($SSRSService.status -eq "Running")
            {
                #if stopped, start the agent
                write-verbose "Stopping SSRS Service $($SSRSService.Name)"
                $SSRSService.Stop()
            }
            else
            {
                #write comfort message that the service is already running
                write-verbose "SSRS Service $($SSRSService.Name) is already stopped."
            }
        }
    }
    else
    {
        write-verbose "Skipping checking SSRS services"
    }
 
    if($StopSSIS -eq $True)
    {
 
        #get the SSIS service (should only be one)
        write-verbose "Checking SSIS Service"
 
        #get all services, even though there should only be one
        ForEach ($SSISService in $Services | where-object {$_.Name -match "MsDtsServer*"})
        {
            #check the status of the service
            if($SSISService.Status -eq "Running")
            {
                #if its stopped, start it
                write-verbose "Stopping SSIS Service $($SSISService.Name)"
                $SSISService.Stop()
            }
            else
            {
                #write comfort message
                write-verbose "SSIS $($SSISService.Name) already stopped"
            }
        }
    }
    else
    {
        write-verbose "Skipping checking SSIS services"
    }
 
    if ($StopBrowser -eq $true)
    {
 
        #Check the browser, start it if there are named instances on the box
        write-verbose "Checking SQL Browser service"
 
        #get the browser service
        $BrowserService = $services | where-object {$_.Name -eq "SQLBrowser"}
 
        if($BrowserService.Status -eq "Running")
        {
            #if its stopped start it
            write-verbose "Stopping Browser Server $($BrowserService.Name)"
            $BrowserService.Stop()
        }
        else
        {
            #write comfort message
            write-verbose "Browser service $($BrowserService.Name) is already stopped"
        }
    }
    else
    {
        write-verbose "Skipping checking Browser service"
    }
 
    if($StopTextDaemon -eq $True)
    {
 
        # Start the full text daemons
        write-verbose "Checking SQL Full Text Daemons"
 
        ForEach($TextService in $Services | where-object {$_.Name -match "MSSQLFDLauncher"})
        {
            #check the service status
            if ($TextService.Status -eq "Running")
            {
                #start the service
                write-verbose "Stopping Full Text Service $($TextService.Name)"
                $TextService.Stop()
            }
            else
            {
                write-verbose "Text service $($TextService.Name) is already stopped."
            }
        }
    }
    else
    {
        write-verbose "Skipping checking Text Daemon services"
    }
 
    if($StopSSAS -eq $True)
    {
 
        # start the SSAS service
        write-verbose "Checking SSAS services"
 
        ForEach($SSASService in $Services | where-object {$_.Name -match "MSSQLServerOLAP"})
        {
            #check the service status
            if ($SSASService.Status -eq "Running")
            {
                #start the service
                Write-verbose "Stopping SSAS Service $($SSASService.Name)"
                $SSASService.Stop()
            }
            else
            {
                write-verbose "SSAS Service $($SSASService.Name) is already stopped."
            }
        }
    }
    else
    {
        write-verbose "Skipping checking SSAS services"
    }
 
     if($StopSQL -eq $true)
    {
        #check the SQL Server Engine services
        write-verbose "Checking SQL Server Engine Services"
 
        #get all named instances and the default instance
        foreach ($SQLService in $Services | where-object {$_.Name -match "MSSQLSERVER" -or $_.Name -like "MSSQL$*"})
        {
            #Check the service running status
            if($SQLService.status -eq "Running")
            {
                #if stopped start the SQL Server service
                write-verbose "Stoppin SQL Server Service $($SQLService.Name)"
                $SQLService.Stop()
            }
            else
            {
                #Write comfort message that the service is already running
                write-verbose "SQL Server Service $($SQLService.Name) is already stopped"
            }
        }
    }
    else
    {
        write-verbose "Skipping checking SQL Engine services"
    }
 
}
 
#export-modulemember -function Stop-AllSQLServerServices
 
#function to start all the sql server services on a given server
 
function Start-AllSQLServerServices
{
    [cmdletbinding()]
    Param([string]$Server
    , [bool]$StartSQL=$true
    , [bool]$StartAgent=$true
    , [bool]$StartSSRS=$true
    , [bool]$StartBrowser=$true
    , [bool]$StartSSIS=$true
    , [bool]$StartTextDaemon=$true
    , [bool]$StartSSAS=$true)
 
    #Get all the services on the server
    $Services = get-service -ComputerName $Server
 
    if($StartSQL -eq $true)
    {
        #check the SQL Server Engine services
        write-verbose "Checking SQL Server Engine Services"
 
        #get all named instances and the default instance
        foreach ($SQLService in $Services | where-object {$_.Name -match "MSSQLSERVER" -or $_.Name -like "MSSQL$*"})
        {
            #Check the service running status
            if($SQLService.status -eq "Stopped")
            {
                #if stopped start the SQL Server service
                write-verbose "Starting SQL Server Service $($SQLService.Name)"
                $SQLService.Start()
            }
            else
            {
                #Write comfort message that the service is already running
                write-verbose "SQL Server Service $($SQLService.Name) already running"
            }
        }
    }
    else
    {
        write-verbose "Skipping checking SQL Engine services"
    }
 
    if($StartAgent -eq $true)
    {
        #check the SQL Server Agent services
        write-verbose "Checking Agent Services"
 
        #get all named agent instances and the default instance
        ForEach ($SQLAgentService in $Services | where-object {$_.Name -match "SQLSERVERAGENT" -or $_.Name -like "SQLAgent$*"})
        {
            #check the servcie running status
            if($SQLAgentService.status -eq "Stopped")
            {
                #if stopped, start the agent
                write-verbose "Starting SQL Server Agent $($SQLAgentService.Name)"
                $SQLAgentService.Start()
            }
            else
            {
                #write comfort message that the service is already running
                write-verbose "SQL Agent Service $($SQLAgentService.Name) already running"
            }
        }
    }
    else
    {
        write-verbose "Skipping checking Agent services"
    }
 
    if($StartSSRS -eq $true)
    {
        #check the SSRS services
        write-verbose "Checking SSRS Services"
 
        #get all reporting service services
        ForEach ($SSRSService in $Services | where-object {$_.Name -match "ReportServer"})
        {
            #check the status of the service
            if($SSRSService.status -eq "Stopped")
            {
                #if stopped, start the agent
                write-verbose "Starting SSRS Service $($SSRSService.Name)"
                $SSRSService.Start()
            }
            else
            {
                #write comfort message that the service is already running
                write-verbose "SQL Agent Service $($SSRSService.Name) already running"
            }
        }
    }
    else
    {
        write-verbose "Skipping checking SSRS services"
    }
 
    if($StartSSIS -eq $True)
    {
 
        #get the SSIS service (should only be one)
        write-verbose "Checking SSIS Service"
 
        #get all services, even though there should only be one
        ForEach ($SSISService in $Services | where-object {$_.Name -match "MsDtsServer*"})
        {
            #check the status of the service
            if($SSISService.Status -eq "Stopped")
            {
                #if its stopped, start it
                write-verbose "Starting SSIS Service $($SSISService.Name)"
                $SSISService.Start()
            }
            else
            {
                #write comfort message
                write-verbose "SSIS $($SSISService.Name) already running"
            }
        }
    }
    else
    {
        write-verbose "Skipping checking SSIS services"
    }
 
    if ($StartBrowser -eq $true)
    {
 
        #Check the browser, start it if there are named instances on the box
        write-verbose "Checking SQL Browser service"
 
        #check if there are named services
        if(($services.name -like "MSSQL$*") -ne $null)
        {
            #get the browser service
            $BrowserService = $services | where-object {$_.Name -eq "SQLBrowser"}
 
            if($BrowserService.Status -eq "Stopped")
            {
                #if its stopped start it
                write-verbose "Starting Browser Server $($BrowserService.Name)"
                $BrowserService.Start()
            }
            else
            {
                #write comfort message
                write-verbose "Browser service $($BrowserService.Name) already running"
            }
        }
        else
        {
            #if no named instances, we don't care about the browser
            write-verbose "No named instances so ignoring Browser"
        }
    }
    else
    {
        write-verbose "Skipping checking Browser service"
    }
 
    if($StartTextDaemon -eq $True)
    {
 
        # Start the full text daemons
        write-verbose "Checking SQL Full Text Daemons"
 
        ForEach($TextService in $Services | where-object {$_.Name -match "MSSQLFDLauncher"})
        {
            #check the service status
            if ($TextService.Status -eq "Stopped")
            {
                #start the service
                write-verbose "Starting Full Text Service $($TextService.Name)"
                $TextService.Start()
            }
            else
            {
                write-verbose "Text service $($TextService.Name) already running."
            }
        }
    }
    else
    {
        write-verbose "Skipping checking Text Daemon services"
    }
 
    if($StartSSAS -eq $True)
    {
 
        # start the SSAS service
        write-verbose "Checking SSAS services"
 
        ForEach($SSASService in $Services | where-object {$_.Name -match "MSSQLServerOLAP"})
        {
            #check the service status
            if ($SSASService.Status -eq "Stopped")
            {
                #start the service
                Write-verbose "Starting SSAS Service $($SSASService.Name)"
                $SSASService.Start()
            }
            else
            {
                write-verbose "SSAS Service $($SSASService.Name) already running."
            }
        }
    }
    else
    {
        write-verbose "Skipping checking SSAS services"
    }
}

Try
{
	Write-Host "about to restart the server $ServerName"
	Stop-AllSQLServerServices $ServerName $true $true $false $false $false $false $false
	Start-AllSQLServerServices $ServerName $true $true $false $false $false $false $false
	Write-Host "SQL server restart success"
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

