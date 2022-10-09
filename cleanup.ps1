$LogFile = "$env:windir\cleanup.log"

if ((Test-Path -Path "$env:windir\cleanup.log" -PathType Leaf)) {
    Remove-Item -Path "$env:windir\cleanup.log"
}

function WriteLog
{
	Param ([string]$LogString)
	$Stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
	$LogMessage = "$Stamp $LogString"
	Add-content $LogFile -value $LogMessage
}

$SteamInstallPath = ''

if(Test-Path 'HKLM:\SOFTWARE\Valve\Steam') {
    $SteamInstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam').InstallPath
}
if(Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam') {
    $SteamInstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath
}

$SteamClearPaths = (
	"appcache",
	"logs",
	"config\*.*",
	"steamapps\downloading",
	"steamapps\shadercache",
	"steamapps\sourcemods",
	"steamapps\temp",
	"steamapps\workshop",
	"userdata"
)

$ClearPaths = (
	"AppData\Local\Temp",
	"AppData\Local\CrashDumps",
	"AppData\Local\Google\Chrome\User Data",
	"AppData\Local\Steam",
	"AppData\Roaming\discord",
	"AppData\Roaming\FACEIT",
	"AppData\Roaming\Origin",
	"AppData\Roaming\Battle.net",
	"Downloads",
	"Pictures",
	"Videos",
	"Music"
)

$Processes = (
	"chrome",
	"FACEIT",
	"discord",
	"Origin",
	"Battle.net",
	"Steam",
	"steamwebhelper"
)

WriteLog "Скрипт запущен"
WriteLog "Завершение работы процессов..."

foreach ($Process in $Processes)
{
	Get-Process -name $Process -ErrorAction SilentlyContinue | ? { $_.SI -eq (Get-Process -PID $PID).SessionId } | Stop-Process -Force | Add-Content $Logfile
	WriteLog "Процесс '$Process' заверешен"
}
Stop-Service "Steam Client Service" -Force | Add-Content $Logfile
WriteLog "Steam Client Service остановлен"
Start-Sleep -Seconds 3

foreach ($Path in $ClearPaths)
{
	if ((Test-Path -Path "$env:userprofile\$Path") -eq $true)
	{
		Get-ChildItem -Path "$env:userprofile\$Path" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "'$Path' удалено"
	}
}

foreach ($SteamClearPath in $SteamClearPaths)
{

	if ((Test-Path -Path "$SteamInstallPath\$SteamClearPath") -eq $true)
	{
		Get-ChildItem -Path "$SteamInstallPath\$SteamClearPath" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "'$SteamClearPath' удалено"
	}
}

Start-Sleep -Seconds 1

Clear-RecycleBin -Force
WriteLog "Корзина очищена"
WriteLog "Скрипт завершил свою работу"