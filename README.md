DeathRun 2.1 Mod for IW4x
=========================
Deathrun is a mod in which a single player fights alone against the other team, his only weapons are his deadly traps.
The players on the opposite team have to kill the trapmaster (aka. activator) after finishing his course without dying. 

<hr>

The code has been altered heavily to work with iw4x, you may do as you please with the code.

<hr>

Configuration & Installation
===========================
Prenotes: Whereas "IW4x Root" you should be aware it is the root directory of iw4x installation, also please see "Requirements" section.
Prenotes: You require a custom iw4x.dll for this code to work, see "Requirements" section.

1. Install and replace the original "IW4x Root/iw4x.dll" with the custom iw4x.dll
2. Extract "deathrun_developer" folder to "IW4x Root/mods"
3. Install RektInator's zonetool
3.1 Copy "zonetool" folder in "IW4x Root/mods/deathrun_developer" to "IW4x Root"
3.2 Copy "zonetool/ZoneTool-win32-release.dll" to "IW4x Root" and rename it to "zonetool.dll"
3.3 Open "zonetool/zonetool-binaries-master.zip/zonetool-binaries-master" and copy "zonetool_iw4.exe" to "IW4x Root" and rename it to "zonetool.exe"
4. Build mod_characters.ff
4.1 Copy "zonetool/mod_characters/mod_characters.csv" to "IW4x Root/zone_source"
4.2 Run "IW4x Root/zonetool.exe" and execute "buildzone mod_characters" ( ignore errors about missing images )
5. Run makeMod.bat to build mod.ff
6. Run makeIWD.bat to build .iwd files
7. [optional] Run runMod.bat to launch your newly compiled mod, you can change launch options (ex. map) by directly editing .bat file

<hr>

Adding new stuff
================
Note: Remember to always run makeMod.bat and makeIWD.bat when adding new stuff.

* Sounds
I have not been able to add new sounds, so I have replaced native sounds.

* Characters
I used RektInator's zonetool to dump a cod4 fastfile that had the character in it. After adding the files from the dump into "zonetool/mod_characters" I added the xmodel,xmodel_name to "mod_characters.csv"
Then I built the mod_characters.ff with RektInator's zonetool.

Remember to add the xmodel,xmodel_name into the "mod.csv"
You also have to add the character in "mp/characterTable.csv" and ui_mp/scriptmenus/dr_characters.menu for it to appear in the characters menu.

* Weapons
I followed this tutorial to port weapons from CoD4 to IW4x: https://youtu.be/7nVqZL2fCHw

Remember to add the xmodel,xmodel_name into the "mod.csv"
You also have to add the weapon in "mp/itemTable.csv" and ui_mp/scriptmenus/dr_weapons.menu for it to appear in the weapons menu.

* Images
I use imgXiwi most of the time when adding images, if you want to add a new image you have to remember to make a new material for it and add the material into the "mod.csv"

You can download my imgXiwi folder for deathrun here: http://www.mediafire.com/folder/qepqxzbeiv6be/imgXiwi_deathrun

* Menus
Adding new menus is the same as in CoD4.
Remember to precache the menus.

* Gsc
Adding new gsc is the same as in CoD4.

<hr>

Maps
====
You can download the usermaps that I have ported for the mod here: https://www.mediafire.com/folder/rupkj2mfzn0uc/usermaps

Additionally, if you wish to port some maps yourself here are 2 Tutorials:
*Custom_Triggers ( recommended )
https://youtu.be/bl9KNqQKL0c

*Spawnable Triggers ( not recommended )
https://youtu.be/m-9EFl7lX1Y

<hr>

Credits
=======
*	quaK
*	BraXi & Others who worked on Braxi's Deat Run for CoD4
* 	Authors of original Deathrun mod for CS 1.6 for idea
* 	And others, special thanks to mappers...

<hr>

Requirements
============
* Call of Duty: Modern Warfare 2 (base game)
* IW4x (iw4x files)
* IW4x.dll (custom dll can be found in releases)
