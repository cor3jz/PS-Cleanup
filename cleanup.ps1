$Version = '0.7.5'
$Host.UI.RawUI.MaxPhysicalWindowSize.Width=550
$Host.UI.RawUI.MaxPhysicalWindowSize.Height=300
$Host.UI.RawUI.WindowTitle="Cleanup Utility" + ' - ' + $Version
$host.UI.Write('Выполняется удаление учетных записей и настроек последнего пользователя')

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
	WriteLog "Работа процесса [$Process] завершена"
}
Stop-Service "Steam Client Service" -Force | Add-Content $LogFile
WriteLog "Служба Steam Client Service остановлена"


#Очистка уч. записей в Steam
$SteamPath = ''
$SteamAppData = $env:localappdata+'\'+'Steam'
if (Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam') {
    $SteamPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath
}
if ($SteamPath -eq '') {
	WriteLog "Не удалось найти Steam на этом компьютере"
}
if (Test-Path $SteamAppData)
{
	Get-ChildItem -Path $SteamAppData | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Кэш браузера Steam очищен"
}
if (Test-Path "$SteamPath\config\loginusers.vdf")
{
	Remove-Item "$SteamPath\config\loginusers.vdf" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Данные учетных записей Steam удалены"
}
Start-Sleep -Seconds 1


#Очистка уч. записей в EA App
if (Test-Path "$env:localappdata\Electronic Arts\EA Desktop\*.ini")
{
	Remove-Item "$env:localappdata\Electronic Arts\EA Desktop\*.ini" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Данные учетных записей EA Desktop удалены"
}
Start-Sleep -Seconds 1


#Очистка уч. записей в VK Play
if (Test-Path "$env:localappdata\GameCenter\GameCenter.ini")
{
	Remove-Item "$env:localappdata\GameCenter\GameCenter.ini" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Данные учетных записей VK Play удалены"
}
Start-Sleep -Seconds 1


#Очистка уч. записей в Epic Games
if (Test-Path "$env:localappdata\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini")
{
	Remove-Item "$env:localappdata\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Данные учетных записей Epic Games удалены"
}
Start-Sleep -Seconds 1


#Очистка уч. записей в Battle.net
if (Test-Path -Path "$env:appdata\Battle.net")
{
	Get-ChildItem -Path "$env:appdata\Battle.net" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Данные учетных записей Battle.net удалены"
}
Start-Sleep -Seconds 1


#Очистка уч. записей в Lesta Games
if (Test-Path "$env:localappdata\Lesta\GameCenter\user_info.xml")
{
	Remove-Item "$env:localappdata\Lesta\GameCenter\user_info.xml" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Данные учетных записей Lesta Games удалены"
}
Start-Sleep -Seconds 1


#Очистка уч. записей в Wargaming.net
if (Test-Path "$env:localappdata\Wargaming.net\GameCenter\user_info.xml")
{
	Remove-Item "$env:localappdata\Wargaming.net\GameCenter\user_info.xml" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Данные учетных записей Wargaming.net удалены"
}
Start-Sleep -Seconds 1


#Удаление профилей в Chrome, Discord и FaceIT
$AppPaths = (
	"$env:localappdata\Google\Chrome\User Data",
	"$env:appdata\discord",
	"$env:appdata\FACEIT"
)
foreach ($AppPath in $AppPaths)
{
	if (Test-Path -Path $AppPath)
	{
		Get-ChildItem -Path $AppPath | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
		WriteLog "Каталог [$AppPath] очищен"
	}
}


#Удаление временных файлов и очистка каталогов пользователя Windows
$SystemPaths = (
	"$env:localappdata\Temp",
	"$env:localappdata\CrashDumps",
	"$env:userprofile\Downloads",
	"$env:userprofile\Pictures",
	"$env:userprofile\Videos",
	"$env:userprofile\Music"
)
foreach ($SysPath in $SystemPaths)
{
	if (Test-Path -Path $)
	{
		Get-ChildItem -Path $SysPath | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
		WriteLog "Каталог [$SysPath] очищен"
	}
}
WriteLog "Каталоги пользователя и временные файлы системы очищены"

#Очистка корзины
Clear-RecycleBin -Force
WriteLog "Корзина очищена"
WriteLog "Скрипт завершил свою работу"