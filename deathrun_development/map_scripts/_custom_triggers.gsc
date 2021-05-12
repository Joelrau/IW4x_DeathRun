/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
	
	//-- CUSTOM TRIGGERS --//
	
	Script by: 	quaK
	Steam: 		https://steamcommunity.com/id/Joelrau/		
	Discord: 	quaK#0426
	
	This script makes triggers from .mapEnts!
	
	Types of triggers supported:
        |- trigger_multiple
        |- trigger_use
		|- trigger_use_touch
        |- trigger_hurt
		|- trigger_damage ( sort of )
		
	
	**NOTES
		- setHintString doesn't work so you must use setHintStringTrigger.
		- setCursorHint doesn't work so you must use setCursorHintTrigger.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
*/

makeTrigger( name, classname, hintstring, cursorhint, dmg, accumulate, threshold )
{
	trigger = undefined;
	if( !isDefined( self ) )
		trigger = getEnt( name, "targetname" );
	else
		trigger = self;

	trigger.targetname = name;
	trigger._classname = classname; // classname cannot be changed so it is saved as _classname
	trigger hide();
	trigger notSolid();
	if (classname == "trigger_once")
	{
		trigger.type = "once";
	}
	if (classname == "trigger_multiple")
	{
		trigger.type = "multiple";
	}
	if(classname == "trigger_hurt")
	{
		trigger.type = "hurt";
		trigger.dmg = dmg;
	}
	if(classname == "trigger_use" || classname == "trigger_use_touch")
	{
		trigger.type = "use_touch";
		trigger.hintstring = hintstring;
		trigger.cursorhint = cursorhint;
		if(braxi\_common::stringContains(trigger.hintstring, "&&1"))
		{
			trigger.hintstring = braxi\_common::stringReplace(trigger.hintstring, "&&1", "[{+activate}]");
		}
	}
	if(classname == "trigger_damage")
	{
		trigger.type = "damage";
		trigger.accumulate = accumulate;
		trigger.threshold = threshold;
		
		if(!isDefined(level.SPAWNFLAGS_DEFINED))
		{
			level.PISTOL_NO = 1; // turns off response to pistol damage
			level.RIFLE_NO = 2; // turns off response to rifle damage
			level.PROJ_NO = 4; // turns off response to projectile damage from grenades and rockets. Note that turning off projectile damage will also turn off splash damage, whether or not the splash is on.
			level.EXPLOSION_NO = 8; // turns off response to explosion damage
			level.SPLASH_NO = 16; // turns off response to splash damage from grenades and rockets.
			level.MELEE_NO = 32; // turns off response to melee damage
			level.FIRE_NO = 64; // turns off response to flame/fire damage
			level.MISC_NO = 128; // turns off response to all other misc types of damage
			
			level.SPAWNFLAGS_DEFINED = true;
		}
		
		if(trigger.classname == "script_brushmodel")
			trigger thread private_damage_think();
		else
			trigger thread private_damage_think_old();
	}
	if(trigger.type != "damage")
		trigger thread private_watchTrigger();
	private_addTriggerIntoList( trigger );
	trigger.customTrigger = true;
}

makeTriggers( name, classname, hintstring, cursorhint, dmg, accumulate, threshold )
{
	triggers = getEntArray( name, "targetname" );
	for( i = 0; i < triggers.size; i++ )
	{
		trigger = triggers[i];
		trigger makeTrigger( name, classname, hintstring, cursorhint, dmg, accumulate, threshold );
	}
	return triggers;
}

private_addTriggerIntoList( trigger )
{
	if( !isDefined( level.customTriggers ) )
		level.customTriggers = [];
	level.customTriggers[level.customTriggers.size] = trigger;
}

