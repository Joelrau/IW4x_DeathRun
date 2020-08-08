/*

///////////////////////////////////////////////////////////////
////|         |///|        |///|       |/\  \/////  ///|  |////
////|  |////  |///|  |//|  |///|  |/|  |//\  \///  ////|__|////
////|  |////  |///|  |//|  |///|  |/|  |///\  \/  /////////////
////|          |//|  |//|  |///|       |////\    //////|  |////
////|  |////|  |//|         |//|  |/|  |/////    \/////|  |////
////|  |////|  |//|  |///|  |//|  |/|  |////  /\  \////|  |////
////|  |////|  |//|  | //|  |//|  |/|  |///  ///\  \///|  |////
////|__________|//|__|///|__|//|__|/|__|//__/////\__\//|__|////
///////////////////////////////////////////////////////////////

 ██████╗ ██╗   ██╗ █████╗ ██╗  ██╗
██╔═══██╗██║   ██║██╔══██╗██║ ██╔╝
██║   ██║██║   ██║███████║█████╔╝ 
██║▄▄ ██║██║   ██║██╔══██║██╔═██╗ 
╚██████╔╝╚██████╔╝██║  ██║██║  ██╗
 ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
	
	Original mod by: BraXi;
	Edited mod by: quaK;
	
*/

getAllPlayers()
{
	return getEntArray( "player", "classname" );
}

getPlayingPlayers()
{
	players = getAllPlayers();
	array = [];
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] isActuallyAlive() && players[i].pers["team"] != "spectator" ) 
			array[array.size] = players[i];
	}
	return array;
}

cleanScreen()
{
	for( i = 0; i < 6; i++ )
	{
		iPrintlnBold( " " );
		iPrintln( " " );
	}
}

restrictSpawnAfterTime( time )
{
	wait time;
	level.allowSpawn = false;
}


getBestPlayerFromTime()
{
	score = 999999999;
	guy = undefined;

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		if( players[i].pers["time"] <= score )
		{
			score = players[i].pers["time"];
			guy = players[i];
		}
	}
	return guy;
}

float( value )
{
	setDvar("temp_float", value);
	return getDvarFloat("temp_float");
}

appendToDvar( dvar, string )
{
	setDvar( dvar, getDvar( dvar ) + string );
}

bounce( euler_angles )
{
	self setVelocity( self getVelocity() + euler_angles );
}

spawnCollision( origin, height, width )
{
	level.colliders[level.colliders.size] = spawn( "trigger_radius", origin, 0, width, height );
	level.colliders[level.colliders.size-1] setContents( 1 );
	level.colliders[level.colliders.size-1].targetname = "script_collision";
}

spawnSmallCollision( origin )
{
	level.colliders[level.colliders.size] = spawn( "script_model", origin );
	level.colliders[level.colliders.size-1] setContents( 1 );
	level.colliders[level.colliders.size-1].targetname = "script_collision";
}

deleteAfterTime( time )
{
	wait time;
	if( isDefined( self ) )
		self delete();
}

restartLogic()
{
	level notify( "kill logic" );
	wait .05;
	level thread braxi\_mod::gameLogic();
}

freeRunTimer()
{
	wait level.dvar["freerun_time"];
	level thread braxi\_mod::endRound( "Free Run round has ended", "jumpers" );
}

canStartRound( min )
{
	if (getPlayingPlayers().size >= min)
		return true;

	return false;
}

waitForEnoughPlayers( requiredPlayersCount )
{
	while (getPlayingPlayers().size < requiredPlayersCount)
		wait .5;
}

canReallySpawn()
{
	if( level.freeRun || self.pers["lifes"] )
		return true;

	if( !level.allowSpawn )
		return false;

	if( self.died )
		return false;
	return true;
}

isActuallyAlive()
{
	if( self.sessionstate == "playing" && !isGhost( self ) )
		return true;
	return false;
}

isGhost( player )
{
	return isDefined(player.ghost) && player.ghost == true;
}

isPlaying()
{
	return isActuallyAlive();
}

doDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, 0 );
}

loadWeapon( name, attachments, image )
{
	array = [];
	array[0] = name;

	if( isDefined( attachments ) )
	{
		addon = strTok( attachments, " " );
		for( i = 0; i < addon.size; i++ )
			array[array.size] = name + "_" + addon[i];
	}

	for( i = 0; i < array.size; i++ )
		precacheItem( array[i] + "_mp" );

	if( isDefined( image ) )
		precacheShader( image );
}

