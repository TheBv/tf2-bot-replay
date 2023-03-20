//File for creating recordings of games/demos mainly meant to generate testing data
//For now this will only handle player cmd files
//#include "GameStateHandler.sp"
//TODO: If someone leaves the server their client id get's moved
bool recording = false;
const int FileVersion = 1;
ArrayList recordings[AMOUNT_CLIENTS];
int maxRecordingLength = 400;


FileHeader fileHeader;


public void initRecording(){
	for (int idx =0;idx < sizeof(recordings) ; idx++){
		recordings[idx] = new ArrayList(maxRecordingLength);
	}
}


public void initGameData(){
	fileHeader.initHeader(0);
}

public void startRecording(){
	if (recording) return;
	initRecording();
	initGameData();
	recording = true;
}

public void endRecording(){
	if (!recording) return;
	recording = false;
	writeHeader(fileHeader);
	writeUCMDs(recordings);
    //playercmd files should be updated dynamically?
}

public void OnMapTimeLeftChanged(){
    //Adds game-save state to file
}


public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]){
	if (recording){
		if (GetClientTeam(client) <= 1) return; //Don't record spec players
		CBotCmd cmd1;
		cmd1 = Create_CBotCmd(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);
		//TODO: Add map for client -> array idx
		recordings[client].PushArray(cmd1,sizeof(cmd1));
	}
}
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


