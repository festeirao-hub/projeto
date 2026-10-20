@echo off
chcp 65001 >nul
cd /d "%~dp0"
python sync_projeto.py
if errorlevel 1 pause & exit /b 1
cd /d "C:\Users\User\Downloads\FloripaOT-ClienteR1\FloripaOT-ClienteR1\FloripaOT-ClienteR1\FloripaOT-Cliente"
start "" "otclient_gl.exe"
echo.
echo Logue no OT que permitir OTCv8 aberto.
echo Bot ^(menu superior^) - Projeto - Enable.
echo.
echo Olders oficial NAO roda Projeto: use este client no Floripa/outros OTs,
echo ou envie o ZIP em olders\dist ao staff do Olders.
timeout /t 8 >nul
