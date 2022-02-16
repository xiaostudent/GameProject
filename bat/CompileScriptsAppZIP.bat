@echo off
set CURR_PATH=%cd%

py %CURR_PATH%\..\tool\quick\bin\CompileScripts.py  -p %CURR_PATH%\..\  -o  app -b 32  -d app
