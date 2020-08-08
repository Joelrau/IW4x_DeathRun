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
		level waittill("sayCommand", command, player, param_1);
		if(toLower(command) == "map")
		{
			if(player.pers["admin"] == true)
			{
				if(isDefined(param_1))
				{
					map(param_1);
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