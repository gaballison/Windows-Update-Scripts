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
    # First we stop the services 
    foreach ($Service in $AfServiceNames)
    {
        Stop-Service -Name $Service -Force
        # Write-Host "Stopping " $Service
    }

    # Then we rename the SoftwareDistribution folder to force Windows Updates to download new stuff
    # ONLY IF folder already exists
    if (Test-Path -Path "C:\Windows\SoftwareDistribution" -PathType Container) {
        if (Test-Path -Path "C:\Windows\SoftwareDistribution.old" -PathType Container) {
            Remove-Item -Path "C:\Windows\SoftwareDistribution.old" -Recurse -Force
            # Write-Host "---- SoftwareDistribution.old directory existed & was removed `n` "
        } else {
            Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "SoftwareDistribution.old" -Force
            # Write-Host "---- SoftwareDistribution directory renamed successfully `n` "
        }

    } 


    # Then we start the services again

    foreach ($Service2 in $AfServiceNames) {

        # check if the startup type is Disabled
        if ((Get-Service -Name $Service2 -ErrorAction SilentlyContinue).StartType -eq 'Disabled') {
            # writing out the StartType to make sure it formats properly...
            #Write-Host "Start type for" $Service2 "is Disabled:" (Get-Service -Name $Service2).StartType " `n` "

            # if true, set StartupType to Manual and Status to Running
            Set-Service -Name $Service2 -StartupType Manual -Status Running -PassThru
            #Write-Host $Service2 "start type set to Manual & status to Running `n` "
        } else {
            # if false, we just need to set the Status to Running
           # Write-Host $Service2 "is NOT Disabled so we are only starting it `n` "
            Set-Service -Name $Service2 -Status Running -PassThru

        }

    }

}
catch {
    Write-Host "An error occurred: "
    Write-Host $_
}
finally {
    # Write the status of all services in list
    foreach ($Service3 in $AfServiceNames) {
        Get-Service -Name $Service3 | Select-Object -Property DisplayName, StartType, Status
    }

    # TO DO: write-host list of services that aren't running
    # is there a way to forcibly start them??
}