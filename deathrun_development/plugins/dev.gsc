//
// Plugin name: Dev
// Author: quaK
//
// Info: Only use this for testing.

#include map_scripts\_spawnable_triggers;

init( modVersion )
{
	thread onPlayerConnect();
	thread onPlayerSpawn();
	
	//thread showBrushmodelStuff();
	//thread showOriginStuff();
}

onPlayerConnect()
{
	while(1)
	{
		level waittill("connected", player);
		//player thread test1();
		//player thread testHealth();
	}
}

onPlayerSpawn()
{
	while(1)
	{
		level waittill("jumper", player);
	}
}

showBrushmodelStuff()
{
	brushes = getEntArray("script_brushmodel", "classname");
	for(i = 0; i < brushes.size; i++)
	{
		brush = brushes[i];
		brush thread brushmodelDebugInfo1();
	}
}

brushmodelDebugInfo1()
{
	while(isDefined(self))
	{
		self debugInfo((1, 1, 1));
		wait ( 0.05 );
	}
}

showOriginStuff()
{
	origins = getEntArray("script_origin", "classname");
	for(i = 0; i < origins.size; i++)
	{
		origin = origins[i];
		origin thread originStuff();
	}
}

originStuff()
{
	while(isDefined(self))
	{
		self debugInfo((0, 1, 1));
		wait ( 0.05 );
	}
}

debugInfo(color)
{
	if( isDefined( self.classname ) )
		print3d( self.origin+(0,0,2), "classname: " +self.classname, color, 1, 0.2 );
	if( isDefined( self.targetname ) )
		print3d( self.origin+(0,0,0), "targetname: " +self.targetname, color, 1, 0.2 );
}

testHealth()
{
	while(1)
	{
		self iPrintLn("self health: " + self.health);
		self iPrintLn("self maxhealth: " + self.maxhealth);
		wait 1;
	}
}

test1()
{
	self thread testButton();
	wait 5;
	self iPrintlnBold( "^7Press ^3[{+actionslot 4}] ^7to ^3test" );
}
testButton()
{
	self endon("disconnect");
	
	self notifyOnPlayerCommand( "xuxu", "+actionslot 4" );
	for(;;) 
	{
		self waittill( "xuxu" );
		players = braxi\_common::getAllPlayers();
		for( i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.pers["team"] != "axis" && !isAlive(player))
			{
				player thread braxi\_teams::setTeam( "allies" );
				player braxi\_mod::spawnPlayer();
			}
		}
	}
}