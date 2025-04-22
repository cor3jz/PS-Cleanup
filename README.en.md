<div align="center">

<img width="360" height="240" src="./assets/Card.jpg">

# Cleanup Utility

**Cleanup is a utility for cleaning the session data of the last user**


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

## Removing credentials

Once launched, Cleanup automatically terminates necessary processes and deletes user data in the following applications:  

1. **Game Launchers**
    - Steam
    - Battle.net
    - Epic Games
    - EA App
    - VK Play
    - Riot Games
    - Lesta Games
    - Wargaming.net
    - Ubisoft Connect
    - Battlestate Games
    - Arena Breakout Infinite

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

...and other applications such as Faceit, MarketApp, etc. The list is updated as requests are received to add a particular program.


## How to use?

1. Download the installer **[here](https://github.com/cor3jz/PS-Cleanup/releases/latest)**
2. Install Cleanup in any convenient location, or leave the default installation folder
3. To clean by default (all applications), just add a `cleanup'.exe` to auto-upload in any convenient way
4. To exclude an application(s) from cleaning, add the startup parameter `-SkipApps` and the names of the applications that will be excluded.
5. Specify the names of programs to exclude as written in the `how-to-use.txt` file, which is located in the Cleanup installation folder.