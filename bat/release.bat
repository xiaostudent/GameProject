set curPath=%cd%
rd /s /q  %curPath%\..\proj.win32\Release\Resources
xcopy %curPath%\..\Resources  %curPath%\..\proj.win32\Release\Resources /D /E /I /F /Y
copy %curPath%\..\src\main.lua  %curPath%\..\proj.win32\Release\Resources\main.lua 
copy %curPath%\..\src\update.lua  %curPath%\..\proj.win32\Release\Resources\update.lua 
cd  ../proj.win32/Release/
start cocos2dGame.exe

