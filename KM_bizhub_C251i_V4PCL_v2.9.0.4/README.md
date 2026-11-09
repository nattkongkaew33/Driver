# KONICA MINOLTA bizhub C251i – Universal V4 PCL (v2.9.0.4, x64)

| File | Purpose |
|---|---|
| `KM_C251i_V4PCL_x64_v2.9.0.4.zip` | Driver package (INF: `KOBxxK__01.inf`, name **KONICA MINOLTA Universal V4 PCL**) |
| `Install-KM_C251i_V4PCL.ps1` | Installs driver, port `IP_192.168.10.201`, printer **KONICA MINOLTA bizhub C251i PCL** |
| `Download-Install-KM_C251i_V4PCL.ps1` | Creates `C:\Temp`, downloads the zip + installer from this repo, runs the install |

## MeshCentral one-liner (PowerShell terminal, runs as SYSTEM)

Replace `<TOKEN>` with a fine-grained GitHub token (read-only **Contents** on this repo):

```powershell
$t='<TOKEN>'; New-Item C:\Temp -ItemType Directory -Force | Out-Null; [Net.ServicePointManager]::SecurityProtocol='Tls12'; $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -Headers @{Authorization="Bearer $t";Accept='application/vnd.github.raw';'User-Agent'='mesh'} -Uri 'https://api.github.com/repos/nattkongkaew33/Driver/contents/KM_bizhub_C251i_V4PCL_v2.9.0.4/Download-Install-KM_C251i_V4PCL.ps1' -OutFile C:\Temp\Download-Install-KM_C251i_V4PCL.ps1; powershell -NoProfile -ExecutionPolicy Bypass -File C:\Temp\Download-Install-KM_C251i_V4PCL.ps1 -Token $t
```

Different printer IP: append `-PrinterIP 192.168.10.xxx`.
