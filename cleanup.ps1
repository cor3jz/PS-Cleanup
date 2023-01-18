$Version = '0.7.0'
$Host.UI.RawUI.MaxPhysicalWindowSize.Width=550
$Host.UI.RawUI.MaxPhysicalWindowSize.Height=300
$Host.UI.RawUI.WindowTitle="Cleanup Script" + ' - ' + $Version
$host.UI.Write('Выполняется очистка данных предыдущего пользователя...')

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
WriteLog "Скрипт начал работу"

#Cleanup Game Launchers
$Processes = (
	"chrome",
	"EpicGamesLauncher",
	"EpicWebHelper",
	"EADesktop",
	"EABackgroundService",
	"FACEIT",
	"GameCenter",
	"discord",
	"Origin",
	"Battle.net",
	"Steam",
	"steamwebhelper"
)
foreach ($Process in $Processes)
{
	Get-Process -name $Process -ErrorAction SilentlyContinue | ? { $_.SI -eq (Get-Process -PID $PID).SessionId } | Stop-Process -Force | Add-Content $Logfile
	WriteLog "Работа процесса [$Process] завершена"
}
Stop-Service "Steam Client Service" -Force | Add-Content $LogFile
WriteLog "Служба Steam Client Service остановлена"

#Cleanup Game Launchers
##Steam
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
	WriteLog "Очистка Steam завершена"
}
Start-Sleep -Seconds 1

##EA Desktop
if (Test-Path "$env:localappdata\Electronic Arts\EA Desktop\*.ini")
{
	Remove-Item "$env:localappdata\Electronic Arts\EA Desktop\*.ini" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Очистка EA Desktop завершена"
}
Start-Sleep -Seconds 1

##VK Play
if (Test-Path "$env:localappdata\GameCenter\GameCenter.ini")
{
	Remove-Item "$env:localappdata\GameCenter\GameCenter.ini" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Очистка VK Play завершена"
}
Start-Sleep -Seconds 1

##Epic Games
if (Test-Path "$env:localappdata\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini")
{
	Remove-Item "$env:localappdata\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini" -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Очистка Epic Games завершена"
}
Start-Sleep -Seconds 1

##Origin
if (Test-Path -Path "$env:appdata\Origin")
{
	Get-ChildItem -Path "$env:appdata\Origin" | Remove-Item -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Очистка Origin завершена"
}
Start-Sleep -Seconds 1

##Battle.net
if (Test-Path -Path "$env:appdata\Battle.net")
{
	Get-ChildItem -Path "$env:appdata\Battle.net" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $LogFile
	WriteLog "Очистка Battle.net завершена"
}
Start-Sleep -Seconds 1

