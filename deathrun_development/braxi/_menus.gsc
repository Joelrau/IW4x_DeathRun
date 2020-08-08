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

init()
{
	game["menu_team"] = "team_select";
	game["menu_characters"] = "character_stuff";
	game["menu_quickstuff"] = "quickstuff";

	precacheMenu( "scoreboard" );
	precacheMenu( game["menu_team"] );
	precacheMenu( game["menu_characters"] );
	precacheMenu( game["menu_quickstuff"] );

	precacheMenu( "dr_help" );
	precacheMenu( "dr_characters" );
	precacheMenu( "dr_characters_2" );
	precacheMenu( "dr_weapons" );
	precacheMenu( "dr_weapons_2" );
	precacheMenu( "dr_knives" );
	precacheMenu( "dr_sprays" );
	precacheMenu( "dr_sprays_2" );

	precacheString( &"MP_HOST_ENDED_GAME" );
	precacheString( &"MP_HOST_ENDGAME_RESPONSE" );
	
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		
		player setClientDvar("ui_3dwaypointtext", "1");
		player.enable3DWaypoints = true;
		player setClientDvar("ui_deathicontext", "1");
		player.enableDeathIcons = true;
		player.classType = undefined;
		player.selectedClass = false;
		
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon("disconnect");
	
	if( !isDefined( self.pers["failedLogins"] ) )
		self.pers["failedLogins"] = 0;

	for(;;)
	{
		self waittill("menuresponse", menu, response);
		
		///#
		//iPrintLn( self getEntityNumber() + " menuresponse: " + menu + " '" + response +"'" );
		//#/

		tokens = strTok( response, ":" );

		if( tokens.size && tokens[0] == "authorize" && !self.pers["admin"] )
		{
			if( !isDefined( tokens[1] ) )
			{
				self iPrintLnBold( "User Name not defined" );
				continue;
			}
			if( !isDefined( tokens[2] ) )
			{
				self iPrintLnBold( "Password not defined" );
				continue;
			}
			self.pers["login"] = tokens[1];
			self.pers["password"] = tokens[2];

			for( i = 0; i < 32; i++ )
			{
				dvar = getDvar( "dr_admin_loginpass_"+i );
				if( dvar == "" )
					break;
				
				self braxi\_admin::parseAdminInfo( dvar );

				if( self.pers["admin"] )
					break;
			}
			if( !self.pers["admin"] )
			{
				self iPrintLnBold( "Incorrect user name or password" );
				self.pers["failedLogins"]++;

				if( self.pers["failedLogins"] >= 3 )
					braxi\_common::dropPlayer( self, "kick", "Too many failed login attempts.", "Your actions will be investigated by server administration." );
			}

		}


		if( response == "adminmenu" && self.pers["admin"] )
		{
			self closepopupMenu();
			self closeMenu();
			self closeInGameMenu();
			//self openMenu( "dr_admin" );
			self openpopupMenu( "dr_admin" );
		}

		// client side commands
		if( response == "2doff" )
		{
			self setClientDvar( "cg_draw2d", 0 );
		}

		if( response == "2don" )
		{
			self setClientDvar( "cg_draw2d", 1 );
		}

		if( isSubStr( response, "whois:" ) )
		{
			str = strTok( response, ":" );
			if( !isDefined( str[1] ) || isDefined( str[1] ) && str[1] == "" )
				continue;
				
			player = braxi\_admin::getPlayerByName( str[1] );
			str = player.name + "^7 :: ";
			str = str + "Health: ^2" + player.health + "^7, ";
			str = str + "Team: ^2" + player.pers["team"] + "^7, ";
			str = str + "State: ^2" + player.sessionstate + "^7, ";
			str = str + "Warnings: ^2" + player braxi\_stats::getStats("warns") + "^7, ";
			str = str + "Guid: ^2" + player getGuid() + "^7.";
			self iPrintLn( "^3[dvar] ^7Who is: " +str );
		}
		// ==============================

		if ( response == "back" )
		{
			self closepopupMenu();
			self closeMenu();
			self closeInGameMenu();
			continue;
		}
		
		if( menu == "dr_characters" || menu == "dr_characters_2" )
		{
			character = int(response)-1; // scripting hacks everywhere :o
			if( braxi\_rank::isCharacterUnlocked( character ) )
			{
				self iPrintLnBold( "Your character will be changed to ^3" + level.characterInfo[character]["name"] + "^7 next time you spawn" );
				self braxi\_stats::setStats( "dr_character", character );
				self setClientDvar( "drui_character", character );
			}
		}		
		else if( menu == "dr_weapons" || menu == "dr_weapons_2" )
		{
			item = int(response)-1;
			if( braxi\_rank::isItemUnlocked1( item ) ) 
			{
				self iPrintLnBold( "Your weapon will change next time you spawn" );
				self braxi\_stats::setStats( "dr_weapon", item );
				self setClientDvar( "drui_weapon", item );
			}
		}
		else if( menu == "dr_knives" )
		{
			knife = int(response)-1;
			if( braxi\_rank::isKnifeUnlocked( knife ) ) 
			{
				self iPrintLnBold( "Your knife will change next time you spawn" );
				self braxi\_stats::setStats( "dr_knife", knife );
				self setClientDvar( "drui_knife", knife );
			}
		}
		else if( menu == "dr_sprays" || menu == "dr_sprays_2" )
		{
			spray = int(response)-1;
			if( braxi\_rank::isSprayUnlocked( spray ) ) 
			{
				self iPrintLnBold( "Your spray has been updated" );
				self braxi\_stats::setStats( "dr_spray", spray );
				self setClientDvar( "drui_spray", spray );
			}
		}

		else if( menu == game["menu_quickstuff"] )
		{
			switch(response)
			{
			case "3rdperson":
				self thirdPerson();
				break;

			case "suicide":
				if( !game["roundStarted"] )
					continue;
				if( self.pers["team"] == "allies" )
					self suicide();
				else
					self iPrintLn( "^1Activator cannot suicide!" );
				break;
			}

		}
		else if( menu == game["menu_team"] )
		{
			switch(response)
			{
			case "allies":
			case "axis":
			case "autoassign":
				self closepopupMenu();
				self closeMenu();
				self closeInGameMenu();


				if( self.pers["team"] == "axis" )
					continue;

				self braxi\_teams::setTeam( "allies" );

				if( self.pers["team"] == "allies" && self.sessionstate != "playing" && self.pers["lifes"] && !level.allowSpawn )
				{
					self braxi\_mod::useLife();
					continue;
				}

				if(self.sessionstate == "playing" || game["state"] == "round ended"  )
					continue;

				if( self canReallySpawn() )
					self braxi\_mod::spawnPlayer();
				break;

			case "spectator":
				self closepopupMenu();
				self closeMenu();
				self closeInGameMenu();
				if(self.pers["team"] == "axis")
				{
               		self iPrintLn("You cant goto spectator as activator!");
               		continue;
            	}
				self braxi\_teams::setTeam( "spectator" );
				self braxi\_mod::spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
				break;
			case "character_menu":
				self closepopupMenu();
				self closeMenu();
				self closeInGameMenu();
				self openMenu( game["menu_characters"] );
				break;
			}
		}
		else if ( !level.console )
		{
			if(menu == game["menu_quickcommands"])
				maps\mp\gametypes\_quickmessages::quickcommands(response);
			else if(menu == game["menu_quickstatements"])
				maps\mp\gametypes\_quickmessages::quickstatements(response);
			else if(menu == game["menu_quickresponses"])
				maps\mp\gametypes\_quickmessages::quickresponses(response);
		}

	}
}
