/*
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

    Sniper[+]FIRE>>> Spawnable triggers script
	EDITED BY: quaK

To spawn a trigger:

    1. Build an array of 6 values. The first set of three
    defines one corner of the trigger. The second three
    define the opposite corner.

    2. Call spawnTrigger(), and pass in the array. an optional
    parameter is type, which determines the type of trigger.
    See extra settings. A new trigger entity is returned.

    Ex:
        trigger = spawnTrigger( volume_array, "trigger_multiple", "classname", "targetname", "hintstring", dmg );
    This would spawn a trigger_multiple.


To monitor a trigger:

    Simply use:
        trigger waittill("trigger", player);
    This will only work on players.
    The player variable is optional.

    Also, you can check to see if an entity is touching it with:
        if( player isTouchingTrigger(trigger) )


Extra settings:

    Types of triggers supported:
        |- trigger_multiple
        |- trigger_use
		|- trigger_use_touch
        |- trigger_hurt
		|- trigger_damage ( sort of )
	
	
    .delay - delay between triggering.
    .dmg - dmg to do for hurt triggers.
    ._color - used in debug to change line color.
	.hintstring - shows string when inside trigger.
	.cursorhint - shows shader when inside trigger.


        -==Debug==-

    When developer_script is enabled and the "dr_debugTriggers" dvar is set,
    boxes will be drawn around triggers to help determine the position.
    use ._color to change the color.


***Notes:

    1. Only rectangular prism shaped triggers will be made, with no rotation.
    2. Waittill("trigger") method only registers players. You can check to see
        if other entities are touching the trigger by: if( entity isTouchingTrigger(trigger) )


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
*/

spawnTrigger(volume, origin, classname, targetname, hintstring, dmg)
{
    trigger = spawnStruct();
	trigger.volume = volume;
	trigger.origin = (origin[0], origin[1], origin[2]);
	trigger.classname = classname;
	trigger.targetname = targetname;
	trigger.type = undefined;
	trigger.isTrigger = true;
	trigger.enabled = true;
	trigger.deleted = false;
    trigger.delay = 0;
	
	if (classname == "trigger_multiple")
	{
		trigger.type = "multiple";
		trigger._color = (0,1,1);
	}
    if(classname == "trigger_hurt")
	{
		trigger.type = "hurt";
		trigger.dmg = dmg;
		trigger._color = (1,0,0);
	}
	if(classname == "trigger_use" || classname == "trigger_use_touch")
	{
		trigger.type = "use_touch";
		trigger.hintstring = hintstring;
		trigger.cursorhint = "HINT_NOICON";
		trigger._color = (1,1,0);
	}
	if(classname == "trigger_damage")
	{
		trigger.type = "damage";
		trigger._color = (0,1,0);
		trigger.accumulate = 0; // This much damage must be accumulated before it will trigger
		trigger.threshold = 0; // The min amount of damage that must be done to it to trigger it
		trigger.excludeTypes = []; // MOD_BAYONET, MOD_EXPLOSIVE, MOD_GRENADE, MOD_GRENADE_SPLASH, MOD_IMPACT, MOD_MELEE, MOD_PISTOL_BULLET, MOD_PROJECTILE, MOD_PROJECTILE_SPLASH, MOD_RIFLE_BULLET, MOD_UNKNOWN
		trigger thread _damage_think();
	}
	if(trigger.type != "damage")
		trigger thread _watchTrigger();
	
	_addTriggerIntoList( trigger );
	trigger thread _autoUpdateVolume();
	
    return trigger;
}

_addTriggerIntoList( trigger )
{
	if( !isDefined(level.spawnableTriggers) )
		level.spawnableTriggers = [];
	level.spawnableTriggers[level.spawnableTriggers.size] = trigger;
}

