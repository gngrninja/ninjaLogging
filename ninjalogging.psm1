Set-StrictMode -Version Latest

$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$scriptName = (Get-ChildItem $MyInvocation.PSCommandPath | Select-Object -ExpandProperty BaseName)

if ($scriptName.count -gt 1) {
    
    $scriptName = 'ScriptLog'
    
}

function New-LogFile {
<#
.SYNOPSIS
   New-LogFile will create a log file.

.DESCRIPTION
   New-LogFile will create a log file. 

   You can specify different paramaters to change the file's name, and where it is stored.
   By default it will attempt to get the name of the calling function or script via $scriptName = (Get-ChildItem $MyInvocation.PSCommandPath | Select-Object -ExpandProperty BaseName).
   It will also attempt to get the path via $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition.
   You can also specify the path and name, as well as if you'd like to append the date in the following format: MM-dd-yy_HHmm.

   Use the -Verbose parameter to display what is happening to the host.

.PARAMETER logPath
    Alias: Path
    Type : String

    Specify the path to the logfile

.PARAMETER logName    
    Alias: Name
    Type : String

    Specify the name of the log file. Be sure to include the extension if specifying the name.

.PARAMETER scriptVersion
    Type : Double

    Specify the version of your script being run. If left blank, will default to 0.1

.PARAMETER addDate
    Type : Boolean

    Specify if you'd like to add the date to the file name.  If you're specifying logName, you can use addDate to append the current date/time in the format: MM-dd-yy_HHmm.

.NOTES
    Name: New-LogFile
    Version: 1.0
    Author: Ginger Ninja (Mike Roberts)
    DateCreated: 5/11/16
    

.LINK
    http://www.gngrninja.com

.EXAMPLE
    $logFile = New-LogFile 
    -----------------------------
    
    gngrNinja> $logFile
    C:\PowerShell\logs\ScriptLog_05-11-16_1612.log

.EXAMPLE
    $logFile = New-LogFile -Verbose
    -----------------------------
    
    VERBOSE: No path specified. Using: C:\PowerShell\logs
    VERBOSE:
    VERBOSE: No log name specified. Setting log name to: ScriptLog.log and adding date.
    VERBOSE:
    VERBOSE: Adding date to log file with an extension! New file name:
    ScriptLog_05-11-16_1613.log
    VERBOSE:
    VERBOSE: Created C:\PowerShell\logs\ScriptLog_05-11-16_1613.log
    VERBOSE:
    VERBOSE: File C:\PowerShell\logs\ScriptLog_05-11-16_1613.log created and verified to
    exist.
    VERBOSE:
    VERBOSE: Adding the following information to:
    C:\PowerShell\logs\ScriptLog_05-11-16_1613.log
    VERBOSE:
    VERBOSE: -----------------------------------------------------------------
    VERBOSE: Started logging at [05/11/2016 16:13:11]
    VERBOSE: Script (Version 0.1) executed by: [thegn] on computer: [GINJA10]
    VERBOSE: -----------------------------------------------------------------
    VERBOSE:
    gngrNinja>

.EXAMPLE
    $logfile = New-LogFile -Name 'testName.log' -path  'c:\temp' -addDate $true -Verbose
    -----------------------------

    VERBOSE: Adding date to log file with an extension! New file name:
    testName_05-11-16_1615.log
    VERBOSE:
    VERBOSE: Created c:\temp\testName_05-11-16_1615.log
    VERBOSE:
    VERBOSE: File C:\temp\testName_05-11-16_1615.log created and verified to exist.
    VERBOSE:
    VERBOSE: Adding the following information to: C:\temp\testName_05-11-16_1615.log
    VERBOSE:
    VERBOSE: -----------------------------------------------------------------
    VERBOSE: Started logging at [05/11/2016 16:15:13]
    VERBOSE: Script (Version 0.1) executed by: [thegn] on computer: [GINJA10]
    VERBOSE: -----------------------------------------------------------------
    VERBOSE:

.OUTPUTS
    Full path to the log file created.
#>
[cmdletbinding()]
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false,
                   Position  = 0)]
        [Alias('Path')]
        [string]
        $logPath,
        [Parameter(Mandatory = $false,
                   Position  = 1)]
        [Alias('Name')]
        [string]
        $logName,
        [Parameter(Mandatory = $false,
                   Position  = 2)]
        [double]
        $scriptVersion = 0.1,
        [Parameter(Mandatory = $false,
                   Position  = 3)]
        [boolean]
        $addDate = $false
    )

