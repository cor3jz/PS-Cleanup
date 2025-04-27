param (
  [string[]]$SkipApps = @(),
  [string[]]$SkipFolders = @()
)

$Title = 'Cleanup Utility'
$VersionFile = Join-Path -Path $PSScriptRoot -ChildPath 'version.json'
$Version = (Get-Content -Path $VersionFile -Raw | ConvertFrom-Json).version

$Host.UI.RawUI.WindowTitle = "$Title - $Version"

$logFile = Join-Path -Path $PSScriptRoot -ChildPath 'debug.log'
if (Test-Path -Path $logFile -PathType Leaf) 
{
Remove-Item -Path $logFile -Force
}

function Write-Log 
{
  param (
    [string]$message,
    [ValidateSet('INFO', 'WARNING', 'ERROR', 'DEBUG')]
    [string]$level = 'INFO'
  )
  $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  $logEntry = "[$timestamp] [$level] $message"
  Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
}

$programs = @(
  @{
    Name    = 'Steam'
    Process = @('Steam', 'steamwebhelper')
    Path    = Join-Path -Path (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath -ChildPath 'config\loginusers.vdf'
  }, 
  @{
    Name    = 'EA'
    Process = @('EADesktop', 'EABackgroundService')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'Electronic Arts\EA Desktop'
  }, 
  @{
    Name         = 'Battle.net'
    Process      = @('Battle.net')
    Path         = Join-Path -Path $env:appdata -ChildPath 'Battle.net\Battle.net.config'
    FileType     = 'json'
    KeysToRemove = @('AutoLogin', 'SavedAccountNames')
  }, 
  @{
    Name         = 'VK Play'
    Process      = @('GameCenter')
    Path         = Join-Path -Path $env:localappdata -ChildPath 'GameCenter\GameCenter.ini'
    FileType     = 'ini'
    KeysToRemove = @('LastAGSTime', 'LastAUITime', 'MyComUserMagic', 'cLastLoginTime', 'MyComUserMagic4', 'FirstAuth', 'LastAUITime', 'MyComUserMagic2', 'MyComUserLogin', 'MyComUserUid', 'CurrentUserName', 'CurrentUserNick', 'CurrentUserAvatarFileName')
  }, 
  @{
    Name    = 'Riot Games'
    Process = @('RiotClientServices')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'Riot Games\Riot Client\Data\RiotGamesPrivateSettings.yaml'
  }, 
  @{
    Name    = 'Lesta'
    Process = @('lgc')
    Path    = Join-Path -Path $env:appdata -ChildPath 'Lesta\GameCenter\user_info.xml'
  }, 
  @{
    Name    = 'Wargaming'
    Process = @('wgc')
    Path    = Join-Path -Path $env:appdata -ChildPath 'Wargaming.net\GameCenter\user_info.xml'
  }, 
  @{
    Name    = 'Ubisoft'
    Process = @('upc')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'Ubisoft Game Launcher\user.dat'
  }, 
  @{
    Name    = 'Epic Games'
    Process = @('EpicGamesLauncher', 'EpicWebHelper')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini'
  }, 
  @{
    Name    = 'BSGLauncher'
    Process = @('BsgLauncher')
    Path    = Join-Path -Path $env:appdata -ChildPath 'Battlestate Games\BsgLauncher\settings'
  }, 
  @{
    Name    = 'Arena Breakout'
    Process = @('arena_breakout_infinite_launcher')
    Path    = Join-Path -Path $env:appdata -ChildPath 'arena_breakout_infinite_launcher\last_user.dat'
  }, 
  @{
    Name    = 'Rockstar Games'
    Process = @('Launcher')
    Path    = Join-Path -Path $env:userprofile -ChildPath 'Documents\Rockstar Games\Social Club\Profiles'
  }, 
  @{
    Name    = 'Roblox'
    Process = @('RobloxPlayerBeta')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'Roblox\LocalStorage\RobloxCookies.dat'
  }, 

  @{
    Name    = 'Discord'
    Process = @('discord')
    Path    = Join-Path -Path $env:appdata -ChildPath 'discord'
  }, 
  @{
    Name    = 'Telegram'
    Process = @('Telegram')
    Path    = Join-Path -Path $env:appdata -ChildPath 'Telegram Desktop\tdata'
  }, 
  @{
    Name    = 'TeamSpeak 3'
    Process = @('ts3client_win64')
    Path    = Join-Path -Path $env:appdata -ChildPath 'TS3Client\settings.db'
  }, 
  @{
    Name    = 'TeamSpeak 6'
    Process = @('TeamSpeak')
    Path    = Join-Path -Path $env:appdata -ChildPath 'TeamSpeak\Default'
  }, 
  @{
    Name    = 'WhatsApp'
    Process = @('WhatsApp')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\LocalState'
  }, 

  @{
    Name    = 'Chrome'
    Process = @('chrome')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'Google\Chrome\User Data'
  }, 
  @{
    Name    = 'Firefox'
    Process = @('firefox')
    Path    = Join-Path -Path $env:appdata -ChildPath 'Mozilla\Firefox'
  }, 
  @{
    Name    = 'Opera'
    Process = @('opera')
    Path    = Join-Path -Path $env:appdata -ChildPath 'Opera Software\Opera GX Stable'
  }, 
  @{
    Name    = 'Edge'
    Process = @('msedge')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'Microsoft\Edge\User Data'
  }, 
  @{
    Name    = 'Yandex'
    Process = @('browser')
    Path    = Join-Path -Path $env:localappdata -ChildPath 'Yandex\YandexBrowser\User Data'
  }, 
    
  @{
    Name    = 'FACEIT'
    Process = @('FACEIT')
    Path    = Join-Path -Path $env:appdata -ChildPath 'FACEIT'
  }, 
  @{
    Name    = 'MarketApp'
    Process = @('MarketApp')
    Path    = Join-Path -Path $env:appdata -ChildPath 'marketapp'
  }
)

$systemFolders = @(
  @{
    Name = 'Downloads'
    Path = [Environment]::GetFolderPath('UserProfile') + '\Downloads'
  }, 
  @{
    Name = 'Images'
    Path = [Environment]::GetFolderPath('MyPictures')
  }, 
  @{
    Name = 'Video'
    Path = [Environment]::GetFolderPath('MyVideos')
  }, 
  @{
    Name = 'Music'
    Path = [Environment]::GetFolderPath('MyMusic')
  }, 
  @{
    Name = 'Temp'
    Path = $env:TEMP
  }, 
  @{
    Name = 'SystemTemp'
    Path = "$env:SystemRoot\Temp"
  }, 
  @{
    Name = 'CrashDumps'
    Path = "$env:localappdata\CrashDumps"
  }, 
  @{
    Name = 'Thumbnails'
    Path = "$env:localappdata\Microsoft\Windows\Explorer"
  }
)

function Stop-Processes 
{
  $allProcessNames = $programs.Process | Select-Object -Unique
  $runningProcesses = Get-Process -Name $allProcessNames -ErrorAction SilentlyContinue

  foreach ($program in $programs) 
  {        
    if ($SkipApps -contains $program.Name) 
    {
      Write-Log -message "$($program.Name) исключен, пропускаем."
      continue
    }

    $processStopped = $false
    foreach ($processName in $program.Process) 
    {
      $procs = $runningProcesses | Where-Object -FilterScript {$_.Name -eq $processName}
      if ($procs) 
      {
        $procs | Stop-Process -Force
        Write-Log -message "Процесс $processName завершен."
        $processStopped = $true
      }
    }
    if ($processStopped) 
    {Write-Log -message "Все процессы $($program.Name) остановлены."}
  }
}

function Remove-CredentialsFromConfig 
{
  param (
    [string]$FilePath,
    [string]$FileType,
    [string[]]$KeysToRemove
  )

  if (!(Test-Path $FilePath)) 
  {
    Write-Log -level 'ERROR' -message "Файл конфигурации не найден: `"$FilePath`""
    return
  }

  try 
  {
    switch ($FileType.ToLower()) {
      'json' 
      {
        $content = Get-Content $FilePath -Raw | ConvertFrom-Json

        foreach ($key in $KeysToRemove) 
        {
          if ($content.Client.PSObject.Properties.Name -contains $key) 
          {$content.Client.PSObject.Properties.Remove($key)}
        }
        Write-Log -level 'DEBUG' -message "Файл конфигурации изменен: `"$FilePath`""
        $content |
        ConvertTo-Json -Depth 10 |
        Out-File $FilePath -Encoding UTF8
      }
      'ini' 
      {
        $lines = Get-Content $FilePath
        $filtered = $lines | Where-Object -FilterScript {
          $line = $_
          -not ($KeysToRemove | Where-Object -FilterScript {$line -match "^\s*$_\s*="})
        }
        $filtered | Set-Content -Path $FilePath -Encoding UTF8
        Write-Log -level 'DEBUG' -message "Файл конфигурации изменен: `"$FilePath`""
      }
    }
  }
 catch 
  {
Write-Log -level 'ERROR' -message "Ошибка при очистке ${FilePath}: $_"
}
}

function Clear-Data 
{
  foreach ($program in $programs) 
  {        
    if ($SkipApps -contains $program.Name) 
    {
      Write-Log -message "$($program.Name) исключен, пропускаем."
      continue
    }

    if (-not (Test-Path -Path $program.Path)) 
    {
      Write-Log -message "Путь $($program.Path) не найден."
      continue
    }

    if ($program.ContainsKey('FileType') -and $program.ContainsKey('KeysToRemove')) 
    {Remove-CredentialsFromConfig -FilePath $program.Path -FileType $program.FileType -KeysToRemove $program.KeysToRemove}
    else 
    {
      Remove-Item -Path $program.Path -Recurse -Force -ErrorAction SilentlyContinue
      Write-Log -message "Данные $($program.Name) удалены."
    }
  }
}

function Clear-SystemFolders 
{
  foreach ($folder in $systemFolders) 
  {        
    if ($SkipFolders -contains $folder.Name) 
    {
      Write-Log -message "Папка $($folder.Name) исключена."
      continue
    }

    if (-not (Test-Path -Path $folder.Path)) 
    {
      Write-Log -message "Папка $($folder.Path) не найдена."
      continue
    }

    try 
    {
      Get-ChildItem -Path $folder.Path -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
      Write-Log -message "Очищено: $($folder.Name) ($($folder.Path))"
    } catch 
    {Write-Log -level 'ERROR' -message "Ошибка при очистке $($folder.Path): $_"}
  }
}


Write-Host -Object "$Title - $Version" -ForegroundColor Cyan
Write-Log -message "$Title - $Version"

Write-Log -level 'DEBUG' -message '========== Завершение процессов =========='
Stop-Processes
Start-Sleep -Seconds 1

Write-Log -level 'DEBUG' -message '========== Очистка данных приложений =========='
Clear-Data
Start-Sleep -Seconds 1

Write-Log -level 'DEBUG' -message '========== Очистка системных папок =========='
Clear-SystemFolders
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Log -message 'Корзина очищена'
Write-Host -Object 'Очистка успешно завершена!' -ForegroundColor Green

Write-Log -message '========== Очистка успешно завершена =========='
Write-Log -level 'DEBUG' -message 'Скрипт завершил работу'

try 
{
  Add-Type -AssemblyName System.Windows.Forms
  $global:balmsg = New-Object -TypeName System.Windows.Forms.NotifyIcon
  $path = (Get-Process -Id $pid).Path
  $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
  $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
  $balmsg.BalloonTipText = 'Очистка завершена!'
  $balmsg.BalloonTipTitle = 'Cleanup Utility'
  $balmsg.Visible = $true
  $balmsg.ShowBalloonTip(3000)
  Start-Sleep -Seconds 3
}
 catch 
{
Write-Log -level 'ERROR' -message "Не удалось показать уведомление: $_"
}