private_watchTrigger()
{
	self thread private_showDebugTillNotified();
	
	while( isDefined( self ) )
	{
		players = getEntArray( "player", "classname" );
		for( i = 0; i < players.size; i++ )
		{
			player = players[i];
			if( player.sessionstate != "playing" )
                continue;
			
			if( player isTouching( self ) && player private_canTrigger( self ) )
			{
				if( self.type == "use" || self.type == "use_touch" )
				{
					player thread private_hintString( self, self.hintstring );
					player thread private_cursorHint( self, self.cursorhint );
					if( !player useButtonPressed() || isDefined( player.use_trigger_holding ) && player.use_trigger_holding == true )
						continue;
					
					player thread private_use_trigger_holding();
				}
				
                self notify("trigger", player);
				
				if( self.type == "once" )
				{
					self delete();
					return;
				}
				else if( self.type == "hurt" )
				{
					if( self.dmg > 0 )
						player maps\mp\gametypes\_callbacksetup::CodeCallback_PlayerDamage( self, undefined, self.dmg, 0, "MOD_TRIGGER_HURT", "none", player.origin, (0,0,0), "none", 0 );
				}
				
				if(isDefined(self._wait) && self._wait == -1)
					return;

                if( isDefined(self.delay) && self.delay > 0 )
                    wait( self.delay );
            }
		}
		wait ( 0.05 );
	}
}

private_hintString( trigger, text )
{
	if (self.sessionstate != "playing")
	{
		if (isDefined(self.hintstringhud))
			self.hintstringhud destroy();
				
		return;
	}
	
	if (isDefined(self.hintstringhud))
	{
		return;
	}
	
	self.hintstringhud = maps\mp\gametypes\_hud_util::createFontString( "default", 1.4 );
	self.hintstringhud.alignX = "center";
	self.hintstringhud.alignY = "middle";
	self.hintstringhud.horzAlign = "center";
	self.hintstringhud.vertAlign = "middle";
	self.hintstringhud.x = 0;
	self.hintstringhud.y = 65;
	self.hintstringhud.alpha = 1;
	self.hintstringhud.text = text;
	self.hintstringhud setText(text);
	
	while(isDefined(self.hintstringhud) && isDefined(trigger) && self isTouching(trigger) && isAlive(self) && self.hintstringhud.text == trigger.hintstring)
		wait ( 0.1 );
		
	self.hintstringhud fadeOverTime( 0.1 );
	self.hintstringhud.alpha = 0;
	wait ( 0.1 );
	if (isDefined(self.hintstringhud))
		self.hintstringhud destroy();
}

setHintStringTrigger( string )
{
	self.hintstring = string;
}

private_cursorHint( trigger, shader )
{	
	if (self.sessionstate != "playing")
	{
		if (isDefined(self.cursorhinthud))
			self.cursorhinthud destroy();
				
		return;
	}
	
	if (isDefined(self.cursorhinthud))
	{
		return;
	}
	
	self.cursorhinthud = maps\mp\gametypes\_hud_util::createIcon( shader, 32, 32 );
	self.cursorhinthud.alignX = "center";
	self.cursorhinthud.alignY = "middle";
	self.cursorhinthud.horzAlign = "center";
	self.cursorhinthud.vertAlign = "middle";
	self.cursorhinthud.x = 0;
	self.cursorhinthud.y = 95;
	self.cursorhinthud.shader = shader;
	
	while(isDefined(self.cursorhinthud) && isDefined(trigger) && self isTouching(trigger) && isAlive(self) && self.cursorhinthud.shader == trigger.cursorhint)
		wait ( 0.1 );
		
	self.cursorhinthud fadeOverTime( 0.1 );
	self.cursorhinthud.alpha = 0;
	wait ( 0.1 );
	if (isDefined(self.cursorhinthud))
		self.cursorhinthud destroy();
}

setCursorHintTrigger( shader )
{
	self.cursorhint = shader;
}

// FIXES

private_canTrigger( trigger ) // fix for noclip triggers
{
	if(!isDefined(self.cantriggerobj) || self.cantriggerobj.origin != self.origin)
	{
		if(isDefined(self.cantriggerobj))
			self.cantriggerobj delete();
		
		radius = 32 * 2; // * 2 just in case
		height = 70 * 2; // * 2 just in case
		self.cantriggerobj = spawn( "trigger_radius", self.origin, 0, radius, height );
		self.cantriggerobj enableLinkTo();
		self.cantriggerobj linkTo(self);
	}
	
	if(self isTouching(self.cantriggerobj))
		return true;
	return false;
}

