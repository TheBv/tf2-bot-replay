//Should have a list of players and keep track of the current tick that's being played back etc

//Things to keep in mind:
//After point capture: new gamestate for capture status to ensure correct playback

#pragma newdecls required
#pragma semicolon 1

#include <tf2>
#include <tf2utils>
//#include <smlib>

enum struct PointCaptureStatus{
	//Defines which points are currently capped by which team(might need to add more/use a different system for pl maps)
	int point0;
	int point1;
	int point2;
	int point3;
	int point4;
}

enum struct Weapon {
	char name[128];
	int index;
	int slot;
	void setWeapon(int client){
		GetClientWeapon(client,this.name,128);
		int entity = GetPlayerWeaponSlot(client,0); //TODO: Get Current slot?
		this.index = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
	}
	void applyWeapon(int client){
		TF2_RemoveWeaponSlot(client,0);
		CreateWeapon(client,this.name,this.index);
	}
}

enum struct Loadout {
	char weapon1[128];
	char weapon2[128];
	char weapon3[128];
	char weapon4[128];
	char weapon5[128];
	char cosmetic1[128];
	char cosmetic2[128];
	char cosmetic3[128];
	char cosmetic4[128];
}

enum struct GameConfig {
	char mapName[128];
	int timeLimit;
}


/**
 * Struct to hold player specific data
 */
enum struct PlayerData {
	int id;
	char name[128];
	bool isAlive;
	TFTeam team;
	TFClassType class;
	//Loadout loadout;
	//int ammo;
	float origin[3];
	float vel[3];
	float angles[3];
	int healingTarget;
	TFTeam disguisedTeam;
	TFClassType disguisedClass;
	Weapon activeWeapon;
	int health;
	/**
	* 	Sets the struct values to the corresponding values the client has
		@param client Player Index
	*/
	void setPlayerData(int client){
		this.id = client;
		char nameTmp[128];
		GetClientName(client,nameTmp,sizeof(nameTmp));
		this.name = nameTmp;
		this.isAlive = IsPlayerAlive(client);
		this.team = TF2_GetClientTeam(client);
		this.class = TF2_GetPlayerClass(client);
		Weapon weapon;
		weapon.setWeapon(client);
		this.activeWeapon = weapon;//GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if (IsValidEdict(secondary)){
			if (HasEntProp(secondary,Prop_Send, "m_bHealing")){
				if (GetEntProp(secondary, Prop_Send, "m_bHealing")){
					this.healingTarget = GetEntPropEnt(secondary, Prop_Send, "m_hHealingTarget");
				}
			}
		}
		GetClientAbsOrigin(client,this.origin);
		GetClientEyeAngles(client,this.angles);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", this.vel);
		// player.disguisedClass = 0;
		this.health = GetClientHealth(client);
		// Loadout
	}
	/**
	* 	Applies the struct values to the corresponding client
		@param client Player Index
	*/
	void applyPlayerData(int client, int clientMap[AMOUNT_CLIENTS] ){
		SetClientName(client,this.name);
		TF2_ChangeClientTeam(client,this.team);
		TF2_SetPlayerClass(client,view_as<TFClassType>(this.class));
		if (IsPlayerAlive(client) && !this.isAlive){
		//Tf2 bot kill
		}
		else if (!IsPlayerAlive(client) && this.isAlive){
			TF2_RespawnPlayer(client);
		}
		/*if (IsValidEdict(clientMap[this.healingTarget])){
			int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			if (HasEntProp(secondary,Prop_Send, "m_bHealing")){
				if (GetEntProp(secondary, Prop_Send, "m_bHealing")){
					SetEntPropEnt(secondary, Prop_Send, "m_hHealingTarget",clientMap[this.healingTarget]);
				}
			}
		}*/
		TeleportEntity(client,this.origin,this.angles,this.vel);
		TF2_RemovePlayerDisguise(client);
		TF2_DisguisePlayer(client,this.disguisedTeam,this.disguisedClass);
		this.activeWeapon.applyWeapon(client);
		//TODO: EquipPlayerWeapon(client,this.activeWeapon);
		
		SetEntityHealth(client,this.health);
	}
	void printPlayerData(){
		PrintToServer("Id: %d,Name: %s, alive: %d, team: %d, class: %d, o1: %f, o2: %f,o3: %f,vel1:%f,vel2:%f,vel3:%f",
		this.id,this.name,this.isAlive,this.team,this.class,this.origin[0],this.origin[1],this.origin[2],this.vel[0],this.vel[1],this.vel[2]);
		PrintToServer("a1:%f,a2:%f,a3:%f,disTeam:%d,disClass:%d,actWep:%s,actInd:%d,health:%d",
		this.angles[0],this.angles[1],this.angles[2],this.disguisedTeam,this.disguisedClass,this.activeWeapon.name,this.activeWeapon.index,this.health);
	}
}
/**
 * 	Struct that holds a state for a game
	@param playerData An array of PlayerData structs
 */
enum struct GameStateData {
	int tick;
	int timeRemaining;
	int winlimit;
	int timelimit;
	int roundTimeRemaining;
	PointCaptureStatus captureStatus;
	//Only for koth maps
	int redTime;
	int blueTime;
	ArrayList playerData;
	/**
	* 	Get's the current state of a tf2 game
		@param tick the tick the state corresponds too
	*/
	void setCurrentGameState(int tick){
		ArrayList currClientIds = getCurrentClientIds();
		this.playerData = new ArrayList(300);
		for (int i = 0; i < currClientIds.Length; i++){
			PlayerData playerData;
			int id = currClientIds.Get(i);
			playerData.setPlayerData(id);
			playerData.printPlayerData();
			this.playerData.PushArray(playerData, sizeof(playerData));
		}
		this.tick = 0;
		GetMapTimeLeft(this.timeRemaining);
	}
	void applyGameState(int clientMap[AMOUNT_CLIENTS]){
		int currMapTimeLeft;
		GetMapTimeLeft(currMapTimeLeft);
		ExtendMapTimeLimit(this.timeRemaining-currMapTimeLeft); //Doesn't work
		for (int i = 0; i < this.playerData.Length; i++){
			PlayerData player;
			this.playerData.GetArray(i,player,sizeof(player));
			player.applyPlayerData(clientMap[player.id],clientMap);
		}
	}
}

enum struct FileHeader {
	int version;
	GameConfig config;
	ArrayList gameStateData;
	void initHeader(int tick){
		this.gameStateData = new ArrayList(300);
		this.appendGameState(tick);
	}
	void appendGameState(int tick){
		GameStateData gameState;
		gameState.setCurrentGameState(tick);
		this.gameStateData.PushArray(gameState);
	}
}

enum struct BuildingData {
	int ownerId;
	float pos[3];
	float rot[3];//Maybe [2]?
	int health;
	int ammo; //Need to think about dispenser ammo / sentry ammo: rockets, bullets
}

public ArrayList getCurrentClientIds(){
	ArrayList clients;
	clients = new ArrayList();
	for (int i = 1; i<= MaxClients; i++){
		if(IsClientInGame(i)){
			clients.Push(i);
		}
	}
	return clients;
}