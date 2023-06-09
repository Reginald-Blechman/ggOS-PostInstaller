## NETWORK SETTINGS

Disable-NetAdapterBinding -Name * -ComponentID ms_msclient
Disable-NetAdapterBinding -Name * -ComponentID ms_tcpip6

Disable-NetAdapterBinding -Name * -ComponentID ms_lldp
Disable-NetAdapterBinding -Name * -ComponentID ms_lltdio
Disable-NetAdapterBinding -Name * -ComponentID ms_rspndr
Disable-NetAdapterBinding -Name * -ComponentID ms_server

foreach ($NIC in (Get-NetAdapter -Physical)){
    $PowerSaving = Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root\wmi | ? {$_.InstanceName -match [Regex]::Escape($NIC.PnPDeviceID)}
    if ($PowerSaving.Enable){
        $PowerSaving.Enable = $false
        $PowerSaving | Set-CimInstance
    }
}

$NICS = Get-WmiObject win32_NetworkAdapterConfiguration
foreach ($NIC in $NICS){
    $NIC.settcpipnetbios(2)
    $NIC.EnableWINS($false,$false)
}

Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\TCPIP* -Name NetBIOSoptions -Value 2

Invoke-CimMethod -ClassName Win32_NetworkAdapterConfiguration -Arguments @{WINSEnableLMHostsLookup=$false} -MethodName EnableWINS
Invoke-CimMethod Win32_NetworkAdapterConfiguration @{WINSEnableLMHostsLookup=$false} EnableWINS

$net = get-netconnectionprofile
Set-NetAdapterRSS -Name $net.InterfaceAlias -BaseProcessorNumber 1 -ErrorAction SilentlyContinue;

Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force