#Check if file/path are set
    if (!$logPath) {
        
        $logPath = "$scriptPath\logs"
        
        Write-Verbose "No path specified. Using: $logPath"
        Write-Verbose ""
        
    }
    
    if (!$logName) {
        
        $logName = $scriptName + '.log'
        $addDate = $true
        
        Write-Verbose "No log name specified. Setting log name to: $logName and adding date."
        Write-Verbose ""
      
    }

    #Check if $addDate is $true, take action if so
    if ($addDate) {
        
        if ($logName.Contains('.')) {
            
            $logName = $logName.SubString(0,$logName.LastIndexOf('.')) + "_{0:MM-dd-yy_HHmm}" -f (Get-Date) + $logName.Substring($logName.LastIndexOf('.'))
            
            Write-Verbose "Adding date to log file with an extension! New file name: $logName"
            Write-Verbose ""
           
        } else {
            
            $logName = $logName + "_{0:MM-dd-yy_HHmm}" -f (Get-Date)
            
            Write-Verbose "Adding date to log file. New file name: $logName"
            Write-Verbose ""
            
        }
         
    }
    
    #Variable set up
    $time     = Get-Date
    $fullPath = $logPath + '\' + $logName
    $curUser  = (Get-ChildItem Env:\USERNAME).Value
    $curComp  = (Get-ChildItem Env:\COMPUTERNAME).Value
    
    #Checking paths / Creating directory if needed
    
    if (!(Test-Path $logPath)) {
        
        Try {
            
            New-Item -Path $logPath -ItemType Directory -ErrorAction Stop | Out-Null
            
            Write-Verbose "Folder $logPath created as it did not exist."
            Write-Verbose ""
            
        }
        
        Catch {
            
            $message = $_.Exception.Message
            
            Write-Output "Could not create folder due to an error. Aborting. (See error details below)"
            Write-Error $message
            
            Break
          
        }
    
    }
    
    #Checking to see if a file with the name name exists, renaming it if so.
    if (Test-Path $fullPath) {
        
        Try {
            
            $renFileName = ($fullPath + (Get-Random -Minimum ($time.Second) -Maximum 999) + 'old')
            
            Rename-Item $fullPath -NewName ($renFileName.Substring($renFileName.LastIndexOf('\')+1)) -Force -ErrorAction Stop | Out-Null
            
            Write-Verbose "Renamed $fullPath to $($renFileName.Substring($renFileName.LastIndexOf('\')+1))"
            Write-Verbose ""
            
        }
        
        Catch {
            
            $message = $_.Excetion.Message
            
            Write-Output "Could not rename existing file due to an error. Aborting. (See error details below)"
            Write-Error $message
            
            Break
            
        }
        
    }
    
    #File creation
    Try {
        
        New-Item -Path $fullPath -ItemType File -ErrorAction Stop | Out-Null
        
        Write-Verbose "Created $fullPath"
        Write-Verbose ""
        
    } 
    
    Catch {
        
        $message = $_.Exception.Message
        
        Write-Output "Could not create directory due to an error. Aborting. (See error details below)"
        Write-Error $message
        
        Break
        
    }
    
    #Get the full path in case of dot sourcing
    $fullPath = (Get-ChildItem $fullPath).FullName
    
    if (Test-Path $fullPath) {
        
        $flairLength = ("Script (Version $scriptVersion) executed by: [$curUser] on computer: [$curComp]").Length + 1
        
        Write-Verbose "File $fullPath created and verified to exist."
        Write-Verbose ""
        Write-Verbose "Adding the following information to: $fullPath"
        Write-Verbose ""
        Write-Verbose ('-'*$flairLength)
        Write-Verbose "Started logging at [$time]"
        Write-Verbose "Script (Version $scriptVersion) executed by: [$curUser] on computer: [$curComp]"
        Write-Verbose ('-'*$flairLength)
        Write-Verbose ""
        
        Add-Content -Path $fullPath -Value ('-'*$flairLength)
        Add-Content -Path $fullPath -Value "Started logging at [$time]"
        Add-Content -Path $fullPath -Value "Script (Version $scriptVersion) executed by: [$curUser] on computer: [$curComp]"
        Add-Content -Path $fullPath -Value ('-'*$flairLength)
        Add-Content -Path $fullPath -Value ""
        
        Return [string]$fullPath
         
    } else {
        
        Write-Error "File $fullPath does not exist. Aborting script."

        Break
        
    }
       
}

function Write-LogFile {
<#
.SYNOPSIS
   Write-LogFile will add information to a log file created with New-LogFile.

.DESCRIPTION
   Write-LogFile will add information to a log file created with New-LogFile.

   By default additions to the log file will include a timestamp, unless you specify -addTimeStamp $false.
   This function accepts values from the pipeline, as demonstrated in an example.

   Use the -Verbose parameter to display what is being logged to the host.
   
.PARAMETER logPath
    Alias: Path
    Type : String

    Specify the full path to the log file, including the name.

.PARAMETER logValue
    Alias: Value
    Type : String

    Specify the value(s) you'd like logged.

.PARAMETER addTimeStamp
    Type : Boolean

    Defaults to true, set to false if you'd like to omit the timestamp.

.NOTES
    Name: Write-LogFile
    Version: 1.0
    Author: Ginger Ninja (Mike Roberts)
    DateCreated: 5/11/16

.LINK
    http://www.gngrninja.com

.EXAMPLE
    For this example we'll assume you use:
    $logFile = New-LogFile 

    Write-LogFile -logPath $logFile -logValue 'test log value!'
    -----------------------------

    gngrNinja> more $logfile
    -----------------------------------------------------------------
    Started logging at [05/11/2016 16:19:37]
    Script (Version 0.1) executed by: [thegn] on computer: [GINJA10]
    -----------------------------------------------------------------

    [05-11-16 16:23:24] test log value!

.EXAMPLE
    For this example we'll assume you use:
    $logFile = New-LogFile 

    Write-LogFile -logPath $logFile -logValue 'test log value!' -Verbose
    -----------------------------
    
    VERBOSE: Adding [05-11-16 16:25:19] test log value! to
    C:\PowerShell\logs\ScriptLog_05-11-16_1619.log
    VERBOSE:

.EXAMPLE
    For this example we'll assume you use:
    $logFile = New-LogFile 

    Get-Process | Write-LogFile $logFile -Verbose
    -----------------------------

    ...
    VERBOSE: Adding [05-11-16 16:26:51] System.Diagnostics.Process (wininit) to
    C:\PowerShell\logs\ScriptLog_05-11-16_1619.log
    VERBOSE:
    VERBOSE: Adding [05-11-16 16:26:51] System.Diagnostics.Process (winlogon) to
    C:\PowerShell\logs\ScriptLog_05-11-16_1619.log
    VERBOSE:
    VERBOSE: Adding [05-11-16 16:26:51] System.Diagnostics.Process (WmiPrvSE) to
    C:\PowerShell\logs\ScriptLog_05-11-16_1619.log
    VERBOSE:
    VERBOSE: Adding [05-11-16 16:26:51] System.Diagnostics.Process (WmiPrvSE) to
    C:\PowerShell\logs\ScriptLog_05-11-16_1619.log
    VERBOSE:
    VERBOSE: Adding [05-11-16 16:26:51] System.Diagnostics.Process (WUDFHost) to
    C:\PowerShell\logs\ScriptLog_05-11-16_1619.log
    VERBOSE:
    ...

.EXAMPLE
    For this example we'll assume you use:
    $logFile = New-LogFile 

    Write-LogFile -logPath $logFile -logValue 'test without timestamp' -addTimeStamp $false -Verbose
    -----------------------------

    VERBOSE: Adding test without timestamp to C:\PowerShell\logs\ScriptLog_05-11-16_1631.log
    VERBOSE:
#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true,
                   Position  = 0)]
        [Alias('Path')]
        [string]
        $logPath,
        [Parameter(Mandatory                       = $true,
                   ValueFromPipeline               = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position                        = 1)]
        [Alias('Value')]
        [string]
        $logValue,
        [Parameter(Mandatory = $false,
                   Position  = 2)]
        [boolean]
        $addTimeStamp = $true
    )
    
    Begin {

        if (!(Test-Path $logPath)) {
        
            Write-Error "Unable to access $logPath"

            Break
        
        } 

    }

    Process {

        ForEach ($value in $logValue) {
        
            $timeStamp = "[{0,0:MM}-{0,0:dd}-{0,0:yy} {0,0:HH}:{0,0:mm}:{0,0:ss}]" -f (Get-Date)

            if ($addTimeStamp) {
            
                $value = "$($timeStamp + ' ' + $value)"
           
            }
        
            Write-Verbose "Adding $value to $logPath"
            Write-Verbose ""
        
            Add-Content -Path $logPath -Value $value
            Add-Content -Path $logPath -Value ''

        }
         
    }

}

