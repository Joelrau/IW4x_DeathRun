DeathRun 2.1 Mod for IW4x
=========================
Deathrun is a mod in which a single player fights alone against the other team, his only weapons are his deadly traps. <br>
The players on the opposite team have to kill the trapmaster (aka. activator) after finishing his course without dying. <br>

<hr>

The code has been altered heavily to work with [IW4x](https://github.com/IW4x/iw4x-client), you may do as you please with the code. <br>

<hr>

Configuration & Installation
===========================
Prenotes: Whereas "IW4x Root" you should be aware it is the root directory of iw4x installation, also please see "Requirements" section. <br>
Prenotes: ~~You require a custom iw4x.dll for this code to work, see "Requirements" section.~~ You used to need this but as long as you have the latest compiled IW4x dll you should be good to go. <br>

1. [Compile and use the latest iw4x.dll](https://github.com/IW4x/iw4x-client) or replace the original "IW4x Root/iw4x.dll" with the custom iw4x.dll <br>
2. Extract "deathrun_developer" folder to "IW4x Root/mods" <br>
3. Install RektInator's zonetool <br>
3.1 Copy "zonetool" folder in "IW4x Root/mods/deathrun_developer" to "IW4x Root" <br>
3.2 Copy "zonetool/ZoneTool-win32-release.dll" to "IW4x Root" and rename it to "zonetool.dll" <br>
3.3 Open "zonetool/zonetool-binaries-master.zip/zonetool-binaries-master" and copy "zonetool_iw4.exe" to "IW4x Root" and rename it to "zonetool.exe" <br>
4. Build mod_characters.ff <br>
4.1 Copy "zonetool/mod_characters/mod_characters.csv" to "IW4x Root/zone_source" <br>
4.2 Run "IW4x Root/zonetool.exe" and execute "buildzone mod_characters" ( ignore errors about missing images ) <br>
5. Run makeMod.bat to build mod.ff <br>
6. Run makeIWD.bat to build .iwd files <br>
7. [optional] Run runMod.bat to launch your newly compiled mod, you can change launch options (ex. map) by directly editing .bat file <br>

<hr>

Adding new stuff
================
Note: Remember to always run makeMod.bat and makeIWD.bat when adding new stuff. <br>

* Sounds <br>
-I have not been able to add new sounds, so I have replaced native sounds. <br>

* Characters <br>
-I used RektInator's zonetool to dump a cod4 fastfile that had the character in it. After adding the files from the dump into "zonetool/mod_characters" I added the xmodel,xmodel_name to "mod_characters.csv", then I built the mod_characters.ff with RektInator's zonetool. <br>
-Remember to add the xmodel,xmodel_name into the "mod.csv" <br>
-You also have to add the character in "mp/characterTable.csv" and "ui_mp/scriptmenus/dr_characters.menu" for it to appear in the characters menu. <br>

* Weapons <br>
-I followed this tutorial to port weapons from CoD4 to IW4x: https://youtu.be/7nVqZL2fCHw <br>
-Remember to add the xmodel,xmodel_name into the "mod.csv" <br>
-You also have to add the weapon in "mp/itemTable.csv" and "ui_mp/scriptmenus/dr_weapons.menu" for it to appear in the weapons menu. <br>

* Images <br>
-I use imgXiwi most of the time when adding images, if you want to add a new image you have to remember to make a new material for it and add the material into the "mod.csv" <br>
-You can download my imgXiwi folder for deathrun here: http://www.mediafire.com/folder/qepqxzbeiv6be/imgXiwi_deathrun <br>

* Menus <br>
-Adding new menus is the same as in CoD4. <br>
-Remember to precache the menus. <br>

* Gsc <br>
-Adding new gsc is the same as in CoD4. <br>

<hr>

Maps
====
You can download the usermaps that I have ported for the mod here: https://www.mediafire.com/folder/rupkj2mfzn0uc/usermaps <br>

Additionally, if you wish to port some maps yourself here are 2 Tutorials: <br>
* Custom_Triggers ( recommended ) <br>
https://youtu.be/bl9KNqQKL0c <br>

* Spawnable Triggers ( not recommended ) <br>
https://youtu.be/m-9EFl7lX1Y <br>

<hr>

Credits
=======
* quaK <br>
* BraXi & Others who worked on Braxi's Death Run for CoD4 <br>
* Authors of original Deathrun mod for CS 1.6 for idea <br>
* And others, special thanks to mappers... <br>

<hr>

Requirements
============
* Call of Duty: Modern Warfare 2 (base game) <br>
* IW4x (iw4x files) <br>
* IW4x.dll (custom dll can be found in releases) <br>