takeWeaponsExcept( saveWeapons )
{
	if( saveWeapons[0].size == 1 ) //if !isArray
	{
		temp_weap = saveWeapons;
		saveWeapons = [];
		saveWeapons[0] = temp_weap;
	}
	
	weaponsList = self GetWeaponsListAll();
	
	foreach ( weapon in weaponsList )
	{
		for(i = 0; i < saveWeapons.size; i++)
		{
			if( weapon == saveWeapons[i] )
			{
				continue;
			}
			else
			{
				self takeWeapon( weapon );
			}
		}
	}
}

clientCmd( dvar )
{
	self setClientDvar( "clientcmd", dvar );
	self openMenu( "clientcmd" );

	if( isDefined( self ) ) //for "disconnect", "reconnect", "quit", "cp" and etc..
		self closeMenu( "clientcmd" );	
}

makeActivator( time )
{
	self endon( "disconnect" );
	wait time;
	self braxi\_teams::setTeam( "axis" );
}

thirdPerson()
{
	if( !isDefined( self.tp ) || self.tp == false )
	{
		self.tp = true;
		self setClientDvar( "cg_thirdPerson", 1 );
		self iPrintLn( "Third Person Camera Enabled" );
	}
	else
	{
		self.tp = false;
		self setClientDvar( "cg_thirdPerson", 0 );
		self iPrintLn( "Third Person Camera Disabled" );
	}
}

getBestPlayerFromScore( type )
{
	if( type == "time" ) // hack
		return getBestPlayerFromTime();

	score = 0;
	guy = undefined;

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		if ( players[i].pers[type] >= score )
		{
			score = players[i].pers[type];
			guy = players[i];
		}
	}
	return guy;
}

playSoundOnAllPlayers( soundAlias )
{
	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] playLocalSound( soundAlias );
	}
}

playSoundOnPlayer( soundAlias, player )
{
	if( !isDefined(player) && isPlayer( self ) )
		player = self;
	
	audioPlayer = spawn( "script_origin", player.origin );
	audioPlayer playSound( soundAlias );
	audioPlayer thread follow( player );
	audioPlayer thread deleteAfterTime( 60 );
}

follow( who )
{
	self endon("stopfollowing");
	while(isDefined(self))
	{
		self.origin = who.origin;
		wait .05;
	}
}

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	if ( isDefined( ent ) )
	{
		deathAnim = ent getCorpseAnim();
		if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
			return;
	}

	wait( 0.2 );

	if ( !isDefined( ent ) )
		return;

	if ( ent isRagDoll() )
		return;

	deathAnim = ent getcorpseanim();

	startFrac = 0.35;

	if ( animhasnotetrack( deathAnim, "start_ragdoll" ) )
	{
		times = getnotetracktimes( deathAnim, "start_ragdoll" );
		if ( isDefined( times ) )
			startFrac = times[ 0 ];
	}

	waitTime = startFrac * getanimlength( deathAnim );
	wait( waitTime );

	if ( isDefined( ent ) )
	{
		ent startragdoll( 1 );
	}
}

getHitLocHeight( sHitLoc )
{
	switch( sHitLoc )
	{
		case "helmet":
		case "object":
		case "neck":
			return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun":
			return 48;
		case "torso_lower":
			return 40;
		case "right_leg_upper":
		case "left_leg_upper":
			return 32;
		case "right_leg_lower":
		case "left_leg_lower":
			return 10;
		case "right_foot":
		case "left_foot":
			return 5;
	}
	return 48;
}

waitTillNotMoving( timelimit )
{
	if( !isDefined(timelimit) )
		timelimit = 999;
	
	waittime = 0.15;
	timewaited = 0;
	
	stoppedBool = false;
	
	prevorigin = self.origin;
	
	while( isDefined( self ) && timewaited < timelimit )
	{
		wait waittime;
		timewaited += waittime;
		if ( self.origin == prevorigin )
		{
			stoppedBool = true;
			break;
		}
		prevorigin = self.origin;
	}
	if( stoppedBool == false )
	{
		if( isDefined( self ) )
			self delete();
	}
}

annoyMe()
{
	self endon( "disconnect" );

	while(1)
	{
		wait 0.5;
		self setClientDvar( "cantplay", 1 );
	}
}

bxLogPrint( text )
{
	if( level.dvar["logPrint"] )
		logPrint( text + "\n" );
}

