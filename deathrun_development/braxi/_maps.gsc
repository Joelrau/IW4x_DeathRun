/*

///////////////////////////////////////////////////////////////
////|         |///|        |///|       |/\  \/////  ///|  |////
////|  |////  |///|  |//|  |///|  |/|  |//\  \///  ////|__|////
////|  |////  |///|  |//|  |///|  |/|  |///\  \/  /////////////
////|          |//|  |//|  |///|       |////\    //////|  |////
////|  |////|  |//|         |//|  |/|  |/////    \/////|  |////
////|  |////|  |//|  |///|  |//|  |/|  |////  /\  \////|  |////
////|  |////|  |//|  | //|  |//|  |/|  |///  ///\  \///|  |////
////|__________|//|__|///|__|//|__|/|__|//__/////\__\//|__|////
///////////////////////////////////////////////////////////////

 ██████╗ ██╗   ██╗ █████╗ ██╗  ██╗
██╔═══██╗██║   ██║██╔══██╗██║ ██╔╝
██║   ██║██║   ██║███████║█████╔╝ 
██║▄▄ ██║██║   ██║██╔══██║██╔═██╗ 
╚██████╔╝╚██████╔╝██║  ██║██║  ██╗
 ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
	
	Original mod by: BraXi;
	Edited mod by: quaK;
	
*/

#include braxi\_common;

getMapNameString( mapName ) 
{
	tokens = strTok( toLower( mapName ), "_" ); // mp 0, deathrun/dr 1, name 2, (optional)version 3

	if( tokens.size < 2  || !tokens.size )
		return mapName;
	
	mapName = "";
	for(i = 2; i < tokens.size; i++)
	{
		mapName = mapName + tokens[i];
		if(i != tokens.size)
			mapName = mapName + " ";
	}
	
	return mapName;
}

init()
{
	if( !isDefined( level.trapTriggers ) )
		wait 0.10; // wait for everything to load
	if( isDefined( level.trapTriggers ) )
	{
		level thread checkTrapUsage();
	}
}

checkTrapUsage()
{
	if( !level.trapTriggers.size )
	{
		warning( "checkTrapUsage() reported that level.trapTriggers.size is -1, add trap activation triggers to level.trapTriggers array and recompile FF" );
		warning( "Map doesn't support free run and XP for activation" );
		return;
	}

	for( i = 0; i < level.trapTriggers.size; i++ )
	{
		if ( level.dvar[ "freeRunChoice" ] == 2 )
		{
			level.trapTriggers[i] thread killFreeRunIfActivated();
		}
		if ( level.dvar[ "giveXpForActivation" ] )
		{
			level.trapTriggers[i] thread giveXpIfActivated();
		}
	}
}

killFreeRunIfActivated()
{
	level endon( "death" );
	level endon( "delete" );
	level endon( "deleted" );
	level endon( "kill_free_run_choice" );

	//level.trapsDisabled
	while( isDefined( self ) )
	{
		self waittill( "trigger", who );
		if( who.pers["team"] == "axis" )
		{
			level.canCallFreeRun = false;
			if( !level.trapsDisabled )
			{
				//who iPrintlnBold( "You have activated trap and now you can't call free run" );
				level notify( "kill_free_run_choice" );
			}
			break;
		}
	}
}

giveXpIfActivated()
{
	level endon( "death" );
	level endon( "delete" );
	level endon( "deleted" );

	while( isDefined( self ) )
	{
		self waittill( "trigger", who );
		if( who.pers["team"] == "axis" )
		{
			if( game["state"] != "playing" )
				return;
			who braxi\_rank::giveRankXP( "trap_activation" );
			break;
		}
	}
}