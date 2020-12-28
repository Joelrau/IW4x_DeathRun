//
// Plugin name: Auto Spawn Bots
// Author: quaK
//

#include braxi\_dvar;

init( modVersion )
{
	addDvar( "pi_autospawnbots_enable", "plugin_autospawnbots_enable", 1, 0, 1, "int" ); // 1 == enable 0 == disable
	setDvar( "testClients_doAttack", 0 );
	
	if (level.dvar["pi_autospawnbots_enable"] == 1)
	{
		thread autoSpawnBots();
		thread botTeamFix();
	}
}

autoSpawnBots()
{
	playersRequired = 2;
	maxBots = 1;
	
	thread autoKillBots();
	thread autoKickBots( playersRequired );
	
	while(1)
	{
		wait 10;
		if (canSpawnBots( playersRequired, maxBots ))
		{
			addTestClient();
		}
	}
}

autoKillBots()
{
	while(1)
	{
		level waittill("activator", acti);
		
		if(acti isABot() == false && botsPlaying( "int" ) > 0)
		{
			acti pressToKillBots( "+frag", "Grenade" );
		}
	}
}

pressToKillBots( command, commandname )
{
	self endon("death");
	self thread pressToKillBotsMsg( "Press [^3" + commandname + "^7] to ^1kill^7 bots", 15 );
	self notifyOnPlayerCommand( "killbots", command );
	self waittill("killbots");
	thread killBots();
}

pressToKillBotsMsg( msg, waittime )
{
	self endon("death");
	self endon("disconnect");
	self endon("killbots");
	
	if (!isDefined(waittime))
		waittime = 10;
	
	while( botsPlaying("int") > 0)
	{
		maps\mp\gametypes\_hud_message::hintMessage( msg );
		wait waittime;
	}
}

killBots()
{
	players = getEntArray( "player", "classname" );
	botsKilled = 0;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player isABot() == true)
		{
			player suicide();
			botsKilled++;
		}
	}
	if (botsKilled > 0)
		iPrintLnBold("All bots killed!");
}

autoKickBots( playersRequired )
{
	while(1)
	{
		wait 5;//level waittill("jumper");
		waittillframeend;
		players = getEntArray( "player", "classname" );
		botsKicked = 0;
		if(playersPlaying( "int" ) >= playersRequired || playersInServer( "int" ) == 0)
		{
			for(i = 0; i < players.size; i++)
			{
				player = players[i];
				if (player isABot() == true)
				{
					kick( player getEntityNumber() );
					botsKicked++;
				}
			}
			if (botsKicked > 0)
				iPrintLnBold("All bots kicked!");
		}
	}
}

botTeamFix()
{
	thread botTeamFix2();
	for(;;)
	{
		level waittill("connected", player);
		if (player isABot())
		{
			if(player.pers["team"] != "allies")
				player braxi\_teams::setTeam("allies");
			
			if (level.allowSpawn == true)
				player braxi\_mod::spawnPlayer();
		}
	}
}

botTeamFix2()
{
	while(1)
	{
		if(game["state"] == "endmap")
			return;
		
		bots = botsInServer( "array" );
		for( i = 0; i < bots.size; i++ )
		{
			bot = bots[i];
			
			if(bot.pers["team"] == "spectator" || bot.sessionteam == "spectator")
			{
				bot braxi\_teams::setTeam("allies");
			}
		}
		wait .05;
	}
}


//-----------------------------------------------------------//


isABot()
{
	if (braxi\_common::stringContains(self getGuid(), "bot"))
		return true;
	return false;
}

canSpawnBots( playersRequired, maxBots )
{
	if( playersPlaying( "int" ) > 0 && playersInServer( "int" ) < playersRequired && botsInServer( "int" ) < maxBots )
		return true;
	return false;
}

botsInServer( type )
{
	if (!isDefined(type))
		type = "int";

	if (type == "array")
	{
		bots = [];
		players = getEntArray( "player", "classname" );
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player isABot() == true)
			{
				bots[bots.size] = player;
			}
		}
		return bots;
	}
	
	if (type == "int")
	{
		bots = 0;
		players = getEntArray( "player", "classname" );
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player isABot() == true)
			{
				bots++;
			}
		}
		return bots;
	}
}

botsPlaying( type )
{
	if (!isDefined(type))
		type = "int";

	if (type == "array")
	{
		bots = [];
		players = getEntArray( "player", "classname" );
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player isABot() == true && player.sessionstate == "playing")
			{
				bots[bots.size] = player;
			}
		}
		return bots;
	}
	
	if (type == "int")
	{
		bots = 0;
		players = getEntArray( "player", "classname" );
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player isABot() == true && player.sessionstate == "playing")
			{
				bots++;
			}
		}
		return bots;
	}
}

playersInServer( type )
{
	if (!isDefined(type))
		type = "int";

	if (type == "array")
	{
		playersInServer = [];
		players = getEntArray( "player", "classname" );
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player isABot() == false)
			{
				playersInServer[playersInServer.size] = player;
			}
		}
		return playersInServer;
	}
	
	if (type == "int")
	{
		playersInServer = 0;
		players = getEntArray( "player", "classname" );
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player isABot() == false)
			{
				playersInServer++;
			}
		}
		return playersInServer;
	}
}

playersPlaying( type )
{
	if (!isDefined(type))
		type = "int";

	if (type == "array")
	{
		playingPlayers = [];
		players = getEntArray( "player", "classname" );
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player isABot() == false && player.sessionstate == "playing")
			{
				playingPlayers[playingPlayers.size] = player;
			}
		}
		return playingPlayers;
	}
	
	if (type == "int")
	{
		playingPlayers = 0;
		players = getEntArray( "player", "classname" );
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player isABot() == false && player.sessionstate == "playing")
			{
				playingPlayers++;
			}
		}
		return playingPlayers;
	}
}