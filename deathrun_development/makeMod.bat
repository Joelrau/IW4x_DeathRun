
del mod.ff
copy /Y mod.csv ..\..\zone_source
..\..\iw4x.exe -zonebuilder +set fs_game mods\deathrun_development +buildzone mod +quit
copy /Y ..\..\zone\mod.ff

pause