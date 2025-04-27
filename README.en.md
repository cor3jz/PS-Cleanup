<div align="center">

<img width="360" height="240" src="./assets/card.jpg">

# Cleanup Utility

**Cleanup is a utility for clearing user session data**


![downloads-badge](https://img.shields.io/github/downloads/cor3jz/PS-Cleanup/total?color=blue)
![release-badge](https://img.shields.io/github/v/release/cor3jz/PS-Cleanup?color=green&display_name=release)
![static-badge](https://img.shields.io/badge/PowerShell-blue)


[![ru](https://img.shields.io/badge/lang-ru-blue)](./README.md)
[![en](https://img.shields.io/badge/lang-en-red)](./README.en.md)

![stars-badge](https://img.shields.io/github/stars/cor3jz/PS-Cleanup)

</div>

> [!NOTE]  
> This utility is provided for informational purposes only! The developer is not responsible for files deleted from your computers and incorrect operation of programs with which this script works! All the best :heart:

## What is it?

Cleanup is designed to automatically delete session data of the last PC user, such as accounts in various applications, browser history, as well as deleting temporary files and various kinds of garbage.

## How does it work?

Once launched, Cleanup automatically terminates necessary processes and deletes user data in the following applications:  

1. **Game Launchers**
    - Steam
    - Epic Games
    - EA App
    - Battle.net
    - VK Play
    - Riot Games
    - Lesta Games
    - Wargaming.net
    - Ubisoft Connect
    - Battlestate Games
    - Arena Breakout Infinite
    - Rockstar Games Launcher
    - Roblox

2. **Connectivity**
    - Discord
    - Telegram
    - TeamSpeak 3
    - TeamSpeak 6
    - WhatsApp

3. **Browsers**
    - Google Chrome
    - Firefox
    - Opera GX
    - Microsoft Edge
    - Yandex.Browser

4. **Other**
    - Faceit Client
    - MarketApp

The list is updated as requests are received to add a particular program.


## How to use?

> [!NOTE]  
> If you have used the utility before, do not forget to delete the old version.

1. Download the latest version **[here](https://github.com/cor3jz/PS-Cleanup/releases/latest)**
2. Extract the archive to any convenient location
3. To clean by default (all applications), just add a `cleanup'.exe` to auto-upload in any convenient way
4. To exclude an application(s) from cleaning, add the startup parameter `-SkipApps` and the names of the applications that will be excluded.
5. To exclude a folder from cleaning, add the launch parameter `-SkipFolders` and the names of the folders that will be excluded.
6. Specify the names of programs to exclude as written in the `launch-keys.txt` file, which is located in the Docs folder.

## Examples

1. Default cleanup:
```
C:\Path\To\Cleanup.exe
```

2. Cleaning with exclusion of some programs:
```
C:\Path\To\Cleanup.exe -SkipApps "Steam", "Chrome"
```

3. Cleaning with exclusion of system folders:
```
C:\Path\To\Cleanup.exe -SkipFolders "Downloads", "Temp"
```

4. Cleaning with exclusion of programs and system folders:
```
C:\Path\To\Cleanup.exe -SkipApps "Steam", "Chrome" -SkipFolders "Downloads", "Temp"
```

5. Example of adding Cleanup to autorun in SmartShell

![SmartShell_Example](./assets/example.png)

## Updates

Cleanup can automatically update to the latest version. Run `update.exe` to check for updates and download the new version.
You can also add `update.exe` to the task scheduler to check for updates automatically.

Example of a weekly update check:
```
schtasks /CREATE /TN "Cleanup Utility Update Checker" /TR "C:\Path\To\update.exe" /SC WEEKLY /D MON /ST 09:00 /RU "SYSTEM" /RL HIGHEST /F
```