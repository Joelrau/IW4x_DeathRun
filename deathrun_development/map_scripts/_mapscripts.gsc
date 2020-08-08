init( map )
{
	//
	//	INFO:
	//
	//	this is for debugging the map without having to place the scripts into the usermaps iwd file.
	//	once you are done, place the mapscript.gsc and mp_dr/deathrun_mapname folder to the iwd file.
	//
	//	you can also build the map.ff with _triggers.gsc threaded from map.gsc.
	//
	//	EXAMPLE:
	//	
	//	maps_scripts\_mapscripts.gsc:
	//	
	//	case "mp_deathrun_gold":
	//	thread map_scripts\mp_deathrun_gold\_triggers::setupTriggers();
	//	thread map_scripts\mp_deathrun_gold\mp_deathrun_gold::main();
	//	thread ... you can add more scripts.
	//	break;
	//	
	
	switch( map )
	{
		
	}
}