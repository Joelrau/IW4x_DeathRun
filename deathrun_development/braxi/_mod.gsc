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

 ██████╗ ██╗   ██╗ █████╗ ██╗  ██╗o
██╔═══██╗██║   ██║██╔══██╗██║ ██╔╝
██║   ██║██║   ██║███████║█████╔╝ 
██║▄▄ ██║██║   ██║██╔══██║██╔═██╗ 
╚██████╔╝╚██████╔╝██║  ██║██║  ██╗
 ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
	
	Original mod by: BraXi;
	Edited mod by: quaK;
	
*/

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

#include braxi\_common;
#include braxi\_dvar;

main()
{

	braxi\_dvar::setupDvars(); // all dvars are there
	precache();
	init_spawns();
	braxi\_cod4stuff::main(); // setup vanilla cod4 variables

	game["DeathRunVersion"] = 22;
	level.mapName = toLower( getDvar( "mapname" ) );
	level.jumpers = 0;
	level.activators = 0;
	level.activatorKilled = false;
	level.freeRun = false;
	level.allowSpawn = true;
	level.colliders = [];
	level.trapsDisabled = false;
	level.canCallFreeRun = true;
	level.color_cool_green = ( 0.8, 2.0, 0.8 );
	level.color_cool_green_glow = ( 0.3, 0.6, 0.3 );
	level.hudYOffset = 10;
	level.firstBlood = false;
	level.lastJumper = false;
	level.mapHasTimeTrigger = false;

	if( !isDefined( game["roundsplayed"] ) )
		game["roundsplayed"] = 1;
	game["roundStarted"] = false;
	game["state"] = "readyup";
	
	level.dvar["playedrounds"] = game["roundsplayed"];
	
	if( game["roundsplayed"] == 1 )
	{
		game["playedmaps"] = strTok( level.dvar["playedmaps"], ";" );
		addMap = true;
		if( game["playedmaps"].size )
		{
			for( i = 0; i < game["playedmaps"].size; i++ )
			{
				if( game["playedmaps"][i] == level.mapName )
				{
					addMap = false;
					break;
				}
			}
		}
		if( addMap )
		{
			appendToDvar( "dr_playedmaps", level.mapName+";" );
			level.dvar["playedmaps"] = getDvar( "dr_playedmaps" );
			game["playedmaps"] = strTok( level.dvar["playedmaps"], ";" ); //update
		}

		if( level.dvar["freerun"] )
			level.freeRun = true;
	}

	setDvar( "jump_slowdownEnable", 0 );
	setDvar( "bullet_penetration_enabled", 0 );
	setDvar( "aim_automelee_enabled", 1 ); // automelee ( like aim assist for knifing )
	setDvar( "aim_automelee_range", 64 ); // automelee range
	setDvar( "player_meleeRange", 64 ); // default knife range
	setDvar( "bg_fallDamageMaxHeight", "300" ); // default falldmg max height
	setDvar( "bg_fallDamageMinHeight", "128" ); // default falldmg min height
	setDvar( "g_garvity", "800" ); // default gravity
	setDvar( "jump_height", "39" ); // default jump height
	setDvar( "sv_enableBounces", "1" ); // IW4x bounce enable 
	setDvar( "mod_author", "BraXi, quaK" );
	makeDvarServerInfo( "mod_author", "BraXi, quaK" );
	
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	//thread maps\mp\gametypes\_healthoverlay::init();//level.healthRegenDisabled = true;
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_quickmessages::init();
	thread maps\mp\perks\_perks::init();
	
	thread map_scripts\_mapscripts::init( level.mapName );
	
	thread braxi\_admin::main();
	thread braxi\_stats::init();
	thread braxi\_rank::init();
	thread braxi\_sounds::init();
	thread braxi\_menus::init();
	thread braxi\_scoreboard::init();
	thread braxi\_mapvoting::init();
	thread braxi\_playercard::init();
	thread braxi\_maps::init();
	
	bestMapScores();
	
	havingTroubleStartingMod = false; // if mp/characterTable, mp/itemTable, mp/knifeTable, mp/sprayTable aren't loaded the game will freeze
	if(havingTroubleStartingMod == false) 
	{
		buildCharacterInfo();
		buildItemInfo();
		buildKnifeInfo();
		buildSprayInfo();
	}
	
	level thread gameLogic();
	level thread doHud();
	level thread serverMessages();

	level thread firstBlood();
	level thread fastestTime();
	
	level thread noDoubleMusic();
	level thread forceDeath();
	level thread shittyRenderer();
	
	level thread sayCommand( "#" ); // has to be the size of 1 char!
	
	//level thread test();

	visionSetNaked( level.mapName, 0 );

	if( level.dvar["usePlugins"] )
	{
		println( "Initializing plugins..." );
		thread plugins\_plugins::main();
		println( "Plugins initialized" );
	}
}

sayCommand( commandSymbol )
{
	if(commandSymbol.size != 1)
	{
		printLn("^1Error: braxi/_mod -> sayCommand()^7");
		return;
	}
	level.sayCommandSymbol = commandSymbol;
	while(1)
	{
		level waittill("say", string, player);
		if(string[0] == level.sayCommandSymbol)
		{
			raw = strTok(string, " ");
			raw_command = raw[0];
			command = "";
			for(i = level.sayCommandSymbol.size; i < raw_command.size; i++)
				command += raw_command[i]; // remove sayCommandSymbol
			params = [];
			for(i = 1; i < raw.size; i++)
				params[i - 1] = raw[i]; // remove command
			
			level notify("sayCommand", command, params, player);
			player notify("saidCommand", command, params);
			//iPrintLnBold(command);
		}
	}
}


test()
{
	while(1)
	{
		level waittill("sayCommand", command, player);
		if(toLower(command) == "test")
		{
			//iPrintLnBold("test");
		}
	}
}

/*endmap_trig_test()
{
	level waittill("player_spawn");
	
	text = undefined;
	endmap_trig = undefined;
	if(isDefined(level.endmap_trig))
	{
		endmap_trig = level.endmap_trig;
		text = "^2Updated endmap_trig on this map!^7";
	}
	else
	{
		endmap_trig = getEntArray( "endmap_trig", "targetname" )[0];
		text = "^3There is an endmap_trig on this map!^7";
	}
	if(!isDefined(endmap_trig))
	{
		text = "^1There is no endmap_trig on this map!^7";
	}
	
	iPrintLnBold( text );
	
	if(!isDefined(endmap_trig))
		return;
	
	while(1)
	{
		endmap_trig waittill("trigger", player);
		player iPrintLnBold("triggered");
		wait 0.05;
	}
}*/

/*shittyRendererOLD() // DO NOT USE
{
	while(1)
	{
		brushes = getEntArray("script_brushmodel", "classname");
		for(i = 0; i < brushes.size; i++)
		{
			brush = brushes[i];
			brush hide();
		}
		wait 0.005;
		for(i = 0; i < brushes.size; i++)
		{
			brush = brushes[i];
			brush show();
		}
		wait 0.005;
	}
}*/

shittyRenderer() // Sometimes IW4x doesn't render moving/rotating brushmodels properly. This "fixes" that.
{
	level waittill("connected");
	brushes = getEntArray("script_brushmodel", "classname");
	for(i = 0; i < brushes.size; i++)
	{
		brush = brushes[i];
		brush thread shittyRendererBrushMove();
		brush thread shittyRendererBrushRotate();
	}
}

shittyRendererBrushMove()
{
	while(isDefined(self))
	{
		origin = self.origin;
		while(origin == self.origin)
			wait 0.05;
		
		self waittill("movedone");
		self moveTo(self.origin, 0.05);
		wait 15;
	}
}

shittyRendererBrushRotate()
{
	while(isDefined(self))
	{
		angles = self.angles;
		while(angles == self.angles)
			wait 0.05;
		
		self waittill("rotatedone");
		self rotateTo(self.angles, 0.05);
		wait 15;
	}
}

