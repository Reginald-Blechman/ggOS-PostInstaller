
foreach ($adapter In Get-NetAdapter) {
    Disable-NetAdapterPowerManagement -Name $adapter.Name -ErrorAction SilentlyContinue
}

$hubs = Get-WmiObject Win32_USBController
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
foreach ($p in $powerMgmt) {
    $IN = $p.InstanceName.ToUpper()
    foreach ($h in $hubs){
        $PNPDI = $h.PNPDeviceID
        if ($IN -like "*$PNPDI*"){
            $p.enable = $False
            $p.psbase.put()
        }
    }
}

$hubs = Get-WmiObject Win32_USBControllerDevice
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
foreach ($p in $powerMgmt) {
    $IN = $p.InstanceName.ToUpper()
    foreach ($h in $hubs){
        $PNPDI = $h.PNPDeviceID
        if ($IN -like "*$PNPDI*"){
            $p.enable = $False
            $p.psbase.put()
        }
    }
}

$hubs = Get-WmiObject Win32_USBHub
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
foreach ($p in $powerMgmt) {
    $IN = $p.InstanceName.ToUpper()
    foreach ($h in $hubs){
        $PNPDI = $h.PNPDeviceID
        if ($IN -like "*$PNPDI*"){
            $p.enable = $False
            $p.psbase.put()
        }
    }
}

Get-PnpDevice -FriendlyName 'ACPI Processor Aggregator' | Disable-PnpDevice -confirm:$false
Get-PnpDevice -FriendlyName 'Microsoft Windows Management Interface for ACPI' | Disable-PnpDevice -confirm:$false

Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force