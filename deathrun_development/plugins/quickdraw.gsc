//
// Plugin name: SuperHuman
// Author: quaK
//

init( modVersion )
{
	setDvar("perk_quickDrawSpeedScale", 1.3);
	
	thread onPlayerSpawned();

	while( 1 )
	{
		level waittill( "connected", player );
		//do something here..
	}
}

onPlayerSpawned()
{
	while( 1 )
	{
		level waittill( "jumper", player );
		player thread quickdraw();
	}
}

quickdraw()
{
	wait .1;
	self maps\mp\perks\_perks::givePerk("specialty_quickdraw");
}