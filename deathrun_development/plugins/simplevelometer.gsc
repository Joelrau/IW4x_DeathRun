/*
______           __  _____  _____ 
| ___ \         /  ||  _  ||  _  |
| |_/ /_____  __`| || |/' || |_| |
|    // _ \ \/ / | ||  /| |\____ |
| |\ \  __/>  < _| |\ |_/ /.___/ /
\_| \_\___/_/\_\\___/\___/ \____/ 

*/

init(ver)
{	
    thread onPlayerSpawn();
}

onPlayerSpawn()
{
    while(1)
    {
        level waittill("player_spawn", player);
        player thread initVelo();
		player thread onMapEnd();
    }
}

onMapEnd()
{
	self endon( "disconnect" );
	level waittill("game over");
	
	if (isDefined(self.hud_velo))
		self.hud_velo destroy();
	
	if (isDefined(self.hud_maxvelo))
		self.hud_maxvelo destroy();
}

initVelo()
{
    self endon( "disconnect" );
	level endon( "game over" );
	
	self.maxspeed = 0;
	
	if (isDefined(self.hud_velo))
		self.hud_velo destroy();

	self.hud_velo = addTextHud( self, 0, -15, 1, "center", "bottom", 1.5 );
	self.hud_velo.horzAlign = "center";
    self.hud_velo.vertAlign = "bottom";
	self.hud_velo.hidewheninmenu = true;
	
	if (isDefined(self.hud_maxvelo))
		self.hud_maxvelo destroy();

	self.hud_maxvelo = addTextHud( self, 0, -30, 1, "center", "bottom", 1.5 );
	self.hud_maxvelo.horzAlign = "center";
    self.hud_maxvelo.vertAlign = "bottom";
	self.hud_maxvelo.hidewheninmenu = true;
	self.hud_maxvelo.label = &"^3(&&1)";
	
	self.hud_maxvelo setValue( 0 );
	self.hud_velo setValue( 0 );
	
	wait 0.5;
	
	while(1)
	{
		wait 0.01;
		
		velocity = self getPlayerSpeed();
		
		if (velocity > self.maxspeed)
			self.maxspeed = velocity;
		
		self.hud_velo setValue(velocity);
		self.hud_maxvelo setValue(self.maxspeed);
	}
}

getPlayerSpeed() {
    velocity = self getVelocity();
    return int( sqrt( ( velocity[0] * velocity[0] ) + ( velocity[1] * velocity[1] ) ) );
}

addTextHud( who, x, y, alpha, alignX, alignY, fontScale )
{
	if( isPlayer( who ) )
		hud = newClientHudElem( who );
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.fontScale = fontScale;
	return hud;
}