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