function Write-LogFileError {
<#
.SYNOPSIS
   Write-LogFileError will add information to a log file created with New-LogFile. The information will be prepended with [ERROR].

.DESCRIPTION
   Write-LogFileError will add information to a log file created with New-LogFile. The information will be prepended with [ERROR].

   By default additions to the log file will include a timestamp, unless you specify -addTimeStamp $false.
   This function accepts values from the pipeline, as demonstrated in an example.

   Use the -Verbose parameter to display what is being logged to the host.
   
.PARAMETER logPath
    Alias: Path
    Type : String

    Specify the full path to the log file, including the name.

.PARAMETER errorDesc
    Alias: Value
    Type : String

    Specify the value(s) you'd like logged as errors.

.PARAMETER addTimeStamp
    Type : Boolean

    Defaults to true, set to false if you'd like to omit the timestamp.

.PARAMETER exitScript
    Alias: Exit
    Type : Boolean

    This parameter let's you specify $true if you'd like to exit the script after the error is logged. 
    It defaults to $false.
    
.NOTES
    Name: Write-LogFileError
    Version: 1.0
    Author: Ginger Ninja (Mike Roberts)
    DateCreated: 5/11/16

.LINK
    http://www.gngrninja.com

.EXAMPLE
    For this example we'll assume you use:
    $logFile = New-LogFile 

    Write-LogFileError -logPath $logFile -errorDesc 'test log value error!'
    -----------------------------

    gngrNinja> more $logFile
    -----------------------------------------------------------------
    Started logging at [05/11/2016 16:31:44]
    Script (Version 0.1) executed by: [thegn] on computer: [GINJA10]
    -----------------------------------------------------------------

    [05-11-16 16:31:51] [ERROR ENCOUNTERED]: test log value error!
#>
    [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true,
                       Position  = 0)]
            [Alias('Path')]
            [string]
            $logPath,
            [Parameter(Mandatory                       = $true,
                       ValueFromPipeline               = $true,
                       ValueFromPipelineByPropertyName = $true,
                       Position                        = 1)]
            [string]
            $errorDesc,
            [Parameter(Mandatory = $false,
                       Position  = 2)]
            [boolean]
            $addTimeStamp = $true,
            [Parameter(Mandatory = $false,
                       Position  = 3)]
            [Alias('Exit')]           
            [boolean]
            $exitScript = $false
        )
    
    Begin {

        if (!(Test-Path $logPath)) {
    
            Write-Error "Unable to access $logPath"
            Break

        }

    }

    Process {
     
        ForEach ($value in $errorDesc) { 

            $timeStamp = "[{0,0:MM}-{0,0:dd}-{0,0:yy} {0,0:HH}:{0,0:mm}:{0,0:ss}]" -f (Get-Date)

            $value     = "[ERROR ENCOUNTERED]: $value"
        
            if ($addTimeStamp) {
            
                $value = "$($timeStamp + ' ' + $value)"
           
            }
        
            Write-Verbose "Adding $value to $logPath"
            Write-Verbose ""
        
            Add-Content -Path $logPath -Value $value
            Add-Content -Path $logPath -Value ''

        }

    }

    End {
         
         if ($exitScript) {
            
            Write-Verbose "Performing log file close command: Resolve-LogFile -logPath $logPath -exitonCompletion $true"
            Write-Verbose ""
            
            Resolve-LogFile -logPath $logPath -exitScript $true
            
        }

    }
 
    
    
}

