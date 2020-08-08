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
#include braxi\_clientdvar;


init()
{
	// new script for fileWrite/Read
}

setupStats()
{
	//prestige
	if( self braxi\_rank::_getPlayerData( "experience" ) == 0 && self getStats( "saved_experience" ) >= level.maxRank && self getStats( "saved_prestige" ) +1 == self braxi\_rank::_getPlayerData( "prestige" ) )
	{
		self setStats( "dr_character", 0 );
		self setStats( "dr_weapon", 0 );
		self setStats( "dr_knife", 0 );
		self setStats( "dr_spray", 0 );
		
		self setStats( "saved_experience", self braxi\_rank::_getPlayerData( "experience" ) );
		self setStats( "saved_prestige", self braxi\_rank::_getPlayerData( "prestige" ) );
	}
	
	//reset
	/*if( self braxi\_rank::_getPlayerData( "experience" ) < self getStats( "saved_experience", "int" ) || self braxi\_rank::_getPlayerData( "prestige" ) < self getStats( "saved_prestige" ) )
	{
		self setStats( "dr_stats", 0 );
	}*/
	
	//first time
	if ( self getStats( "dr_stats", "int" ) != 1 )
	{
		self setStats( "dr_stats", 1 );
		self setStats( "dr_character", 0 );
		self setStats( "dr_weapon", 0 );
		self setStats( "dr_knife", 0 );
		self setStats( "dr_spray", 0 );
		self setStats( "warns", 0 );
		
		self setStats( "saved_experience", 0 );
		self setStats( "saved_prestige", 0 );
	}
	
	self braxi\_rank::_setPlayerData( "experience", self getStats( "saved_experience", "int" ) );
	self braxi\_rank::_setPlayerData( "prestige", self getStats( "saved_prestige", "int" ) );
}

setStats( what, value )
{
	fileLoc = "database/players/" + self getGuid() + "/" + what;
	fileWrite(fileLoc, value, "write");
}

getStats( what, type )
{
	fileLoc = "database/players/" + self getGuid() + "/" + what;
	if(fileExists(fileLoc) == false)
		return 0;
	
	stat = fileRead(fileLoc);
	
	if( !isDefined( type ) )
		type = "int";
	
	if( type == "int" )	
		return int(stat);
	else if( type == "string" )
		return stat;
}

resetStats()
{
	self setStats( "dr_stats", 0 );
	self clientCmd( "disconnect; wait 1; resetStats" );
}

/* OLD 2 SCRIPT (using for 0.6.0) */

/*init()
{
	//use old script if there are any problems with the script
	//old script will only save stats per map. so every new map people have to customize their characters again.
	
	level waittill( "game over" );
	saveAllStats();
}

setupStats()
{
	if( self braxi\_rank::_getPlayerData( "experience" ) < self getStats( "saved_experience", "int" ) )
		self setStats( "dr_stats", 0 );
	
	if ( self getStats( "dr_stats", "int" ) != 1 )
	{
		self setStats( "dr_stats", 1 );
		self setStats( "dr_character", 0 );
		self setStats( "dr_knife", 0 );
		self setStats( "dr_weapon", 0 );
		self setStats( "dr_spray", 0);
		self setStats( "warns", 0 );
		
		self setStats( "saved_experience", self braxi\_rank::_getPlayerData( "experience" ) );
		self setStats( "saved_prestige", self braxi\_rank::_getPlayerData( "prestige" ) );
	}
}

setStats( what, value )
{
	_setClientDvar( self, what, value );
}

getStats( what, type )
{
	if( !isDefined( type ) )
		type = "int";
	
	return _getClientDvar( self, what, type );
}

saveAllStats()
{
	logPrint( "\n===== BEGIN STATS =====\n" + "set dr_stats " + "\"" + getDvar("dr_stats") + "\"" + "\n" + "set dr_character " + "\"" + getDvar("dr_character") + "\"" + "\n" + "set dr_knife " + "\"" + getDvar("dr_knife") + "\"" + "\n" + "set dr_weapon " + "\"" + getDvar("dr_weapon") + "\"" + "\n" + "set warns " + "\"" + getDvar("warns") + "\"" + "\n" + "set saved_experience " + "\"" + getDvar("saved_experience") + "\"" + "\n===== END STATS =====\n" );
}*/

/* OLD SCRIPT
init()
{
	if (!isDefined(game["stats"]))
		game["stats"] = [];
}

setupStats()
{
	if (statsContain( "name", self.name ) && statsContain( "guid", self.guid ))
	{
		self restoreStats();
		return;
	}
	
	size = game["stats"].size;
	game["stats"][size]["id"] = size;
	game["stats"][size]["name"] = self.name;
	game["stats"][size]["guid"] = self.guid;
	game["stats"][size]["warns"] = 0;
	game["stats"][size]["dr_character"] = 0;
	game["stats"][size]["dr_weapon"] = 0;
	self.connectedID = game["stats"][size]["id"];
	
	//iPrintLnBold(self.connectedID);
}

setStats( what, value )
{
	game["stats"][self.connectedID][what] = value;
}

getStats( what )
{
	return game["stats"][self.connectedID][what];
}

statsContain( what, value )
{
	for(i = 0; i < game["stats"].size; i++)
	{
		if (game["stats"][i][what] == value)
			return true;
	}
	return false;
}

restoreStats()
{
	for (i = 0; i < game["stats"].size; i++)
	{
		if (game["stats"][i]["name"] == self.name && game["stats"][i]["guid"] == self.guid)
			self.connectedID = game["stats"][i]["id"];
	}	
}
*/