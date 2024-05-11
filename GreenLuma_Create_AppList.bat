@echo off
set TITLE=GreenLuma AppList
title %TITLE%
set HOME=%~dp0
cd /d "%HOME%"
:: resizes the CMD window but maintains the scrolling function
mode con cols=100 lines=40&powershell -command "&{$HEIGHT=get-host; $WIDTH=$HEIGHT.ui.rawui; $BUFFER=$WIDTH.buffersize; $BUFFER.width=100; $BUFFER.height=9999; $WIDTH.buffersize=$BUFFER;}"
color 07
setlocal enabledelayedexpansion

: START_LIST
call :function_banner
if not "%~nx1"=="" goto DRAG_AND_DROP_FILE

: DATABASE
if not exist "Database\*.ini" goto DRAG_AND_DROP_FILE
chcp 65001>NUL
(for /f %%a in ('dir /A:A /B /O:N "Database\*.ini"') do (
	for /f "tokens=1-9 delims=^=" %%1 in (Database\%%a) do (
		if "%%1"=="Title " (
			set dbname=%%2
			set dbid=%%1
			set dbfile=Database\%%a
			echo ^<!dbname:~1!^>^<!dbfile!^>
		)
		if "%%1"=="%%~na " (
			set dbname=%%2
			set dbid=%%1
			set dbfile=Database\%%a
			echo ^<!dbname:~1!^>^<!dbfile!^>
		)
	)
))>dblist
sort dblist /O dblist
set /a count=0
for /f "tokens=1-9 delims=<>" %%1 in (dblist) do (
	set /a count+=1
	echo  [ [93m!count![0m ] - %%1
	set File!count!=%%2
)
del "dblist">NUL

: SELECT_LINE
echo.
set selectline=!count!
set /p selectline="[35m Select one number[0m [ [93m1[0m - [93;4m!count![0m ]: "
if %selectline% GEQ 1 if %selectline% LEQ !count! set FILEPATH="%HOME%!File%selectline%!"&goto START
goto START_LIST

: DRAG_AND_DROP_FILE
if "%~nx1"=="" goto OPEN_FILE_CONTEXT
set FILEPATH="%~dpnx1"

: CHECK_IF_FILE_OR_FOLDER
dir /ad %FILEPATH% 2>&1|findstr /C:"Not Found">NUL:&&(goto IS_FILE)||(goto IS_FOLDER)

: IS_FILE
set FILENAME=%~n1
set FILEEXTEN=%~x1
goto CHECK_FILE

: IS_FOLDER
echo c=msgbox("Not compatible with folders!"+vbNewLine+"Compatible only with *.ini files",vbExclamation,"INCORRECT FILE")>Compatible.vbs&Compatible.vbs&del Compatible.vbs>NUL&exit

: OPEN_FILE_CONTEXT
for /f "tokens=*" %%a in ('powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.OpenFileDialog;$f.InitialDirectory='%cd%';$f.FileName='';$f.Filter='GameName (*.ini)|*.ini';$f.showHelp=$false;$f.ShowDialog()|Out-Null;$f.FileName"') do set "INIPATH=%%a"
if "%INIPATH%"=="" echo c=msgbox("If it is more convenient:"+vbNewLine+"Drag-and-drop the ini file into the "+chr(34)+"%TITLE%.bat"+chr(34)+" file!",vbInformation,"INFO")>Info.vbs&Info.vbs&del Info.vbs>NUL&exit
set FILEPATH="%INIPATH%"
for %%a in (%FILEPATH%) do set FILENAME=%%~na&set FILEEXTEN=%%~xa
goto CHECK_FILE

: CHECK_FILE
if /i "%FILEEXTEN%"==".ini" goto START
echo c=msgbox("Not compatible with this file extension!"+vbNewLine+"Compatible only with *.ini files",vbExclamation,"INCORRECT FILE")>Compatible.vbs&Compatible.vbs&del Compatible.vbs>NUL&exit

: START
call :function_banner
if exist "AppList" set "DIR=%HOME%"&goto INI_START

: OPEN_FOLDER_CONTEXT
set CancelAnswer=
::set "GreenLumaAppList=C:\Program Files (x86)\Steam"
set "GreenLumaAppList="
>SELECT_FOLDER.vbs (
	echo set outp=wscript.stdout
	echo set objShell=CreateObject("Shell.Application"^)
	echo set objExec=objShell.BrowseForFolder(0, "Where is located the GreenLuma?"+vbNewLine+vbNewLine+"Where is the AppList?", ^&H0001, "%GreenLumaAppList%"^)
	echo If Not (objExec Is Nothing^) then c=objExec.self.Path else c=nul End If
	echo outp.write(c^)
)
for /f "tokens=*" %%a in ('cscript /nologo SELECT_FOLDER.vbs') do set SELECT_FOLDER=%%a
del SELECT_FOLDER.vbs>NUL
::folder not selected - cancel or exit
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
for %%a in ("%SELECT_FOLDER%") do if "%%~na"=="AppList" (set "DIR=%%~dpa") else (set "DIR=%%~dpna\")

: INI_START
set /a idfile=0
if exist "%DIR%AppList\*.txt" (
	(for /f "tokens=*" %%a in ('dir /A:A /B "%DIR%AppList\*.txt"') do (
		set sortnum=       %%a
		echo !sortnum:~-7!
	))>AppListSortNum
	sort AppListSortNum /O AppListSortNum
	for /f %%a in (AppListSortNum) do call :function_reorder "%%a"&set /a idfile+=1
	del "AppListSortNum">NUL
)

set CleanAnswer=
if not "%idfile%"=="0" (
	if exist "GreenLuma_Check_AppList.bat" call "GreenLuma_Check_AppList.bat" "goto START" "%DIR%AppList" -extbat
	echo set outp=wscript.stdout : c=msgbox("AppList folder is not empty"+vbNewLine+"Do you want clean folder?",vbInformation+vbYesNo,"APPLIST"^) : outp.write(c^)>Clean.vbs
	for /f "tokens=*" %%a in ('c:\windows\system32\cscript.exe /nologo Clean.vbs') do set CleanAnswer=%%a
	del "Clean.vbs">NUL
) else (
	if not exist "%DIR%AppList" mkdir "%DIR%AppList">NUL
)

if defined CleanAnswer (
	if "%CleanAnswer%"=="6" (
		rmdir /s /q "%DIR%AppList">NUL
		mkdir "%DIR%AppList">NUL
		call :function_banner
	)
	if "%CleanAnswer%"=="7" (
		call :function_banner
	)
)

for /f "tokens=1-9 usebackq delims=^= eol=;" %%1 in (%FILEPATH%) do (
	if not "%%1"=="Title " (
		if not "%%1"=="[*]" (
			set AppId=%%1
			set AppName=%%2
			call :function_append
		)
	)
)

: END
endlocal
echo.
pause>NUL|echo  Press any key to exit . . .
exit

:function_banner
cls
echo. 
echo   [4m  [42m                                                                                            [0;4m  [0m
echo   [102m                                                                                                [0m
echo   [102;97m                                       GREENLUMA APPLIST                                        [0m
echo   [102;37m                                  create applist from database                                  [0m
echo   [102;4;30m                                                                                                [0m
echo     [42;30m                                                                                            [0m
echo. 
goto :EOF

:function_reorder
if not exist "%DIR%AppList\%idfile%.txt" (
	echo  [32mMOVE [90m%~1 - [93m%idfile%.txt
	move "%DIR%AppList\%~1" "%DIR%AppList\%idfile%.txt">NUL
)
goto :EOF

:function_append
set AppId=%AppId: =%
set FirstCharAppName=%AppName:~0,1%
if "%FirstCharAppName%"==" " set AppName=%AppName:~1%
for /l %%a in (0,1,999) do (
	if not exist "%DIR%AppList\%%a.txt" (
		echo  [32mADD [90m%%a.txt - [93m!AppId! - [0m%AppName%
		echo %AppId%> "%DIR%AppList\%%a.txt"
		goto :EOF
	)
)
goto :EOF