function Write-LogFileWarning {
<#
.SYNOPSIS
   Write-LogFileWarning will add information to a log file created with New-LogFile. The information will be prepended with [ERROR].

.DESCRIPTION
   Write-LogFileWarning will add information to a log file created with New-LogFile. The information will be prepended with [ERROR].

   By default additions to the log file will include a timestamp, unless you specify -addTimeStamp $false.
   This function accepts values from the pipeline, as demonstrated in an example.

   Use the -Verbose parameter to display what is being logged to the host.
   
.PARAMETER logPath
    Alias: Path
    Type : String

    Specify the full path to the log file, including the name.

.PARAMETER warningDesc
    Alias: Value
    Type : String

    Specify the value(s) you'd like logged as errors.

.PARAMETER addTimeStamp
    Type : Boolean

    Defaults to true, set to false if you'd like to omit the timestamp.

.PARAMETER exitScript
    Alias: Exit
    Type : Boolean

    This parameter let's you specify $true if you'd like to exit the script after the error is logged. 
    It defaults to $false.

.NOTES
    Name: Write-LogFileWarning
    Version: 1.0
    Author: Ginger Ninja (Mike Roberts)
    DateCreated: 5/11/16

.LINK
    http://www.gngrninja.com

.EXAMPLE
    For this example we'll assume you use:
    $logFile = New-LogFile 

    Write-LogFileWarning -logPath $logFile -warningDesc 'test log value warning!'
    -----------------------------

    gngrNinja> more $logFile
    -----------------------------------------------------------------
    Started logging at [05/11/2016 16:38:29]
    Script (Version 0.1) executed by: [thegn] on computer: [GINJA10]
    -----------------------------------------------------------------

    [05-11-16 16:38:48] [WARNING]: test log value warning!
#>
    [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true,
                       Position  = 0)]
            [Alias('Path')]
            [string]
            $logPath,
            [Parameter(Mandatory                       = $true,
                       ValueFromPipeline               = $true,
                       ValueFromPipelineByPropertyName = $true,
                       Position                        = 1)]
            [string]
            $warningDesc,
            [Parameter(Mandatory = $false,
                       Position  = 2)]
            [boolean]
            $addTimeStamp = $true,
            [Parameter(Mandatory = $false,
                       Position  = 3)]
            [Alias('Exit')]           
            [boolean]
            $exitScript = $false
        )
    
    Begin {

        if (!(Test-Path $logPath)) {
    
            Write-Error "Unable to access $logPath"

            Break

        }

    }

    Process {
     
        ForEach ($value in $warningDesc) { 

            $timeStamp = "[{0,0:MM}-{0,0:dd}-{0,0:yy} {0,0:HH}:{0,0:mm}:{0,0:ss}]" -f (Get-Date)

            $value     = "[WARNING]: $value"
        
            if ($addTimeStamp) {
            
                $value = "$($timeStamp + ' ' + $value)"
           
            }
        
            Write-Verbose "Adding $value to $logPath"
            Write-Verbose ""
        
            Add-Content -Path $logPath -Value $value
            Add-Content -Path $logPath -Value ''

        }

    }

    End {
         
         if ($exitScript) {
            
            Write-Verbose "Performing log file close command: Resolve-LogFile -logPath $logPath -exitonCompletion $true"
            Write-Verbose ""
            
            Resolve-LogFile -logPath $logPath -exitScript $true
            
        }

    }
    
}

