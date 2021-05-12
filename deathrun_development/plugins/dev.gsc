//
// Plugin name: Dev
// Author: quaK
//
// Info: Only use this for testing.

init( modVersion )
{
	thread onPlayerConnect();
	thread onPlayerSpawn();
	
	//thread init_entity_visualizer();
}

onPlayerConnect()
{
	while(1)
	{
		level waittill("connected", player);
	}
}

onPlayerSpawn()
{
	while(1)
	{
		level waittill("jumper", player);
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
		// do stuff
	}
}

/*
______           __  _____  _____ 
| ___ \         /  ||  _  ||  _  |
| |_/ /_____  __`| || |/' || |_| |
|    // _ \ \/ / | ||  /| |\____ |
| |\ \  __/>  < _| |\ |_/ /.___/ /
\_| \_\___/_/\_\\___/\___/ \____/ 

*/

init_entity_visualizer() // made by Rex109
{
    level.printundefined = false; //Set this to true if you want to see undefined entities

    if(getDvarInt("developer_script") == 0 )
    {
        while(1)
        {
            iPrintLnBold("developer_script must be set to 1 for this plugin to work");
            wait 1;
        }
    }

    level waittill( "jumper", player );

    player setClientDvar("developer", "2");

    level.refPlayer = player;

    trig_damage = getEntArray("trigger_damage","classname");
    trig_disk = getEntArray("trigger_disk","classname");
    trig_friendlychain = getEntArray("trigger_friendlychain","classname");
    trig_hurt = getEntArray("trigger_hurt","classname");
    trig_lookat = getEntArray("trigger_lookat","classname");
    trig_multiple = getEntArray("trigger_multiple","classname");
    trig_once = getEntArray("trigger_once","classname");
    trig_radius = getEntArray("trigger_radius","classname");
    trig_use = getEntArray("trigger_use","classname");
    trig_use_touch = getEntArray("trigger_use_touch","classname");

    script_brushmodel = getEntArray("script_brushmodel","classname");
    script_model = getEntArray("script_model","classname");
    script_origin = getEntArray("script_origin","classname");
    script_struct = getEntArray("script_struct","classname");
    script_vehicle = getEntArray("script_vehicle","classname");
    script_vehicle_mp = getEntArray("script_vehicle_mp","classname");

    for(i=0;i<trig_damage.size;i++)
		trig_damage[i] thread spawnName();
    
    for(i=0;i<trig_disk.size;i++)
		trig_disk[i] thread spawnName();

    for(i=0;i<trig_friendlychain.size;i++)
		trig_friendlychain[i] thread spawnName();

    for(i=0;i<trig_hurt.size;i++)
		trig_hurt[i] thread spawnName();

    for(i=0;i<trig_lookat.size;i++)
		trig_lookat[i] thread spawnName();

    for(i=0;i<trig_multiple.size;i++)
		trig_multiple[i] thread spawnName();

    for(i=0;i<trig_once.size;i++)
		trig_once[i] thread spawnName();

    for(i=0;i<trig_radius.size;i++)
		trig_radius[i] thread spawnName();

    for(i=0;i<trig_use.size;i++)
		trig_use[i] thread spawnName();

    for(i=0;i<trig_use_touch.size;i++)
		trig_use_touch[i] thread spawnName();

    for(i=0;i<script_brushmodel.size;i++)
		script_brushmodel[i] thread spawnName();

    for(i=0;i<script_model.size;i++)
		script_model[i] thread spawnName();

    for(i=0;i<script_origin.size;i++)
		script_origin[i] thread spawnName();

    for(i=0;i<script_struct.size;i++)
		script_struct[i] thread spawnName();

    for(i=0;i<script_vehicle.size;i++)
		script_vehicle[i] thread spawnName();

    for(i=0;i<script_vehicle_mp.size;i++)
		script_vehicle_mp[i] thread spawnName();
}

spawnName()
{
    self endon("undefined");

	targetname = "";
    if(isDefined(self.targetname))
        targetname = self.targetname;
    else
    {
        if(!level.printundefined)
            self notify("undefined");

        targetname = "Undefined_targetname!";
    }

	classname = "";
    if(isDefined(self.classname))
        classname = self.classname;
    else
    {
        if(!level.printundefined)
            self notify("undefined");

        classname = "Undefined_classname!";
    }

    color = getColor(classname);

    while(isDefined(self) && isDefined(level.refPlayer))
    {
        if(distance(level.refPlayer getOrigin(),self getOrigin()) < 1500)
        {
            print3d(self getOrigin(), targetname, (1.0, 1.0, 1.0), 1, 1, 10);
            print3d(self getOrigin()-(0,0,15), classname, color, 1, 1, 10);
        }
        wait 0.1;
    }
}

getColor(classname)
{
    if (isSubStr(classname, "trigger_"))
        return (0.0, 1.0, 0.0);

    return (0.0, 1.0, 1.0);
}