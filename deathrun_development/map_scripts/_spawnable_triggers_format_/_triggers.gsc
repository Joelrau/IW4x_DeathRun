/*

WHAT IS THIS:

	You add triggers to the maps here.
	Since iw4x map exporter doesn't support trigger export yet, you need to add them here manually.

EXAMPLE:

	orig = ( 0, 0, 0 ); // Trigger origin. X, Y, Z
	scale = ( 32, 32, 32 ); // Trigger box size. X, Y, Z
	volume = []; volume[0] = orig[0]-scale[0]; volume[1] = orig[1]-scale[1]; volume[2] = orig[2]-scale[2]; volume[3] = orig[0]+scale[0]; volume[4] = orig[1]+scale[1]; volume[5] = orig[2]+scale[2]; // defines the volume..
	trig = spawnTrigger(volume, orig, "trigger_multiple", "targetname", "hintstring", 999); // volume, origin, classname, targetname, hintstring, dmg

*/

#include map_scripts\_spawnable_triggers;

setupTriggers()
{
	
}