##Applications
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
Clear-RecycleBin -Force
WriteLog "Корзина очищена"
WriteLog "Скрипт завершил свою работу"
# SIG # Begin signature block
# MIIbngYJKoZIhvcNAQcCoIIbjzCCG4sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2Tgx1O67hmOQCl6LJ3YWdt9v
# 0KOgghYTMIIDCDCCAfCgAwIBAgIQSQCj7t+fqKJNcYd1JZ98CzANBgkqhkiG9w0B
# AQsFADAcMRowGAYDVQQDDBFGUFMgQXJlbmEgUHJvamVjdDAeFw0yMzAxMTgwNjI0
# MDBaFw0yNTAxMTgwNjM0MDBaMBwxGjAYBgNVBAMMEUZQUyBBcmVuYSBQcm9qZWN0
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2rJ4EwrxWGY9f/8FCb/h
# zpG2h1aWMv7mb3J4XlAgbbKnNoWF75RDOjw+BI9FXiBZYVJAG45IjIy4I+JKg7sF
# L03GJ6YTM0eRd+cZpjGA3mrCeDWI/kp8IMivAIB/1wk4dcXUIirXmFrWO3z58i8j
# 6enyex3DzjU9PN3NszM3LezbRStGNa/XbGivaNkrI3bf8IJt1dK2d/i3LRsI1SdK
# B0FBmIfbFT4wkUt4EIDeTdacgNHQXkUPbwtCN7o7fmAOsbnmmxhzDsH96ryoFkXD
# sLDlYQOM0fBTqn21bPnPK+joEbCq6T+wzjb/oHCduWR9R9wKTtcjo0IV2F/0kyyp
# UQIDAQABo0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# HQYDVR0OBBYEFKxieO0OnndY26GWcCZzzTuqcZjVMA0GCSqGSIb3DQEBCwUAA4IB
# AQAFuZYUizJEqVM8inIQPgCUwogfdxKrDssVWDLtKkxmcjv5h3/zXXLByE+WKFKz
# cwNkUjzkce8VhIprWoxMhg9vildI71RzdBeZVqGA2wScG21j++1TXegCKV6pae0x
# odJ/atbJ0Y4sglDny0wGUGhfUSNVAjeeAJ+ZP8c32++WdWRoSJWucQuC/hOZw4Sd
# v1FS3i697XbW4tQ3kjOhLfS4KAzL1TRvSc8Ww4uoCdIgMLq5+puDXZnjmKHU0cWr
# yeHv4jDJ6dtUMfoYWR0DEmFkp+OJihgNAICwEFeD57zQ8UBiJT0CmnPGO/dK2773
# bEfnCq6Jsa1ZfGtKkwx1Z82PMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAY
# WjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdp
# Q2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5
# MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVz
# dGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBz
# aN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbr
# VsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTR
# EEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJ
# z82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyO
# j4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6R
# AXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k
# 98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJ
# tppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUa
# dmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZB
# dd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVf
# nSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0T
# AQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0j
# BBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsG
# AQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29t
# MEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9j
# cmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYD
# VR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3Qb
# PbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5
# +KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+n
# BgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc
# /RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVr
# zyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o
# 4rmUMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsF
# ADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJv
# b3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0
# IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mX
# UaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34
# V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevT
# sbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GD
# Gd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8By
# xbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcg
# Q+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKV
# EStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP
# 0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj3
# 3GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9
# XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2
# udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYD
# VR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1k
# TN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcD
# CDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmww
# IAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUA
# A4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2q
# KWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVz
# jQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2yS
# vZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQe
# JsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeH
# JLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1P
# tkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5
# h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZ
# Wcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT
# /r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP
# /JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBsAwggSooAMC
# AQICEAxNaXJLlPo8Kko9KQeAPVowDQYJKoZIhvcNAQELBQAwYzELMAkGA1UEBhMC
# VVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBU
# cnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0yMjA5
# MjEwMDAwMDBaFw0zMzExMjEyMzU5NTlaMEYxCzAJBgNVBAYTAlVTMREwDwYDVQQK
# EwhEaWdpQ2VydDEkMCIGA1UEAxMbRGlnaUNlcnQgVGltZXN0YW1wIDIwMjIgLSAy
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAz+ylJjrGqfJru43BDZrb
# oegUhXQzGias0BxVHh42bbySVQxh9J0Jdz0Vlggva2Sk/QaDFteRkjgcMQKW+3Kx
# lzpVrzPsYYrppijbkGNcvYlT4DotjIdCriak5Lt4eLl6FuFWxsC6ZFO7KhbnUEi7
# iGkMiMbxvuAvfTuxylONQIMe58tySSgeTIAehVbnhe3yYbyqOgd99qtu5Wbd4lz1
# L+2N1E2VhGjjgMtqedHSEJFGKes+JvK0jM1MuWbIu6pQOA3ljJRdGVq/9XtAbm8W
# qJqclUeGhXk+DF5mjBoKJL6cqtKctvdPbnjEKD+jHA9QBje6CNk1prUe2nhYHTno
# +EyREJZ+TeHdwq2lfvgtGx/sK0YYoxn2Off1wU9xLokDEaJLu5i/+k/kezbvBkTk
# Vf826uV8MefzwlLE5hZ7Wn6lJXPbwGqZIS1j5Vn1TS+QHye30qsU5Thmh1EIa/tT
# QznQZPpWz+D0CuYUbWR4u5j9lMNzIfMvwi4g14Gs0/EH1OG92V1LbjGUKYvmQaRl
# lMBY5eUuKZCmt2Fk+tkgbBhRYLqmgQ8JJVPxvzvpqwcOagc5YhnJ1oV/E9mNec9i
# xezhe7nMZxMHmsF47caIyLBuMnnHC1mDjcbu9Sx8e47LZInxscS451NeX1XSfRkp
# WQNO+l3qRXMchH7XzuLUOncCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAM
# BgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcw
# CAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91
# jGogj57IbzAdBgNVHQ4EFgQUYore0GH8jzEU7ZcLzT0qlBTfUpwwWgYDVR0fBFMw
# UTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3Rl
# ZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEE
# gYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggr
# BgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0B
# AQsFAAOCAgEAVaoqGvNG83hXNzD8deNP1oUj8fz5lTmbJeb3coqYw3fUZPwV+zbC
# SVEseIhjVQlGOQD8adTKmyn7oz/AyQCbEx2wmIncePLNfIXNU52vYuJhZqMUKkWH
# SphCK1D8G7WeCDAJ+uQt1wmJefkJ5ojOfRu4aqKbwVNgCeijuJ3XrR8cuOyYQfD2
# DoD75P/fnRCn6wC6X0qPGjpStOq/CUkVNTZZmg9U0rIbf35eCa12VIp0bcrSBWcr
# duv/mLImlTgZiEQU5QpZomvnIj5EIdI/HMCb7XxIstiSDJFPPGaUr10CU+ue4p7k
# 0x+GAWScAMLpWnR1DT3heYi/HAGXyRkjgNc2Wl+WFrFjDMZGQDvOXTXUWT5Dmhiu
# w8nLw/ubE19qtcfg8wXDWd8nYiveQclTuf80EGf2JjKYe/5cQpSBlIKdrAqLxksV
# StOYkEVgM4DgI974A6T2RUflzrgDQkfoQTZxd639ouiXdE4u2h4djFrIHprVwvDG
# IqhPm73YHJpRxC+a9l+nJ5e6li6FV8Bg53hWf2rvwpWaSxECyIKcyRoFfLpxtU56
# mWz06J7UWpjIn7+NuxhcQ/XQKujiYu54BNu90ftbCqhwfvCXhHjjCANdRyxjqCU4
# lwHSPzra5eX25pvcfizM/xdMTQCi2NYBDriL7ubgclWJLCcZYfZ3AYwxggT1MIIE
# 8QIBATAwMBwxGjAYBgNVBAMMEUZQUyBBcmVuYSBQcm9qZWN0AhBJAKPu35+ook1x
# h3Uln3wLMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ5qhh8qmc082KhkeICYLtLH3h1HTANBgkq
# hkiG9w0BAQEFAASCAQAGNuqPCiigdPW/7VTCEkB1+nrTAn2/7D02r9MiLcgJe3/w
# U1tGjL7gkIPEWutsseIO6z9FEk5mqOWm1NppHgzYJ2DHflazUkhIqoZxaT25xZyV
# trNcxcU6srNEk4qwEAAipa8Bdp2OeMwodsYmF4O3NaxHSA2HyCIEN3FpdEtosX+G
# Gt1EAb86LH+HZ1/T4PhP2aciJxCs9VuKzMEyPd7Ell9WKG45uAGoc//raz1g7yKk
# Lksi9lHCwy+9WbhaJ0AGKUloEKWANUe2PC97TL2v50giwqfJbRDX8ZJ8yfGtGj8f
# bfkE3qL2NMnOW5qHyNhl5hwt4sm9E96Hm59bbiC0oYIDIDCCAxwGCSqGSIb3DQEJ
# BjGCAw0wggMJAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0
# LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hB
# MjU2IFRpbWVTdGFtcGluZyBDQQIQDE1pckuU+jwqSj0pB4A9WjANBglghkgBZQME
# AgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8X
# DTIzMDExODA2MzQxOVowLwYJKoZIhvcNAQkEMSIEIC5yRLW02yOP0zYr4FzSK+KA
# CE98nwpdFX5ekJkRLXMHMA0GCSqGSIb3DQEBAQUABIICAJ4KLQPBmZYfjXYd7g8l
# miQbGDRY9HoAV0OTqHIBMY/78Yfm6xlH4l2hj9uS9NG0l7cDRFPAEtzFllTtAKa9
# MIl2QMpDPWAlOlNLvwLgraUKV3AbHZMi0q2Xj2KK1tus1juKPqd0xc/+zoXpXsxL
# GSyBIy9BoBfRhh8ef48fztQRHAw6JqwO3IgQcU0cWphkxf3jT+bXPwaGHlqAe29j
# Q0ttNq3TmJ5Te1UerSxM4seglPl+YLoH2w0O/udBnX51Wd96DHGXVqz5gPdGpeSP
# MpmbTIRIhZHGUs8xfwgMGAdNNK+Ct6N1kB7VoshPFoAJeG8iYk4lgnWaQXkZiJBS
# nYM4yoRBu+LjRzGaG+Rg//c1rWihQ85JVunE+HQ4nPK7TRxe8cW0mz+oYsyFqnTS
# aIIGDXVUNG8MTpsFI/PMcSShDilX7SAww5GPjhveL/+Xd0RSpSQwLY/V4vmOyIkP
# n19njEIuOnu2VkxsmQoD+kTsXSJ115Pwi5PzTcJtQyHGRQ61nx3RboXWEyky5Oo/
# Ntl0Yk1ebhCOdPKTAEJytt6mM31jrMBTHdJOVbjnxBy96WeQ2DIW31NO3Mv2p2U9
# 6vGvxJXz+3cmiTxyJZUJbVXthIVnGQ5qzHrmZJ5/WXR1e3+GWVNIqMqf7Yh0akkn
# 3ZPpivPFHjAmlOcgjQN+9c6d
# SIG # End signature block
