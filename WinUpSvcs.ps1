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
    }

    # Then we rename the SoftwareDistribution folder to force Windows Updates to download new stuff
    # ONLY IF folder already exists
    if (Test-Path -Path "C:\Windows\SoftwareDistribution" -PathType Container) {
        if (Test-Path -Path "C:\Windows\SoftwareDistribution.old" -PathType Container) {
            Remove-Item -Path "C:\Windows\SoftwareDistribution.old" -Recurse -Force
        } else {
            Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "SoftwareDistribution.old" -Force
        }

    } 


    # Then we start the services again

    foreach ($Service2 in $AfServiceNames) {

        # check if the startup type is Disabled
        if ((Get-Service -Name $Service2 -ErrorAction SilentlyContinue).StartType -eq 'Disabled') {

            # if true, set StartupType to Manual and Status to Running
            Set-Service -Name $Service2 -StartupType Manual -Status Running -PassThru
        } else {
            # if false, we just need to set the Status to Running
            Set-Service -Name $Service2 -Status Running -PassThru

        }

    }

}
catch {
    Write-Host "An error occurred: "
    Write-Host $_
}
finally {
    # Restart services if they are stopped?
    foreach ($Service3 in $AfServiceNames) {
        # TO DO: write-host list of services that aren't running
        # is there a way to forcibly start them??

       if ((Get-Service -Name $Service3 -ErrorAction SilentlyContinue).Status -eq 'Stopped') {
            Restart-Service -Name $Service3
       }

        # Get-Service -Name $Service3 | Select-Object -Property DisplayName, StartType, Status


    }

    # Launch the Settings app on the Windows Update page so we can try installing updates again
    Start-Process ms-settings:windowsupdate


}