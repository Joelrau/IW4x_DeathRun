init( modVersion )
{
	thread sayCommands();
}

sayCommands()
{
	// common
	level thread saycmd_help();
	level thread saycmd_resetStats();
	
	// admin
	level thread saycmd_map();
	level thread saycmd_party();
	
	// special
	level thread saycmd_finishMap();
}

// common

saycmd_help()
{
	while(1)
	{
		level waittill("sayCommand", command, player);
		if(toLower(command) == "help")
		{
			player thread _saycmd_help();
		}
	}
}
_saycmd_help()
{
	if(!isDefined(self.saycmd_helping))
		self.saycmd_helping = false;
	if(self.saycmd_helping == false)
	{
		self.saycmd_helping = true;
		
		commands = [];
		commands["common"][0] = "help";
		commands["common"][1] = "resetStats";
		
		self iPrintLn("[Common commands]");
		wait 1;
		for(i = 0; i < commands["common"].size; i++)
		{
			self iPrintLn(level.sayCommandSymbol + commands["common"][i]);
			wait 1;
		}
		commands["admin"][0] = "map";
		commands["admin"][1] = "party";
		
		if(self.pers["admin"] == true)
		{
			self iPrintLn("[^1Admin^7 commands]");
			wait 1;
			for(i = 0; i < commands["common"].size; i++)
			{
				self iPrintLn(level.sayCommandSymbol + commands["admin"][i]);
				wait 1;
			}
		}
	}
	self.saycmd_helping = false;
}

saycmd_resetStats()
{
	while(1)
	{
		level waittill("sayCommand", command, player);
		if(toLower(command) == "resetstats")
		{
			player thread braxi\_stats::resetStats();
		}
	}
}

// admin

saycmd_map()
{
	while(1)
	{
		level waittill("sayCommand", command, player, params);
		if(toLower(command) == "map")
		{
			if(player.pers["admin"] == true)
			{
				if(isDefined(params[0]))
				{
					map(params[0]);
				}
				else
				{
					player iPrintLnBold("mapname not defined!");
				}
			}
			else
				player iPrintLnBold("You need to be admin to use this command.");
		}
	}
}

saycmd_party()
{
	while(1)
	{
		level waittill("sayCommand", command, player);
		if(toLower(command) == "party")
		{
			if(player.pers["admin"] == true)
			{
				level thread braxi\_common::partymode();
			}
			else
				player iPrintLnBold("You need to be admin to use this command.");
		}
	}
}

// special
saycmd_finishMap()
{
	wait 5;
	if(game["roundsplayed"] < 2)
	{
		return;
	}
	
	thread _saycmd_finishMap();
	
	while(1)
	{
		level waittill("sayCommand", command, player);
		if(toLower(command) == "finishmap")
		{
			players = getEntArray( "player", "classname" );
			if(players.size >= 2)
			{
				player iPrintLnBold("^1This command can only be used when there are less than 2 players!^7");
				return;
			}
			braxi\_mod::endMap();
		}
	}
}

_saycmd_finishMap()
{
	while(1)
	{
		level waittill("jumper", player);
		if(isDefined(player.saycmd_finishmap_notified) == false)
		{
			player iPrintLnBold("^4Since you are alone, you can say ^3" + level.sayCommandSymbol + "finishMap^4 to end the map.^7");
			player.saycmd_finishmap_notified = true;
		}
	}
}