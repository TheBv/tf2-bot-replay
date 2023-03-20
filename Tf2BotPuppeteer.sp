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



const int AMOUNT_CLIENTS = 24;
Handle g_hWeaponEquip;
Handle g_hWWeaponEquip;
Handle g_hGameConfig;
#include "BotPuppeteer/Util.sp"
#include "BotPuppeteer/GameHandler.sp"
#include "BotPuppeteer/FileHandler.sp"
#include "BotPuppeteer/Recording.sp"
#include "BotPuppeteer/Playback.sp"

public Plugin myinfo =
{
	name = "Tf2BotReplay",
	author = "Bv",
	description = "",
	version = "1.0",
	url = "https://github.com/thebv/Tf2BotPuppeteer"
};

//TODO: Proper cleanup of arrays/and other value
const int recordSize = 1000; // Howmany ticks to record


public void OnPluginStart(){
	PrintToServer("Hello world!");
	//CreateFakeClient("test");
	RegConsoleCmd("test_cmd",Command_Test);
	RegConsoleCmd("pup_kick",KickBots);
	RegConsoleCmd("pup_entities",List_Entity_Stuff);
	RegConsoleCmd("pup_record",StartRecord);
	RegConsoleCmd("pup_stop",EndRecord);
	RegConsoleCmd("pup_load",LoadPlayback);
	RegConsoleCmd("pup_playback",PlaybackRecord);
	PrintToServer("Clients: %d",GetClientCount());
	g_hGameConfig = LoadGameConfigFile("give.bots.weapons");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Virtual, "WeaponEquip");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hWeaponEquip = EndPrepSDKCall();
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Virtual, "EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hWWeaponEquip = EndPrepSDKCall();
	
}
public Action StartRecord(int client, int args){
	startRecording();
	return Plugin_Handled;
}
public Action EndRecord(int client, int args){
	endRecording();
	return Plugin_Handled;
}
public Action LoadPlayback(int client, int args){
	loadPlayback();
	return Plugin_Handled;
}
public Action PlaybackRecord(int client, int args){
	startPlayback();
	return Plugin_Handled;
}
public void OnGameFrame(){
	runPlaybackFrame();
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



public Action Command_Test(int client, int args){
	//BotPuppeteer_RemoveAll();
	//testWriting();
	testSetting(client);
	return Plugin_Handled;
}

public Action KickBots(int client, int args){
	BotPuppeteer_RemoveAll();
	return Plugin_Handled;
}
/*public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]){
	if (record && recordingQueue.Length < recordSize && client == recordId){
		CBotCmd cmd1;
		cmd1 = Create_CBotCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);
		recordingQueue.PushArray(cmd1,sizeof(cmd1));
	}
}*/
