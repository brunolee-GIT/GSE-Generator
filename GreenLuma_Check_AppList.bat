@echo off
set TITLE=GreenLuma AppList
title %TITLE%
set HOME=%~dp0
cd /d "%HOME%"

if [%~3] == [-extbat] (
	set "AppListFolder=%~2"
	set GOTO=:EOF
	%~1
) else (
	set "AppListFolder=%HOME%AppList"
	set GOTO=END
)
:: resizes the CMD window but maintains the scrolling function
mode con cols=100 lines=40&powershell -command "&{$HEIGHT=get-host; $WIDTH=$HEIGHT.ui.rawui; $BUFFER=$WIDTH.buffersize; $BUFFER.width=100; $BUFFER.height=9999; $WIDTH.buffersize=$BUFFER;}"
color 07
chcp 65001>NUL


: START
cls
echo. 
echo   [4m  [42m                                                                                            [0;4m  [0m
echo   [102m                                                                                                [0m
echo   [102;97m                                        GREENLUMA SEARCH                                        [0m
echo   [102;37m                                     check applist content                                      [0m
echo   [102;4;30m                                                                                                [0m
echo     [42;30m                                                                                            [0m
echo. 
echo.

if not exist "%AppListFolder%\" (
	if "%~n1"=="AppList" (
		set "AppListFolder=%~dpn1"
	) else (
		call :function_open_folder_context
	)
)
if not exist "%AppListFolder%\" echo  Not found applist folder! & goto %GOTO%
if not exist "%AppListFolder%\*.txt" echo  Not found any files on applist folder! & goto %GOTO%

: SEARCH_GAME
setlocal enabledelayedexpansion
(for /f "tokens=*" %%a in ('dir /A:A /B "%AppListFolder%"') do (
	set sortnum=       %%a
	echo !sortnum:~-7!
))>AppListSortNum
sort AppListSortNum /O AppListSortNum
for /f %%a in (AppListSortNum) do (
	set AppFile=%%a
	set AppName=
	rem read AppList txt files
	for /f "tokens=* usebackq" %%b in ("%AppListFolder%\!AppFile!") do (
		set AppId=%%b
	)
	rem search AppName by AppId on ini files
	if exist "Database\*.ini" (
		for /f "tokens=*" %%c in ('dir /B /O:N "Database\*.ini"') do (
			set iniFile=%%c
			for /f "tokens=1-9 usebackq delims=^=" %%1 in ("Database\!iniFile!") do (
				set MaybeThis=%%1
				set MaybeThis=!MaybeThis: =!
				if "!MaybeThis!"=="!AppId!" (
					set AppName=%%2
					set FirstCharAppName=!AppName:~0,1!
					if "!FirstCharAppName!"==" " set AppName=!AppName:~1!
					echo  [90m!AppFile! - [93m!AppId![90m = [0m!AppName! [90m!iniFile![0m
				)
			)
		)
	)
	if not defined AppName (
		for /f "tokens=1-26 delims=," %%a in ('curl -s "https://store.steampowered.com/api/appdetails/?filters=basic&appids=!AppId!"') do (
			if "%%a"=="{"!AppId!":{"success":true" (
				set "AppName=%%c"
				set "AppName=!AppName:"name":"=!"
				set "AppName=!AppName:\"=brunolee!"
				set "AppName=!AppName:"=!"
				set "AppName=!AppName:brunolee="!"
				echo  [90m!AppFile! - [93m!AppId![90m = [0m!AppName![90m one by one[0m 
			)
		)
	)
	rem CURL\curl.exe -s --config CURL/config/safari15_5.config --header @CURL/config/safari15_5.header --url "https://cdn.akamai.steamstatic.com/steam/apps/!AppId!/header.jpg" -o "!AppId!.jpg"
	if not defined AppName (
		if not defined AppList (
			set AppList=AppList.txt
			curl -s "https://api.steampowered.com/ISteamApps/GetAppList/v2/" -o !AppList!
			powershell -Command "(gc -LiteralPath '%HOME%!AppList!') -replace '{\"appid\":', \"`r`n^<\" -replace ',\"name\":""', \"^>^<\" -replace '""""},', \"^>\" -replace '""""}]}}', \"^>\" | Out-File -LiteralPath '%HOME%!AppList!' -NoNewline -encoding Default">NUL
		)
		for /f "tokens=1-10 delims=<>" %%a in (!AppList!) do (
			if not defined AppName (
				if "%%a"=="!AppId!" (
					set "AppName=%%b"
					set "AppName=!AppName:\"="!"
					echo  [90m!AppFile! - [93m!AppId![90m = [0m!AppName![90m all in one[0m
				)
			)
		)
	)
	rem AppName by AppId not found
	if not defined AppName (
		set AppName=unknown
		echo  [90m!AppFile! - [93m!AppId![90m = [0munknown[90m .[0m
	)
)
if exist "!AppList!" del "!AppList!">NUL
if exist "AppListSortNum" del "AppListSortNum">NUL
endlocal
goto %GOTO%

: END
echo.
pause>NUL|echo  Press any key to exit . . .
exit

:function_open_folder_context
::set "GreenLumaAppList=C:\Program Files (x86)\Steam"
set "GreenLumaAppList="
>SELECT_FOLDER.vbs (
	echo set outp=wscript.stdout
	echo set objShell=CreateObject("Shell.Application"^)
	echo set objExec=objShell.BrowseForFolder(0, "Select the AppList Folder", ^&H0001, "%GreenLumaAppList%"^)
	echo If Not (objExec Is Nothing^) then c=objExec.self.Path else c=nul End If
	echo outp.write(c^)
)
for /f "tokens=*" %%a in ('cscript /nologo SELECT_FOLDER.vbs') do set SELECT_FOLDER=%%a
del SELECT_FOLDER.vbs>NUL
if "%SELECT_FOLDER%"=="" (
	echo set outp=wscript.stdout : c=msgbox("Do you want cancel?",vbInformation+vbYesNo,"CANCEL"^) : outp.write(c^)>Cancel.vbs
	for /f "tokens=*" %%a in ('cscript /nologo Cancel.vbs') do set CancelAnswer=%%a
	del Cancel.vbs>NUL
)
if defined CancelAnswer (
	if "%CancelAnswer%"=="6" goto END
	if "%CancelAnswer%"=="7" goto OPEN_FOLDER_CONTEXT
)
::folder selected
for %%a in ("%SELECT_FOLDER%") do if "%%~na"=="AppList" (set "AppListFolder=%%~dpna") else (set "AppListFolder=%%~dpna\AppList")
