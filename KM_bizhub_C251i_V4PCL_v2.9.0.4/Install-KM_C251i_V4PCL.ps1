<#
  Install "KONICA MINOLTA bizhub C251i PCL" using driver "KONICA MINOLTA Universal V4 PCL"
  on port IP_192.168.10.201. Run from MeshCentral Terminal (PowerShell) - agent runs as SYSTEM.

  If the V4 driver is not already on the PC, upload the V4 driver zip to C:\Temp
  and set $DriverZip below (or pass -DriverZip).
#>
param(
    [string]$PrinterName = "KONICA MINOLTA bizhub C251i PCL",
    [string]$DriverName  = "KONICA MINOLTA Universal V4 PCL",
    [string]$PrinterIP   = "192.168.10.201",
    [string]$PortName    = "IP_192.168.10.201",
    [string]$DriverZip   = "C:\Temp\KM_C251i_V4PCL_x64_v2.9.0.4.zip"
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path 'C:\Temp')) { New-Item -Path 'C:\Temp' -ItemType Directory -Force | Out-Null }
$pnputil = "$env:windir\System32\pnputil.exe"
if (Test-Path "$env:windir\Sysnative\pnputil.exe") { $pnputil = "$env:windir\Sysnative\pnputil.exe" }

try {
    # 1. Driver: use it if already installed / in the driver store, else install from zip
    if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue)) {
        try {
            Add-PrinterDriver -Name $DriverName     # works if the driver is already in the driver store
        } catch {
            if (-not (Test-Path $DriverZip)) { throw "'$DriverName' not on this PC and $DriverZip not found. Upload the V4 driver zip first." }
            $ext = "C:\Temp\KM_V4_PCL"
            if (Test-Path $ext) { Remove-Item $ext -Recurse -Force }
            Expand-Archive $DriverZip -DestinationPath $ext -Force
            # find the INF that defines this driver name
            $inf = Get-ChildItem $ext -Recurse -Filter *.inf |
                   Where-Object { Select-String -Path $_.FullName -Pattern ([regex]::Escape($DriverName)) -Quiet } |
                   Select-Object -First 1
            if (-not $inf) { throw "No INF in $DriverZip defines '$DriverName'" }
            Write-Output "INF: $($inf.FullName)"
            & $pnputil /add-driver "$($inf.FullName)" /install | Out-String | Write-Output
            Add-PrinterDriver -Name $DriverName
        }
    }
    Write-Output "Driver OK: $DriverName"

    # 2. Port
    if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {
        Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP
    }
    Write-Output "Port OK: $PortName"

    # 3. Printer (recreate if it exists with a different driver/port)
    $p = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
    if ($p -and ($p.DriverName -ne $DriverName -or $p.PortName -ne $PortName)) { Remove-Printer -Name $PrinterName; $p = $null }
    if (-not $p) { Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName }

    Get-Printer -Name $PrinterName | Format-List Name, DriverName, PortName, PrinterStatus
}
catch { Write-Output "FAILED: $($_.Exception.Message)"; exit 1 }
