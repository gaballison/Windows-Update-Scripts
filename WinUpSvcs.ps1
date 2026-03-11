<#
The following are the services we need to stop/restart
BITS = Background Intelligent Transfer Service
wuauserv = Windows Update
CryptSvc = Cryptographic Services
DoSvc = Delivery Optimization
UsoSvc = Update Orchestrator Service
TrustedInstsaller = Windows Modules Installer
msiserver = Windows Installer
#>

# ! Remember to Set-ExecutionPolicy -ExecutionPolicy RemoteSigned to allow local scripts to run

# Service Names
$AfServiceNames = 'BITS', 'wuauserv', 'CryptSvc', 'DoSvc', 'UsoSvc', 'TrustedInstaller', 'msiserver'

try {

    # Step 01: stop the services
    # 1a. Use foreach to loop through each service name in the $AfServiceNames array
    foreach ($Service in $AfServiceNames)
    {
        # 1b. Use Stop-Service cmdlet to forcibly stop each service
        Stop-Service -Name $Service -Force
    }

    # Step 02: rename the SoftwareDistribution folder to force Windows Updates to download new stuff
    # 2a. test if SoftwareDistribution folder exists and is a directory
    if (Test-Path -Path "C:\Windows\SoftwareDistribution" -PathType Container) {
        # 2b. If 2a is TRUE, test if SoftwareDistribution.old exists and is a directory
        if (Test-Path -Path "C:\Windows\SoftwareDistribution.old" -PathType Container) {
            # 2c. If 2a is TRUE and 2b is TRUE, remove SoftwareDistribution.old and rename SoftwareDistribution
            Remove-Item -Path "C:\Windows\SoftwareDistribution.old" -Recurse -Force
            Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "SoftwareDistribution.old" -Force
        } else {
            # 2d. If 2a is TRUE and 2b is FALSE, rename SoftwareDistribution folder to SoftwareDistribution.old
            Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "SoftwareDistribution.old" -Force
        }

    } 


    # Step 03: start the services again
    # 3a. Loop through each service in $AfServiceNames again (now that they've all been stopped)
    foreach ($Service2 in $AfServiceNames) {

        # 3b. Check if the startup type is Disabled
        if ((Get-Service -Name $Service2 -ErrorAction SilentlyContinue).StartType -eq 'Disabled') {

            # 3c. if 3b is TRUE, set StartupType to Manual and Status to Running
            Set-Service -Name $Service2 -StartupType Manual -Status Running
        } else {
            # 3d. if 3b is FALSE, we just need to set the Status to Running
            Set-Service -Name $Service2 -Status Running

        }

    }

}
catch {
    # Use the built-in error variable $ to show any errors
    Write-Host "An error occurred: "
    Write-Host $_
}
finally {

    # Step 04: Start services if they are still stopped
    # 4a. Loop through each service in $AfServiceNames array
    foreach ($Service3 in $AfServiceNames) {

        # 4b. Check to see if the service's status is Stopped
        # IMPORTANT: Use single quotes for things like status, startup type, etc.
       if ((Get-Service -Name $Service3 -ErrorAction SilentlyContinue).Status -eq 'Stopped') {
            # 4c. If 4b is TRUE, use Start-Service cmdlet to start the service
            Start-Service -Name $Service3
       }

        # OLD: Get-Service -Name $Service3 | Select-Object -Property DisplayName, StartType, Status

        # 4d. TEST: manually writing each service status
        Write-Host $Service3 "is" (Get-Service -Name $Service3).Status

    }

    # Step 05: Launch the Services window depending on input
    # 5a. Create variable to hold command line input regarding the services window
    $AfOpenSvc = Read-Host -Prompt "`n` Do you want to open the Services window?  [Y] Yes    [N] No"

    #5b. Check if input from 5a (when converted to uppercase) is Y
    if($AfOpenSvc.ToUpper() = "Y") {

        #5c. If 5b is TRUE, launch the Services process with administrator priveleges
        Start-Process services.msc -Verb RunAs
    }
    

    # Step 06: Launch the Settings app on the Windows Update page so we can try installing updates again
    # 6a. Create a variable to hold the command line input response regarding the Settings window
    $AfOpenSet = Read-Host -Prompt "`n` Do you want to open Windows Updates?  [Y] Yes   [N] No"

    # 6b. Check if input from 6a (when converted to uppercase) is Y
    if($AfOpenSet.ToUpper() = "Y") {

        # 6c. If 6b is TRUE, launch the Settings app on the Windows Updtae screen
        Start-Process ms-settings:windowsupdate
    }


}