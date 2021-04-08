@echo off

set "map=mp_dr_crosscode"
set /p "map=Enter map name or press [ENTER] for default [%map%]: "

cd ..\..\
start iw4x.exe +set fs_game "mods\deathrun_development" +connect localhost +devmap %map%