
del deathrun.iwd
7za a -tzip deathrun.iwd localizedstrings -r -x!*.zip
7za a -tzip deathrun.iwd maps\mp\gametypes\war.gsc
7za a -tzip deathrun.iwd maps\mp\gametypes\_quickmessages.gsc
7za a -tzip deathrun.iwd ui_mp
7za a -tzip deathrun.iwd weapons
7za a -tzip deathrun.iwd deathrun_readme.txt

del deathrun_images.iwd
7za a -tzip deathrun_images.iwd images

del deathrun_sounds.iwd
7za a -tzip deathrun_sounds.iwd sound -r -x!*soundaliases.txt

pause