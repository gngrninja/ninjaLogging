Set-StrictMode -Version Latest


$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$scriptName = (Get-ChildItem $MyInvocation.PSCommandPath | Select-Object -ExpandProperty BaseName)

if ($scriptName.count -gt 1) {
    
    $scriptName = 'ScriptLog'
    
}

function New-LogFile {
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
        Write-Verbose "Started processing at [$time]"
        Write-Verbose "Script (Version $scriptVersion) executed by: [$curUser] on computer: [$curComp]"
        Write-Verbose ('-'*$flairLength)
        Write-Verbose ""
        
        Add-Content -Path $fullPath -Value ('-'*$flairLength)
        Add-Content -Path $fullPath -Value "Started processing at [$time]"
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
        Write-Verbose "Finished processing at [$time]"
        Write-Verbose ('-'*$flairLength)
        Write-Verbose ""
        
        Add-Content -Path $logPath -Value ('-'*$flairLength)
        Add-Content -Path $logPath -Value "Finished processing at [$time]"
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
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true,
                   ValueFromPipeLine               = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position                        = 0)]
        [Alias('Value')]
        [string]
        $logValue,
        [Parameter(Mandatory = $false,
                   Position  = 1)]
        [boolean]
        $addTimeStamp = $true
    )
    
    Begin {
    
        $logFile = New-LogFile

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