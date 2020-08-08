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

init()
{
	level.sounds = [];
	
	level.sounds["music"]["endround"][0] = "mp_suspense_01";	
	level.sounds["music"]["endround"][1] = "mp_suspense_02";	
	level.sounds["music"]["endround"][2] = "mp_suspense_03";	
	level.sounds["music"]["endround"][3] = "mp_suspense_04";	
	level.sounds["music"]["endround"][4] = "mp_suspense_05";	
	level.sounds["music"]["endround"][5] = "mp_suspense_06";	
	
	level.sounds["music"]["endmap"] = "us_victory_music";
	
	level.sounds["sfx"]["lastalive"] = "mp_last_stand";
	level.sounds["sfx"]["firstblood"] = "mp_obj_captured";
	
	level.sounds["sfx"]["wtf"] = "AB_mp_cmd_attackleftflank";
	level.sounds["sfx"]["gib_splat"] = "AB_mp_cmd_attackrightflank";
	level.sounds["sfx"]["sprayer"] = "AB_mp_cmd_fallback";
	
}