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
		Get-ChildItem -Path $SteamLibraryFolder -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -WhatIf -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Каталог '$SteamLibraryFolder' очищен"
	}
}


foreach ($SteamSysFolder in $SteamSysFolders)
{
	if ((Test-Path -Path "$SteamInstallPath\$SteamSysFolder") -eq $true)
	{
		Get-ChildItem -Path "$SteamInstallPath\$SteamSysFolder" -Recurse -Force -Exclude config.vdf, loginusers.vdf, libraryfolders.vdf, localconfig.vdf, sharedconfig.vdf | Where-Object {($_.LastWriteTime -le (Get-Date).AddHours(-24) )} | Remove-Item -Recurse -Force -WhatIf -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "Каталог '$SteamInstallPath\$SteamSysFolder' очищен"
	}
}

if(Test-Path 'HKCU:\SOFTWARE\Valve\Steam') {
    Get-ChildItem -Path (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Valve\Steam').SourceModInstallPath | Remove-Item -Recurse -Force -WhatIf -ErrorAction SilentlyContinue | Add-Content $Logfile
	WriteLog "Каталог 'Source Mods' очищен"
}

foreach ($Path in $ClearPaths)
{
	if ((Test-Path -Path "$env:userprofile\$Path") -eq $true)
	{
		Get-ChildItem -Path "$env:userprofile\$Path" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
		WriteLog "'$Path' удалено"
	}
}


Start-Sleep -Seconds 1

Clear-RecycleBin -Force
WriteLog "Корзина очищена"
WriteLog "Скрипт завершил свою работу"