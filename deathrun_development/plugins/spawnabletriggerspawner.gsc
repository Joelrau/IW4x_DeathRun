//
// Plugin name: Spawnable Trigger Spawner
// Author: quaK
//
// This plugin is made for _spawnable_triggers.gsc
//

#include map_scripts\_spawnable_triggers;

init( modVersion )
{
	thread playerSpawned();
}

playerSpawned()
{
	while( 1 )
	{
		level waittill( "player_spawn", player );
	
		player notify( "end this shit jobba" );
		player thread doTheJob();
		player thread commands();
	}
}

commands()
{
	self endon( "disconnect" );
	self endon( "death" );
	while( 1 )
	{
		self waittill( "menuresponse", menu, cmd );

		if( cmd == "save_trigger" && isDefined( self.selectedTrig ) )
		{
			trigger = self.selectedTrig;
			if(trigger.targetname == "")
				trigger.hintstring = "targetname";
			if(trigger.hintstring == "")
				trigger.hintstring = "hintstring";
			
			originstring = "orig = " + trigger.origin + ";";
			scalestring = "scale = " + trigger.scale + ";";
			volumestring = "volume = []; volume[0] = orig[0] - scale[0]; volume[1] = orig[1] - scale[1]; volume[2] = orig[2] - scale[2]; volume[3] = orig[0] + scale[0]; volume[4] = orig[1] + scale[1]; volume[5] = orig[2] + scale[2];";
			spawnstring = "trig = spawnTrigger(volume, orig, " + "\"" + trigger.classname + "\"" + ", " + "\"" + trigger.targetname + "\"" + ", " + "\"" + trigger.hintstring + "\"" + ", 0);"; // volume, origin, classname, targetname, hintstring, dmg;
			logstring = "\nSPAWNABLE_TRIGGER:\n" + originstring + "\n" + scalestring + "\n" + volumestring + "\n" + spawnstring + "\n";
			
			logPrint( logstring );
			printLn( logstring );
			
			if( !isDefined( logstring ) || logstring == undefined || logstring == "undefined" )
				iPrintLnBold( "failed to save trigger " + trigger getTriggerNumber() );
			else
				iPrintLnBold( "saved trigger " + trigger getTriggerNumber() + "\nconsole_mp.log" );
		}
		if( cmd == "save_trigger_all" && isDefined( level.spawnedDevTriggers ) )
		{
			logstring = "\nSPAWNABLE_TRIGGERS:\n";
			triggers = getSpawnedTriggers();
			for( i = 0; i < triggers.size; i++ )
			{
				trigger = triggers[i];
				if(trigger.targetname == "")
					trigger.hintstring = "targetname";
				if(trigger.hintstring == "")
					trigger.hintstring = "hintstring";
			
				originstring = "orig = " + trigger.origin + ";";
				scalestring = "scale = " + trigger.scale + ";";
				volumestring = "volume = []; volume[0] = orig[0] - scale[0]; volume[1] = orig[1] - scale[1]; volume[2] = orig[2] - scale[2]; volume[3] = orig[0] + scale[0]; volume[4] = orig[1] + scale[1]; volume[5] = orig[2] + scale[2];";
				spawnstring = "trig = spawnTrigger(volume, orig, " + "\"" + trigger.classname + "\"" + ", " + "\"" + trigger.targetname + "\"" + ", " + "\"" + trigger.hintstring + "\"" + ", 0);"; // volume, origin, classname, targetname, hintstring, dmg;
				logstring = logstring + originstring + "\n" + scalestring + "\n" + volumestring + "\n" + spawnstring + "\n\n";
			}
			logPrint( logstring );
			printLn( logstring );
			
			if( !isDefined( logstring ) || logstring == undefined || logstring == "undefined" )
				iPrintLnBold( "failed to save triggers" );
			else
				iPrintLnBold( "saved triggers\nconsole_mp.log" );
		}
	}
}

