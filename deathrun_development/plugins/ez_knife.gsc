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
    self endon("disconnect");
    while(1)
    {
        level waittill("player_spawn", player);
        player.canknife = false;
        player thread watchForButton();
        player thread watchForWeapon();
    }
}

watchForWeapon()
{
    self endon("disconnect");
    self endon("death");

    self.currentweaponinhand = "";

    while(1)
    {
        if(self getCurrentWeapon() != "none" && self.currentweaponinhand != self getCurrentWeapon())
        {
            self.currentweaponinhand = self getCurrentWeapon();

            if (weaponClipSize(self.currentweaponinhand) == 0) {
                self.canknife = true;
            }
            else
            {
                self.canknife = false;
            }
        }

        wait 0.01;
    }
}


watchForButton()
{
    self endon("disconnect");
    self endon("death");

    while(1)
    {
        if(self attackButtonPressed() && self.canknife)
        {
            self braxi\_common::clientCmd( "+melee;-melee" );
        }
        wait 0.01;
    }
}