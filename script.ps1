param (
    [string[]]$SkipApps = @(),
    [string[]]$SkipSystemFolders = @()
)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Ошибка: для запуска нужны права Администратора!" -ForegroundColor Red
    Write-Host "Попробуйте запустить PowerShell от имени Администратора и повторите." -ForegroundColor Yellow
    
    $choice = Read-Host "Перезапустить скрипт от имени Администратора? (Y/N)"
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -SkipApps `"$($SkipApps -join ',')`" -SkipSystemFolders `"$($SkipSystemFolders -join ',')`"" -Verb RunAs
    }
    exit 1
}

$Title = "Cleanup Utility"
$Version = (Get-Content -Path 'version.json' -Raw | ConvertFrom-Json).version

$Host.UI.RawUI.WindowTitle = "$Title - $Version"

$logFile = Join-Path $PSScriptRoot 'debug.log'
if (Test-Path -Path $logFile -PathType Leaf) {
    Remove-Item -Path $logFile -Force
}

function Write-Log {
    param (
        [string]$message,
        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG")]
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$level] $message"
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
}

$programs = @(
    @{
        Name = "Steam";
        Process = @("Steam", "steamwebhelper");
        Path = Join-Path (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath 'config\loginusers.vdf';
    },
    @{
        Name = "Battle.net";
        Process = @("Battle.net");
        Path = Join-Path $env:appdata 'Battle.net\Battle.net.config';
        FileType = "json"; 
        KeysToRemove = @("GaClientId", "AutoLogin", "SavedAccountNames");
    },
    @{
        Name = "EA";
        Process = @("EADesktop", "EABackgroundService");
        Path = Join-Path $env:localappdata 'Electronic Arts\EA Desktop';
    },
    @{
        Name = "VK Play";
        Process = @("GameCenter");
        Path = Join-Path $env:localappdata 'GameCenter\GameCenter.ini';
        FileType = "ini"; 
        KeysToRemove = @(
            "MyComUserMagic4", "FirstAuth", "LastAUITime", "MyComUserMagic2",
            "MyComUserLogin", "MyComUserUid", "CurrentUserName", "CurrentUserNick"
        );
    },
    @{
        Name = "Riot Games";
        Process = @("RiotClientServices");
        Path = Join-Path $env:localappdata 'Riot Games\Riot Client\Data\RiotGamesPrivateSettings.yaml';
    },
    @{
        Name = "Lesta";
        Process = @("lgc");
        Path = Join-Path $env:appdata 'Lesta\GameCenter\user_info.xml';
    },
    @{
        Name = "Wargaming";
        Process = @("wgc");
        Path = Join-Path $env:appdata 'Wargaming.net\GameCenter\user_info.xml';
    },
    @{
        Name = "Ubisoft";
        Process = @("upc");
        Path = Join-Path $env:localappdata 'Ubisoft Game Launcher\user.dat';
    },
    @{
        Name = "Epic Games";
        Process = @("EpicGamesLauncher", "EpicWebHelper");
        Path = Join-Path $env:localappdata 'EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini';
    },
    @{
        Name = "BSG";
        Process = @("BsgLauncher");
        Path = Join-Path $env:appdata 'Battlestate Games\BsgLauncher\settings';
    },
    @{
        Name = "ABI";
        Process = @("arena_breakout_infinite_launcher");
        Path = Join-Path $env:appdata 'arena_breakout_infinite_launcher\last_user.dat';
    },

    @{
        Name = "Discord";
        Process = @("discord");
        Path = Join-Path $env:appdata 'discord';
    },
    @{
        Name = "Telegram";
        Process = @("Telegram");
        Path = Join-Path $env:appdata 'Telegram Desktop\tdata';
    },
    @{
        Name = "TeamSpeak 3";
        Process = @("ts3client_win64");
        Path = Join-Path $env:appdata 'TS3Client\settings.db';
    },
    @{
        Name = "TeamSpeak 6";
        Process = @("TeamSpeak");
        Path = Join-Path $env:appdata 'TeamSpeak\Default';
    },
    @{
        Name = "WhatsApp";
        Process = @("WhatsApp");
        Path = Join-Path $env:localappdata 'Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\LocalState';
    },

    @{
        Name = "Google Chrome";
        Process = @("chrome");
        Path = Join-Path $env:localappdata 'Google\Chrome\User Data';
    },
    @{
        Name = "Mozilla Firefox";
        Process = @("firefox");
        Path = Join-Path $env:appdata 'Mozilla\Firefox';
    },
    @{
        Name = "Opera GX";
        Process = @("opera");
        Path = Join-Path $env:appdata 'Opera Software\Opera GX Stable';
    },
    @{  
        Name = "Edge";
        Process = @("msedge");
        Path = Join-Path $env:localappdata 'Microsoft\Edge\User Data';
    },
    @{  
        Name = "Yandex";
        Process = @("browser");
        Path = Join-Path $env:localappdata 'Yandex\YandexBrowser\User Data';
    },
    
    @{
        Name = "FACEIT";
        Process = @("FACEIT");
        Path = Join-Path $env:appdata 'FACEIT';
    },
    @{
        Name = "MarketApp";
        Process = @("MarketApp");
        Path = Join-Path $env:appdata 'marketapp';
    }
)

$systemFolders = @(
    @{ Name = "Загрузки"; Path = [Environment]::GetFolderPath("UserProfile") + "\Downloads" },
    @{ Name = "Изображения"; Path = [Environment]::GetFolderPath("MyPictures") },
    @{ Name = "Видео"; Path = [Environment]::GetFolderPath("MyVideos") },
    @{ Name = "Музыка"; Path = [Environment]::GetFolderPath("MyMusic") },
    @{ Name = "Temp"; Path = $env:TEMP },
    @{ Name = "SystemTemp"; Path = "$env:SystemRoot\Temp" },
    @{ Name = "CrashDumps"; Path = "$env:LOCALAPPDATA\CrashDumps" },
    @{ Name = "Кэш браузеров"; Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache" },
    @{ Name = "Журналы Windows"; Path = "$env:SystemRoot\Logs" },
    @{ Name = "Thumbnails"; Path = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" }
)

function Stop-Processes {
    $total = $programs.Count
    $i = 0
    $allProcessNames = $programs.Process | Select-Object -Unique
    $runningProcesses = Get-Process -Name $allProcessNames -ErrorAction SilentlyContinue

    foreach ($program in $programs) {
        $i++
        Write-Progress -Activity "Завершение процессов" -Status "$($program.Name)" -PercentComplete (($i / $total) * 100)
        
        if ($SkipApps -contains $program.Name) {
            Write-Log -message "$($program.Name) исключен, пропускаем."
            continue
        }

        $processStopped = $false
        foreach ($processName in $program.Process) {
            $procs = $runningProcesses | Where-Object { $_.Name -eq $processName }
            if ($procs) {
                $procs | Stop-Process -Force 
                Write-Log -message "Процесс $processName завершен."
                $processStopped = $true
            }
        }
        if ($processStopped) { Write-Log -message "Все процессы $($program.Name) остановлены." }
    }
    Write-Progress -Activity "Завершение процессов" -Completed
}

function Remove-CredentialsFromConfig {
    param (
        [string]$FilePath,
        [string]$FileType,
        [string[]]$KeysToRemove
    )
    if (-not (Test-Path $FilePath)) { 
        Write-Log -level "ERROR" -message "Файл не найден: $FilePath"
        return 
    }
    try {
        switch ($FileType.ToLower()) {
            'json' {
                $content = Get-Content $FilePath -Raw | ConvertFrom-Json -Depth 10
                foreach ($key in $KeysToRemove) {
                    if ($content.Client.PSObject.Properties.Name -contains $key) {
                        $content.Client.PSObject.Properties.Remove($key)
                        Write-Log -message "Удален ключ $key из $FilePath"
                    }
                }
                $content | ConvertTo-Json -Depth 10 | Set-Content $FilePath -Encoding UTF8
            }
            'ini' {
                $lines = Get-Content $FilePath
                $filtered = $lines | Where-Object { $line = $_; -not ($KeysToRemove | Where-Object { $line -match "^\s*$_\s*=" }) }
                $filtered | Set-Content $FilePath -Encoding UTF8
            }
        }
    } catch {
        Write-Log -level "ERROR" -message "Ошибка при обработке $FilePath : $_"
    }
}

function Clear-Data {
    $total = $programs.Count
    $i = 0
    foreach ($program in $programs) {
        $i++
        Write-Progress -Activity "Очистка данных" -Status "$($program.Name)" -PercentComplete (($i / $total) * 100)
        
        if ($SkipApps -contains $program.Name) {
            Write-Log -message "$($program.Name) исключен, пропускаем."
            continue
        }

        if (-not (Test-Path $program.Path)) {
            Write-Log -message "Путь $($program.Path) не найден."
            continue
        }

        if ($program.ContainsKey("FileType") -and $program.ContainsKey("KeysToRemove")) {
            Remove-CredentialsFromConfig -FilePath $program.Path -FileType $program.FileType -KeysToRemove $program.KeysToRemove
        } else {
            Remove-Item -Path $program.Path -Recurse -Force  -ErrorAction SilentlyContinue
            Write-Log -message "Данные $($program.Name) удалены."
        }
    }
    Write-Progress -Activity "Очистка данных" -Completed
}

function Clear-SystemFolders {
    $total = $systemFolders.Count
    $i = 0
    
    foreach ($folder in $systemFolders) {
        $i++
        Write-Progress -Activity "Очистка системных папок" -Status "$($folder.Name)" -PercentComplete (($i / $total) * 100)
        
        if ($SkipSystemFolders -contains $folder.Name) {
            Write-Log -message "Папка $($folder.Name) исключена."
            continue
        }

        if (-not (Test-Path $folder.Path)) {
            Write-Log -message "Папка $($folder.Path) не найдена."
            continue
        }

        try {
            Get-ChildItem -Path $folder.Path -Recurse -Force | Remove-Item  -Force -Recurse -ErrorAction Stop
            Write-Log -message "Очищено: $($folder.Name) ($($folder.Path))"
        } catch {
            Write-Log -level "ERROR" -message "Ошибка при очистке $($folder.Path): $_"
        }
    }
    Write-Progress -Activity "Очистка системных папок" -Completed
}

Write-Host "$Title - $Version" -ForegroundColor Cyan
Write-Log -message "$Title - $Version"

Stop-Processes
Start-Sleep -Seconds 1
Write-Log -level "DEBUG" -message "Очистка данных"
Clear-Data
Write-Log -level "DEBUG" -message "Очистка папок"
Clear-SystemFolders

Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Log -message "Корзина очищена"

Write-Host "Очистка успешно завершена!" -ForegroundColor Green
Write-Log -message "Скрипт завершил работу"

try {
    Add-Type -AssemblyName System.Windows.Forms
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $PID).Path)
    $notify.BalloonTipTitle = $Title
    $notify.BalloonTipText = "Очистка завершена!"
    $notify.Visible = $true
    $notify.ShowBalloonTip(3000)
    Start-Sleep -Seconds 3
    $notify.Dispose()
} catch {
    Write-Log -level "ERROR" -message "Не удалось показать уведомление: $_"
}