doTheJob()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "end this shit jobba" );
	
	self.maxhealth = 999999999;
	self.health = 999999999;

	if( !isDefined( self.devTrigHuds ) )
	{
		self.devTrigHuds = [];
		
		self.devTrigHuds[0] = braxi\_mod::addTextHud( self, 10, 150+50, 1, "left", "middle", 1.4 ); // selected trigger
		self.devTrigHuds[1] = braxi\_mod::addTextHud( self, 10, 165+50, 1, "left", "middle", 1.4 ); // selected mode
		self.devTrigHuds[2] = braxi\_mod::addTextHud( self, 10, 180+50, 1, "left", "middle", 1.4 ); // scale
		self.devTrigHuds[3] = braxi\_mod::addTextHud( self, 10, 195+50, 1, "left", "middle", 1.4 ); // origin
		self.devTrigHuds[4] = braxi\_mod::addTextHud( self, 10, 210+50, 1, "left", "middle", 1.4 ); // type
		self.devTrigHuds[5] = braxi\_mod::addTextHud( self, 7, 5, 1, "left", "top", 1.4 );	// usage

		for( i = 0; i < self.devTrigHuds.size; i++ )
		{
			self.devTrigHuds[i].horzAlign = "fullscreen";
			self.devTrigHuds[i].vertAlign = "fullscreen";
		}
		self.devTrigHuds[5] setText( "^3melee^7: spawn trigger\n^3attack^7: select trigger \n^3offhand^7: unselect trigger\n^3aim^7: switch mode\n^3use^7: increment\n^3grenade^7: substract\n^3stand^7: X\n^3crouch^7: Y\n^3prone^7: Z\n^3save: ^7\openScriptMenu -1 save_trigger\n^3save all: ^7\openScriptMenu -1 save_trigger_all" );
	}
	//========================================================

	self.selectedTrig = undefined;

	while( self.sessionstate == "playing" )
	{
		wait 0.1;
		
		if( self meleeButtonPressed() ) // create new trigger
		{
			self.selectedTrig = newTrigger();
			
			wait 0.5;
		}

		if( self attackButtonPressed() ) // select trigger ( need to be touching the trigger )
		{
			ents = getSpawnedTriggers();
			if(ents.size == 0)
				continue;
			for( i = 0; i < ents.size; i++ )
			{
				if( self isTouchingTrigger( ents[i] ) )
				{
					self.selectedTrig = ents[i];
					self iPrintLnBold( "selected trigger " + self.selectedTrig getTriggerNumber() );
					wait 0.5;
					break;
				}
			}
		}
		
		if( !isDefined( self.selectedTrig ) )
		{
			self.devTrigHuds[0] setText( "Trigger not selected" );
			for( i = 1; i < self.devTrigHuds.size-1; i++ )
				self.devTrigHuds[i] setText( " " );
			continue;
		}

		//========================================================
		
		if( self secondaryOffhandButtonPressed() ) // unselect trigger
		{
			if( isDefined( self.selectedTrig ) )
				self.selectedTrig = undefined;
			continue;
		}
		
		if( self adsButtonPressed() ) // switch mode
		{
			if( self.selectedTrig.mode == "scale" )
				self.selectedTrig.mode = "origin";
			else if ( self.selectedTrig.mode == "origin" )
				self.selectedTrig.mode = "type";
			else
				self.selectedTrig.mode = "scale";
			
			self allowAds( false );
			wait 0.05;
			self allowAds( true );
		}
		
		amount = 1;
		x = 0;
		if ( self useButtonPressed() ) 
				x = amount; // Adding
			else if ( self fragButtonPressed() )
				x = amount*-1; // Subtracting
				
		if( self useButtonPressed() || self fragButtonPressed() )
		{
			if( self.selectedTrig.mode == "scale" && self.selectedTrig.classname != "trigger_damage" )
			{
				if( self getStance() == "stand" ) // X
				{
					self.selectedTrig.volume[0] -= x;
					self.selectedTrig.volume[3] += x;
					self.selectedTrig.scale = ( self.selectedTrig.scale[0] + x, self.selectedTrig.scale[1], self.selectedTrig.scale[2] );
				}
				else if( self getStance() == "crouch" ) //Y
				{
					self.selectedTrig.volume[1] -= x;
					self.selectedTrig.volume[4] += x;
					self.selectedTrig.scale = ( self.selectedTrig.scale[0], self.selectedTrig.scale[1] + x, self.selectedTrig.scale[2] );
				}
				else if( self getStance() == "prone" ) //Z
				{
					self.selectedTrig.volume[2] -= x;
					self.selectedTrig.volume[5] += x;
					self.selectedTrig.scale = ( self.selectedTrig.scale[0], self.selectedTrig.scale[1], self.selectedTrig.scale[2] + x );
				}
			}
			else if( self.selectedTrig.mode == "origin" )
			{
				if( self getStance() == "stand" ) // X
				{
					self.selectedTrig moveTriggerX(x);
				}
				else if( self getStance() == "crouch" ) //Y
				{
					self.selectedTrig moveTriggerY(x);
				}
				else if( self getStance() == "prone" ) //Z
				{
					self.selectedTrig moveTriggerZ(x);
				}
				self.selectedTrig waittill("movedone");
			}
			else if( self.selectedTrig.mode == "type" )
			{
				if(!isDefined(level.devTrigTypesArray))
				{
					level.devTrigTypesArray = [];
					level.devTrigTypesArray[level.devTrigTypesArray.size] = "trigger_multiple";
					level.devTrigTypesArray[level.devTrigTypesArray.size] = "trigger_use_touch";
					level.devTrigTypesArray[level.devTrigTypesArray.size] = "trigger_hurt";
					level.devTrigTypesArray[level.devTrigTypesArray.size] = "trigger_damage";
				}
				
				for( i = 0; i < level.devTrigTypesArray.size; i++ )
					if( level.devTrigTypesArray[i] == self.selectedTrig.classname )
						break;
				
				if( x > 0 ) // up
				{
					if(i < level.devTrigTypesArray.size-1)
						self.selectedTrig.classname = level.devTrigTypesArray[i+1];
					else if (i >= level.devTrigTypesArray.size-1)
						self.selectedTrig.classname = level.devTrigTypesArray[0];
				}
				else if ( x < 0 ) // down
				{
					if(i > 0)
						self.selectedTrig.classname = level.devTrigTypesArray[i-1];
					else if (i <= 0)
						self.selectedTrig.classname = level.devTrigTypesArray[level.devTrigTypesArray.size-1];
				}
				self.selectedTrig = respawnTrigger( self.selectedTrig );
				wait 0.25;
			}
		}
		
		if( randomIntRange(0, 100) == 50 )
			for(i = 0; i < self.devTrigHuds.size; i++)
				self.devTrigHuds[i] clearAllTextAfterHudElem();
		
		self.devTrigHuds[0] setText( "Selected: " 	+ self.selectedTrig getTriggerNumber() );
		self.devTrigHuds[1] setText( "Mode: "		+ self.selectedTrig.mode );
		self.devTrigHuds[2] setText( "Scale: " 		+ self.selectedTrig.scale );
		self.devTrigHuds[3] setText( "Origin: " 	+ self.selectedTrig.origin );
		self.devTrigHuds[4] setText( "Type: " 		+ self.selectedTrig.classname );
	}
}

