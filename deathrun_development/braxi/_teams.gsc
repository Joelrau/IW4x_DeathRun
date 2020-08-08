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

setPlayerModel( team )
{	
	if(!isDefined(team))
		team = self.pers["team"];
	
	self detachAll();
	if( team == "allies" )
	{
		id = self braxi\_stats::getStats( "dr_character" );

		if( id >= level.numCharacters )
			id = level.numCharacters-1;
		else if( id < 0 )
			id = 0;

		self setModel( level.characterInfo[id]["model"] );
		self setViewModel( level.characterInfo[id]["handsModel"] );
		self attach( level.characterInfo[id]["headModel"] , "", true);
		self.headModel = level.characterInfo[id]["headModel"];
		//self.voice = "american";
	}
	else if( team == "axis" )
	{
		self setModel("mp_body_opforce_arab_assault_a");
		self attach("head_opforce_arab_a", "", true);
		self.headModel = "head_opforce_arab_a";
		self setViewModel("viewhands_militia");
		//self.voice = "taskforce";
	}
}

setWeapon()
{
	self.pers["weapon"] = level.itemInfo[self braxi\_stats::getStats( "dr_weapon" )]["item"];
	self.pers["knife"] = level.knifeInfo[self braxi\_stats::getStats( "dr_knife" )]["item"];
	
	if ( self.pers["team"] == "allies" )
	{
		if (level.trapsDisabled == false)
		{
			self giveWeapon( self.pers["weapon"] );
			self setSpawnWeapon( self.pers["weapon"] );
			self giveMaxAmmo( self.pers["weapon"] );
			self giveWeapon( self.pers["knife"] );
		}
		else
		{
			self giveWeapon( self.pers["knife"] );
			self setSpawnWeapon( self.pers["knife"] );
		}
	}
	if( self.pers["team"] == "axis" )
	{
		if (level.trapsDisabled == false)
		{
			self.pers["knife"] = "tomahawk_mp";
		}
		self giveWeapon( self.pers["knife"] );
		self setSpawnWeapon( self.pers["knife"] );
	}
}

setHealth()
{
	self.maxhealth = 10;
	switch( self.pers["team"] )
	{
	case "allies":
		self.maxhealth = level.dvar["allies_health"];
		break;
	case "axis":
		self.maxhealth = level.dvar["axis_health"];
		break;
	}
	self.health = self.maxhealth;
}

setSpeed()
{
	speed = 1.0;
	switch( self.pers["team"] )
	{
	case "allies":
		speed = level.dvar["allies_speed"];
		break;
	case "axis":
		speed = level.dvar["axis_speed"];
		break;
	}
	self setMoveSpeedScale( speed );
}

setTeam( team )
{	
	if (self.pers["team"] != "spectator")
		if( self.pers["team"] == team )
			return;
	
	if( isAlive( self ) )
		self suicide();
		
	if( team != "spectator" )
		self.statusicon = "hud_status_dead";
	
	self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;

	menu = game["menu_team"];
	self setClientDvars( "g_scriptMainMenu", menu );
}

setSpectatePermissions()
{
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "none", false );
}
