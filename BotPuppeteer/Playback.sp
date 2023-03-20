// File for playing back recordings 
bool playback = false;
bool loaded = false;
ArrayList playbackUserCmds[AMOUNT_CLIENTS];
FileHeader playbackHeader;
int idMap[AMOUNT_CLIENTS];
int playbackTick;


public void loadPlayback(){
    if (playback || recording) return;
    //Read the file data
    readHeader(playbackHeader);
    for (int idx =0;idx < sizeof(playbackUserCmds) ; idx++){
		playbackUserCmds[idx] = new ArrayList(maxRecordingLength);
	}
    readUCMDs(playbackUserCmds);
    BotPuppeteer_RemoveAll();
    //Add all the players to the game
    // How are we gonna add all the players? We could go through
    int maxPlayers;
    for (int i = 0; i < sizeof(playbackUserCmds); i++){
        if (playbackUserCmds[i].Length > 1){
            PrintToServer("%d",playbackUserCmds[i].Length);
            maxPlayers++;
            char name[AMOUNT_CLIENTS];
            Format(name,sizeof(name),"%d",i);
            idMap[i] = BotPuppeteer_CreateBot(name); //This returns an entity index...
            //TODO: Consider GetClientUserId/GetClientOfUserId and other stuff
            PrintToServer("%d -> %d",i,idMap[i]);
        }
    }
    loaded = true;
}


public void startPlayback(){
    if (playback || recording || !loaded) return; 
    GameStateData state;
    playbackHeader.gameStateData.GetArray(0,state,sizeof(state));
    state.applyGameState(idMap);
    ServerCommand("mp_waitingforplayers_cancel 1");
    playbackTick = state.tick; //TODO: think about how to handle ticks/ Ucmd inconsistency. 
    playback = true;
    // Current Idea : Start at tick 0; tick++/ dunno
}

public void runPlaybackFrame(){
    if (!playback) return;
    for (int i = 0; i < sizeof(playbackUserCmds); i++){
        if (playbackUserCmds[i].Length > playbackTick+1){
            CBotCmd cmd;
            playbackUserCmds[i].GetArray(playbackTick,cmd,sizeof(cmd));
            
            runPlayerCommand(cmd,idMap[i]);
        }//Need to save the max playback time... Consideration for better tick-system
        else if (playbackUserCmds[i].Length > 1){
            playback = false;
        }
    }
    playbackTick++;
}

public void runPlayerCommand(CBotCmd botCmd, int client){
	//PrintToServer("Buttons: %i,Impulse: %i, Velocity: %0.1f,%0.1f,%0.1f,Angles: %0.1f,%0.1f,%0.1f",botCmd.buttons,botCmd.impulse,botCmd.vel[0],botCmd.vel[1],botCmd.vel[2],botCmd.angles[0],botCmd.angles[1],botCmd.angles[2]);
	BotPuppeteer_CommandBot(client,botCmd.buttons,botCmd.impulse,botCmd.vel,botCmd.angles,botCmd.weapon,botCmd.subtype,botCmd.cmdnum,botCmd.tickcount,botCmd.seed,botCmd.mouse);
}

public void testSetting(int client){
    GameStateData state;
    playbackHeader.gameStateData.GetArray(0,state,sizeof(state));
    //state.applyGameState(idMap);
    PlayerData data;
    state.playerData.GetArray(0,data,sizeof(data));
    data.applyPlayerData(client, idMap);
}

public void stopPlayback(){
    if (recording || !playback) return;
    playback = false;
}