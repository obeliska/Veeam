@powershell %~dp0%~n0.ps1 '%~1'
@echo %cmdcmdline%|find /i """%~f0""">nul && (echo. & pause)

