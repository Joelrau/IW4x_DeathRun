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
		//player thread testCollision();
		//player thread testInvulnerability();
	}
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

testCollision()
{

		//self notSolid();
		self setContents( 288 );
		self iPrintLnBold("NOTSOLID");
}

testInvulnerability()
{
	self.originalhealth = self.health;
	self.originalmaxhealth = self.maxhealth;
	self.maxhealth = 9999999999;
	self.health = self.maxhealth;
	self iPrintLnBold("GOD");
	wait 10;
	self.maxhealth = self.originalmaxhealth;
	self.health = self.originalhealth;
	self iPrintLnBold("NOTGOD");
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