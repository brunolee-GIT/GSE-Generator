@echo off
mode con cols=100 lines=40
set TITLE=Font selector
title %TITLE%
set HOME=%~dp0
cd /d "%HOME%"


: START
cls
echo.
echo   [44;4m                                                                                                [0m
echo   [104m                                                                                                [0m
echo   [104;97m                               GOLDBERG STEAM EMULATOR GENERATOR                                [0m
echo   [104;37m                                     overlay font selector                                      [0m
echo   [104;4;30m                                                                                                [0m
echo   [44;30m                                                                                                [0m
echo.


: START_LIST
setlocal enabledelayedexpansion
set /a count=0
if exist "ACHIVEMENTS\fonts\*.ttf" (
	for /f "tokens=*" %%a in ('dir /B /O:N "ACHIVEMENTS\fonts\*.ttf"') do (
		set /a count+=1
		echo  [ [93m!count![0m ] - %%a
		set File!count!=%%a
	)
) else (
	exit
)
echo.
if "!count!"=="0" echo [31m No font file found![0m&timeout 3 &exit
if "!count!"=="1" (set "FONTSELECTED=!File1!"&goto TEST) else (goto SELECT_LINE)

: SELECT_LINE
set selectline=!count!
set /p selectline="[35m Select one number[0m [ [93m1[0m - [93;4m!count![0m ]: "
if %selectline% GEQ 1 if %selectline% LEQ !count! set "FONTSELECTED=!File%selectline%!"&goto TEST
goto START


:TEST
for /f "tokens=1-2 delims=^= eol=#" %%1 in (ACHIVEMENTS\configs.overlay.ini) do if "%%1"=="Font_Override" set FONTOVERRIDE=%%2
powershell -Command "(gc -LiteralPath '%HOME%ACHIVEMENTS\configs.overlay.ini') -replace 'Font_Override=%FONTOVERRIDE%', 'Font_Override=%FONTSELECTED%' | Out-File -LiteralPath '%HOME%ACHIVEMENTS\configs.overlay.ini' -encoding ASCII">NUL
endlocal
::goto :EOF
exit