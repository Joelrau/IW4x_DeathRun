//
// Plugin name: Admins
// Author: quaK
//

/*
a - login to rcon
b - admin head icon
c - kill
d - wtf
e - spawn
f - warn
g - kick
h - ban
i - remove warn(s)
j - heal
k - bounce
l - drop item
m - teleport
n - finish round or map
o - restart round or map
p - give life
x - show message to players when admin join server

/bind <key> "openScriptMenu -1 adminmenu"
*/

init( modVersion )
{
	addAdmin( "c1b3d865a9eb5951", "abcdefghijklmnopx" , "quaK" );
	
	while( 1 )
	{
		level waittill( "connected", player );
		player thread verifyAdmin();
	}
}

verifyAdmin()
{
	if(isDefined(level.admins) == false)
		return;
	
	for( i = 0; i < level.admins.size; i++ )
	{
		if( isDefined(level.admins[i]["guid"]) && level.admins[i]["guid"] != "" )
		{
			if( self getGuid() == level.admins[i]["guid"] )
			{
				self.pers["admin"] = true;
				self.pers["permissions"] = level.admins[i]["permissions"];
				self.headicon = "headicon_admin";
				self setClientDvars( "dr_admin_name", self.name, "dr_admin_perm", self.pers["permissions"] );
				return;
			}
		}
	}
}

addAdmin( guid, permissions, name )
{
	if(isDefined(level.admins) == false)
		level.admins = [];
	
	num = level.admins.size;
	level.admins[num]["guid"] = guid;
	level.admins[num]["permissions"] = permissions;
	level.admins[num]["name"] = name;
}