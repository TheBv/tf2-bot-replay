#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <sdktools>
#include <queue>
#pragma newdecls required
#pragma semicolon 1
#include <dhooks>
#include <BotPuppeteer>

//#include "BotPuppeteer/GameHandler.sp"
#include "BotPuppeteer/Recording.sp"

public Plugin myinfo =
{
	name = "Tf2BotPuppeteer",
	author = "Bv",
	description = "",
	version = "1.0",
	url = "https://github.com/thebv/Tf2BotPuppeteer"
};

const int recordSize = 1000; // Howmany ticks to record
bool record = false;
int recordId;
int botId;
float initialOrigin[3];
float initialAngles[3];
float initalVelocities[3];
bool playback = false;
Queue recordingQueue;
Queue recordClone;


public void OnPluginStart()
{
	PrintToServer("Hello world!");
	//CreateFakeClient("test");
	RegConsoleCmd("test_cmd",Command_Test);
	RegConsoleCmd("pup_entities",List_Entity_Stuff);
	RegConsoleCmd("move_bot",Move_Bot);
	RegConsoleCmd("pup_changeTeam",ChangePuppetTeam);
	RegConsoleCmd("pup_record",StartRecord);
	RegConsoleCmd("pup_stop",EndRecord);
	RegConsoleCmd("pup_playback",PlaybackRecord);
	recordingQueue = new Queue(recordSize);
	recordClone = new Queue(recordSize);
	//Handle gameconf = LoadGameConfigFile("botpuppet.games");
	//void CTFPlayer::PlayerRunCommand( CUserCmd *ucmd, IMoveHelper *moveHelper )
	//g_call_CTFPlayer_PlayerRunCommand = CheckedDHookCreateFromConf(gameconf, "CTFPlayer::PlayerRunCommand");
	KeyValues kv = new KeyValues("MyFile");
	kv.JumpToKey("STEAM_0:0:7", true);
	//float test[3];
	//kv.SetString("name", test);
	kv.Rewind();
	kv.ExportToFile("C:\\javalia.txt");
	delete kv;
	PrintToServer("Clients: %d",GetClientCount());
	
}
public Action StartRecord(int client, int args){
	GetClientAbsOrigin(client,initialOrigin);
	GetClientAbsAngles(client,initialAngles);
	//GetEntPropVector(client,Prop_Send, "m_vecOrigin",initialOrigin);
	//GetEntPropVector(client, Prop_Data, "m_angRotation", initialAngles);
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", initalVelocities);
	recordId = client;
	record = true;
	playback = false;
	recordingQueue = new Queue(recordSize);
	recordClone = new Queue(recordSize);
	return Plugin_Handled;
}
public Action EndRecord(int client, int args){
	record = false;
	return Plugin_Handled;
}
public Action PlaybackRecord(int client, int args){
	if (recordClone.Length != 0 && recordingQueue.Length == 0){
		recordingQueue = recordClone.Clone();
	}
	playback = true;
	PrintToServer("Initial pos: %0.1f,%0.1f,%0.1f",initialOrigin[0],initialOrigin[1],initialOrigin[2]);
	PrintToServer("Bot Id: %i",botId);
	TeleportEntity(botId,initialOrigin,initialAngles,initalVelocities);
	recordClone = recordingQueue.Clone();
	return Plugin_Handled;
}
public void OnGameFrame(){
	if (playback && recordingQueue.Length != 0){
		CBotCmd cmd;
		recordingQueue.PopArray(cmd,sizeof(cmd));
		runPlayerCommand(cmd);
	}
	else if(playback){
		playback = false;
	}
}
public Action ChangePuppetTeam(int client,int args){
	botId = BotPuppeteer_BotChangeTeam("test",2);
	TF2_SetPlayerClass(botId,TFClass_Soldier);
}
public Action Move_Bot(int client, int args){
	CBotCmd cmd;
	float vel[3] = {0.0,0.0,0.0};
	float angles[3] = {0.0,0.0,0.0};
	if (args < 1){
		 angles[0]=30.0;
		 angles[1]=20.0;
		 angles[2]=10.0;
	}
	cmd = Create_CBotCmd(client,0,0,vel,angles,0,0,0,0,0,{10,20});
	runPlayerCommand(cmd);
	return Plugin_Handled;
}
public Action List_Entity_Stuff(int client, int args){
	for(int i=0;i < GetEntityCount();i++){
		char[] clsname = new char[40];
		if (IsValidEdict(i) && GetEntityNetClass(i,clsname,40)){
			PrintToServer("Entity index %d",i);
			PrintToServer("Entity Class: %s",clsname);
		}
	}
	
	return Plugin_Handled;
}

public void runPlayerCommand(CBotCmd botCmd){
	PrintToServer("Buttons: %i,Impulse: %i, Velocity: %0.1f,%0.1f,%0.1f,Angles: %0.1f,%0.1f,%0.1f",botCmd.buttons,botCmd.impulse,botCmd.vel[0],botCmd.vel[1],botCmd.vel[2],botCmd.angles[0],botCmd.angles[1],botCmd.angles[2]);
	BotPuppeteer_CommandBot("test",botCmd.buttons,botCmd.impulse,botCmd.vel,botCmd.angles,botCmd.weapon,botCmd.subtype,botCmd.cmdnum,botCmd.tickcount,botCmd.seed,botCmd.mouse);
}
public Action Command_Test(int client, int args){
	PrintToServer("Clients: %d",GetClientCount());
	BotPuppeteer_CreateBot("test");
	return Plugin_Handled;
}
/*public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]){
	if (record && recordingQueue.Length < recordSize && client == recordId){
		CBotCmd cmd1;
		cmd1 = Create_CBotCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);
		recordingQueue.PushArray(cmd1,sizeof(cmd1));
	}
}*/
static any Create_CBotCmd(int client, int buttons, int impulse, float vel[3], float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, int mouse[2]){
	CBotCmd cmd;
	cmd.setButtons(buttons);
	cmd.setImpulse(impulse);
	cmd.setVel(vel);
	cmd.setAngles(angles);
	cmd.setWeapon(weapon);
	cmd.setSubType(subtype);
	cmd.setCmdnum(cmdnum);
	cmd.setTickCount(tickcount);
	cmd.setSeed(seed);
	cmd.setMouse(mouse);
	return cmd;
}