newTrigger()
{
	default_amount = 10;
	default_origin = (int(self.origin[0]), int(self.origin[1]), int(self.origin[2]));
	default_volume = []; default_volume[0] = default_origin[0]-default_amount; default_volume[1] = default_origin[1]-default_amount; default_volume[2] = default_origin[2]-default_amount; default_volume[3] = default_origin[0]+default_amount; default_volume[4] = default_origin[1]+default_amount; default_volume[5] = default_origin[2]+default_amount;
	trig = spawnTrigger(default_volume, default_origin, "trigger_spawned", "targetname", "hintstring", 0); // volume, origin, classname, targetname, hintstring, dmg
	trig.mode = "scale";
	trig.scale = ( default_amount, default_amount, default_amount );
	spawnedTriggers( trig );
	return trig;
}

respawnTrigger( oldTrigger )
{
	volume = oldTrigger.volume;
	if(isDefined(oldTrigger.devoriginalvolume))
	volume = oldTrigger.devoriginalvolume;
	origin = oldTrigger.origin;
	classname = oldTrigger.classname;
	targetname = oldTrigger.targetname;
	hintstring = oldTrigger.hintstring;
	if(classname == "trigger_use_touch" && hintstring == "")
	hintstring = "hintstring";
	mode = oldTrigger.mode;
	scale = oldTrigger.scale;
	if(isDefined(oldTrigger.originalscale))
	scale = oldTrigger.originalscale;
	ordernumber = oldTrigger.ordernumber;
	oldTrigger deleteTrigger();
	trig = spawnTrigger(volume, origin, classname, targetname, hintstring, 0); // volume, origin, classname, targetname, hintstring, dmg
	trig.mode = mode;
	trig.scale = scale;
	trig.ordernumber = ordernumber;
	if(classname == "trigger_damage")
	{
	trig.devoriginalvolume = volume;
	trig.originalscale = scale;
	}
	spawnedTriggers( trig );
	return trig;
}

spawnedTriggers( trigger )
{
	if( !isDefined( level.spawnedDevTriggers ) )
		level.spawnedDevTriggers = [];
	
	for( i = 0; i < level.spawnedDevTriggers.size; i++ )
	{
		if( isDefined( trigger.ordernumber ) )
		{
			if( trigger.ordernumber == level.spawnedDevTriggers[i].ordernumber )
			{
				level.spawnedDevTriggers[i] = trigger;
				return;
			}
		}
	}
	level.spawnedDevTriggers[level.spawnedDevTriggers.size] = trigger;
	trigger.ordernumber = level.spawnedDevTriggers.size;
}

getSpawnedTriggers()
{
	if( !isDefined( level.spawnedDevTriggers ) )
		return;
	return level.spawnedDevTriggers;
}