@echo off

if not exist ..\..\zonetool.exe goto ERROR_ZONETOOL_EXE_NOT_FOUND

set moddir=%cd%

if exist ..\..\zone_source goto SKIP_ZONE_SOURCE_FOLDER
:MAKE_ZONE_SOURCE_FOLDER
mkdir ..\..\zone_source
:SKIP_ZONE_SOURCE_FOLDER

copy /Y mod.csv ..\..\zone_source

if exist ..\..\zonetool goto SKIP_ZONETOOL_FOLDER
:MAKE_ZONETEOOL_FOLDER
mkdir ..\..\zonetool
:SKIP_ZONETOOL_FOLDER

if exist ..\..\zonetool\mod goto SKIP_MOD_FOLDER
:MAKE_MOD_FOLDER
mkdir ..\..\zonetool\mod
:SKIP_MOD_FOLDER

xcopy braxi ..\..\zonetool\mod\braxi\ /EY
xcopy fx ..\..\zonetool\mod\fx\ /EY
xcopy images ..\..\zonetool\mod\images\ /EY
xcopy loaded_sound ..\..\zonetool\mod\loaded_sound\ /EY
xcopy map_scripts ..\..\zonetool\mod\map_scripts\ /EY
xcopy maps ..\..\zonetool\mod\maps\ /EY
xcopy materials ..\..\zonetool\mod\materials\ /EY
xcopy mp ..\..\zonetool\mod\mp\ /EY

if exist ..\..\zonetool\mod\plugins goto SKIP_PLUGINS
:DO_PLUGINS
mkdir ..\..\zonetool\mod\plugins
echo main(){}> ..\..\zonetool\mod\plugins\_plugins.gsc
:SKIP_PLUGINS

xcopy sound ..\..\zonetool\mod\sound\ /EY
xcopy sounds ..\..\zonetool\mod\sounds\ /EY

if not exist ..\..\zonetool\mod\techsets\ goto DO_TECHSETS
choice /c YN /t 3 /d N /m "Has your techsets folder changed"
if %errorlevel% equ 2 goto SKIP_TECHSETS
:DO_TECHSETS
del ..\..\zonetool\mod\techsets\ /Q
xcopy techsets ..\..\zonetool\mod\techsets\ /EY
:SKIP_TECHSETS

xcopy ui_mp ..\..\zonetool\mod\ui_mp\ /EY
xcopy weapons ..\..\zonetool\mod\weapons\ /EY
xcopy vision ..\..\zonetool\mod\vision\ /EY
xcopy xanim ..\..\zonetool\mod\xanim\ /EY
xcopy xmodel ..\..\zonetool\mod\xmodel\ /EY
xcopy xsurface ..\..\zonetool\mod\xsurface\ /EY

cd ..\..\
zonetool.exe -buildzone mod -quit
cd %moddir%

del mod.ff
copy /Y ..\..\zone\english\mod.ff

pause
exit 0



:ERROR_ZONETOOL_EXE_NOT_FOUND
echo ERROR: Zonetool.exe not found!
pause
exit 2