$Version = '1.0.1'
$Host.UI.RawUI.WindowTitle="Cleanup" + ' - ' + $Version

#Log Config
$LogFile = $env:windir+'\'+'cleanup.log'
if (Test-Path -Path "$env:windir\cleanup.log" -PathType Leaf) {
    Remove-Item -Path "$env:windir\cleanup.log"
}
function WriteLog
{
	Param ([string]$LogString)
	$Timestamp = (Get-Date).toString("[dd/MM/yyyy HH:mm:ss]")
	$LogMessage = "$Timestamp $LogString"
	Add-Content $LogFile -value $LogMessage
}
Write-Host "Cleanup Utility"
Write-Host "Выполняется удаление учетных записей и настроек последнего пользователя"
WriteLog "Cleanup Utility $Version"
WriteLog "Скрипт начал работу"

#Остановка процессов и служб
$Processes = (
	"Battle.net",
    "BsgLauncher",
	"chrome",
	"discord",
	"EADesktop",
	"EABackgroundService",
	"EpicGamesLauncher",
	"EpicWebHelper",
	"FACEIT",
    "firefox",
	"GameCenter",
	"lgc",
    "MarketApp",
    "opera",
    "RiotClientServices",
	"Steam",
	"steamwebhelper",
    "Telegram",
    "upc",
	"wgc"
)
foreach ($Process in $Processes)
{
	Get-Process -name $Process -ErrorAction SilentlyContinue | ? { $_.SI -eq (Get-Process -PID $PID).SessionId } | Stop-Process -Force | Add-Content $Logfile

	Write-Host "Процесс [$Process] остановлен"
	WriteLog "Процесс [$Process] остановлен"
}

Stop-Service "Steam Client Service" -Force | Add-Content $LogFile

Write-Host "Служба Steam Client Service остановлена"
WriteLog "Служба Steam Client Service остановлена"

#Путь установки Steam
$SteamInstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath

#Удаление учетных данных других приложений
$CleanupPaths = (
    "$SteamInstallPath\config\loginusers.vdf",
	"$env:localappdata\Electronic Arts\EA Desktop\cookie.ini",
    "$env:localappdata\GameCenter\GameCenter.ini",
    "$env:localappdata\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini",
    "$env:localappdata\Steam\*",
    "$env:appdata\Lesta\GameCenter\user_info.xml",
    "$env:appdata\Wargaming.net\GameCenter\user_info.xml",
    "$env:appdata\Battle.net\*.config",
    "$env:localappdata\Google\Chrome\User Data\*",
	"$env:appdata\discord\*",
	"$env:appdata\FACEIT\*",
	"$env:appdata\Battlestate Games\BsgLauncher\settings",
	"$env:appdata\Telegram Desktop\tdata\*",
	"$env:appdata\marketapp\*",
    "$env:localappdata\Ubisoft Game Launcher\user.dat",
    "$env:localappdata\Riot Games\Riot Client\Data\RiotGamesPrivateSettings.yaml",
	"$env:appdata\Opera Software\Opera GX Stable\*",
	"$env:appdata\Mozilla\Firefox\*"
)

foreach ($CleanupPath in $CleanupPaths)
{
    $FileName = $CleanupPath.Split("\")[5]

    switch ($FileName)
    {        
        #Папки приложений
        'Battlestate Games' {$Message = 'Учетные данные Battlestate Games удалены'}
        'Battle.net' {$Message = 'Учетные данные Battle.net удалены'}
        'Electronic Arts' {$Message = 'Учетные данные EA Desktop удалены'}
        'GameCenter' {$Message = 'Учетные данные VK Play удалены'}
        'EpicGamesLauncher' {$Message = 'Учетные данные Epic Games удалены'}
        'Lesta' {$Message = 'Учетные данные Lesta Games удалены'}
        'Steam' {$Message = 'Кэш браузера Steam очищен'}
        'Telegram Desktop' {$Message = 'Учетные данные Telegram удалены'}
        'Wargaming.net' {$Message = 'Учетные данные Wargaming.net удалены'}
        'Google' {$Message = 'Профиль пользователя Google Chrome удален'}
        'discord' {$Message = 'Учетные данные Discord удалены'}
        'FACEIT' {$Message = 'Учетные данные FACEIT удалены'}
        'Ubisoft Game Launcher' {$Message = 'Учетные данные Ubisoft Connect удалены'}
        'marketapp' {$Message = 'Учетные данные MarketApp удалены'}
        'Riot Games' {$Message = 'Учетные данные Riot Games удалены'}
        'Opera Software' {$Message = 'Учетные данные Opera GX удалены'}
        'Mozilla' {$Message = 'Учетные данные Mozilla Firefox удалены'}
        'Steam' {$Message = 'Учетные данные Steam удалены'}
    }

    if ((Test-Path "$CleanupPath") -eq $true) {
        Get-Item $CleanupPath | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue | Add-Content $Logfile
        WriteLog "$Message"
	    Write-Host "$Message"
    } else {
        WriteLog "Данные $FileName не обнаружены"
	    Write-Host "Данные $FileName не обнаружены"
    }
}

Start-Sleep -Seconds 1

#Очистка системных папок и каталогов пользователя
$SystemPaths = (
	"$env:localappdata\Temp",
	"$env:localappdata\CrashDumps",
	"$env:userprofile\Downloads",
	"$env:userprofile\Pictures",
	"$env:userprofile\Videos",
	"$env:userprofile\Music"
)
foreach ($Path in $SystemPaths)
{
    $DirName = $Path.Split("\")[-1]

    switch ($DirName)
    {
        'Temp' {$Message = 'Временные файлы Windows удалены'}
        'CrashDumps' {$Message = 'Дампы крашей удалены'}
        'Downloads' {$Message = 'Папка Загрузки очищена'}
        'Pictures' {$Message = 'Папка Изображения очищена'}
        'Videos' {$Message = 'Папка Видео очищена'}
        'Music' {$Message = 'Папка Музыка очищена'}
    }

    if ((Test-Path "$Path") -eq '') {
        WriteLog "Каталог [$Path] не существует"
	    Write-Host "Каталог [$Path] не существует"
        continue
    }

    if ((Test-Path "$Path\*") -eq '') {
        WriteLog "Каталог $DirName пуст"
	    Write-Host "Каталог $DirName пуст"
        continue
    }

    Get-ChildItem -Path $Path | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue | Add-Content $LogFile
    WriteLog "$Message"
	Write-Host "$Message"
}

Start-Sleep -Seconds 1

Clear-RecycleBin -Force -ErrorAction SilentlyContinue | Add-Content $LogFile

Write-Host "Корзина очищена"
WriteLog "Корзина очищена"
WriteLog "Скрипт завершил свою работу"


Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balmsg.BalloonTipText = "Скрипт завершил свою работу!"
$balmsg.BalloonTipTitle = "Cleanup Utility $Version"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(5000)