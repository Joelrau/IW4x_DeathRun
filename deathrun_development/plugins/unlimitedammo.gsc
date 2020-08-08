//
// Plugin name: Unlimited Ammo
// Author: quaK
//
init( modVersion )
{
	thread onPlayerSpawned();
}

onPlayerSpawned()
{
	while( 1 )
	{
		level waittill( "jumper", player );
		player thread doAmmo();
	}
}

doAmmo()
{
    self endon ( "disconnect" );
    self endon ( "death" );

    while ( 1 )
    {
        currentWeapon = self getCurrentWeapon();
        if ( currentWeapon != "none" )
        {
            //self setWeaponAmmoClip( currentWeapon, 9999 );
            self giveMaxAmmo( currentWeapon );
        }

        currentoffhand = self GetCurrentOffhand();
        if ( currentoffhand != "none" )
        {
            //self setWeaponAmmoClip( currentoffhand, 9999 );
            //self giveMaxAmmo( currentoffhand );
        }
        wait 1;
    }
}