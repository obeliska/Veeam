@echo off
@setlocal enabledelayedexpansion
@prompt $s

::
:: Set the Veaam logging levels.
::

set key="HKLM\SOFTWARE\Veeam\Veeam Endpoint Backup"
set vals=AgentLogging,LoggingLevel
set min=1
set level%min%=Low
set max=6
set level%max%=Ultimate

call :get_current

set level=%1
if "%level%" == "" goto usage
for /l %%a in (%min%,1,%max%) do if %level% equ %%a goto ok
goto usage

:ok
if %LoggingLevel% equ %level% goto already_set

bcdedit > nul
if errorlevel 1 goto not_admin

@echo Setting logging level %level%
for %%a in (%vals%) do (
   @echo - %%a
   reg add %key% /v %%a /t reg_dword /d %level% /f >nul
)
goto end

:get_current
   for %%a in (%vals%) do for /f "tokens=1,3" %%b in ('reg query %key% /v %%a ^| findstr "%%a"') do set /a %%b=%%c
   goto :eof

:already_set
@echo Logging level is already %level%
@goto end

:not_admin
@echo ERROR: Need to be Administrator to change the logging level
@goto end

:usage
@echo Usage: %~n0 n
@echo where n is between %min% (!level%min%!) and %max% (!level%max%!)
@echo.
@echo Current logging level is %LoggingLevel%
@goto end

:end
@call %utils%\pause_if_doubleclicked

