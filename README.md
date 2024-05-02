# GSE-Generator
<p align="center">
  <img width="600" src="https://i.imgur.com/evuBfti.png">
  <br><br>
  <a href=""><img src="https://img.shields.io/badge/script-bat / hta- ?logo=windowsterminal&style=social" alt="" title="Scripts"></a>
	&nbsp;<a href=""><img src="https://img.shields.io/badge/windows-10 / 11- ?logo=windows10&style=social" alt="" title="Windows"></a>
</p>

GSE_Generator.bat generates the "steam_settings" folder for the desired game with the following structure and contents:
``` text
Game name/
 ├── steam_settings/
 │    ├── images/
 │    │    └── achievements images...
 │    ├── sounds/
 │    │    └── overlay_achievement_notification.wav
 │    ├── header image
 │    ├── achievements.json
 │    ├── configs.app.ini
 │    ├── configs.overlay.ini
 │    ├── configs.user.ini
 │    ├── steam_appid.txt
 │    ├── steam_interfaces.txt
 │    └── supported_languages.txt
 ├── steam_api.dll or steam_api64.dll
 └── steam_api_o.dll or steam_api64_o.dll
```
> **How it works**
>
>> *The information about available dlcs is downloaded from steam or the database, the names for the dlcs are searched in 4 places in the database, steam, steamdb and steam api.*
>> 
>> *The achievements will be downloaded in one of the languages supported by the game, with the respective images.*
>> 
>> *The emulator will always be the latest release of [goldberg_emulator fork by @otavepto](https://github.com/otavepto/gbe_fork).*

***
#### Database
``` text
Database/
      ↳ appid...
```
>> *The database, in addition to speeding up the work of **GSE_Generator.bat**, can also be used to create the Applist for GreenLuma with **GreenLuma_Create_AppList.bat***

***
#### GSE force
>> ***Tools/GSE_force.ini** is used to automatically fill in some of the fields presented in the window to create the **configs.user.ini** file*

***
#### Command Line
[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Console&size=22&color=ffffff&background=000000&lines=>_+COMMAND+LINE+USAGE:)](https://git.io/typing-svg)
Command | Result
------ | ------
GSE_Generator.bat `-toast` | *test achievements*
GSE_Generator.bat `-interfaces` | *create steam_interfaces.txt*
GSE_Generator.bat `-emulator` | *download the latest release of goldberg_emulator fork by @otavepto*
GSE_Generator.bat `-help` | *more information...*

***
#### Notes
> [!NOTE]
> There are many emulator settings missing, but because I don't use them, I don't even know what they are for.
> But here's a good base to remove or add anything.

<p align="center"> 
  <a href="https://www.paypal.com/donate/?hosted_button_id=9WWD5XXJXQ9VG"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif"/></a>
  <img alt="" border="1" src="https://www.paypal.com/en_PT/i/scr/pixel.gif" width="10" height="10"/>
</p>
