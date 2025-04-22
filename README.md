<div align="center">

<img width="360" height="240" src="./assets/Card.jpg">

# Cleanup Utility

**Утилита для очистки данных сессии последнего пользователя**


![downloads-badge](https://img.shields.io/github/downloads/cor3jz/PS-Cleanup/total?color=blue)
![release-badge](https://img.shields.io/github/v/release/cor3jz/PS-Cleanup?color=green&display_name=release)
![static-badge](https://img.shields.io/badge/PowerShell-blue)


[![ru](https://img.shields.io/badge/lang-ru-blue)](./README.md)
[![en](https://img.shields.io/badge/lang-en-red)](./README.en.md)

![stars-badge](https://img.shields.io/github/stars/cor3jz/PS-Cleanup)

</div>

> [!NOTE]  
> Данная утилита представлена исключительно для ознакомления! Разработчик не несет ответственности за удаленные с ваших компьютеров файлы и некорректную работу программ с которыми работает данный скрипт! Всем добра :heart:

## Для чего?

Cleanup предназначен для автоматического удаления данных сессии последнего пользователя ПК, таких как: аккаунты в различных приложениях, история браузера, а также удаления временных файлов и разного рода мусора.

## Удаление учетных данных

После запуска Cleanup автоматически завершает необходимые процессы и удаляет данные пользователей в следующих приложениях:  

1. **Лаунчеры**
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

2. **Связь**
    - Discord
    - Telegram
    - TeamSpeak 3
    - TeamSpeak 6
    - WhatsApp

3. **Браузеры**
    - Google Chrome
    - Firefox
    - Opera GX
    - Microsoft Edge
    - Яндекс.Браузер

...и другие приложения, такие как: Faceit, MarketApp и др. Список пополняется по мере поступления запросов на добавление той или иной программы.


## Как использовать?

1. Скачиваем установщик **[тут](https://github.com/cor3jz/PS-Cleanup/releases/latest)**
2. Устанавливаем Cleanup в любое удобное место, или же оставляем папку установки по умолчанию
3. Для очистки по умолчанию (все приложения), просто добавляем `cleanup.exe` в автозагрузку любым удобным способом
4. Для исключения того или иного приложения из очистки, добавляем параметр запуска `-SkipApps` и названия приложений которые будут исключены
5. Названия программ для исключения указывайте так, как написано в файле `how-to-use.txt`, который находится в папке установки Cleanup.