// USE

private_use_trigger_holding()
{
	self.use_trigger_holding = true;
	while(self useButtonPressed())
		wait ( 0.05 );
	self.use_trigger_holding = false;
}

// DAMAGE

private_damage_think()
{
	self thread private_showDebugTillNotified();
	
	self solid();
	self setCanDamage(true);
	
	self.damageTaken = 0;
	while(isDefined(self))
	{	
		self waittill("damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags);
		
		if(isDefined(self.spawnflags) && self.spawnflags > 0)
		{
			if(self.spawnflags & level.PISTOL_NO)
			{
				if(type == "MOD_PISTOL_BULLET")
				{
					continue;
				}
			}
			if(self.spawnflags & level.RIFLE_NO)
			{
				if(type == "MOD_RIFLE_BULLET")
				{
					continue;
				}
			}
			if(self.spawnflags & level.PROJ_NO)
			{
				if(type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH")
				{
					continue;
				}
			}
			if(self.spawnflags & level.EXPLOSION_NO)
			{
				if(type == "MOD_EXPLOSIVE")
				{
					continue;
				}
			}
			if(self.spawnflags & level.SPLASH_NO)
			{
				if(type == "MOD_PROJECTILE_SPLASH" || type == "MOD_GRENADE_SPLASH")
				{
					continue;
				}
			}
			if(self.spawnflags & level.MELEE_NO)
			{
				if(type == "MOD_MELEE" || type == "MOD_BAYONET")
				{
					continue;
				}
			}
			if(self.spawnflags & level.FIRE_NO)
			{
				if(type == "MOD_BURNED")
				{
					continue;
				}
			}
			if(self.spawnflags & level.MISC_NO)
			{
				if(type == "MOD_UNKNOWN")
				{
					continue;
				}
			}
		}
		
		if(isDefined(self.threshold) && amount < self.threshold)
			continue;
		
		self.damageTaken += amount;
		if(isDefined(self.accumulate) && self.damageTaken < self.accumulate)
			continue;
		
		self notify("trigger", attacker);
	}
}

private_damage_think_old()
{
	self thread private_showDebugTillNotified();
	
	braxi\_common::_precacheModel( "com_plasticcase_friendly" );
	self.damage_obj = spawn( "script_model", self.origin );
	self.damage_obj setModel( "com_plasticcase_friendly" );
	self.damage_obj hide();
	self.damage_obj setCanDamage(true);
	
	self.damage_obj enableLinkTo();
	self.damage_obj linkTo(self);
	
	self.damageTaken = 0;
	while(isDefined(self))
	{
		self.damage_obj waittill("damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags);
		self notify("damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags);
		
		if(isDefined(self.threshold) && amount < self.threshold)
			continue;
		
		self.damageTaken += amount;
		if(isDefined(self.accumulate) && self.damageTaken < self.accumulate)
			continue;
		
		self notify("trigger", attacker);
		
		wait ( 0.05 );
	}
}

// DEBUG

private_showDebugTillNotified(notify1, notify2, notify3, notify4)
{
	self notify("NEWTillNotified");
	self endon("NEWTillNotified");
	
	self endon(notify1);
	self endon(notify2);
	self endon(notify3);
	self endon(notify4);
	while(isDefined(self))
	{
		self private_debug_info();
		wait ( 0.05 );
	}
}

private_debug_info()
{
	if( getDvarInt("r_drawTriggers") != 1 )
        return;
	
	if( isDefined( self._classname ) )
		print3d( self.origin+(0,0,2), "classname: "+self._classname, (0.5, 1, 0), 1, 0.2 );
	if( isDefined( self.targetname ) )
		print3d( self.origin+(0,0,0), "targetname: "+self.targetname, (0.5, 1, 0), 1, 0.2 );
}