precache()
{
	level.text = [];
	level.fx = [];

	_precacheModel( "tag_origin" );
	
	_precacheItem( "defaultweapon_mp" );		// Default Weapon
	_precacheItem( "claymore_mp" );				// Insertion item
	_precacheItem( "tomahawk_mp" );				// Activator knife
	
	_precacheModel( "mp_body_desert_tf141_assault_a" );		// Activator model
	_precacheModel( "head_hero_price_desert" );				// Activator model
	_precacheModel( "viewmodel_hands_zombie" );				// Activator model

	_precacheMenu( "clientcmd" );
	
	_precacheShader( "black" );
	_precacheShader( "white" );
	_precacheShader( "killiconsuicide" );
	_precacheShader( "killiconmelee" );
	_precacheShader( "killiconheadshot" );
	_precacheShader( "killiconfalling" );
	_precacheShader( "stance_stand" );
	_precacheShader( "hudstopwatch" );
	_precacheShader( "ui_host" );
	_precacheShader( "HINT_FRIENDLY" );
	
	_precacheShader( "splatter_alt" );

	_precacheStatusIcon( "hud_status_connecting" );
	_precacheStatusIcon( "hud_status_dead" );
	
	level.text["round_begins_in"] = &"BRAXI_ROUND_BEGINS_IN";
	level.text["waiting_for_players"] = &"BRAXI_WAITING_FOR_PLAYERS";
	//level.text["spectators_count"] = &"BRAXI_SPECTATING1";
	level.text["jumpers_count"] = &"BRAXI_ALIVE_JUMPERS";
	level.text["call_freeround"] = &"BRAXI_CALL_FREEROUND";

	_precacheString( level.text["round_begins_in"] );
	_precacheString( level.text["waiting_for_players"] );
	//_precacheString( level.text["spectators_count"] );
	_precacheString( level.text["jumpers_count"] );
	_precacheString( level.text["call_freeround"] );
	_precacheString( &"Your Time: ^2&&1" );
	
	level.fx["falling_teddys"] = loadFX( "deathrun/falling_teddys" );
	level.fx["gib_splat"] = loadFX( "deathrun/gib_splat" );
}

init_spawns()
{
	level.spawn = [];
	level.spawn["allies"] = getEntArray( "mp_jumper_spawn", "classname" );
	level.spawn["axis"] = getEntArray( "mp_activator_spawn", "classname" );
	level.spawn["spectator"] = getEntArray( "mp_global_intermission", "classname" )[0];

	if( !level.spawn["allies"].size ) // try to use diferent spawn points if not found vaild mod spawns on map
		level.spawn["allies"] = getEntArray( "mp_dm_spawn", "classname" );
	if( !level.spawn["axis"].size )
		level.spawn["axis"] = getEntArray( "mp_tdm_spawn", "classname" );

	for( i = 0; i < level.spawn["allies"].size; i++ )
		level.spawn["allies"][i] placeSpawnPoint();

	for( i = 0; i < level.spawn["axis"].size; i++ )
		level.spawn["axis"][i] placeSpawnPoint();
}

buildCharacterInfo()
{
	level.characterInfo = [];
	level.numCharacters = 0;
	
	tableName = "mp/characterTable.csv";

	for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.characterInfo[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.characterInfo[id]["shader"] = tableLookup( tableName, 0, idx, 3 );
		level.characterInfo[id]["model"] = tableLookup( tableName, 0, idx, 4 );
		level.characterInfo[id]["handsModel"] = tableLookup( tableName, 0, idx, 5 );
		level.characterInfo[id]["name"] = tableLookup( tableName, 0, idx, 6 );
		level.characterInfo[id]["desc"] = tableLookup( tableName, 0, idx, 7 );
		level.characterInfo[id]["headModel"] = tableLookup ( tableName, 0, idx, 8);
		
		_precacheShader( level.characterInfo[id]["shader"] );
		_precacheModel( level.characterInfo[id]["model"] );
		_precacheModel( level.characterInfo[id]["handsModel"] );
		_precacheModel( level.characterInfo[id]["headModel"] );
		level.numCharacters++;
	}
}

buildItemInfo()
{
	level.itemInfo = [];
	level.numItems = 0;
	
	tableName = "mp/itemTable.csv";

	for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.itemInfo[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.itemInfo[id]["shader"] = tableLookup( tableName, 0, idx, 3 );
		level.itemInfo[id]["item"] = (tableLookup( tableName, 0, idx, 4 ) + "_mp");
		level.itemInfo[id]["name"] = tableLookup( tableName, 0, idx, 5 );
		level.itemInfo[id]["desc"] = tableLookup( tableName, 0, idx, 6 );
		
		_precacheShader( level.itemInfo[id]["shader"] );
		_precacheItem( level.itemInfo[id]["item"] );
		level.numItems++;
	}
}

buildKnifeInfo()
{
	level.knifeInfo = [];
	level.numKnifes = 0;
	
	tableName = "mp/knifeTable.csv";

	for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.knifeInfo[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.knifeInfo[id]["shader"] = tableLookup( tableName, 0, idx, 3 );
		level.knifeInfo[id]["item"] = (tableLookup( tableName, 0, idx, 4 ) + "_mp");
		level.knifeInfo[id]["name"] = tableLookup( tableName, 0, idx, 5 );
		level.knifeInfo[id]["desc"] = tableLookup( tableName, 0, idx, 6 );
		
		_precacheShader( level.knifeInfo[id]["shader"] );
		_precacheItem( level.knifeInfo[id]["item"] );
		level.numKnifes++;
	}
}

buildSprayInfo()
{
	level.sprayInfo = [];
	level.numSprays = 0;
	
	tableName = "mp/sprayTable.csv";

	for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
	{
		id = int( tableLookup( tableName, 0, idx, 1 ) );
		level.sprayInfo[id]["rank"] = (int(tableLookup( tableName, 0, idx, 2 )) - 1);
		level.sprayInfo[id]["shader"] = tableLookup( tableName, 0, idx, 3 );
		level.sprayInfo[id]["effect"] = loadFX( tableLookup( tableName, 0, idx, 4 ) );
		
		_precacheShader( level.sprayInfo[id]["shader"] );
		level.numSprays++;
	}
}

healthOverlay()
{
	//self setClientDvar("cg_drawSplatter", 1); // better splatter // mw2 splatter disabled in ui_mp/hud_fullscreen
	self setClientDvar("painVisionTriggerHealth", 0); // no .vision change
	
	splatter_overlay = newClientHudElem( self );
	splatter_overlay.x = 640/2;
	splatter_overlay.y = 480/2;
	splatter_overlay setShader( "splatter_alt", 640, 480 );
	splatter_overlay.alignX = "center";
	splatter_overlay.alignY = "middle";
	splatter_overlay.horzAlign = "fullscreen";
	splatter_overlay.vertAlign = "fullscreen";
	splatter_overlay.alpha = 0;
	
	flash_overlay = newClientHudElem( self );
	flash_overlay.x = 640/2;
	flash_overlay.y = 480/2;
	flash_overlay setShader( "white", 640, 480 );
	flash_overlay.alignX = "center";
	flash_overlay.alignY = "middle";
	flash_overlay.horzAlign = "fullscreen";
	flash_overlay.vertAlign = "fullscreen";
	flash_overlay.color = (1,0,0);
	flash_overlay.alpha = 0;
	
	savedHealth = 0;
	dangerHealth = 100;
	
	lastHealth = 999;
	for(;;)
	{
		//self waittill("damage");
		if(self.health == lastHealth)
		{
			wait 0.05;
			continue;
		}
		if(self.health > lastHealth)
		{
			lastHealth = self.health;
			continue;
		}
		takenDmg = lastHealth - self.health;
		takenPercent = takenDmg / self.maxhealth;
		lastHealth = self.health;
		
		if(self.health <= 0)
			continue;
			
		if(takenPercent < 0.2)
			takenPercent = 0.2;
		
		self thread healthOverlayFlash( flash_overlay, takenPercent );
		
		dangerHealth = self.maxhealth / 3;
		if(self.health > dangerHealth)
			continue;
		
		savedHealth = self.health;
		
		self playLocalSound("breathing_hurt");
		splatter_overlay fadeOverTime( 1 );
		splatter_overlay.alpha = 1;
		for(i = 0; i < 100; i++)
		{
			if(self.health != savedHealth)
			{
				savedHealth = self.health;
				lastHealth = self.health;
				i = 0;
			}
			if(self.health <= 0)
				break;
			
			wait 0.05;
		}
		if(self.health > 0)
		{
			self playLocalSound("breathing_better");
			splatter_overlay fadeOverTime( 2 );
		}
		splatter_overlay.alpha = 0;
		
		lastHealth = self.health;
	}
}