_watchTrigger()
{
	self thread _showTillNotified("triggerDeleted");
    while(!self.deleted)
    {
		level.players = getEntArray ("player", "classname");
        for(i=0;i<level.players.size;i++)
        {
            player = level.players[i];
            if(player.sessionstate != "playing")
                continue;

            if(player isTouchingTrigger(self) && player _canTrigger(self) && self.enabled)
            {
				if (getDvarInt("spawnable_triggers_debug_names") == 1)
				{
					if (!isDefined(self.targetname) || self.targetname == "")
						tname = "undefined";
					else
						tname = self.targetname;
					player iPrintLn("^1Targetname:^7 " + tname);
					wait ( 1 );
					continue;
				}
				
                if(self.type == "hurt")
				{
					if(self.dmg > 0)
						player maps\mp\gametypes\_callbacksetup::CodeCallback_PlayerDamage(self, undefined, self.dmg, 0, "MOD_TRIGGER_HURT", "none", player.origin, (0,0,0), "none", 0);
				}
                else if(self.type == "use_touch")
				{
					player thread _hintString( self, self.hintstring );
					player thread _cursorHint( self, self.cursorhint );
					if(!player useButtonPressed() || isDefined(player.use_trigger_delay) && player.use_trigger_delay > 0)
						continue;
					
					player thread _use_trigger_wait(0.2);
				}

                self notify("trigger", player);

                if(self.delay > 0)
                    wait( self.delay );
            }
        }
        wait( 0.05 );
    }
}

isTouchingTrigger(trigger)
{
    return self _isInVolume(trigger.volume);
}

_isInVolume(volume)
{
	player_height = 70.0;
	player_radius = 15.0;
	
	if (self getStance() == "crouch")
		player_height = 50;
	else if (self getStance() == "prone")
		player_height = 30;
	
	volume[0] -= player_radius + 0; //fix for player collision
	volume[1] -= player_radius + 0; //fix for player collision
	volume[2] -= player_height + 0; //fix for player collision
	volume[3] += player_radius + 0; //fix for player collision
	volume[4] += player_radius + 0; //fix for player collision
	volume[5] += -1; //fix for player collision
	
    max[0] = _getVmax(volume, 0);
    max[1] = _getVmax(volume, 1);
    max[2] = _getVmax(volume, 2);
    min[0] = _getVmin(volume, 0);
    min[1] = _getVmin(volume, 1);
    min[2] = _getVmin(volume, 2);

    for(axis=0;axis<3;axis++)
    {
        if(self.origin[axis] < min[axis] || self.origin[axis] > max[axis])
            return false;
    }
    return true;
}

_getVmax(points, axis)
{
    max = undefined;

    for(i=0;i<points.size;i+=3)
    {
        if(!isdefined(max) || points[i+axis] > max)
        {
            max = points[i+axis];
        }
    }
    return max;
}

_getVmin(points, axis)
{
    min = undefined;

    for(i=0;i<points.size;i+=3)
    {
        if(!isdefined(min) || points[i+axis] < min)
        {
            min = points[i+axis];
        }
    }
    return min;
}

_autoUpdateVolume()
{
	self.scale = ( int(self.origin[0]) - int(self.volume[0]), int(self.origin[1]) - int(self.volume[1]), int(self.origin[2]) - int(self.volume[2]) );
	while(!self.deleted)
	{
		old_origin = self.origin;
		
		while(self.origin == old_origin)
			wait ( 0.05 );

		self.volume[0] = int(self.origin[0]) - self.scale[0];
		self.volume[3] = int(self.origin[0]) + self.scale[0];
		
		self.volume[1] = int(self.origin[1]) - self.scale[1];
		self.volume[4] = int(self.origin[1]) + self.scale[1];
		
		self.volume[2] = int(self.origin[2]) - self.scale[2];
		self.volume[5] = int(self.origin[2]) + self.scale[2];
	}
}

_debugTrigger(volume)
{
	if( getDvarInt("r_drawTriggers") != 1 )
        return;

    if(!isdefined(self._color))
        self._color = (1,1,1);

    max[0] = _getVmax(volume, 0);
    max[1] = _getVmax(volume, 1);
    max[2] = _getVmax(volume, 2);
    min[0] = _getVmin(volume, 0);
    min[1] = _getVmin(volume, 1);
    min[2] = _getVmin(volume, 2);

    line( (max[0], max[1], max[2]), (min[0], max[1], max[2]), self._color);
    line( (max[0], max[1], max[2]), (max[0], min[1], max[2]), self._color);
    line( (max[0], max[1], max[2]), (max[0], max[1], min[2]), self._color);

    line( (min[0], min[1], max[2]), (min[0], max[1], max[2]), self._color);
    line( (min[0], min[1], max[2]), (max[0], min[1], max[2]), self._color);
    line( (min[0], min[1], max[2]), (min[0], min[1], min[2]), self._color);

    line( (max[0], min[1], min[2]), (max[0], max[1], min[2]), self._color);
    line( (max[0], min[1], min[2]), (min[0], min[1], min[2]), self._color);
    line( (max[0], min[1], min[2]), (max[0], min[1], max[2]), self._color);

    line( (min[0], max[1], min[2]), (max[0], max[1], min[2]), self._color);
    line( (min[0], max[1], min[2]), (min[0], max[1], max[2]), self._color);
    line( (min[0], max[1], min[2]), (min[0], min[1], min[2]), self._color);

}

