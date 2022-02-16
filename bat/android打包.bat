set curPath=%cd%
copy %curPath%\..\src\main.lua  %curPath%\..\Resources\main.lua 
copy %curPath%\..\src\update.lua  %curPath%\..\Resources\update.lua 
rd /s /q  %curPath%\..\proj.android\app\build
cd ../proj.android
call gradlew.bat assembleRelease
copy  %curPath%\..\proj.android\app\build\outputs\apk\release\cocos2dGame-release.apk  %curPath%\..\game.apk
cd %curPath%\..\Resources
del /f /s /q   *.lua

