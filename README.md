# Windows-Update-Scripts

PowerShell script for restarting services and renaming directories whenever I have to troubleshoot Windows Updates on computers using [Deep Freeze](https://www.faronics.com/products/deep-freeze).

* `BITS` = [Background Intelligent Transfer Service](https://learn.microsoft.com/en-us/windows/win32/bits/background-intelligent-transfer-service-portal)
* `wuauserv` = Windows Update
* `CryptSvc` = [Cryptographic Services](https://learn.microsoft.com/en-us/windows/iot/iot-enterprise/optimize/services#system-services)
* `DoSvc` = [Delivery Optimization](https://learn.microsoft.com/en-us/windows/win32/delivery_optimization/delivery-optimization-portal)
* `UsoSvc` = Update Orchestrator Service
* `TrustedInstsaller` = Windows Modules Installer
* `msiserver` = Windows Installer

## About

This script does the following:

1. Uses a [`foreach` loop](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/06-flow-control?view=powershell-7.5) to forcibly stop each of the above services using the [`Stop-Service` cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-service?view=powershell-7.5).
2. Uses [`Test-Path` cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.5) to check if a backup of `SoftwareDistribution` exists and is a directory; removes `SoftwareDistribution.old` directory if it exists (using [`Remove-Item` cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-7.5)), otherwise renames `SoftwareDistribution` directory to `SoftwareDistribution.old` using [`Rename-Item` cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-item?view=powershell-7.5).
3. Uses another `foreach` loop and uses [`Get-Item` cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service?view=powershell-7.5) to check if service `StartType` is "Disabled" -- if so, uses [`Set-Service` cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service?view=powershell-7.5) to set the `StartType` to "Automatic" and `Status` to "Running"; otherwise just sets `Status` to "Running".
4. [Catches](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.5) any errors
5. Loops through services again and checks if `Status` = "Stopped; if so, sets to "Running" and writes the status to the host.
6. Prompts user if they want to open the `Services` snap-in and if so, uses the [`Start-Process` cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.5) with the [`-Verb` parameter](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.5#-verb) `RunAs` to launch it as an administrator.
7. Prompts user if they want to open the Settings app on the Windows Update screen and if so, uses the `Start-Process` cmdlet to do so.

## Installing

Create a folder in `C:` called `Scripts` and clone this repo into it (or copy the script file individually or whatever).

## Running

1. Open PowerShell **as admin** and `cd` into the directory where you've cloned the repo (e.g. `cd ..\..\Scripts`)
2. Set the execution policy by running: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`
3. Type `A` or `Y` and hit enter to accept changing the policy
4. Type `.\WinUpSvcs.ps1` and hit enter to run the script

***Optional:***

* Type `Y` when prompted to open the `Services` snap-in as an admin.
* Type `Y` when prompted to launch `Settings` on the Windows Updates page.
