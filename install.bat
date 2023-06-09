@echo off
setlocal ENABLEDELAYEDEXPANSION

:: CLEANUP
net user defaultuser0 /delete >nul 2>&1
rd /q /s "%HOMEDRIVE%\Users\defaultuser0" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E cmd /c "del /f /q C:\ProgramData\Microsoft\Windows\SystemData\setup.7z"
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{45ea75a0-a269-11d1-b5bf-0000f8051516}" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Active Setup\Installed Components\{45ea75a0-a269-11d1-b5bf-0000f8051516}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{89B4C1CD-B018-4511-B0A1-5476DBF70821}" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Active Setup\Installed Components\{89B4C1CD-B018-4511-B0A1-5476DBF70821}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{C9E9A340-D1F1-11D0-821E-444553540601}" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Active Setup\Installed Components\{C9E9A340-D1F1-11D0-821E-444553540601}" /f >nul 2>&1

:: PREVENT INPUT FROM CORRUPTING INSTALL
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v "Debugger" /t REG_SZ /d "." /f >nul 2>&1
devcon remove =Keyboard >nul 2>&1
devcon remove =Mouse >nul 2>&1
pssuspend winlogon >nul 2>&1

:: AUTHORIZE USE
call:hash "%PROGRAMDATA%\Microsoft\User Account Pictures\user.bmp" "cfcb41de723e69b670471fe49cd335d7"
call:hash "%PROGRAMDATA%\Microsoft\User Account Pictures\user.png" "269037c66b17946b5cd8e216ddaa9c90
call:hash "C:\Users\Default\Desktop\Setup\LEGAL NOTICE.txt" "d252a18795039860ca9059e67b6068d3"
call:hash "C:\Users\Default\Desktop\Setup\ggOS Discord.url" "8da661ab60cd5ac832d21987a359e820"
call:hash "C:\Users\Default\Desktop\Setup\ggOS Twitter.url" "875619f0cbbcb84e511f75c193638410"
for /f "tokens=2* skip=2" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Manufacturer"') do ( 
	if not "%%b"=="ggOS - a free iso by phlegm" ( call:unauthorized )
)
for %%a in (vmware hvm kvm virtual hyper innotek qemu xen parallel) do (
	echo.%MANUFACTURER%%MODEL% | find /i "%%a" && ( call:unauthorized )
)

:: IMPORT REG FILES
NSudoL -ShowWindowMode:hide -Wait -U:T -P:E reg import "C:\Windows\Temp\appx.reg" >nul 2>&1
NSudoL -ShowWindowMode:hide -Wait -U:T -P:E reg import "C:\Windows\Temp\cleanup.reg" >nul 2>&1
reg import "C:\Windows\Temp\counters.reg" >nul 2>&1
reg import "C:\Windows\Temp\remapping.reg" >nul 2>&1
del /f /q "C:\Windows\Temp\appx.reg" >nul 2>&1
del /f /q "C:\Windows\Temp\cleanup.reg" >nul 2>&1
del /f /q "C:\Windows\Temp\counters.reg" >nul 2>&1
del /f /q "C:\Windows\Temp\remapping.reg" >nul 2>&1

:: EXECUTE EXTERNAL SCRIPTS
NSudoL -ShowWindowMode:hide -U:C -P:E C:\Windows\Temp\custom.bat
NSudoL -ShowWindowMode:hide -U:T -P:E C:\Windows\Temp\msi.bat
NSudoL -ShowWindowMode:hide -U:T -P:E C:\Windows\Temp\nic.bat

:: SERVICES
sc config fvevol start=disabled >nul 2>&1
sc delete fvevol >nul 2>&1

