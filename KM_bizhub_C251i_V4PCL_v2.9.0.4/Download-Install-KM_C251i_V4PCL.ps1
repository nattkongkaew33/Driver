<#
  Download the C251i V4 PCL driver + installer from the private GitHub repo
  nattkongkaew33/Driver into C:\Temp, then install the printer.
  Run from MeshCentral Terminal (PowerShell). Requires a GitHub fine-grained
  token with read-only "Contents" access to the Driver repo.
#>
param(
    [Parameter(Mandatory)][string]$Token,
    [string]$PrinterIP   = "192.168.10.201",
    [string]$PrinterName = "KONICA MINOLTA bizhub C251i PCL"
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'   # much faster Invoke-WebRequest

$Repo   = "nattkongkaew33/Driver"
$Folder = "KM_bizhub_C251i_V4PCL_v2.9.0.4"
$Temp   = "C:\Temp"
$Files  = "KM_C251i_V4PCL_x64_v2.9.0.4.zip", "Install-KM_C251i_V4PCL.ps1"
$Hdr    = @{ Authorization = "Bearer $Token"; Accept = "application/vnd.github.raw"; "User-Agent" = "mesh-deploy" }

if (-not (Test-Path $Temp)) { New-Item -Path $Temp -ItemType Directory -Force | Out-Null }

foreach ($f in $Files) {
    $url = "https://api.github.com/repos/$Repo/contents/$Folder/$f"
    Write-Output "Downloading $f ..."
    Invoke-WebRequest -Uri $url -Headers $Hdr -OutFile (Join-Path $Temp $f) -UseBasicParsing
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Temp "Install-KM_C251i_V4PCL.ps1") `
    -PrinterIP $PrinterIP -PortName "IP_$PrinterIP" -PrinterName $PrinterName `
    -DriverZip (Join-Path $Temp "KM_C251i_V4PCL_x64_v2.9.0.4.zip")
exit $LASTEXITCODE