_showTillNotified(notify1, notify2, notify3, notify4)
{
	self notify("NEWshowTriggerTillNotified");
	self endon("NEWshowTriggerTillNotified");
	
	self endon(notify1);
	self endon(notify2);
	self endon(notify3);
	self endon(notify4);
	while(!self.deleted)
	{
		_debugTrigger(self.volume);
		wait ( 0.05 );
	}
}

_hintString( trigger, text )
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
	
	while(isDefined(self.hintstringhud) && isDefined(trigger) && self isTouchingTrigger(trigger) && isAlive(self) && self.hintstringhud.text == trigger.hintstring && trigger.enabled && !trigger.deleted)
		wait ( 0.1 );
		
	self.hintstringhud fadeOverTime( 0.1 );
	self.hintstringhud.alpha = 0;
	wait ( 0.1 );
	if (isDefined(self.hintstringhud))
		self.hintstringhud destroy();
}

setHintStringTrig( string )
{
	self.hintstring = string;
}

_cursorHint( trigger, shader )
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
	
	while(isDefined(self.cursorhinthud) && isDefined(trigger) && self isTouchingTrigger(trigger) && isAlive(self) && self.cursorhinthud.shader == trigger.cursorhint && trigger.enabled && !trigger.deleted)
		wait ( 0.1 );
		
	self.cursorhinthud fadeOverTime( 0.1 );
	self.cursorhinthud.alpha = 0;
	wait ( 0.1 );
	if (isDefined(self.cursorhinthud))
		self.cursorhinthud destroy();
}

setCursorHintTrig( shader )
{
	self.cursorhint = shader;
}

disableTrigger()
{
	if (!isDefined(self.originalColor))
		self.originalColor = self._color;
		
	self._color = (0,0,0);
	self.enabled = false;
}

enableTrigger()
{
	self._color = self.originalColor;
	self.enabled = true;
}

deleteTrigger()
{
	level notify("deletedTrigger", self);
	self notify("triggerDeleted");
	self.deleted = true;
	self.restoreVolume = self.volume;
	for(i=0; i < self.volume.size; i++)
		self.volume[i] = 0;
}

linkTriggerTo(target)
{
	self thread linkTriggerTo(target);
}
_linkTriggerTo(target)
{
	while(!self.deleted)
	{
		if(self.origin != target.origin)
			self.origin = target.origin;
		wait ( 0.05 );
	}
}

moveTriggerX(amount, time)
{
	self thread moveTrigger(amount, time, "X");
}

moveTriggerY(amount, time)
{
	self thread moveTrigger(amount, time, "Y");
}

moveTriggerZ(amount, time)
{
	self thread moveTrigger(amount, time, "Z");
}

moveTriggerTo(origin, time)
{
	X = origin[0] - self.origin[0];
	Y = origin[1] - self.origin[1];
	Z = origin[2] - self.origin[2];

	self moveTriggerX(X, time);
	self moveTriggerY(Y, time);
	self moveTriggerZ(Z, time);
}

moveTrigger(amount, time, axis)
{
	if (!isDefined(time) || time < 0.05)
		time = 0.05;
		
	wSpeed = 0.05;
	
	tempTime = time / wSpeed;
	tempAmount = amount / tempTime;
	
	for(i = 0; i < tempTime; i++)
	{
		switch (axis)
		{
			case "X":
				self.origin = (self.origin[0] + tempAmount, self.origin[1], self.origin[2]);
				break;
				
			case "Y":
				self.origin = (self.origin[0], self.origin[1] + tempAmount, self.origin[2]);
				break;
				
			case "Z":
				self.origin = (self.origin[0], self.origin[1], self.origin[2] + tempAmount);
				break;
		}
		wait ( wSpeed );
	}
	self notify("movedone");
}

getTrig(name, key)
{
	if (!isDefined(level.spawnableTriggers))
		return;
	
	for(i = 0; i < level.spawnableTriggers.size; i++)
	{
		maptrig = level.spawnableTriggers[i];
		if (key == "targetname")
		{
			if (maptrig.targetname == name)
				return maptrig;
		}
		else if (key == "classname")
		{
			if (maptrig.classname == name)
				return maptrig;
		}
	}
	return "NoTrigger";
}

