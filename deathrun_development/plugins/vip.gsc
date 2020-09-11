//
// Plugin name: VIP
// Author: quaK
//

init( modVersion )
{
	addVip( "c1b3d865a9eb5951", "quaK" );
	
	precacheItem("beretta_silencer_mp");
	
	thread onPlayerSpawned();

	while( 1 )
	{
		level waittill( "connected", player );
	
		if( !isDefined( player.pers["vip"] ) )
			player.pers["vip"] = false;

		if( !player.pers["vip"] ) 
			player thread verifyVIP();
	}
}

verifyVIP()
{
	if(isDefined(level.vips) == false)
		return;
	
	for( i = 0; i < level.vips.size; i++ )
	{
		if( isDefined(level.vips[i]["guid"]) && level.vips[i]["guid"] != "" )
		{
			if( self getGuid() == level.vips[i]["guid"] )
			{
				self.pers["vip"] = true;
				self.pers["vipOnce"] = false;
				self.pers["vipThrice"] = 0;
				vipAlert( self );
				return;
			}
		}
	}
}

vipAlert( who )
{
	iPrintLnBold("^3[VIP]^4 " + who.name + " ^7joined the server!");
}

onPlayerSpawned()
{
	while( 1 )
	{
		level waittill( "jumper", player );
		//player iPrintLn("your guid: " + player getGuid());
		if( !player.pers["vip"] )
			continue;
		
		player thread doVIPStuff();
	}
}

doVIPStuff()
{
	self endon("death");
	waittillframeend; wait 0.10;
	//self thread VIPGun();
	//self thread VIPPerks();
	
	if( self.pers["vipOnce"] == false )
	{
		self.pers["vipOnce"] = true;
		self braxi\_mod::giveLife();
	}
			
	if ( self.pers["vipThrice"] < 3 )
	{
			self thread VIPSpawnAll();
	}
}

VIPGun()
{
	if ( level.trapsDisabled == false && self.pers["team"] != "axis" )
		self giveWeapon( "beretta_silencer_mp" );
}

VIPPerks()
{
	self maps\mp\perks\_perks::givePerk("specialty_fastreload");
}

VIPSpawnAll()
{
	self endon("disconnect");
	self notify("VIPkillme");
	self endon("VIPkillme");
	
	if ( self.pers["vipThrice"] >= 3 )
		return;
	
	wait 5;
	//if ( !isDefined( self.vipalreadytold ) )
		//self iPrintLnBold( "^7Say ^3#sa ^7or ^3#spawnall ^7to ^3spawn everyone" );
	//self.vipalreadytold = true;
	
	while( self.pers["vipThrice"] < 3 )
	{
		howmany = 3 - self.pers["vipThrice"];
		self iPrintLn( "You have ^2" + howmany + "^7 spawnall left" );
		
		for(;;)
		{
			level waittill("sayCommand", command, player);
			if(player == self)
			{
				if(toLower(command) == "sa" || toLower(command) == "spawnall")
				{
					break;
				}
			}
		}
		
		spawnedAmount = 0;
		players = getEntArray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			if (players[i].pers["team"] == "allies" && !isAlive(players[i]))
			{
				players[i] braxi\_mod::spawnPlayer();
				//players[i] iPrintLnBold("You were respawned by the ^3VIP^7!");
				spawnedAmount++;
			}
		}
		if (spawnedAmount == 0)
		{
			self iPrintLn("^3[VIP]:^7 There is no one to respawn!");
		}
		else
		{
			iPrintLnBold("^3[VIP]^7\nEveryone respawned!");
			self.pers["vipThrice"]++;
		}
	}
	self iPrintLn("You have used all ^2spawnalls^7!");
}

addVip( guid, name )
{
	if(isDefined(level.vips) == false)
		level.vips = [];
	
	num = level.vips.size;
	level.vips[num]["guid"] = guid;
	level.vips[num]["name"] = name;
}