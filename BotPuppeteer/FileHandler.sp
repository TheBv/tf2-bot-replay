//File for reading specifc file data


public void writeHeader(FileHeader header){
	File file = OpenFile("test.data","wb"); //TODO: Define custom paths
	file.WriteInt8(header.version);
	file.WriteLine(header.config.mapName);
	file.WriteInt8(header.config.timeLimit);
	writeStateGameData(header, file);
	CloseHandle(file);
}

public void writeStateGameData(FileHeader header, File file) {
	file.WriteInt16(header.gameStateData.Length);
	for (int i=0; i< header.gameStateData.Length; i++){
		GameStateData state;
		header.gameStateData.GetArray(i,state,sizeof(state)); //This will probably cause issues due to nested arrayLists and sizeof...
		file.WriteInt8(state.tick);
		PrintToServer("%d",state.tick);
		file.WriteInt16(state.timeRemaining);
		PrintToServer("Amount of players: %d",state.playerData.Length);
		writeStateUserData(state, file);
	}
}

public void writeStateUserData(GameStateData state, File file){
	file.WriteInt16(state.playerData.Length);
	for (int j=0; j< state.playerData.Length; j++){
		PlayerData playerData;
		state.playerData.GetArray(j,playerData,sizeof(playerData));
		file.WriteInt8(playerData.id);
		file.WriteString(playerData.name,true);
		file.WriteInt8(playerData.isAlive);
		file.WriteInt8(view_as<int>(playerData.team));
		file.WriteInt8(view_as<int>(playerData.class));
		file.WriteString(playerData.activeWeapon.name,true);
		file.WriteInt8(playerData.healingTarget);
		file.WriteInt16(playerData.activeWeapon.index);
		file.WriteInt16(playerData.health);
		WriteFloat(file,playerData.origin[0],8);
		WriteFloat(file,playerData.origin[1],8);
		WriteFloat(file,playerData.origin[2],8);
		WriteFloat(file,playerData.vel[0],8);
		WriteFloat(file,playerData.vel[1],8);
		WriteFloat(file,playerData.vel[2],8);
		WriteFloat(file,playerData.angles[0],8);
		WriteFloat(file,playerData.angles[1],8);
		WriteFloat(file,playerData.angles[2],8);
		//Loadout shenanigans
	}
}

public void writeUCMD(File file, CBotCmd cmd){
	file.WriteInt16(cmd.buttons);
	file.WriteInt8(cmd.impulse);
	WriteFloat(file, cmd.vel[0], 8);
	WriteFloat(file, cmd.vel[1], 8);
	WriteFloat(file, cmd.vel[2], 8);
	WriteFloat(file, cmd.angles[0], 8);
	WriteFloat(file, cmd.angles[1], 8);
	WriteFloat(file, cmd.angles[2], 8);
	file.WriteInt8(cmd.weapon);
	file.WriteInt8(cmd.subtype);
	file.WriteInt32(cmd.cmdnum);
	file.WriteInt32(cmd.tickcount);
	file.WriteInt32(cmd.seed);
	file.WriteInt8(cmd.mouse[0]);
	file.WriteInt8(cmd.mouse[1]);
}


public void writeUCMDs(ArrayList records[AMOUNT_CLIENTS]){
	for (int idx =0;idx < sizeof(records); idx++){
		char fileName[16];
		Format(fileName, sizeof(fileName),"player_%i.txt",idx);
		File fileHandler = OpenFile(fileName,"wb");
		for (int recIdx = 0; recIdx < records[idx].Length; recIdx++){
			CBotCmd cmd;
			records[idx].GetArray(recIdx,cmd,sizeof(cmd));
			writeUCMD(fileHandler, cmd);
		}
		CloseHandle(fileHandler);
	}
}

public void readHeader(FileHeader header){
	File file = OpenFile("test.data","rb"); //TODO: Define custom paths
	file.ReadInt8(header.version);
	file.ReadLine(header.config.mapName, 128);
	file.ReadInt8(header.config.timeLimit);
	readStateGameData(header, file);
	CloseHandle(file);
}

public void readStateGameData(FileHeader header, File file){
	int length;
	file.ReadInt16(length);
	header.gameStateData = new ArrayList(400);
	for (int i=0; i< length; i++){
		GameStateData state;
		file.ReadInt8(state.tick);
		file.ReadInt16(state.timeRemaining);
		readStateUserData(state, file);
		header.gameStateData.PushArray(state);
	}
}


