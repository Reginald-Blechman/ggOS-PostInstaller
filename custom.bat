@echo off
setlocal ENABLEDELAYEDEXPANSION

for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfCores /format:value ^| findstr "NumberOfCores"') do set /a "NumberOfCores=%%a" >nul 2>&1

set /a ETHERNET=0
ping -n 1 1.1.1.1 >nul 2>&1
if %errorlevel% EQU 0 ( set /a ETHERNET=1 )
ping -n 1 8.8.8.8 >nul 2>&1
if %errorlevel% EQU 0 ( set /a ETHERNET=1 )

set /a LAPTOP=0
if %CHASSISTYPE% GTR 7 ( 
	if %CHASSISTYPE% LSS 17 ( set /a LAPTOP=1 )
    if %CHASSISTYPE% GTR 28 ( set /a LAPTOP=1 )
)

:: ETHERNET OR WIFI
if %ETHERNET%==1 ( 
	if %LAPTOP%==0 (
		NSudoL -ShowWindowMode:hide -Wait -U:C -P:E C:\Windows\Temp\disable-wifi.bat
	) 
)
del /f /q "C:\Windows\Temp\disable-wifi.bat"

:: DESKTOP OR LAPTOP
if %LAPTOP%==0 (
	NSudoL -ShowWindowMode:hide -U:T -P:E powershell -NoProfile "C:\Windows\Temp\custom.ps1"
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f
	for %%a in (AllowIdleIrpInD3 D3ColdSupported DeviceSelectiveSuspended EnableIdlePowerManagement	EnableSelectiveSuspend
		EnhancedPowerManagementEnabled IdleInWorkingState SelectiveSuspendEnabled SelectiveSuspendOn WaitWakeEnabled 
		WakeEnabled WdfDirectedPowerTransitionEnable) do (
		for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "%%a" ^| findstr "HKEY"') do (
			reg add "%%b" /v "%%a" /t REG_DWORD /d "0" /f >nul 2>&1
		)
	)
	for %%a in (DisableIdlePowerManagement) do (
		for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "%%a" ^| findstr "HKEY"') do (
			reg add "%%b" /v "%%a" /t REG_DWORD /d "1" /f >nul 2>&1
		)
	)
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Storage" /v "StorageD3InModernStandby" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\pci\Parameters" /v "ASPMOptOut" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "IdlePowerMode" /t REG_DWORD /d "0" /f >nul 2>&1
) else (
	powercfg /s 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
)

:: MEMORY
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "%SVCHOSTSPLIT%" /f >nul 2>&1
if %SVCHOSTSPLIT% LSS 8000000 (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "33554432" /f >nul 2>&1
) else if %SVCHOSTSPLIT% LSS 16000000 (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "67108864" /f >nul 2>&1
) else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "134217728" /f >nul 2>&1
)

::reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "33554432" /f >nul 2>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "67108864" /f >nul 2>&1
::reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d "134217728" /f >nul 2>&1

:: CPU
set /a CPU=%NUMBER_OF_CORES%*%MAX_CLOCK_SPEED%

:: Set the Delay in Microseconds When Scheduling Packets for Transmission
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "1" /f >nul 2>&1
if %CPU% LEQ 18000 reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "2" /f >nul 2>&1
if %CPU% LEQ 12000 reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "5" /f >nul 2>&1
if %CPU% LEQ 8000 reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /f >nul 2>&1

:: Set Cursor Update Interval
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v "CursorUpdateInterval" /t REG_DWORD /d "1" /f >nul 2>&1
if %CPU% LEQ 15000 reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v "CursorUpdateInterval" /t REG_DWORD /d "2" /f >nul 2>&1
if %CPU% LEQ 10000 reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v "CursorUpdateInterval" /t REG_DWORD /d "5" /f >nul 2>&1

:: OTHER CONDITIONAL TWEAKS
call:greg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" SelectedUserSID
reg add "HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex\Sites\{%SelectedUserSID%}\Paths\0" /v "SuppressIndex" /t REG_DWORD /d "1"
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%LOCALAPPDATA%\Programs\Lively Wallpaper\livelywpf.exe" /t REG_SZ /d "~ WIN8RTM" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%LOCALAPPDATA%\Microsoft\Teams\Update.exe" /t REG_SZ /d "~ WIN8RTM" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%LOCALAPPDATA%\Microsoft\Teams\current\Teams.exe" /t REG_SZ /d "~ WIN8RTM" /f >nul 2>&1

:: COPY LOCKSCREEN
NSudoL -ShowWindowMode:hide -U:T -P:E cmd /c "xcopy /e /r /y /q C:\ProgramData\Microsoft\Windows\SystemData\S-1-5-18\ReadOnly\LockScreen_Z\*.jpg C:\ProgramData\Microsoft\Windows\SystemData\%SelectedUserSID%\ReadOnly\LockScreen_W\"

del /f /q "%~f0" >nul 2>&1
exit

:: FUNCTIONS ----------------------------------------------------------------------------------------------------------------------------------------

:greg
for /f "tokens=2* skip=2" %%a in ('reg query "%~1" /v "%~2"') do set "tmp=%%b"
if "%tmp:~0,2%"=="0x" ( set /a "%~2=%tmp%" & set "tmp=" ) else ( set "%~2=%tmp%" & set "tmp=" )
exit /b