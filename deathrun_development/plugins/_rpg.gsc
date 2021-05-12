init( modVersion )
{
	level thread OnPlayerConnected();
}

onPlayerConnected()
{
	while(1)
	{
		level waittill("connected", player);
		player thread onRPGFired();
	}
}

onRPGFired()
{
	while(1)
	{
		self waittill("weapon_fired");
		if( self getCurrentWeapon() != "rpg_mp" )
			continue;
		
		anglesForward = anglesToForward(self getPlayerAngles());
		velocity = self getVelocity();
		
		power = 64;
		newAnglesForward = ( anglesForward[0] * -1, anglesForward[1] * -1, anglesForward[2] * -1 );
		newVelocity = ( velocity[0] + ( newAnglesForward[0] * power ), velocity[1] + ( newAnglesForward[1] * power ), velocity[2] + ( newAnglesForward[2] * power ) );
		
		self setVelocity( newVelocity );
	}
}