public void readStateUserData(GameStateData state, File file){
	int length;
	file.ReadInt16(length);
	state.playerData = new ArrayList(150); //145
	for (int j=0; j< length; j++){
		PlayerData playerData;
		//state.playerData.GetArray(j,playerData,sizeof(playerData));
		file.ReadInt8(playerData.id);
		file.ReadString(playerData.name,sizeof(playerData.name));
		file.ReadInt8(playerData.isAlive);
		file.ReadInt8(playerData.team);
		file.ReadInt8(view_as<int>(playerData.class));
		Weapon weapon;
		weapon = playerData.activeWeapon;
		file.ReadString(playerData.activeWeapon.name,sizeof(weapon.name));
		file.ReadInt8(playerData.healingTarget);
		file.ReadInt16(playerData.activeWeapon.index);
		file.ReadInt16(playerData.health);
		ReadFloat(file,playerData.origin[0],8);
		ReadFloat(file,playerData.origin[1],8);
		ReadFloat(file,playerData.origin[2],8);
		ReadFloat(file,playerData.vel[0],8);
		ReadFloat(file,playerData.vel[1],8);
		ReadFloat(file,playerData.vel[2],8);
		ReadFloat(file,playerData.angles[0],8);
		ReadFloat(file,playerData.angles[1],8);
		ReadFloat(file,playerData.angles[2],8);
		state.playerData.PushArray(playerData);
		playerData.printPlayerData();
		//Loadout shenanigans
	}
}

public void readUCMD(File file, CBotCmd cmd){
	file.ReadInt16(cmd.buttons);
	file.ReadInt8(cmd.impulse);
	ReadFloat(file, cmd.vel[0], 8);
	ReadFloat(file, cmd.vel[1], 8);
	ReadFloat(file, cmd.vel[2], 8);
	ReadFloat(file, cmd.angles[0], 8);
	ReadFloat(file, cmd.angles[1], 8);
	ReadFloat(file, cmd.angles[2], 8);
	file.ReadInt8(cmd.weapon);
	file.ReadInt8(cmd.subtype);
	file.ReadInt32(cmd.cmdnum);
	file.ReadInt32(cmd.tickcount);
	file.ReadInt32(cmd.seed);
	file.ReadInt8(cmd.mouse[0]);
	file.ReadInt8(cmd.mouse[1]);
}

public void readUCMDs(ArrayList[AMOUNT_CLIENTS] records){
	PrintToServer("%d",sizeof(records));
	for (int idx =0;idx < sizeof(records); idx++){
		char fileName[16];
		Format(fileName, sizeof(fileName),"player_%i.txt",idx);
		File fileHandler = OpenFile(fileName,"rb");
		while (!fileHandler.EndOfFile()){
			CBotCmd cmd;
			readUCMD(fileHandler,cmd);
			records[idx].PushArray(cmd,sizeof(cmd));
		}
		CloseHandle(fileHandler);
	}
}



static char[] CmdToString(CBotCmd cmd){
	char line[512];
	Format(line,sizeof(line),"%i,%i,%f,%f,%f,%f,%f,%f,%i,%i,%i,%i,%i,%i,%i",cmd.buttons,cmd.impulse,cmd.vel[0],cmd.vel[1],cmd.vel[2],cmd.angles[0],cmd.angles[1],cmd.angles[2],cmd.weapon,cmd.subtype,cmd.cmdnum,cmd.tickcount,cmd.seed, cmd.mouse[0],cmd.mouse[1]);
	//PrintToServer(line);
	return line;
}

public void testWriting(){
	File test = OpenFile("testing.data","wb");
	WriteFloat(test,1.513123,8);
	test.WriteInt16(1231);
	WriteFloat(test,9.123123,8);
	CloseHandle(test);
	File test2 = OpenFile("testing.data","rb");
	float val1;
	int val2;
	float val3;
	ReadFloat(test2, val1,8);
	test2.ReadInt16(val2);
	ReadFloat(test2, val3,8);
	PrintToServer("%f,%d,%f",val1,val2,val3);
}


public bool WriteFloat(File fileHandler, float value, int size){
	char[] val = new char[size];
	FloatToString(value,val,size);
	//Format(val, size,"%f",value); //TODO: increase float size
	return fileHandler.WriteString(val,true);
}


public int ReadFloat(File fileHandler, float& value, int size){
	char[] val = new char[size*2];
	int success = fileHandler.ReadString(val,size*2,-1);
	value = StringToFloat(val);
	return success;
}