healthOverlayFlash( flash_overlay, takenPercent )
{
	flash_overlay fadeOverTime( 0.05 );
	flash_overlay.alpha = takenPercent;
	for(i = 0; i < 5; i++)
	{
		if(self.health <= 0)
			break;
		wait 0.05;
	}
	if(self.health > 0)
		flash_overlay fadeOverTime( 0.2 );
	flash_overlay.alpha = 0;
}

forceRagdoll()
{
	self notify ("stopforceragdoll");
	self endon ("stopforceragdoll");
	for(;;)
	{
		self setClientDvar("ragdoll_enable", 1);
		wait 0.5;
	}
}

forceDeath()
{
	while(1)
	{
		players = getAllPlayers();
		for(i=0;i<players.size;i++)
		{
			player = players[i];
			if(player.health <= 0 && player isActuallyAlive())
				player suicide();
		}
		wait 0.05;
	}
}

playerConnect() // Called when player is connecting to server
{
	level notify( "connected", self );
	self thread cleanUp();
	self.guid = self getGuid();
	self.number = self getEntityNumber();
	self.statusicon = "hud_status_connecting";
	self.died = false;
	self.doingNotify = false; //for hud logic

	if( !isDefined( self.name ) )
		self.name = "undefined name";
	if( !isDefined( self.guid ) )
		self.guid = "undefined guid";
	
	self braxi\_stats::setupStats();

	// we want to show hud and we get an IP adress for "add to favourities" menu
	self setClientDvars( "show_hud", "true", "ip", getDvar("net_ip"), "port", getDvar("net_port") );
	if( !isDefined( self.pers["team"] ) )
	{
		if( level.dvar["show_guids"] )
			iPrintLn( self.name + " ^2[" + getSubStr( self.guid, 24, 32 ) + "^2] ^7entered the game" );
		else
			iPrintLn( self.name + " ^7entered the game" );

		self.sessionstate = "null";
		self.team = "none";
		self.pers["team"] = "none";
		
		self.pers["score"] = 0;
		self.pers["kills"] = 0;
		self.pers["deaths"] = 0;
		self.pers["assists"] = 0;
		self.pers["lifes"] = 0;
		self.pers["headshots"] = 0;
		self.pers["knifes"] = 0;
		self.pers["activator"] = 0;
		self.pers["time"] = 99999999;

		self.pers["ability"] = "specialty_null";
	}
	else
	{
		self.score = self.pers["score"];
		self.kills = self.pers["kills"];
		self.assists = self.pers["assists"];
		self.deaths = self.pers["deaths"];
	}
	
	self setClientDvar("drui_character", braxi\_stats::getStats("dr_character"));
	self setClientDvar("drui_weapon", braxi\_stats::getStats("dr_weapon"));
	self setClientDvar("drui_knife", braxi\_stats::getStats("dr_knife"));
	self setClientDvar("drui_spray", braxi\_stats::getStats("dr_spray"));
	
	self thread healthOverlay();
	self thread forceRagdoll();
	self thread SetupLives();

	if(!isDefined(level.spawn["spectator"]))
		level.spawn["spectator"] = level.spawn["allies"][0];
		
	if( game["state"] == "endmap" )
	{
		self spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		self.sessionstate = "intermission";
		return;
	}

	if( isDefined(self.pers["weapon"]) && self.pers["team"] != "spectator" && level.allowSpawn )
	{
		self thread braxi\_teams::setTeam( "allies" );
		self spawnPlayer();
		return;
	}
	else
	{
		self spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		self thread delayedMenu();
		logPrint("J;" + self.guid + ";" + self.number + ";" + self.name + "\n");
	}

	self setClientDvars( "r_lodScaleRigid", 1, "r_lodScaleSkinned", 1, "r_lodBiasRigid", -1000, "r_lodBiasSkinned", -1000 ); // Better lods
}

playerDisconnect() // Called when player disconnect from server
{
	level notify( "disconnected", self );
	self thread cleanUp();
	self thread destroyLifeIcons();

	if( !isDefined( self.name ) )
		self.name = "no name";

	if( level.dvar["show_guids"] )
		iPrintLn( self.name + " ^2[" + getSubStr( self getGuid(), 24, 32 ) + "^2] ^7left the game" );
	else
		iPrintLn( self.name + " ^7left the game" );

	logPrint("Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n");
}


PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self suicide();
}

PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if( isPlayer( self ) && isAlive(self) == false )
		return;
		
	if( self.sessionteam == "spectator" || game["state"] == "endmap" )
		return;
		
	if( isPlayer( eAttacker ) && eAttacker.pers["team"] == self.pers["team"] )
		return;

	if( isPlayer( eAttacker ) && sMeansOfDeath == "MOD_MELEE" && isWallKnifing( eAttacker, self ) )
		return;
	
	if( sMeansOfDeath == "MOD_FALLING" && self getNoFallDamage() == true )
		return;
	
	if( isGhost( eAttacker ) )
	{
		eAttacker suicide();
		return;
	}

	level notify( "player_damage", self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	// damage modifier
	if( sMeansOfDeath != "MOD_MELEE" )
	{
		if( isPlayer( eAttacker ) && eAttacker.pers["ability"] == "specialty_bulletdamage" )
			iDamage = int( iDamage * 1.1 );

		modifier = getDvarFloat( "dr_damageMod_" + sWeapon );
		if( modifier <= 2.0 && modifier >= 0.1 && sMeansOfDeath != "MOD_MELEE" )
			iDamage = int( iDamage * modifier );
	}

	if( level.dvar["damage_messages"] && isPlayer( eAttacker ) && eAttacker != self )
	{	
		eAttacker iPrintLn( "You hit " + self.name + " ^7for ^2" + iDamage + " ^7damage." );
		self iPrintLn( eAttacker.name + " ^7hit you for ^2" + iDamage + " ^7damage." );
	}
	if ( level.dvar["damage_hitmarkers"] )
	{
		eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("hitmarker");
	}

	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(iDamage < 1)
			iDamage = 1;

		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, 0 );
	}
}

PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self endon("spawned");
	self notify("killed_player");
	self notify("death");

	if(self.sessionteam == "spectator" || game["state"] == "endmap" )
		return;

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	if( level.dvar[ "giveXpForKill" ] && !level.trapsDisabled )		
	{
		if( isDefined( level.activ ) && level.activ != self && level.activ isReallyAlive() && !isGhost( self ) )	
			if( sMeansOfDeath == "MOD_UNKNOWN" || sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" )
				level.activ braxi\_rank::giveRankXP( "jumper_died" );
	}

	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
	{
		sMeansOfDeath = "MOD_HEAD_SHOT";
	}
	
	body = self clonePlayer( 120 );
	body.targetname = "dr_deadbody";
	
	if( level.dvar["gibs"] && iDamage >= self.maxhealth && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_RIFLE_BULLET" && sMeansOfDeath != "MOD_PISTOL_BULLET" && sMeansOfDeath != "MOD_SUICIDE" && sMeansOfDeath != "MOD_HEAD_SHOT" )
		body gib_splat();
	else if ( level.dvar["deathsound"] )
		self playDeathSound();

	if( isDefined( body ) )
	{
		body startRagDoll();
	}
	
	self.statusicon = "hud_status_dead";
	self.sessionstate =  "spectator";

	if( isPlayer( attacker ) )
	{
		if( attacker != self )
		{
			braxi\_rank::processXpReward( sMeansOfDeath, attacker, self );

			attacker.kills++;
			attacker.pers["kills"]++;

			if( self.pers["team"] == "axis" )
			{
				attacker giveLife();
			}
		}
	}

	if( !level.freeRun && !isGhost( self ) )
	{
		deaths = self braxi\_rank::_getPlayerData( "deaths" );
		self braxi\_rank::_setPlayerData( "deaths", deaths+1 );
		self.deaths++;
		self.pers["deaths"]++;
	}
	self.died = true;

	self thread cleanUp();

	obituary( self, attacker, sWeapon, sMeansOfDeath );

	if( self.pers["team"] == "axis" )
	{
		if( isPlayer( attacker ) && attacker.pers["team"] == "allies" )
		{
			text = ( attacker.name + " ^7killed Activator" );
			thread drawInformation( 800, 0.8, 1, text );
			thread drawInformation( 800, 0.8, -1, text );
		}

		level.activatorKilled = true;
		self thread braxi\_teams::setTeam( "allies" );
	}

	if( self.pers["team"] != "axis" )
	{
		self thread respawn();
	}
}

spawnPlayer( origin, angles )
{
	waittillframeend;
	if( game["state"] == "endmap" || self.pers["team"] == "spectator" ) 
		return;

	level notify( "jumper", self );
	self thread cleanUp();
	resettimeout();

	self.team = self.pers["team"];
	self.sessionteam = self.team;
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";

	if( isDefined( origin ) && isDefined( angles ) )
		self spawn( origin,angles );
	else
	{
		spawnPoint = level.spawn[self.pers["team"]][randomInt(level.spawn[self.pers["team"]].size)];
		self spawn( spawnPoint.origin, spawnPoint.angles );
	}

	//self SetActionSlot( 1, "nightvision" );
	
	self thread braxi\_teams::setPlayerModel();
	self thread braxi\_teams::setWeapon();
	self thread braxi\_teams::setHealth();
	self thread braxi\_teams::setSpeed();
	self thread afterFirstFrame();

	self notify( "spawned_player" );
	level notify( "player_spawn", self );
}

spawnSpectator( origin, angles )
{
	if( !isDefined( origin ) )
		origin = (0,0,0);
	if( !isDefined( angles ) )
		angles = (0,0,0);

	self notify( "joined_spectators" );

	self thread cleanUp();
	resettimeout();
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.statusicon = "";
	self spawn( origin, angles );
	self braxi\_teams::setSpectatePermissions();
	self braxi\_teams::setTeam("spectator");

	level notify( "player_spectator", self );
}

afterFirstFrame()
{
	self endon( "disconnect" );
    self endon( "joined_spectators" );
    self endon( "death" );
	waittillframeend;

	if( !self isPlaying() )
		return;

	if( game["state"] == "readyup" )
	{
		self _freezeControls(true);
		self disableWeapons();
	}
	else
	{
		self thread antiAFK();
	}

	if( self.pers["team"] == "allies" )
	{
	}
	else
	{
		self thread freeRunChoice();
	}

	// give special ability
	self clearPerks();
	self.pers["ability"] = "specialty_null";
	if( self.pers["ability"] != "specialty_null" && self.pers["ability"] != "" )
	{
		self setPerk( self.pers["ability"] );
	}
	
	self thread watchItems();
	self thread playerTimer();
	self thread bunnyHoop();
	self thread sprayLogo();
	
	self thread ejectFaster( 60 );
}

ejectFaster( amount )
{
	self setClientDvar( "g_playerCollisionEjectSpeed", amount );	
}

bunnyHoop()
{
    self endon( "disconnect" );
    self endon( "spawned_player" );
    self endon( "joined_spectators" );
    self endon( "death" );

    while( game["state"] != "playing" )
		wait 0.05;

    if( !level.dvar["bunnyhoop"] )
        return;
	
	self.bh = 0;
	self.bhOldOrigin = (0,0,0);

    while( isAlive( self ) )
    {
		wait 0.05;
        stance = self getStance();
        useButton = self useButtonPressed();
        onGround = self isOnGround();
        fraction = bulletTrace( self getEye(), self getEye() + vector_scale(anglesToForward(self.angles), 32 ), true, self )["fraction"];
        
        // Begin
        if( !self.doingBH && useButton && !onGround && fraction == 1 )
        {
            self.doingBH = true;
        }

        // Accelerate
        if( self.doingBH && useButton && onGround && fraction == 1 )
        {
			if (stance == "crouch" || stance == "stand")
			{
				if( self.bh < 200 )
					self.bh += 50;
			}
        }

        // Finish
        if( self.doingBH && !useButton || self.doingBH && stance != "crouch" && stance != "stand" || self.doingBH && fraction < 1 )
        {
            self.doingBH = false;
            self.bh = 0;
            continue;
        }

        // Bounce
        if( self.bh && self.doingBH && onGround && fraction == 1 )
        {
			X = anglesToForward( self.angles );
			a = X[0] * self.bh;
			b = X[1] * self.bh;
			c = X[2] + self.bh + 20;
			XD = (a, b, c);
			
			if (level.dvar["bunnyhoop_lagjump_fix"] == 1)
			{
				if (self.origin != self.bhOldOrigin) // fixes lagjumping
				{
					self bounce( XD );
					self.bhOldOrigin = self.origin;
				}
			}
			else
				self bounce( XD );
			
            wait 0.1;
        }
    }
}

sprayLogo()
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );
	self endon( "death" );
	
	if( !level.dvar["sprays"] )
		return;
	
	while( game["state"] != "playing" )
		wait 0.05;

	while( self isActuallyAlive() )
	{
		while( !self fragButtonPressed() )
			wait .2;

		if( !self isOnGround() )
		{
			wait 0.2;
			continue;
		}

		angles = self getPlayerAngles();
		eye = self getTagOrigin( "j_head" );
		forward = eye + vector_scale( anglesToForward( angles ), 70 );
		trace = bulletTrace( eye, forward, false, self );
		
		if( trace["fraction"] == 1 ) //we didnt hit the wall or floor
		{
			wait 0.1;
			continue;
		}

		position = trace["position"] - vector_scale( anglesToForward( angles ), -2 );
		angles = vectorToAngles( eye - position );
		forward = anglesToForward( angles );
		up = anglesToUp( angles );

		sprayNum = self braxi\_stats::getStats("dr_spray");

		if( sprayNum < 0 )	
			sprayNum = 0;
		else if( sprayNum > level.numSprays )
			sprayNum = level.numSprays;

		playFx( level.sprayInfo[sprayNum]["effect"], position, forward, up );
		self playSound( level.sounds["sfx"]["sprayer"] );

		self notify( "spray", sprayNum, position, forward, up ); // ch_sprayit

		wait level.dvar["sprays_delay"];
	}
}

isAngleOk( angles, min, max )
{
	diff = distance( angles, self.angles );
	iPrintLn( "diff:" + diff );
	if( diff >= min && diff <= max )
		return true;
	return false;
}

endRound( reasonText, team )
{
	level endon ( "endmap" );

	if( game["state"] == "round ended" || !game["roundStarted"] )
		return;

	level notify( "round_ended", reasonText, team );
	level notify( "endround" );
	level notify( "kill logic" );

	game["state"] = "round ended";
	game["roundsplayed"]++;

	if( isDefined( level.hud_time ) )
		level.hud_time destroy();

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] setClientDvars( "cg_thirdperson", 1, "show_hud", "false" );
	}

	if( team == "jumpers" )
	{
		visionSetNaked( "jumpers", 4 );
	}
	else
	{
		visionSetNaked( "activators", 4 );
		
		if( isDefined( level.activ ) && isPlayer( level.activ ) ) 
			level.activ braxi\_rank::giveRankXp( "activator" );
	}

	if( game["roundsplayed"] >= (level.dvar[ "round_limit" ]+1) )
	{
		level endMap( "Game has ended" );
		return;
	}
	else
	{
		level thread endRoundAnnoucement( reasonText, (0,1,0) );
		if( level.dvar["roundSound"] )
		{
			song = randomIntRange(0,level.sounds["music"]["endround"].size);
			level thread playLocalSoundToAllPlayers( level.sounds["music"]["endround"][song] );	
		}
	}

	wait 10;
	map_restart( true );
}

addTextHud( who, x, y, alpha, alignX, alignY, fontScale )
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.fontScale = fontScale;
	return hud;
}

