@echo off
setlocal ENABLEDELAYEDEXPANSION

:: SET ALL MSI PRIORITIES TO UNDEFINED
for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\PCI"^| findstr "HKEY"') do (
	for /f "tokens=*" %%a in ('reg query "%%i"^| findstr "HKEY"') do reg delete "%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
)

:: SET MSI MODE FOR NETWORK ADAPTER
for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do (
	reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
)

:: SET MSI MODE FOR USB
for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do (
	reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
)

:: SET MSI MODE FOR GPU
for /f %%a in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /L "VEN_"') do (
	reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
)

del /f /q "%~f0" >nul 2>&1
exit