getTrigArray(name, key)
{
	if (!isDefined(level.spawnableTriggers))
		return;
	
	array = [];
	x = 0;
	
	for(i = 0; i < level.spawnableTriggers.size; i++)
	{
		maptrig = level.spawnableTriggers[i];
		if (key == "targetname")
		{
			if (maptrig.targetname == name)
			{
				array[x] = maptrig;
				x++;
			}
		}	
		else if (key == "classname")
		{
			if (maptrig.classname == name)
			{
				array[x] = maptrig;
				x++;
			}
		}
	}
	return array;
}

getTriggerNumber()
{
	if (!isDefined(level.spawnableTriggers))
		return;
	
	for(i = 0; i < level.spawnableTriggers.size; i++)
	{
		if (level.spawnableTriggers[i] == self)
			return i;
	}
	return "NoTrigger";
}

getTrigByNum( number )
{
	if (!isDefined(level.spawnableTriggers))
		return;
	
	for(i = 0; i < level.spawnableTriggers.size; i++)
	{
		if (i == number)
			return level.spawnableTriggers[i];
	}
	return "NoTrigger";
}

getAllTriggers()
{
	if (!isDefined(level.spawnableTriggers))
		return;
	
	return level.spawnableTriggers;
}

isSpawnedTrigger( trigger )
{
	if( !isDefined( trigger ) )
		trigger = self;
	
	trigs = getTrigArray( trigger.targetname, "targetname" );
	if( isDefined( trigs ) && trigs.size > 0 )
	{
		for( i = 0; i < trigs.size; i++ )
		{
			trig = trigs[i];
			if( trig == trigger )
				return true;
		}
	}
	return false;
}

// DAMAGE

_damage_think() // this is working but not ideally ( checks if script_model is hit ). only 1 size available
{
	self thread _showTillNotified("triggerDeleted");
	
	precacheModel("com_plasticcase_friendly");
	
	self.damage_obj = spawn( "script_model", self.origin );
	self.damage_obj.father = self;
	self.damage_obj setModel( "com_plasticcase_friendly" );
	self.damage_obj hide();
	self.damage_obj.damageTaken = 0;
	self.damage_obj.personalDamageTaken = [];
	self.damage_obj setCanDamage(true);
	self.damage_obj thread _damage_model_rotation( self, "default" );
	self.damage_obj thread _damage_link_to( self );
	self.damage_obj thread _damage_model_del( self );
	while(isDefined(self.damage_obj))
	{
		self.damage_obj waittill("damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags);
		self notify("damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags);
		
		goback = false;
		if(!self.enabled)
			goback = true;
		for(i = 0; i < self.excludeTypes.size; i++)
		{
			if(type == self.excludeTypes[i])
				goback = true;
		}
		if(goback)
			continue;
		
		if(amount < self.threshold)
			continue;
		
		self.damage_obj.damageTaken += amount;
		self.damage_obj.personalDamageTaken[attacker getEntityNumber()] += amount;
		
		if(self.damage_obj.damageTaken < self.accumulate)
			continue;
		
		self notify("trigger", attacker);
		
		wait ( 0.05 );
	}
}

_damage_link_to( target )
{
	while(!target.deleted)
	{
		if(self.origin != target.origin)
			self moveTo( target.origin, 0.05 );
		wait ( 0.1 );
	}
}

_damage_model_del( target )
{
	while(!target.deleted)
		wait ( 0.05 );
	self delete();
}

_damage_model_rotation( target, choice )
{
	switch( choice )
	{
		case 1:
			sizeX = 15; sizeY = 28; sizeZ = 14; // com_plasticcase_friendly box size rotate : 90
			self rotateYaw( 90, 0.05 );
		break;
		case "default":
		default:
			sizeX = 28; sizeY = 15; sizeZ = 14; // com_plasticcase_friendly box size rotate : 0
			self rotateYaw( 0, 0.05 );
		break;
	}
	target.volume[0] = target.origin[0]-sizeX; target.volume[1] = target.origin[1]-sizeY; target.volume[2] = target.origin[2]-sizeZ; target.volume[3] = target.origin[0]+sizeX; target.volume[4] = target.origin[1]+sizeY; target.volume[5] = target.origin[2]+sizeZ;
}

// fixes

_canTrigger( trigger ) // fix for noclip triggers
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

_use_trigger_wait( waittime )
{
	self.use_trigger_delay = waittime;
	wait ( self.use_trigger_delay );
	self.use_trigger_delay = 0;
}