endRoundAnnoucement( text, color )
{
	notifyData = spawnStruct();
	notifyData.titleText = text;
	notifyData.notifyText = ("Starting round ^3" + game["roundsplayed"] + "^7 out of ^3" + level.dvar["round_limit"] );
	notifyData.glowColor = color;
	notifyData.duration = 8.8;

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
		players[i] thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

cleanUp()
{
	self clearLowerMessage();
	self notify( "kill afk monitor" );
	self setClientDvar( "cg_thirdperson", 0 );
	self unlink();

	self.bh = 0; 
	self.doingBH = false;
	self enableWeapons();

	if( isDefined( self.hud_freeround ) )		self.hud_freeround destroy();
	if( isDefined( self.hud_freeround_time ) )	self.hud_freeround_time destroy();
	if( isDefined( self.hud_time ) )			self.hud_time destroy();
}

gameLogic()
{
	level endon( "endround" );
	level endon( "kill logic" );
	waittillframeend;

	level.allowSpawn = true;

	visionSetNaked( "mpIntro", 0 );
	if( isDefined( level.matchStartText ) )
		level.matchStartText destroyElem();

	wait 0.2;

	level.matchStartText = createServerFontString( "objective", 1.5 );
	level.matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
	level.matchStartText.sort = 1001;
	level.matchStartText setText( level.text["waiting_for_players"] );
	level.matchStartText.foreground = false;
	level.matchStartText.hidewheninmenu = true;

	min = 2;
	if( level.freeRun == true )
		min = 1;
		
	waitForEnoughPlayers( min );
	//waitForPlayers( min ); // wait for 2 players to start game
	level notify("round_starting");
	roundStartTimer();
	
	if( !canStartRound( min ) )
	{
		thread restartLogic(); // lets start all over again...
		return;
	}

	level notify( "round_started", game["roundsplayed"] );
	level notify( "game started" );
	game["state"] = "playing";
	game["roundStarted"] = true;

	visionSetNaked( level.mapName, 2.0 );
	
	thread roundDelay();

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] isPlaying() )
		{
			players[i] unlink();
			players[i] _freezeControls(false);
			players[i] thread enableWeaponsDelay( 0.2 );
			players[i] thread antiAFK();
		}
	}

	if( level.freeRun )
	{
		level.hud_time setTimer( level.dvar["freerun_time"] );
		thread freeRunTimer();

		thread drawInformation( 800, 0.8, 1, "FREE RUN" );
		thread drawInformation( 800, 0.8, -1, "FREE RUN" );
		return; //no logic in free run
	}
	else
	{
		level thread restrictSpawnAfterTime( level.dvar["spawn_time"] );
		level thread checkTimeLimit();

		level.hud_jumpers fadeOverTime( 2 );
		level.hud_jumpers.alpha = 1;
	}

	startJumpers = undefined;
	while( game["state"] == "playing" )
	{
		wait 0.2;

		level.jumper = [];
		level.jumpers = 0;
		level.activators = 0;
		level.totalPlayers = 0;
		level.totalPlayingPlayers = 0;

		players = getAllPlayers();
		if(players.size > 0)
		{
			for(i = 0; i < players.size; i++)
			{
				level.totalPlayers++;

				if( isDefined( players[i].pers["team"] ) )	
				{
					if( players[i] isActuallyAlive() )
						level.totalPlayingPlayers++;

					if(players[i].pers["team"] == "allies" && players[i] isActuallyAlive() )
					{
						level.jumpers++;
						level.jumper[level.jumper.size] = players[i];
					}
					if(players[i].pers["team"] == "axis" && players[i] isActuallyAlive() )
						level.activators++;
				}
			}		
			
			if( !isDefined( startJumpers ) )
				startJumpers = level.jumpers;

			if( startJumpers >= 3 && level.jumpers == 1 && !level.freeRun )
				level.jumper[0] thread lastJumper();

			if( level.jumpers > 1 && !level.activators && !level.activatorKilled && !level.freeRun )
			{
				if( !level.dvar["pickingsystem"] )
					pickRandomActivator();
				else
					NewPickingSystem();
				continue;
			}

			if( !level.jumpers && level.activators )
				thread endRound( "Jumpers died", "activators" );
			else if( !level.freeRun && !level.activators && level.jumpers )
				thread endRound( "Activator died", "jumpers" );
			else if( !level.activators && !level.jumpers )
				thread endRound( "Everyone died", "activators" );
		}
	}
}

enableWeaponsDelay( waitDur )
{
	if(!isDefined(waitDur))
		waitDur = 0;
	wait waitDur;
	self enableWeapons();
}

roundDelay()
{
	wait 2;
	if (!level.freeRun)
		level.allowConnectedSpawn = false;
}

pickRandomActivator()
{
	level notify( "picking activator" );
	level endon( "picking activator" );

	if( game["state"] != "playing" || level.activatorKilled || level.activators )
		return;

	players = getAllPlayers();
	if( !isDefined( players ) || isDefined( players ) && !players.size )
		return;

	num = randomInt( players.size );
	guy = players[num];

	if( level.dvar["dont_make_peoples_angry"] == 1 && guy getEntityNumber() == getDvarInt( "last_picked_player" ) )
	{	
		if( isDefined( players[num-1] ) && isPlayer( players[num-1] ) )
			guy = players[num-1];
		else if( isDefined( players[num+1] ) && isPlayer( players[num+1] ) )
			guy = players[num+1];
	}
	
	if( !isDefined( guy ) && !isPlayer( guy ) || level.dvar["dont_pick_spec"] && guy.sessionstate == "spectator" )
	{
		level thread pickRandomActivator();
		return;
	}

	bxLogPrint( ("A: " + guy.name + " ; guid: " + guy.guid) );
	iPrintLnBold( guy.name + "^2 was picked to be ^1Activator^2." );
		
	guy thread braxi\_teams::setTeam( "axis" );
	guy spawnPlayer();
	guy braxi\_rank::giveRankXp( "activator" );
		
	setDvar( "last_picked_player", guy getEntityNumber() );
	level notify( "activator", guy );
	level.activ = guy;
	wait 0.1;
}

checkTimeLimit()
{
	level endon( "endround" );
	level endon( "game over" );

	if( !level.dvar["time_limit"] )
		return;

	time = 60 * level.dvar["time_limit"];	
	level.hud_time setTimer( time );
	wait time;	
	level thread endRound( "Time limit reached", "activators" );
}

endMap( winningteam )
{
	game["state"] = "endmap";
	level notify( "intermission" );
	level notify( "game over" );

	setDvar( "g_deadChat", 1 );

	if( isDefined( level.hud_jumpers ) )
		level.hud_jumpers destroy();

	level.hud_round fadeOverTime( 2.6 );
	level.hud_round.alpha = 0;
	wait 3;
	level.hud_round destroy();

	level thread playLocalSoundToAllPlayers( level.sounds["music"]["endmap"] );

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] closeMenu();
		players[i] closeInGameMenu();
		players[i] _freezeControls( true );
		players[i] cleanUp();
		players[i] destroyLifeIcons();

//		players[i] setClientDvar( "cg_thirdpersonangle", randomInt(360), "cg_thirdpersonrange", 120 );
//		if( players[i].sessionstate != "spectator" )
//			players[i] setClientDvar( "cg_thirdperson", 0 );
//		else
//			players[i] setClientDvar( "cg_thirdperson", 1 );
	}
	wait .05;

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		players[i] allowSpectateTeam( "allies", false );
		players[i] allowSpectateTeam( "axis", false );
		players[i] allowSpectateTeam( "freelook", false );
		players[i] allowSpectateTeam( "none", true );
	}

	if( level.dvar["displayBestPlayers"] )
		braxi\_scoreboard::showBestStats();

	saveMapScores();

	wait 0.5;
	
	if( level.dvar["falling_teddys"] )
	{
		FXOrigin = level.spawn["spectator"].origin + vector_scale( anglesToForward( level.spawn["spectator"].angles ), 120 ) + vector_scale( anglesToUp( level.spawn["spectator"].angles ), 180 );
		playFx( level.fx["falling_teddys"], FXOrigin );
		playFx( level.fx["falling_teddys"], level.spawn["spectator"].origin + (0,0,100) );
	}
	
	braxi\_mapvoting::startMapVote();
	braxi\_credits::main();
	
	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		players[i].sessionstate = "intermission";
	}
	wait 5;
	
	if( !level.dvar["mapvote"] )
		exitLevel( false );
	else
		braxi\_mapvoting::changeMap( braxi\_mapvoting::getWinningMap() );
}