delayedMenu()
{
	self endon( "disconnect" );
	wait 0.05; //waitillframeend;
	
	self closepopupMenu();
	self closeInGameMenu();
	self openpopupMenu(game["menu_team"]);
}

spawnHUD( x, y, alignX, alignY, color, font, duration )
{
	self.spawnedhud = newClientHudElem(self);
	self.spawnedhud.x = x;
	self.spawnedhud.y = y;
	self.spawnedhud.elemType = "font";
	self.spawnedhud.alignX = alignX; //center
	self.spawnedhud.alignY = alignY; //middle
	self.spawnedhud.horzAlign = alignX;
	self.spawnedhud.vertAlign = alignY;
	self.spawnedhud.color = color;
	self.spawnedhud.alpha = 1;
	self.spawnedhud.sort = 0;
	self.spawnedhud.font = font;
	self.spawnedhud.fontScale = 3;
	self.spawnedhud.foreground = true;
	self.spawnedhud.archived = false;	
	self.spawnedhud.hidewheninmenu = true;
	
	if (isDefined(duration))
		self thread destroySpawnedHUD( self.spawnedhud, duration );
	
	return self.spawnedhud;
}

destroySpawnedHUD( hud, duration )
{
	wait duration;
	hud fadeOverTime(0.5);
	hud.alpha = 0;
	wait (0.5);
	if (isDefined(hud))
		hud destroy();
}

warning( msg )
{
	if( !level.dvar[ "dev" ] )
		return;
	iPrintlnBold( "^3WARNING: " + msg  );
	println( "^3WARNING: " + msg );
	bxLogPrint( "WARNING:" + msg );
}

dropPlayer( player, method, msg1, msg2 )
{
	if( msg1 != "" )
		self setClientDvar( "ui_dr_info", msg1 );
	if( msg2 != "" )
		self setClientDvar( "ui_dr_info2", msg2 );

	num = player getEntityNumber();
	switch( method )
	{
	case "kick":
		kick( num );
		break;
	case "ban":
		ban( num );
		break;
	case "disconnect":
		clientCmd( "disconnect" );
		break;
	}
}

partymode() 
{
	level endon("stopparty");	
	players = getAllPlayers();
	for(k=0;k<players.size;k++) players[k] setClientDvar("r_fog", 1);
	for(;;wait .5)
		SetExpFog(256, 900, RandomFloat(1), RandomFloat(1), RandomFloat(1), 0.1); 
}

positiveOrNegative( num )
{
	if (num > 0)
		return "positive";
	else if (num < 0)
		return "negative";
	else
		return "zero";
}

firstLetterToUpper( word )
{
	newWord = _letterToUpper( word[0] );
	for(i=1;i<word.size;i++)
		newWord += word[i];
	return newWord;
}

toUpper( string )
{
	output = "";
	
	for ( i = 0; i < string.size; i++ )
	{
		if( string[i] == toLower(string[i]) )
			output += _letterToUpper( string[i] );
		else
			output += string[i];
	}
	return output;
}

_letterToUpper( letter )
{
	if		(letter == "a") letter = "A";
	else if	(letter == "b") letter = "B";
	else if	(letter == "c") letter = "C";
	else if	(letter == "d") letter = "D";
	else if	(letter == "e") letter = "E";
	else if	(letter == "f") letter = "F";
	else if	(letter == "g") letter = "G";
	else if	(letter == "h") letter = "H";
	else if	(letter == "i") letter = "I";
	else if	(letter == "j") letter = "J";
	else if	(letter == "k") letter = "K";
	else if	(letter == "l") letter = "L";
	else if	(letter == "m") letter = "M";
	else if	(letter == "n") letter = "N";
	else if	(letter == "o") letter = "O";
	else if	(letter == "p") letter = "P";
	else if	(letter == "q") letter = "Q";
	else if	(letter == "r") letter = "R";
	else if	(letter == "s") letter = "S";
	else if	(letter == "t") letter = "T";
	else if	(letter == "u") letter = "U";
	else if	(letter == "v") letter = "V";
	else if	(letter == "w") letter = "W";
	else if	(letter == "x") letter = "X";
	else if	(letter == "y") letter = "Y";
	else if	(letter == "z") letter = "Z";
	return letter;
}