:: DISABLE TASKS
schtasks /change /disable /TN "\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64 Critical" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 Critical" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Automated)" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Manual)" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\AppID\EDP Policy Manager" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\AppID\PolicyConverter" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Application Experience\PcaPatchDbTask" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Application Experience\StartupAppTask" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\ApplicationData\appuriverifierdaily" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\ApplicationData\appuriverifierinstall" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\ApplicationData\DsSvcCleanup" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\BrokerInfrastructure\BgTaskRegistrationMaintenanceTask" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\CertificateServicesClient\AikCertEnrollTask" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\CertificateServicesClient\KeyPreGenTask" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Clip\License Validation" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\HandleCommand" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceProtectionStateChanged" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Diagnosis\Scheduled" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\DiskFootprint\Diagnostics" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\InstallService\ScanForUpdates" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\InstallService\ScanForUpdatesAsUser" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\InstallService\SmartRetry" >nul 2>&1
::schtasks /change /disable /TN "\Microsoft\Windows\LanguageComponentsInstaller\Installation" >nul 2>&1
::schtasks /change /disable /TN "\Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources" >nul 2>&1
::schtasks /change /disable /TN "\Microsoft\Windows\LanguageComponentsInstaller\Uninstallation" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Management\Provisioning\Cellular" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\MUI\LPRemove" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskNetwork" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\StateRepository\MaintenanceTasks" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Subscription\EnableLicenseAcquisition" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Subscription\LicenseAcquisition" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Sysmain\ResPriStaticDbSync" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Sysmain\WsSwapAssessmentTask" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Time Synchronization\ForceSynchronizeTime" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Time Synchronization\SynchronizeTime" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Time Zone\SynchronizeTimeZone" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\USB\Usb-Notifications" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Windows Error Reporting\QueueReporting" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\Windows\Wininet\CacheTask" >nul 2>&1
schtasks /change /disable /TN "\Microsoft\XblGameSave\XblGameSaveTask" >nul 2>&1

schtasks /delete /f /tn "\Microsoft\Windows\PLA\System" >nul 2>&1
schtasks /delete /f /tn "\Microsoft\Windows\PLA" >nul 2>&1
schtasks /delete /f /tn "\Microsoft\Windows\RetailDemo\CleanupOfflineContent" >nul 2>&1
schtasks /delete /f /tn "\Microsoft\Windows\RetailDemo" >nul 2>&1
schtasks /delete /f /tn "\Microsoft\Windows\SyncCenter" >nul 2>&1
schtasks /delete /f /tn "\Microsoft\Windows\TaskScheduler" >nul 2>&1
schtasks /delete /f /tn "\Microsoft\Windows\Windows Activation Technologies" >nul 2>&1

NSudoL -ShowWindowMode:hide -U:T -P:E schtasks /change /disable /TN "\Microsoft\Windows\Device Setup\Metadata Refresh" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E schtasks /delete /f /tn "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E schtasks /delete /f /tn "\Microsoft\Windows\UpdateOrchestrator" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E schtasks /delete /f /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E schtasks /delete /f /tn "\Microsoft\Windows\WindowsUpdate" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E schtasks /delete /f /tn "\Microsoft\Windows\WaaSMedic" >nul 2>&1

:: COMPLETE SCRIPT
del /f /q "C:\Windows\Temp\*.log"
timeout /t 15 /nobreak >nul 2>&1
pssuspend -r winlogon >nul 2>&1
devcon rescan >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v "Debugger" /f >nul 2>&1

del /f /q "%~f0" >nul 2>&1
exit

:: FUNCTIONS --------------------------------------------------------------------------------------

:hash
for /f "delims= " %%a in ('md5sum "%~1"') do (
    if not "%%a"=="\%~2" ( call:unauthorized )
)
exit /b

:unauthorized
del /f /q "%PROGRAMDATA%\Microsoft\User Account Pictures\*.bmp" >nul 2>&1
del /f /q "%PROGRAMDATA%\Microsoft\User Account Pictures\*.png" >nul 2>&1
del /f /q "C:%HOMEPATH%\Desktop\setup.log" >nul 2>&1
del /f /q "C:%HOMEPATH%\Desktop\Support.lnk" >nul 2>&1
del /f /q "C:\Users\Default\Desktop\*.*" >nul 2>&1
rd /s /q "C:\Users\Default\Desktop\Setup" >nul 2>&1
rd /s /q "C:%HOMEPATH%\Desktop\Setup" >nul 2>&1
rd /s /q "%PROGRAMDATA%\GGOS" >nul 2>&1
rd /s /q "%PROGRAMFILES%\GGOS" >nul 2>&1
rd /s /q "%PROGRAMFILES%\Windows Optimization" >nul 2>&1
rd /s /q "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Windows Optimization" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E rd /s /q "C:\Windows\Temp\" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E rd /s /q "C:\$RECYCLE.BIN" >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E sc config cng start=disabled >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E sc config mountmgr start=disabled >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E sc config partmgr start=disabled >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E sc config pdc start=disabled >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E sc config volmgr start=disabled >nul 2>&1
NSudoL -ShowWindowMode:hide -U:T -P:E sc config volume start=disabled >nul 2>&1
timeout /t 5 /nobreak >nul 2>&1
sc stop pdc
del /f /q "%~f0" >nul 2>&1
exit /b
