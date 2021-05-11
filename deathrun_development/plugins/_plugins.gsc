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

	In this script you can load your own plugins from "\mods\<fs_game>\plugins\" directory or IWD package.

	=====

	LoadPlugin( plugins\PLUGIN_SCRIPT::ENTRY_POINT, PLUGIN_NAME, PLUGIN_AUTHOR )

	PLUGIN_SCRIPT	- Script file name without ".gsc" extension, ex. "example"
	ENTRY_POINT		- Plugin function called once a round to load script, if you
					use 'main' mod will call function main( modVersion ) from plugin file
	PLUGIN_NAME		- Name of the plugin, fox example "Extreme DR"
	PLUGIN_AUTHOR	- Plugin author's name


	NOTE!
	Plugins might be disabled via dvar "dr_usePlugins" 
*/

main()
{
	//
	// LoadPlugin( pluginScript, name, author )
	//

	/* === BEGIN === */
	LoadPlugin( plugins\_antiwallbang::init, "Anti-Wallbang", "Viking" ); // dont remove for best experience
	LoadPlugin( plugins\_efr::init, "Unlimit Free Run Rounds", "Rycoon" ); // dont remove for best experience
	LoadPlugin( plugins\_killcam::init, "Killcam", "Amnesia" ); // dont remove for best experience
	LoadPlugin( plugins\_fpsboost::init, "Fpsboost", "Dizzy" ); // dont remove for best experience
	LoadPlugin( plugins\_rpg::init, "RPG fix", "quaK" ); // dont remove for best experience
	LoadPlugin( plugins\_svmaprotation::init, "sv_mapRotation", "quaK" ); // dont remove for best experience
	
	LoadPlugin( plugins\admins::init, "Admins", "quaK" );
	LoadPlugin( plugins\vip::init, "VIP", "quaK" );
	LoadPlugin( plugins\rtd::init, "Roll The Dice", "quaK" );
	LoadPlugin( plugins\quickdraw::init, "Quickdraw", "quaK" );
	//LoadPlugin( plugins\nohardscope::init, "No Hard Scope", "Legend" );
	//LoadPlugin( plugins\unlimitedammo::init, "Unlimited Ammo", "quaK" );
	LoadPlugin( plugins\healthbar::init, "Healthbar", "unknown" );
	//LoadPlugin( plugins\autospawnbots::init, "Auto Spawn Bots", "quaK" );
	//LoadPlugin( plugins\dynamichostname::init, "Dynamic Host Name", "quaK" );
	LoadPlugin( plugins\dynamicmaprotate::init, "Dynamic Map Rotate", "quaK" );
	LoadPlugin( plugins\ghostrun::init, "Ghost Run", "quaK" );
	LoadPlugin( plugins\doublexp::init, "Double XP", "quaK" );
	LoadPlugin( plugins\simplevelometer::init, "Velocity meter", "Ohh Rexy<3" );
	LoadPlugin( plugins\ez_knife::init, "EZ Knife", "Ohh Rexy<3" );
	
	LoadPlugin( plugins\saycommands::init, "Say Commands", "quaK" );
	
	LoadPlugin( plugins\dev::init, "Developer(^1debug^7)", "quaK" );
	/* ==== END ==== */
}



// ===== DO NOT EDIT ANYTHING UNDER THIS LINE ===== //
LoadPlugin( pluginScript, name, author )
{
	thread [[ pluginScript ]]( game["DeathRunVersion"] );
	printLn( "" + name + " ^7plugin created by " + author + "\n" );
}