function Resolve-LogFile {
<#
.SYNOPSIS
   Resolve-LogFile will resolve a created log file.

.DESCRIPTION
   Resolve-LogFile will resolve a created log file.

   Use the -Verbose parameter to display what is happening to the host.

.PARAMETER logPath
    Alias: Path
    Type : String

    Specify the full path, including name, to the log file to be resolved.

.PARAMETER logName    
    Alias: Name
    Type : String

    Specify the name of the log file. Be sure to include the extension if specifying the name.

.PARAMETER exitScript
    Alias: Exit
    Type : Boolean

    Specify $true if you'd like to exit the script after the log file is resolved. 
    It defaults to $false.

.NOTES
    Name: Resolve-LogFile
    Version: 1.0
    Author: Ginger Ninja (Mike Roberts)
    DateCreated: 5/11/16
    
.LINK
    http://www.gngrninja.com

.EXAMPLE
    $logFile = New-LogFile 
    -----------------------------
    
    gngrNinja> $logFile
    C:\PowerShell\logs\ScriptLog_05-11-16_1612.log

.EXAMPLE

    $logFile = New-LogFile 
    Get-Process | Write-LogFile $logFile

    Resolve-LogFile $logFile
    -----------------------------
    
    ...
    [05-11-16 16:43:58] System.Diagnostics.Process (wininit)

    [05-11-16 16:43:58] System.Diagnostics.Process (winlogon)

    [05-11-16 16:43:58] System.Diagnostics.Process (WmiPrvSE)

    [05-11-16 16:43:58] System.Diagnostics.Process (WmiPrvSE)

    [05-11-16 16:43:58] System.Diagnostics.Process (WUDFHost)

    ---------------------------------------------
    Ended logging at [05/11/2016 16:44:01]
    ---------------------------------------------
#>
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true,
                   Position  = 0)]
        [Alias('Path')]
        [string]
        $logPath,
        [Parameter(Mandatory = $false,
                   Position  = 1)]
        [Alias('Exit')]
        [boolean]
        $exitScript = $false
    )
    
    $time = Get-Date
    
    if (Test-Path $logPath) {
        
        $flairLength = ("Finished processing at [$time]").Length + 1
        
        Write-Verbose "Adding the following content to: $logPath"
        Write-Verbose ('-'*$flairLength)
        Write-Verbose "Ended logging at [$time]"
        Write-Verbose ('-'*$flairLength)
        Write-Verbose ""
        
        Add-Content -Path $logPath -Value ('-'*$flairLength)
        Add-Content -Path $logPath -Value "Ended logging at [$time]"
        Add-Content -Path $logPath -Value ('-'*$flairLength)
   
    } else {
        
        Write-Error "Unable to access $logPath"

        Break
        
    }
    
    if ($exitScript) {
        
        Write-Verbose "Exiting on completion specified, exiting..."
        
        Exit
        
    } 
   
}

