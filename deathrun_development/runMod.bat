@echo off

set "map=mp_dr_mirrors_edge"
set /p "map=Enter map name or press [ENTER] for default [%map%]: "

cd ..\..\
start iw4x.exe +set fs_game "mods\deathrun_development" +set developer 2 +set developer_script 1 +set logfile 2 +connect localhost +devmap %map%