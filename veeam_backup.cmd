@echo off
@setlocal enabledelayedexpansion
@prompt $s

::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Uses Veeam Agent for Windows to perform a full backup if the last one is too
:: old and the laptop has a wired network connection; otherwise performs an 
:: incremental backup.
::
:: This replaces Veeam's scheduler and limitation of performing a full backup on 
:: a specific day.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::

set rem=
if "%1" == "debug" (
   echo on
   set rem=REM 
)

@echo ----------------------------------------------------------------------

bcdedit > nul
if errorlevel 1 goto not_admin

:: Check that scheduled backups are disabled to avoid any clashes.
call :read_reg "HKLM\SOFTWARE\Veeam\Veeam Endpoint Backup" DisableScheduledBackups data d
if "%data%" equ "0" goto sched_enabled

set config=%~dp0%~n0.ini
if not exist %config% goto no_config

for /f %%a in ('hostname') do set host=%%a
for /f "tokens=* eol=#" %%a in (%config%) do call set %%a

if not exist "%location%" goto bad_location
call %utils%\message "Starting backup on %host%"

:: Check for wired network.
set wired=false
netsh interface show interface | findstr /r "Connected.*%wired_interface%" >nul
if %errorlevel% equ 0 set wired=true

:: Get date of last full backup and its age in days.
set last=
for %%a in (%location%\%jobname%????-??-*.vbk) do set last=%%~ta
if defined last (
   call %utils%\elapsed_days %last:~0,10% %date% days
) else (
   set days=-1
)

set type=incremental
if %days% geq %full_days% set type=full
if %days% equ -1 set type=full
if %type% equ full (
   if %wired% equ false (
      if %days% equ -1 (
         call %utils%\message "No previous full backup"
      ) else (
         call %utils%\message "Last full backup was %days% days ago"
         set type=incremental
      )
   )
)

if %type% equ full (
   set qual=activefull
) else (
   set qual=backup
)

call %utils%\message "Performing %type% backup"
%rem%%program% /%qual%
set status=%errorlevel%
goto end

:read_reg
   :: %1 = key
   :: %2 = value
   :: %3 = name of variable to receive data
   :: %4 = type (s=string, d=dword)
   @setlocal
   set d=
   for /f "tokens=3" %%a in ('reg query "%~1" /v %2 ^| findstr "%2"') do set d=%%a
   if "%4" == "d" set /a d=%d%
   @endlocal & set "%3=%d%"
   @goto :eof

:not_admin
call %utils%\message "ERROR: This script must be run as Administrator"
set status=1
goto exit

:sched_enabled
call %utils%\message "ERROR: Veeam scheduled backups need to be disabled to run this script"
set status=1
goto exit

:no_config
call %utils%\message "ERROR: Config file %config% not found"
set status=1
goto exit

:bad_location
call %utils%\message "Unable to access backup location %location%"
set status=2
goto exit

:end
call %utils%\message "Finished with status %status%"
:exit
exit /b %status%