function Out-LogFile {
<#
.SYNOPSIS
   Out-LogFile will create, add to, and resolve a logfile.

.DESCRIPTION
   Out-LogFile will create, add to, and resolve a logfile.

   Value from the pipeline is accepted.

   Use the -Verbose parameter to display what is happening to the host.

.PARAMETER logPath
    Alias: Path
    Type : String

    Specify the path to the logFile you'd like created.

.PARAMETER logName    
    Alias: Name
    Type : String

    Specify the name of the log file. Be sure to include the extension if specifying the name.

.PARAMETER logValue
    Alias: Value
    Type : String

    Specify the value(s) you'd like logged.

.PARAMETER addTimeStamp
    Type : Boolean

    Defaults to true, set to false if you'd like to omit the timestamp.

.NOTES
    Name: Out-LogFile
    Version: 1.0
    Author: Ginger Ninja (Mike Roberts)
    DateCreated: 5/11/16
    
.LINK
    http://www.gngrninja.com

.EXAMPLE
    $outLog = Get-Process | Out-LogFile -logPath c:\temp -logName 'outlog.log' -Verbose 
    -----------------------------
    
    VERBOSE: Created c:\temp\outlog.log
    VERBOSE:
    VERBOSE: File C:\temp\outlog.log created and verified to exist.
    VERBOSE:
    VERBOSE: Adding the following information to: C:\temp\outlog.log
    VERBOSE:
    VERBOSE: -----------------------------------------------------------------
    VERBOSE: Started logging at [05/11/2016 16:58:43]
    VERBOSE: Script (Version 0.1) executed by: [thegn] on computer: [GINJA10]
    VERBOSE: -----------------------------------------------------------------
    VERBOSE:
    VERBOSE: Adding [05-11-16 16:58:43] System.Diagnostics.Process (AdobeUpdateService) to
    C:\temp\outlog.log
    VERBOSE:

.EXAMPLE
    $outLog = Get-Process | Out-LogFile -Verbose
    -----------------------------
    
    gngrNinja> more $outLog
    ...
    [05-11-16 16:56:02] System.Diagnostics.Process (winlogon)

    [05-11-16 16:56:02] System.Diagnostics.Process (WmiPrvSE)

    [05-11-16 16:56:02] System.Diagnostics.Process (WmiPrvSE)

    [05-11-16 16:56:02] System.Diagnostics.Process (WUDFHost)

    ---------------------------------------------
    Ended logging at [05/11/2016 16:56:02]
    ---------------------------------------------

gngrNinja>
#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false,
                   Position  = 0)]
        [Alias('Path')]
        [string]
        $logPath,
        [Parameter(Mandatory = $false,
                   Position  = 1)]
        [Alias('Name')]
        [string]
        $logName,
        [Parameter(Mandatory = $true,
                   ValueFromPipeLine               = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position                        = 2)]
        [Alias('Value')]
        [string]
        $logValue,
        [Parameter(Mandatory = $false,
                   Position  = 3)]
        [boolean]
        $addTimeStamp = $true
    )
    
    Begin {
        
        $logFile = New-LogFile -logPath $logPath -logName $logName

    }
    
    Process {

        ForEach ($value in $logValue) {
        
            Write-LogFile -logPath $logFile -logValue $value -addTimeStamp $addTimeStamp
        
        }


    }
    
    End {
    
        Resolve-LogFile $logFile 

        Return $logFile

    }
    
}

function Send-LogEmail {
    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $To,
    [string]
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    $Subject,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    $Body),
    [string]
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    $emailFrom,
    [string]
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    $provider = 'gmail'

    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    $password = (Read-Host "Password?" -AsSecureString)

    if (!$to)      {Write-Error "No recipient specified";break}
    if (!$subject) {Write-Error "No subject specified";break}
    if (!$body)    {Write-Error "No body specified";break}
    if (!$emailFrom)    {$emailFrom = 'Ninja_PS_Logging@gngrninja.com'}
   
    Switch ($provider) {

        {$_ -eq 'gmail'} {$SMTPServer   = "smtp.gmail.com"}


    }

    $SMTPClient  = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$To,$Subject,$Body)

    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($emailUser,$emailPass); 
    
    $SMTPClient.Send($SMTPMessage)

}