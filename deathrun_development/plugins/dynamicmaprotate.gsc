//
// Plugin name: Dynamic Map Rotate
// Author: quaK
//

init( modVersion )
{
	thread mapRotate();
}

mapRotate()
{
	i = 0;
	waitDur = 1800;
	while(1)
	{
		wait waitDur;
		
		players = braxi\_common::getAllPlayers();
		if(!isDefined(players) || players.size == 0)
		{
			if(i >= waitDur)
			{
				mapRotation = getDvar( "sv_mapRotation" );
				mapRotation_raw = strTok( mapRotation, " " );
				maps = [];
				for(i = 0; i < mapRotation_raw.size; i++)
				{
					if( mapRotation_raw[i] != "map" && mapRotation_raw[i] != getDvar( "mapname" ) )
					{
						maps[maps.size] = mapRotation_raw[i];
					}
				}
				if(maps.size < 1)
				{
					return;
				}
				smap = maps[randomIntRange(0, maps.size)];
				map( smap );
			}
			i += waitDur;
		}
		else
		{
			i = 0;
		}
	}
}

