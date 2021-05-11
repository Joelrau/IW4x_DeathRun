init( modVersion )
{
	braxi\_dvar::addDvar( "pi_ghostrun_enable", "plugin_ghostrun_enable", 1, 0, 1, "int" ); // 1 == enable 0 == disable
	if (level.dvar["pi_ghostrun_enable"] != 1)
		return;
	
	if(level.freeRun == true)
		return;
		
	disabled = false;
	
	collision = getDvarInt("g_playerCollision");
	ejection = getDvarInt("g_playerEjection");
	if(isDefined(collision) && isDefined(ejection))
	{
		if(collision != false)
		{
			iPrintLn("Ghost Run plugin: ^1Error: dvar 'g_playerCollision' is not false^7");
			disabled = true;
		}
		
		if(ejection != false)
		{
			iPrintLn("Ghost Run plugin: ^1Error: dvar 'g_playerEjection' is not false^7");
			disabled = true;
		}
	}
	else
	{
		iPrintLn("Ghost Run plugin: ^1Error: dvar 'g_playerCollision' or 'g_playerEjection' is not defined^7");
		disabled = true;
	}
		
	if(!isDefined(level.endmap_trig))
	{
		endmap_trig = getEntArray( "endmap_trig", "targetname" );
		if( !endmap_trig.size || endmap_trig.size > 1 )
		{
			endmap_trig = map_scripts\_spawnable_triggers::getTrigArray( "endmap_trig", "targetname" );
			if( !endmap_trig.size || endmap_trig.size > 1 )
			{
				iPrintLn("Ghost Run plugin: ^1Error: no 'endmap_trig' found in map!^7");
				disabled = true;
			}
		}
		if( endmap_trig[0]._classname == "trigger_multiple" || endmap_trig[0].classname == "trigger_multiple" || endmap_trig[0].classname == "trigger_radius" )
		{
			level.endmap_trig = endmap_trig[0];
		}
		else
		{
			classname = endmap_trig[0]._classname;
			if(!isDefined(classname))
				classname = endmap_trig[0].classname;
			if(!isDefined(classname))
				classname = "<unknown>"
			iPrintLn("Ghost Run plugin: ^1Error: endmap_trig classname is '" + classname + "' when it should be 'trigger_multiple' or 'trigger_radius'!^7");
			disabled = true;
		}
	}
	if(disabled == true)
	{
		level waittill("game started");
		iPrintLn("Ghost Run [^1Disabled^7]");
		return;
	}
	
	level.ghostRunWeapon = "knife_mp";
	precacheItem(level.ghostRunWeapon);
	level.ghostRunModel = "defaultactor";
	precacheModel(level.ghostRunModel);
	
	onPlayerKilled();
}

onPlayerKilled()
{
	for(;;)
	{
		level waittill("player_killed", player);
		player thread main();
	}
}

main()
{
	wait 1;
	self GhostRun();
}

GhostRun()
{
	self endon("disconnect");
	self endon("killghostrun");
	
	if(self.pers["team"] != "allies" || isAlive(self) || game["state"] != "playing")
		return;
	
	self thread GhostHudWatcher();
	
	self GhostHud( "^7Press ^3[{+frag}]^7 to play Ghost Run!" );
	self waittillFragButtonPressed();
	self GhostHud();

	self notify("killghostrunhudwatcher");
	
	if(self.pers["team"] != "allies" || isAlive(self) || game["state"] != "playing")
		return;
	
	self.ghost = true;
	self braxi\_mod::spawnPlayer();
	self.statusicon = "hud_status_dead";
	self thread keepHidingGhost();
	
	self GhostHud( "You're playing in Ghost Run!" );
	
	self takeAllWeapons();
	self ghostRunWeapon();
	self thread checkWeapons();
	
	self thread KillGhostRunOnEndTrigger();
	self thread GhostWatcher( "spawned_player", "death", "joined_spectators", "disconnect", "endround" );
}

waittillFragButtonPressed()
{
	self endon("spawned_player");
	self endon("joined_spectators");
	while(!self fragButtonPressed())
		wait 0.05;
}

