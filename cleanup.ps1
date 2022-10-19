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
$SteamLibraryFolders = @()
$SteamAppsFolders = @(
	"downloading",
	"shadercache",
	"temp",
	"workshop"
)
$SteamSysFolders = @(
	"appcache",
	"config",
	"userdata"
)

if(Test-Path 'HKLM:\SOFTWARE\Valve\Steam') {
    $SteamInstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam').InstallPath
}
if(Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam') {
    $SteamInstallPath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam').InstallPath
}
if($SteamInstallPath -eq '') { throw "Can't find steam installed on this machine"}

$ClearPaths = (
	"$env:localappdata\Temp",
	"$env:localappdata\CrashDumps",
	"$env:localappdata\Google\Chrome\User Data",
	"$env:localappdata\Steam",
	"$env:appdata\discord",
	"$env:appdata\FACEIT",
	"$env:appdata\Origin",
	"$env:appdata\Battle.net",
	"$env:userprofile\Downloads",
	"$env:userprofile\Pictures",
	"$env:userprofile\Videos",
	"$env:userprofile\Music"
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
	WriteLog "Процесс '$Process' успешно завершен"
}
Stop-Service "Steam Client Service" -Force | Add-Content $Logfile
WriteLog "Служба Steam Client Service остановлена"
Start-Sleep -Seconds 3

if(Test-Path "$SteamInstallPath\steamapps\libraryfolders.vdf") {
	$filedata = Get-Content "$SteamInstallPath\steamapps\libraryfolders.vdf"

	foreach($line in $filedata) {
		if($line -match '"path".*"(.*)"') {
			foreach ($SteamAppsFolder in $SteamAppsFolders)
			{
				$SteamLibraryFolders += "$($Matches[1])\steamapps\$SteamAppsFolder" -replace '\\\\', '\'
			}
		}
	}
}

foreach ($SteamLibraryFolder in $SteamLibraryFolders)
{
	if ((Test-Path -Path $SteamLibraryFolder) -eq $true)
	{
		Get-ChildItem -Path $SteamLibraryFolder -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Каталог '$SteamLibraryFolder' очищен"
	}
}


foreach ($SteamSysFolder in $SteamSysFolders)
{
	if ((Test-Path -Path "$SteamInstallPath\$SteamSysFolder") -eq $true)
	{
		Get-ChildItem -Path "$SteamInstallPath\$SteamSysFolder" -Recurse -Force -Exclude config.vdf, loginusers.vdf, libraryfolders.vdf, localconfig.vdf, sharedconfig.vdf | Where-Object {($_.LastWriteTime -le (Get-Date).AddHours(-24) )} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Каталог '$SteamInstallPath\$SteamSysFolder' очищен"
	}
}

if(Test-Path 'HKCU:\SOFTWARE\Valve\Steam') {
    Get-ChildItem -Path (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Valve\Steam').SourceModInstallPath | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
	WriteLog "Каталог 'Source Mods' очищен"
}

foreach ($Path in $ClearPaths)
{
	if ((Test-Path -Path $Path) -eq $true)
	{
		Get-ChildItem -Path $Path | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Каталог '$Path' очищен"
	}
}

Start-Sleep -Seconds 1

Clear-RecycleBin -Force
WriteLog "Корзина очищена"
WriteLog "Скрипт завершил свою работу"