@echo off
setlocal ENABLEDELAYEDEXPANSION

sc config WlanSvc start=disabled >nul 2>&1
sc config vwififlt start=demand >nul 2>&1
for /f "delims=" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\PCI" /s /f "FriendlyName" ^| find "802.11"') do (
	set "device=%%a"
	set device=!device:~30!
	powershell -NoProfile "Get-PnpDevice -FriendlyName '!device!' | Disable-PnpDevice -confirm:$false"
)

del /f /q "%~f0" >nul 2>&1
exit
