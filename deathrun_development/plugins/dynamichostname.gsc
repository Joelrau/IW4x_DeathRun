//
// Plugin name: Dynamic Host Name
// Author: quaK
//

init( modVersion )
{
	original_host_name = "^2Quak's^7 Deathrun ^22.1 ^2INDEV";
	
	updateHostName( original_host_name + "^7 | ^3Round^7:^1 " + level.dvar["playedrounds"] + "/" + level.dvar["round_limit"] + "^7"  );
	
	//thread creepyHostName( original_host_name );
}

updateHostName( new_hostname )
{	
	if( new_hostname == "" )
		return;
	
	setDvar( "sv_hostname", new_hostname );
}

creepyHostName( original_host_name )
{
	strings = strTok( "Hello there :)|Nice weather, don't u think?|Come play on my server!", "|" );
	waitDur = 10;
	while(1)
	{
		r = randomIntRange( 0, strings.size );
		
		updateHostName( original_host_name + " | " + strings[r] );
		wait waitDur;
	}
}