respawn()
{
	self endon( "disconnect" );
	//self endon( "spawned_player" );
	//self endon( "joined_spectators" );

	if( level.freeRun || !game["roundStarted"] )
	{
		wait 0.1;
		self spawnPlayer();
		return;
	}

	if( self canReallySpawn() && self.pers["team"] == "allies" )
	{
		wait 0.5;

		if( game["state"] != "playing" )
			return;
		
		//self setLowerMessage( &"PLATFORM_PRESS_TO_SPAWN" );
		if(isDefined(self.spawnedhud))
			self.spawnedhud destroy();
		
		if(!isDefined(self.spawnedhud))
		{
			self.spawnedhud = spawnHUD( 0, 50, "center", "middle", (1,1,1), "objective", 10 );
			self.spawnedhud.fontscale = 1.5;
			self.spawnedhud setText (&"PLATFORM_PRESS_TO_SPAWN");
		}
		
		while( self useButtonPressed() == false && !isAlive(self) )
			wait .05;
			
		if (isDefined(self.spawnedhud))
			self.spawnedhud destroy();

		if( game["state"] != "playing" )
			return;

		self thread useLife();
	}
}

antiAFK()
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );
	self notify( "kill afk monitor" );
	self endon( "kill afk monitor" );

	if( !level.dvar["afk"] || self.pers["team"] == "axis" )
		return;

	time = 0;
	oldOrigin = self.origin - (0,0,50);
	while( isAlive( self ) )
	{
		wait 0.2;
		if( distance(oldOrigin, self.origin) <= 10 )
			time++;
		else
			time = 0;

		if( time == (level.dvar["afk_warn"]*5) )
		{
			if( level.dvar["afk_method"] )
				self iPrintLnBold( "You will be kicked from server due to AFK if you don't move" );
			else
				self iPrintLnBold( "Move or you will be killed due to AFK" );
		}

		if( time == (level.dvar["afk_time"]*5) )
		{
			if( level.dvar["afk_method"] )
			{
				iPrintLn( self.name + " was kicked from server due to AFK." );
				self clientCmd( "disconnect" );
				//kick( self getEntityNumber() );
				self thread kickAfterTime( 2 );
			}
			else
			{
				iPrintLn( self.name + " was killed due to AFK." );
				self suicide();
			}
			break;
		}
		oldOrigin = self.origin;
	}
}

kickAfterTime( time )
{
	self endon( "disconnect" );
	wait time;

	if( isDefined( self ) )
		kick( self getEntityNumber() );
}

roundStartTimer()
{	
	if( isDefined( level.matchStartText ) )
		level.matchStartText destroyElem();
	
	if( isDefined( level.matchStartTimer ) )
		level.matchStartTimer destroyElem();

	level.matchStartText = createServerFontString( "objective", 1.5 );
	level.matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
	level.matchStartText.sort = 1001;
	level.matchStartText setText( level.text["round_begins_in"] );
	level.matchStartText.foreground = false;
	level.matchStartText.hidewheninmenu = true;
	
	level.matchStartTimer = createServerTimer( "objective", 1.4 );
	level.matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	level.matchStartTimer setTimer( level.dvar["spawn_time"] );
	level.matchStartTimer.sort = 1001;
	level.matchStartTimer.foreground = false;
	level.matchStartTimer.hideWhenInMenu = true;
		
	wait level.dvar["spawn_time"];
	
	level.matchStartText destroyElem();
	level.matchStartTimer destroyElem();
}



doHud()
{
	level endon( "intermission" );

	level.hud_round = newHudElem();
    level.hud_round.foreground = true;
	level.hud_round.alignX = "right";
	level.hud_round.alignY = "top";
	level.hud_round.horzAlign = "right";
    level.hud_round.vertAlign = "top";
    level.hud_round.x = 0;
    level.hud_round.y = 20 + level.hudYOffset;
    level.hud_round.sort = 0;
  	level.hud_round.fontScale = 4;
	level.hud_round.color = (0.8, 1.0, 0.8);
	level.hud_round.font = "objective";
	level.hud_round.glowColor = (0.3, 0.6, 0.3);
	level.hud_round.glowAlpha = 1;
//	level.hud_round SetPulseFX( 30, 100000, 700 );//something, decay start, decay duration
 	level.hud_round.hidewheninmenu = false;
	level.hud_round setText( game["roundsplayed"] + "/" + level.dvar["round_limit"] );

	level.hud_time = newHudElem();
    level.hud_time.foreground = true;
	level.hud_time.alignX = "right";
	level.hud_time.alignY = "top";
	level.hud_time.horzAlign = "right";
    level.hud_time.vertAlign = "top";
    level.hud_time.x = 0;
    level.hud_time.y = 60 + level.hudYOffset;
    level.hud_time.sort = 0;
  	level.hud_time.fontScale = 3;
	level.hud_time.color = (0.8, 1.0, 0.8);
	level.hud_time.font = "objective";
	level.hud_time.glowColor = (0.3, 0.6, 0.3);
	level.hud_time.glowAlpha = 1;
 	level.hud_time.hidewheninmenu = false;

	if( level.freeRun )
		return;

	level.hud_jumpers = newHudElem();
    level.hud_jumpers.foreground = true;
	level.hud_jumpers.alignX = "right";
	level.hud_jumpers.alignY = "top";
	level.hud_jumpers.horzAlign = "right";
    level.hud_jumpers.vertAlign = "top";
    level.hud_jumpers.x = -3;
    level.hud_jumpers.y = 95 + level.hudYOffset;
    level.hud_jumpers.sort = 0;
  	level.hud_jumpers.fontScale = 1.6;
	level.hud_jumpers.color = (0.8, 1.0, 0.8);
	level.hud_jumpers.font = "objective";
	level.hud_jumpers.glowColor = (0.3, 0.6, 0.3);
	level.hud_jumpers.glowAlpha = 1;
	level.hud_jumpers.label = level.text["jumpers_count"];
 	level.hud_jumpers.hidewheninmenu = false;
	level.hud_jumpers setValue( 0 );

	while( 1 )
	{
		wait .1;
		level.hud_jumpers setValue( level.jumpers );
	}
}


freeRunChoice()
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );
	self endon( "death" );

	if( !level.dvar["freeRunChoice"] || level.trapsDisabled )
		return;

	self.hud_freeround = newClientHudElem( self );
	self.hud_freeround.elemType = "font";
	self.hud_freeround.x = 320;
	self.hud_freeround.y = 370;
	self.hud_freeround.alignX = "center";
	self.hud_freeround.alignY = "middle";
	self.hud_freeround.alpha = 1;
	self.hud_freeround.font = "default";
	self.hud_freeround.fontScale = 1.8;
	self.hud_freeround.sort = 0;
	self.hud_freeround.foreground = true;
	self.hud_freeround.label = level.text["call_freeround"];

	self.hud_freeround_time = newClientHudElem( self );
	self.hud_freeround_time.elemType = "font";
	self.hud_freeround_time.x = 320;
	self.hud_freeround_time.y = 390;
	self.hud_freeround_time.alignX = "center";
	self.hud_freeround_time.alignY = "middle";
	self.hud_freeround_time.alpha = 1;
	self.hud_freeround_time.font = "default";
	self.hud_freeround_time.fontScale = 1.8;
	self.hud_freeround_time.sort = 0;
	self.hud_freeround_time.foreground = true;
	self.hud_freeround_time setTimer( level.dvar["freeRunChoiceTime"] );

	wait 1;
	freeRun = false;
	for( i = 0; i < 10*level.dvar["freeRunChoiceTime"]; i++ ) // time to switch into free run
	{
		if( !level.canCallFreeRun )
		{
			self.hud_freeround destroy();
			self.hud_freeround_time destroy();
			return;
		}
		if( self attackButtonPressed() )
		{
			freeRun = true;
			level endon( "kill_free_run_choice" );
			break;
		}
		wait 0.1;
	}
	level endon( "kill_free_run_choice" );


	if( isDefined( self.hud_freeround ) )
		self.hud_freeround destroy();
	if( isDefined( self.hud_freeround_time ) )
		self.hud_freeround_time destroy();

	if( freeRun )
	{
		thread drawInformation( 800, 0.8, 1, "FREE RUN" );
		thread drawInformation( 800, 0.8, -1, "FREE RUN" );

		disableTraps();
			
		players = getAllPlayers();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] isPlaying() )
			{
				players[i] braxi\_common::takeWeaponsExcept( players[i].insertionItem );
				players[i] braxi\_teams::setWeapon();
			}
		}
		level notify( "round_freerun" );
	}
}

