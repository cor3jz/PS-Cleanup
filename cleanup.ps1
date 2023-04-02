$Version = '0.7.5'
$Host.UI.RawUI.MaxPhysicalWindowSize.Width=550
$Host.UI.RawUI.MaxPhysicalWindowSize.Height=300
$Host.UI.RawUI.WindowTitle="Cleanup Utility" + ' - ' + $Version

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
WriteLog "Cleanup Utility"
WriteLog "Скрипт начал работу"

#Остановка процессов и служб
$Processes = (
	"chrome",
	"EpicGamesLauncher",
	"EpicWebHelper",
	"EADesktop",
	"EABackgroundService",
	"FACEIT",
	"GameCenter",
	"discord",
	"Battle.net",
	"Steam",
	"steamwebhelper",
	"lgc",
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


#Очистка уч. записей в Steam
$SteamPath = ''
if ((Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam') -eq $true) {
    $SteamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath
} else {
	Write-Host "Не удалось найти Steam на этом компьютере"
	WriteLog "Не удалось найти Steam на этом компьютере"
}

if ((Test-Path "$SteamPath\config\loginusers.vdf") -eq $true)
{
	Remove-Item "$SteamPath\config\loginusers.vdf" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	Write-Host "Учетные данные Steam удалены"
	WriteLog "Учетные данные Steam удалены"
} else {
	Write-Host "Учетные данные Steam не обнаружены"
	WriteLog "Учетные данные Steam не обнаружены"
}
Start-Sleep -Seconds 1

#Удаление учетных данных других приложений
$CredentialStores = (
	"$env:localappdata\Electronic Arts\EA Desktop\cookie.ini",
    "$env:localappdata\GameCenter\GameCenter.ini",
    "$env:localappdata\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini",
    "$env:localappdata\Steam\*",
    "$env:appdata\Lesta\GameCenter\user_info.xml",
    "$env:appdata\Wargaming.net\GameCenter\user_info.xml",
    "$env:appdata\Battle.net\*.config",
    "$env:localappdata\Google\Chrome\User Data\*",
	"$env:appdata\discord\*",
	"$env:appdata\FACEIT\*"
)

foreach ($CredentialFile in $CredentialStores)
{
    $FileName = $CredentialFile.Split("\")[5]

    switch ($FileName)
    {
        'Battle.net' {$Message = 'Учетные данные Battle.net удалены'}
        'Electronic Arts' {$Message = 'Учетные данные EA Desktop удалены'}
        'GameCenter' {$Message = 'Учетные данные VK Play удалены'}
        'EpicGamesLauncher' {$Message = 'Учетные данные Epic Games удалены'}
        'Lesta' {$Message = 'Учетные данные Lesta Games удалены'}
        'Steam' {$Message = 'Кэш браузера Steam очищен'}
        'Wargaming.net' {$Message = 'Учетные данные Wargaming.net удалены'}
        'Google' {$Message = 'Профиль пользователя Google Chrome удален'}
        'discord' {$Message = 'Учетные данные Discord удалены'}
        'FACEIT' {$Message = 'Учетные данные FACEIT удалены'}
    }

    if ((Test-Path "$CredentialFile") -eq $true) {
        Get-Item $CredentialFile | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue | Add-Content $Logfile
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
WriteLog "Корзина очищена"
WriteLog "Скрипт завершил свою работу"

Write-Host "Корзина очищена"
Write-Host "Скрипт завершил свою работу"