// =============================================================================
//  Removes the color from a string.
//    <string> The string from wich we want the colors removed. (^0 ^1 ^2 ^3 ^4 ^5 ^6 ^7 ^8 ^9)
//	Script written by Scillman
// =============================================================================
removeColorFromString( string )
{
	output = "";

	for ( i = 0; i < string.size; i++ )
	{
		if ( string[i] == "^" )
		{
			if ( i < string.size - 1 )
			{
				if ( string[i + 1] == "0" || string[i + 1] == "1" || string[i + 1] == "2" || string[i + 1] == "3" || string[i + 1] == "4" ||
					 string[i + 1] == "5" || string[i + 1] == "6" || string[i + 1] == "7" || string[i + 1] == "8" || string[i + 1] == "9" )
				{
					i++;
					continue;
				}
			}
		}

		output += string[i];
	}

	return output;
}

// =============================================================================
//  Replaces something in string
//    	<str> The string from wich we want to replace something.
//		<what> What do we want to replace?
//		<to> What do we want to replace it with?
//	Script written by Duffman
// =============================================================================
stringReplace( str, what, to )  
{
	outstring="";
	if( !isString(what) ) {
		outstring = str;
		for(i=0;i<what.size;i++) {
			if(isDefined(to[i]))
				r = to[i];
			else
				r ="UNDEFINED["+what[i]+"]";
			outstring = stringReplace(outstring, what[i], r); 
		}
	}
	else {
		for(i=0;i<str.size;i++) {
			if(GetSubStr(str,i,i+what.size )==what) {
				outstring+=to;
				i+=what.size-1;
			}
			else
				outstring+=GetSubStr(str,i,i+1);
		}
	}
	return outstring;
}

// =============================================================================
//  Returns true if string contains something, if not then false
//    <string1> The string from wich we want to check.
//	  <string2> The string that we want to check.
//	Example: if ("FiN||quaK", "quaK") <-- this checks if "FiN||quaK" contains "quaK"
//	Script written by quaK
// =============================================================================
stringContains(string1, string2)
{
	boolean = false;
	
	for (i=0; i<string1.size; i++)
	{
		if (string1[i] == string2[0])
		{
			if (string1.size - i >= string2.size)
			{
				for(o=0; o<string2.size; o++)
				{
					if (string1[i+o] == string2[o])
					{
						boolean = true;
					}
					else
					{
						boolean = false;
					}
				}
			}
		}
	}
	return boolean;
}

/* VECTOR SCALE */

vector_scale(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
	return vec;
}

/* linkTo */

_linkto(what)
{
	self thread __linkto(what);
}
__linkto(what)
{
	self endon("death");
	self._linked = true;
	force = 10;
	while(self._linked == true)
	{
		at = ((what.origin[0] - self.origin[0]) * force, (what.origin[1] - self.origin[1]) * force, (what.origin[2] - self.origin[2]) * force);
		self setVelocity(at);
		wait 0.05;
		//self setVelocity((0,0,0));
	}
}

/* unlink */

_unlink(what)
{
	self._linked = false;
}

/* freezeControls */

_freezeControls( boolean )
{
	if( !isDefined( boolean ) )
		boolean = true;
	self thread _freezeControlsWrapper( boolean );
}

_freezeControlsWrapper( boolean )
{
	if( boolean == false )
	{
		self notify("_unfreeze");
		return;
	}
	if(isDefined(self._frozen) && self._frozen == true)
		return;
	self._frozen = true;
	ent = spawn( "script_origin", self getOrigin() );
	self playerLinkTo( ent );
	self common_scripts\utility::waittill_any("_unfreeze", "death");
	self unlink();
	ent delete();
	self._frozen = false;
}

/* triggerOn */

triggerOn()
{
	if (isDefined (self.realOrigin) )
		self.origin = self.realOrigin;
}

/* triggerOff */

triggerOff()
{
	if (!isdefined (self.realOrigin))
		self.realOrigin = self.origin;

	if (self.origin == self.realorigin)
		self.origin += (0, 0, -10000);
}

/* precache */

_precacheShader( shader )
{
	if( !isDefined( level.precachedShader ) )
		level.precachedShader = [];
	
	if( !level.precachedShader[shader] )
	{
		precacheShader( shader );
		level.precachedShader[shader] = true;
	}
}

_precacheItem( item )
{
	if( !isDefined( level.precachedItem ) )
		level.precachedItem = [];
	
	if( !level.precachedItem[item] )
	{
		precacheItem( item );
		level.precachedItem[item] = true;
	}
}

_precacheModel( model )
{
	if( !isDefined( level.precachedModel ) )
		level.precachedModel = [];
	
	if( !level.precachedModel[model] )
	{
		precacheModel( model );
		level.precachedModel[model] = true;
	}
}