disableTraps()
{
	level.trapsDisabled = true;
	if ( isDefined( level.trapTriggers ) )
	{
		for( i = 0; i < level.trapTriggers.size; i++ )
		{
			if( isDefined( level.trapTriggers[i] ) )
			{
				if( map_scripts\_spawnable_triggers::isSpawnedTrigger( level.trapTriggers[i] ) )
					level.trapTriggers[i] map_scripts\_spawnable_triggers::disableTrigger();
				else
					level.trapTriggers[i].origin = level.trapTriggers[i].origin - (0,0,10000);
			}
		}
	}
	level notify( "traps_disabled" ); //for mappers
}

serverMessages()
{
	if( !level.dvar["messages_enable"] )
		return;

	messages = strTok( level.dvar["messages"], ";" );
	lastMessage = messages.size-1;
	if( !isDefined( game["msg_time"] ) )	game["msg_time"] = 0;
	if( !isDefined( game["msg"] ) )			game["msg"] = 0;

	while( 1 )
	{
		if( game["msg_time"] == level.dvar["messages_delay"] )
		{
			game["msg_time"] = 0;
			iPrintLn( "^1>>^7 " + messages[game["msg"]] );
			game["msg"]++;
			if( game["msg"] > lastMessage )
				game["msg"] = 0;
		}
		wait 1;
		game["msg_time"]++;
	}
}


isWallKnifing( attacker, victim )
{
	start = attacker getEye();
	end = victim getEye();

	if( bulletTracePassed( start, end, false, attacker ) == 1 )
	{
		return false;
	}
	return true;
}



NewPickingSystem()
{
//
// How it works:
// 1. Build array of players that have lowest number of being activator (starting from 0)
// 2. Check if we got some players in array
//		a) If array size is -1 increase startValue and go back to step 1
//		b) Array size is okey lets go to step 3
// 3. Now pick random player from array to be Activator
//

	level notify( "picking activator" );
	level endon( "picking activator" );

	if( game["state"] != "playing" || level.activatorKilled || level.activators )
		return;

	players = getAllPlayers();
	if( !isDefined( players ) || isDefined( players ) && !players.size )
		return;

	startValue = 0;
	goodPlayers = [];

	while( 1 )
	{
		allPlayers = getAllPlayers();
		for( i = 0; i < allPlayers.size; i++ )
		{
			if( level.dvar["dont_pick_spec"] && allPlayers[i].sessionstate == "spectator" )
			{
				i++;
				continue;
			}
			if ( allPlayers[i].pers["activator"] == startValue )
				goodPlayers[goodPlayers.size] = allPlayers[i];
			i++;
		}

		if( !goodPlayers.size )
		{
			startValue++;
			if( players.size >= 15 )
				wait 0.05; // dont want 'infinite loop' error here
			continue;
		}
		break;
	}
	
	level.activ = goodPlayers[ randomInt( goodPlayers.size ) ];
	level.activ.pers["activator"]++;

	level.activ thread braxi\_teams::setTeam( "axis" );
	level.activ spawnPlayer();
	level.activ thread braxi\_rank::giveRankXp( "activator" );

	level notify( "activator", level.activ );

	bxLogPrint( ("A: " + level.activ.name + " ; guid: " + level.activ.guid) );
	iPrintLnBold( level.activ.name + " ^7was picked to be ^1Activator" );
}


new_ending_hud( align, fade_in_time, x_off, y_off )
{
	hud = newHudElem();
    hud.foreground = true;
	hud.x = x_off;
	hud.y = y_off;
	hud.alignX = align;
	hud.alignY = "middle";
	hud.horzAlign = align;
	hud.vertAlign = "middle";

 	hud.fontScale = 3;

	hud.color = (0.8, 1.0, 0.8);
	hud.font = "objective";
	hud.glowColor = (0.3, 0.6, 0.3);
	hud.glowAlpha = 1;

	hud.alpha = 0;
	hud fadeovertime( fade_in_time );
	hud.alpha = 1;
	hud.hidewheninmenu = true;
	hud.sort = 10;
	return hud;
}


drawInformation( start_offset, movetime, mult, text )
{
	start_offset *= mult;
	hud = new_ending_hud( "center", 0.1, start_offset, 90 );
	hud setText( text );
	hud moveOverTime( movetime );
	hud.x = 0;
	wait( movetime );
	wait( 3 );
	hud moveOverTime( movetime );
	hud.x = start_offset * -1;

	wait movetime;
	hud destroy();
}

SetupLives()
{
	self endon( "disconnect" );

	if( !level.dvar["allowLifes"] )
		return;

	self.hud_lifes = []; // hud elems array
	
	self addLifeIcon( 0, 16, 94, -18, 10 );
	self addLifeIcon( 1, 16, 94, -18, 10 );
	self addLifeIcon( 2, 16, 94, -18, 10 );

	wait .05;
	
	if( !self.pers["lifes"] )
		return;

	for( i = 0; i != self.pers["lifes"]; i++ )
	{
		self.hud_lifes[i] showLifeIcon();
	}
}

giveLife()
{
	if( !level.dvar["allowLifes"] )
		return;

	if( self.pers["lifes"] >= 3 )
		return; 

	self.pers["lifes"]++;

	// hud stuff;
	hud = self.hud_lifes[ self.pers["lifes"]-1 ];
	hud showLifeIcon();

	hud SetPulseFX( 30, 100000, 700 );
	//self iPrintLnBold( "You earned additional life" );
}

showLifeIcon()
{
	self fadeOverTime( 1 );
	self.alpha = 1;
	self.glowAlpha = 1;
	self.color = level.color_cool_green;
}

useLife()
{
	if( !self.pers["lifes"] || self.sessionstate == "playing" || !level.dvar["allowLifes"] )
		return;
	
	self braxi\_teams::setTeam( "allies" );

	hud = self.hud_lifes[ self.pers["lifes"]-1 ];
	hud fadeOverTime( 1 );
	hud.alpha = 0;
	hud.glowAlpha = 0;
	//hud.color = level.color_cool_green;

	self.pers["lifes"]--;

	if( !self.pers["lifes"] )
		self iPrintLnBold( "This was your last life, don't waste it" );
	else
		self iPrintLnBold( "You used one of your additional lifes" );

	if( level.dvar["insertion"] && isDefined( self.insertion ) )
	{
		self spawnPlayer( self.insertion.origin, (0,self.insertion.angles[1],0) );
	}
	else
		self spawnPlayer();

	self.usedLife = true;
}


addLifeIcon( num, x, y, offset, sort )
{

	hud = newClientHudElem( self );
    hud.foreground = true;
	hud.x = x + num * offset;
	hud.y = y + level.hudYOffset;
	hud setShader( "stance_stand", 64, 64 );
	hud.alignX = "right";
	hud.alignY = "top";
	hud.horzAlign = "right";
	hud.vertAlign = "top";
	hud.sort = sort;
	hud.color = level.color_cool_green;
	hud.glowColor = level.color_cool_green_glow;
	hud.glowAlpha = 0;
	hud.alpha = 0;
 	hud.hidewheninmenu = true;
 	self.hud_lifes[num] = hud;
}

destroyLifeIcons()
{
	if( !isDefined( self.hud_lifes ) )
		return;
	for( i = 0; i < self.hud_lifes.size; i++ )
		if( isDefined( self.hud_lifes[i] ) )
			self.hud_lifes[i] destroy();
}


fastestTime()
{
	trig = getEntArray( "endmap_trig", "targetname" );
	if( !trig.size || trig.size > 1 )
		trig = map_scripts\_spawnable_triggers::getTrigArray( "endmap_trig", "targetname" );
	if( !trig.size || trig.size > 1 )
		return;

	level.mapHasTimeTrigger = true;

	trig = trig[0];
	while( 1 )
	{
		trig waittill( "trigger", user );

		if( !user isActuallyAlive() || user.pers["team"] == "axis" )
			continue;

		user thread endTimer();
	}
}



