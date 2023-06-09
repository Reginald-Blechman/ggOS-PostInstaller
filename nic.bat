@echo off
setlocal ENABLEDELAYEDEXPANSION

:: CHANGE NETWORK SETTINGS
netsh int isatap set state disable >nul 2>&1
netsh interface teredo set state servername=default >nul 2>&1
netsh int ipv6 set teredo enterpriseclient >nul 2>&1
netsh int ip set global sourceroutingbehavior=drop >nul 2>&1
netsh int ip set global neighborcachelimit=4096 >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global nonsackrttresiliency=disabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set security mpp=disabled >nul 2>&1
netsh int tcp set security profiles=disabled >nul 2>&1

if %NUMBER_OF_CORES% GTR 4 (
	netsh int tcp set global rsc=disabled >nul 2>&1
)

:: CHANGE NETWORK ADAPTER SETTINGS
for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
	for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%a" /v "Driver"') do (
		for /f %%b in ('echo %%a ^| findstr "{"') do (
			for %%c in (AlternateSemaphoreDelay DeviceSleepOnDisconnect EEE FlowControl ModernStandbyWoLMagicPacket Node
				PMARPOffload PMNSOffload PMWiFiRekeyOffload PriorityVLANTag SelectiveSuspend WakeOnMagicPacket WakeOnPattern) do (
				reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*%%c" >nul 2>&1
				if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*%%c" /t REG_SZ /d "0" /f >nul 2>&1
			)
			for %%c in (AdvancedEEE AlternateSemaphoreDelay AutoDisableGigabit AutoPowerSaveModeEnabled EEELinkAdvertisement
				EeePhyEnable EnableEDT EnableGreenEthernet EnableModernStandby GigaLite GPPSW LogLevelWarn Node PowerDownPll PowerSavingMode
				ReduceSpeedOnPowerDown S5WakeOnLan SavePowerNowEnabled ULPMode WakeOnLink WakeOnSlot WakeUpModeCap) do (
				reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "%%c" >nul 2>&1
				if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "%%c" /t REG_SZ /d "0" /f >nul 2>&1
			)
			for %%c in (RssBaseProcNumber) do (
				reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*%%c" >nul 2>&1
				if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*%%c" /t REG_SZ /d "1" /f >nul 2>&1
				reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "%%c" >nul 2>&1
				if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "%%c" /t REG_SZ /d "1" /f >nul 2>&1
			)
			reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*NumRssQueues" >nul 2>&1
			if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*NumRssQueues" /t REG_SZ /d "2" /f >nul 2>&1
			reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "WolShutdownLinkSpeed" >nul 2>&1
			if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "WolShutdownLinkSpeed" /t REG_SZ /d "2" /f >nul 2>&1
			reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "MIMOPowerSaveMode" >nul 2>&1
			if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "MIMOPowerSaveMode" /t REG_SZ /d "3" /f >nul 2>&1
			reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "PnPCapabilities" >nul 2>&1
			if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "PnPCapabilities" /t REG_SZ /d "24" /f >nul 2>&1
			if %NUMBER_OF_CORES% GTR 6 (
				for %%c in (InterruptModeration IPChecksumOffloadIPv4 IPChecksumOffloadIPv6 IPsecOffloadV1IPv4 IPsecOffloadV2 IPsecOffloadV2IPv4 LsoV1IPv4 
					LsoV2IPv4 LsoV2IPv6 TCPChecksumOffloadIPv4 TCPChecksumOffloadIPv6 UDPChecksumOffloadIPv4 UDPChecksumOffloadIPv6) do (
					reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*%%c" >nul 2>&1
					if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*%%c" /t REG_SZ /d "0" /f >nul 2>&1
				)
				reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*NumRssQueues" >nul 2>&1
				if %errorlevel% equ 0 reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b" /v "*NumRssQueues" /t REG_SZ /d "4" /f >nul 2>&1
			)
		)
	)
)

:: DISABLE NAGLE'S
for /f %%a in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do (
	reg query "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%a" /v "DhcpIPAddress" >nul 2>&1
	if NOT ERRORLEVEL 1 ( 
		call sreg -d "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%a" "TcpAckFrequency" "1"
		call sreg -d "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%a" "TCPNoDelay" "1"
	)
)

:: DISABLE NETBIOS OVER TCPIP
for /f "eol=E" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" /s /f "NetbiosOptions"^| findstr /V "NetbiosOptions"') do (
	reg add "NetbiosOptions" /t REG_DWORD /d "2" /f >nul 2>&1
)

:: DISABLE NETWORK ADAPTER POWER SAVINGS
NSudoL -ShowWindowMode:hide -U:T -P:E powershell -NoProfile "C:\Windows\Temp\nic.ps1"

del /f /q "%~f0"
exit
