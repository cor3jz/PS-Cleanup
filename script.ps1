param (
    [string[]]$Skip
)

$Title = "Cleanup"
$Version = "2.0.0-beta"
$Host.UI.RawUI.WindowTitle= $Title + ' - ' + $Version

# Лог файл
$logFile = Join-Path $PSScriptRoot 'debug.log'

if (Test-Path -Path $logFile -PathType Leaf) {
    Remove-Item -Path $logFile
}

function Write-Log {
    param (
        [string]$message,
        [ValidateSet("INFO", "ERROR", "DEBUG", "WARNING")]
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$level] $message"
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
}

# Список программ для очистки
$programs = @(
    # Лаунчеры
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
        Name = "Battlestate Games";
        Process = @("BsgLauncher");
        Path = Join-Path $env:appdata 'Battlestate Games\BsgLauncher\settings';
    },
    @{
        Name = "Arena Breakout Infinite";
        Process = @("arena_breakout_infinite_launcher");
        Path = Join-Path $env:appdata 'arena_breakout_infinite_launcher\last_user.dat';
    },

    # Общение
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
        Name = "TeamSpeak";
        Process = @("TeamSpeak");
        Path = Join-Path $env:appdata 'TeamSpeak\Default';
    },
    @{
        Name = "WhatsApp";
        Process = @("WhatsApp");
        Path = Join-Path $env:localappdata 'Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\LocalState';
    },

    # Браузеры
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
    }

    # Другое
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

# Функция для завершения процессов
function Stop-Processes {
    $total = $programs.Count
    $i = 0
    
    foreach ($program in $programs) {
        $i++
        $percent = [int](($i / $total) * 100)
        Write-Progress -Activity "Завершение работы программ" -Status "$($program.Name)" -PercentComplete $percent
        
        $name = $program.Name

        $processList = @()
        if ($program.Process -is [Array]) {
            $processList = $program.Process
        } else {
            $processList = @($program.Process)
        }

        if ($Skip -contains $name) {
            Write-Log -message "$name исключен, пропускаем."
            continue
        }

        Write-Log -message "Завершение работы $name."

        $processStopped = $false

        foreach ($processName in $processList) {
            try {
                $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
                if ($processes) {
                    foreach ($proc in $processes) {
                        $proc | Stop-Process -Force
                        Write-Log -message "Процесс [$processName] (PID: $($proc.Id)) завершен"
                    }
                    $processStopped = $true
                } else {
                    Write-Log -message "Процесс [$processName] не найден"
                }
            } catch {
                Write-Log -level "ERROR" -message "Произошла ошибка при завершении процесса ${processName}: $_"
            }
        }

        if ($processStopped) {
            Write-Log -message "Работа $name завершена!"
        }
        
    }

    Write-Progress -Activity "Завершение работы программ" -Completed
}

function Remove-CredentialsFromConfig {
    param (
        [string]$FilePath,
        [string]$FileType,
        [string[]]$KeysToRemove
    )

    if (!(Test-Path $FilePath)) {
        Write-Log -level "ERROR" -message "Файл не найден: `"$FilePath`""
        return
    }

    try {
        switch ($FileType.ToLower()) {
            'json' {
                $content = Get-Content $FilePath -Raw | ConvertFrom-Json -Depth 10
                foreach ($key in $KeysToRemove) {
                    if ($content.Client.PSObject.Properties.Name -contains $key) {
                        $content.Client.PSObject.Properties.Remove($key)
                    }
                }
                Write-Log -level "DEBUG" -message "Файл конфигурации изменен: `"$FilePath`""
                $content | ConvertTo-Json -Depth 10 | Set-Content -Path $FilePath -Encoding UTF8
            }
            'ini' {
                $lines = Get-Content $FilePath
                $filtered = $lines | Where-Object { $line = $_; -not ($KeysToRemove | Where-Object { $line -match "^\s*$_\s*=" }) }
                $filtered | Set-Content -Path $FilePath -Encoding UTF8
                Write-Log -level "DEBUG" -message "Файл конфигурации изменен: `"$FilePath`""
            }
        }
    } catch {
        Write-Log -level "ERROR" -message "Ошибка при очистке ${FilePath}: $_"
    }
}

# Функция для удаления данных
function Clear-Data {
    param (
        [string]$programName,
        [hashtable]$program,
        [int]$index,
        [int]$total
    )

    $percentComplete = [int](($index / $total) * 100)
    Write-Progress -Activity "Очистка данных" -Status "Обрабатывается: $programName ($index из $total)" -PercentComplete $percentComplete

    $path = $program.Path

    if ($Skip -contains $programName) {
        Write-Log -message "$programName исключен, пропускаем"
        return
    }

    if (-not (Test-Path $path)) {
        Write-Log -message "Данные $programName не обнаружены"
        return
    }

    $files = Get-ChildItem -Path $path -Force

    if ($program.ContainsKey("FileType") -and $program.ContainsKey("KeysToRemove")) {
        Remove-CredentialsFromConfig -FilePath $path -FileType $program.FileType -KeysToRemove $program.KeysToRemove
        Write-Log -message "Данные $programName удалены"
    } else {
        if ($files.Count -gt 0) {
            try {
                Get-ChildItem -Path $path -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                Write-Log -message "Данные $programName удалены, путь: `"$path`""
            } catch {
                Write-Log -level "ERROR" -message "Произошла ошибка при очистке данных ${programName}: $_"
            }
        } else {
            Write-Log -message "Данные $programName не обнаружены"
        }
    }
}

# Логирование начала работы
Write-Host "$Title - $Version"
Write-Log -message "$Title - $Version"

Write-Host "Очистка данных сессии пользователя..."
Write-Log -message "Очистка данных сессии пользователя..."

# Завершаем работу программ
Write-Host "Завершаем работу программ для очистки..."
Write-Log -message "Завершаем работу программ для очистки..."

Stop-Processes

Write-Log -message "Работа программ завершена."

Start-Sleep -Seconds 2

Write-Host "Удаляем данные..."
Write-Log -message "Удаляем данные..."

# Удаляем данные для каждой программы, кроме исключенных
$i = 1
$total = $programs.Count
foreach ($program in $programs) {
    $name = $program.Name
    Clear-Data -programName $name -program $program -index $i -total $total
    $i++
}
Write-Progress -Activity "Очистка данных" -Completed

Start-Sleep -Seconds 1

# Логирование завершения работы
Write-Log -message "Завершение работы скрипта..."
Write-Log -message "Очистка успешно завершена!"
Write-Host "Очистка успешно завершена!"

# Уведомление о завершении работы программы
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balloon.BalloonTipText = "Очистка успешно завершена!"
$balloon.BalloonTipTitle = $Title
$balloon.Visible = $true
$balloon.ShowBalloonTip(5000)
Start-Sleep 5
$balloon.Dispose();