endTimer()
{
	if( isDefined( self.finishedMap ) )
		return;

	self.finishedMap = true;

	time = (getTime() - self.timerStartTime) / 1000;

	self.hud_time destroy();
	self.hud_time = addTextHud( self, 0, -15, 1, "left", "bottom", 1.5 );
	self.hud_time.horzAlign = "left";
    self.hud_time.vertAlign = "bottom";
	self.hud_time.glowAlpha = 1;
	self.hud_time.glowColor = (0.7,0.9,0);
	self.hud_time.hideWhenInMenu = true;

	//self.hud_time reset();
	self.hud_time setText( "Your Time: ^2" + time );

	self iPrintLnBold( "You've finished map in ^2" + time + " ^7seconds" );

	if( time < self.pers["time"] )
		self.pers["time"] = time;
}

playerTimer()
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );
	self endon( "death" );

	if( !level.mapHasTimeTrigger || isDefined( self.finishedMap ) || self.pers["team"] == "axis" || level.freeRun || self.died )
		return;

	level waittill( "game started" );
	
	self.timerStartTime = getTime();
	
	self.hud_time = addTextHud( self, 0, -15, 1, "left", "bottom", 1.4 );
	self.hud_time.horzAlign = "left";
    self.hud_time.vertAlign = "bottom";
	self.hud_time.glowAlpha = 1;
	self.hud_time.glowColor = (0.7,0.9,0);
	self.hud_time.hideWhenInMenu = true;
	self.hud_time.label = &"Your Time: ^2&&1";
	self.hud_time setTenthsTimerUp( 0 );
}


/*
level.hud_round
*/

initScoresStat( num, name, value )
{
	level.bestScores[num]["name"] = name;
	level.bestScores[num]["value"] = value;
	level.bestScores[num]["player"] = " ";
	level.bestScores[num]["guid"] = "123";
}

bestMapScores()
{
	level.bestScores = [];
	
	initScoresStat( 0, "kills", 0 );
	initScoresStat( 1, "deaths", 0 );
	initScoresStat( 2, "headshots", 0 );
	initScoresStat( 3, "score", 0 );
	initScoresStat( 4, "knifes", 0 );
	initScoresStat( 5, "time", 99999999 );
	
	/*	THIS WORKS WITH MY PERSONAL iw4x.dll */
	fileLoc = "database/maps/" + level.mapName + "/" + level.mapName;
	if( !fileExists( fileLoc ) )
		return;
	data = strTok( fileRead( fileLoc ), ";" );
	if( !data.size ) 
		return;

	for( i = 0; i < data.size; i++ )
	{
		stat = strTok( data[i], "," );
		if( !isDefined( stat[0] ) || !isDefined( stat[1] ) || !isDefined( stat[2] ) || !isDefined( stat[3] ) )
		{
			iPrintLn( "Error reading " + level.statDvar + " (" + i + "), stat size is " + stat.size );
			continue;
		}
		for( x = 0; x < level.bestScores.size; x++ )
		{
			if( level.bestScores[x]["name"] == stat[0] )
			{
				level.bestScores[x]["value"] = stat[1];
				level.bestScores[x]["guid"] = stat[2];
				level.bestScores[x]["player"] = stat[3];
				//iPrintLn( "stat " + stat[0] );
			}
		}
	}
}

saveMapScores()
{
	//iPrintLn("map scores are not saved!");
	/*	THIS WORKS WITH MY PERSONAL iw4x.dll */
	fileLoc = "database/maps/" + level.mapName + "/" + level.mapName;
	fileWrite( fileLoc, "", "write" );
	for( i = 0; i < level.bestScores.size; i++ )
	{
		var = ";" + level.bestScores[i]["name"];
		var = var + "," + level.bestScores[i]["value"];
		var = var + "," + level.bestScores[i]["guid"];
		var = var + "," + level.bestScores[i]["player"];

		fileWrite( fileLoc, var, "append" );
	}
	level.dvar["best_scores"] = fileRead( fileLoc );
}

statToString( stat )
{
	name = "unknown";
	switch( stat )
	{
	case "kills":
		name = "Kills";
		break;
	case "deaths":
		name = "Deaths";
		break;
	case "headshots":
		name = "Head Shots";
		break;
	case "score":
		name = "Score";
		break;
	case "knifes":
		name = "Melee Kills";
		break;
	case "time":
		name = "Fastest Time";
		break;
	}
	return name;
}

updateRecord( num, player )
{
	level.bestScores[num]["value"] = player.pers[level.bestScores[num]["name"]];
	level.bestScores[num]["player"] = player.name;
	level.bestScores[num]["guid"] = player getGuid();

	if( level.bestScores[num]["player"] == "" )
		level.bestScores[num]["player"] = " ";

	if( level.bestScores[num]["guid"] == "" )
		level.bestScores[num]["guid"] = "123";
}


firstBlood()
{
	if( !level.dvar["firstBlood"] )
		return;

	level waittill( "activator" );
	wait 0.1;

	level waittill( "player_killed", who );
	
	if ( who == level.activ || getAllPlayers().size <= 2 )
		return;
	
	level thread playLocalSoundToAllPlayers( level.sounds["sfx"]["firstblood"] );

	hud = addTextHud( level, 320, 220, 0, "center", "middle", 2.4 );
	hud setText( "First victim of this round is " + who.name );

	hud.glowColor = (0.7,0,0);
	hud.glowAlpha = 1;
	hud SetPulseFX( 30, 100000, 700 );

	hud fadeOverTime( 0.5 );
	hud.alpha = 1;

	wait 2.6;

	hud fadeOverTime( 0.4 );
	hud.alpha = 0;
	wait 0.4;

	hud destroy();
}

lastJumper()
{
	if( !level.dvar["lastalive"] || level.lastJumper )
		return;

	level.lastJumper = true;
	level thread playLocalSoundToAllPlayers( level.sounds["sfx"]["lastalive"] );

	hud = addTextHud( level, 320, 240, 0, "center", "middle", 2.4 );
	hud setText( self.name + " is the last Jumper alive" );

	hud.glowColor = (0.7,0,0);
	hud.glowAlpha = 1;
	hud SetPulseFX( 30, 100000, 700 );

	hud fadeOverTime( 0.5 );
	hud.alpha = 1;

	wait 2.6;

	hud fadeOverTime( 0.4 );
	hud.alpha = 0;
	wait 0.4;

	hud destroy();
}



watchItems()
{
	if( !level.dvar["insertion"] || self.pers["team"] == "axis" )
		return;

	self endon( "spawned_player" );
	self endon( "disconnect" );

	self.insertionItem = "claymore_mp";
	
	self setActionSlot( 3, "weapon", self.insertionItem );
	self giveWeapon( self.insertionItem );
	self giveMaxAmmo( self.insertionItem );

	while( self isActuallyAlive() )
	{
		self waittill( "grenade_fire", entity, weapName );

		if( weapName != self.insertionItem )
			continue;
		
		self thread watchInsertion( entity );
	}
}

watchInsertion( entity )
{
	self giveMaxAmmo( self.insertionItem );
		
	if( isDefined( self.insertion_busy ) && self.insertion_busy == true )
	{
		self iPrintLnBold( "^1Last Insertion still calculating..." );
		entity delete();
		return;
	}
		
	self.insertion_busy = true;
	entity waitTillNotMoving( 5 );
	self.insertion_busy = false;
		
	if( !isDefined( entity ) )
	{
		self iPrintLnBold( "^1Insertion got bugged!" );
		return;
	}
		
	pos = entity.origin;
	angle = entity.angles;

	if( !self isOnGround() || distance( self.origin, pos ) > 48 )
	{
		self iPrintLnBold( "^1You can't use insertion here" );
		entity delete();
		return;
	}
		
	self cleanUpInsertion();
	self.insertion = entity;
	entity notify("smartStop");

	self iPrintLnBold( "^2Insertion at " + pos );
}

cleanUpInsertion()
{
	if( isDefined( self.insertion ) )
		self.insertion delete();
}

noDoubleMusic()
{
    thread onIntermission();

    level waittill( "round_ended" );
    ambientStop( 0 );
}

onIntermission()
{
    level waittill( "intermission" );
    ambientStop( 0 );
}

gib_splat()
{
	self playSound( level.sounds["sfx"]["gib_splat"] );
	playFX( level.fx["gib_splat"], self.origin + (0,0,20) );
	self delete();
}