keepHidingGhost()
{
	self endon("killghostrun");
	while(isDefined(self))
	{
		self detachAll();
		self setModel(level.ghostRunModel);
		self hide();
		wait 1;
	}
}

GhostHud( text )
{
	if(!isDefined(self.ghostHud))
	{
		self.ghostHud = newclienthudElem(self);	
		self.ghostHud.x = 0;	
		self.ghostHud.y = -120;	
		self.ghostHud.horzAlign = "center";	
		self.ghostHud.vertAlign = "bottom";
		self.ghostHud.alignX = "center";
		self.ghostHud.alignY = "bottom";
		self.ghostHud.font = "objective";
		self.ghostHud.sort = 102;	
		self.ghostHud.alpha = 1;	
		self.ghostHud.fontScale = 1.6;
		self.ghostHud.color = (1,1,1);
		self.ghostHud.foreground = true;	
		self.ghostHud.archived = false;	
		self.ghostHud.hidewheninmenu = true;
	}
	if(!isDefined(text) || text == "")
		self.ghostHud destroy();
	else
		self.ghostHud setText( text );
}

GhostHudWatcher()
{
	self endon("killghostrun");
	self endon("killghostrunhudwatcher");
	while(isDefined(self))
	{
		if(!isDefined(self.ghostHud))
		{
			wait 0.05;
			continue;
		}
		
		if( self attackButtonPressed() || self adsButtonPressed() )
		{
			if(self.ghostHud.alpha != 0)
				self.ghostHud.alpha = 0;
		}
		else if( self meleeButtonPressed() )
		{
			if(self.ghostHud.alpha != 1)
				self.ghostHud.alpha = 1;
		}
		wait 0.05;
	}
}

GhostWatcher( endon_1, endon_2, endon_3, endon_4, endon_5 )
{
	self endon("killghostrun");
	self endon("killghostrunwatcher");
	self GhostRunWaittill( endon_1, endon_2, endon_3, endon_4, endon_5 );
	self KillGhostRun();
}

GhostRunWaittill( endon_1, endon_2, endon_3, endon_4, endon_5 )
{
	self endon( endon_1 );
	self endon( endon_2 );
	self endon( endon_3 );
	self endon( endon_4 );
	
	level endon( endon_5 );
	
	while(1)
		wait 420;
}

KillGhostRun()
{
	self.ghost = false;
	self GhostHud();
	if(isAlive(self))
		self suicide();
	self notify("killghostrun");
}

KillGhostRunOnEndTrigger()
{
	self endon("killghostrun");
	while(isDefined(level.endmap_trig))
	{
		level.endmap_trig waittill("trigger", player);
		if(player == self)
		{
			player KillGhostRun();
		}
	}
}

ghostRunWeapon()
{	
	weapon = self.pers["knife"];
	if(!isDefined(weapon))
		weapon = level.ghostRunWeapon;
	
	self giveWeapon( weapon );
	self setSpawnWeapon( weapon );
	self giveMaxAmmo( weapon );
	self switchToWeapon( weapon );
	self.ghostRunWeapon = weapon;
}

checkWeapons()
{
	self endon("killghostrun");
	
	allowedWeapons = [];
	allowedWeapons[0] = undefined;
	allowedWeapons[1] = "none";
	allowedWeapons[2] = "rpg_mp";
	
	while(isDefined(self))
	{
		allowedWeapons[0] = self.ghostRunWeapon;
		
		weaponsList = self getWeaponsListAll();
		
		for(i = 0; i < weaponsList.size; i++)
		{
			weapon = weaponsList[i];
			
			canKeep = false;
			for( j = 0; j < allowedWeapons.size; j++)
			{
				if( weapon == allowedWeapons[j] )
				{
					canKeep = true;
					break;
				}
			}
			
			if( canKeep == false )
			{
				self takeWeapon( weapon );
				self ghostRunWeapon();
			}
		}
		if( self hasWeapon( self.ghostRunWeapon ) == false )
			self ghostRunWeapon();
		wait 0.05;
	}
}