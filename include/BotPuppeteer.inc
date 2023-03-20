

native int BotPuppeteer_CreateBot(char[] name);

//native int BotPuppeteer_BotChangeTeam(char[] name,int team);

native void BotPuppeteer_CommandBot(int client,int buttons, int impulse, float vel[3], float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, int mouse[2]);

native int BotPuppeteer_RemoveBot(int client);

native void BotPuppeteer_RemoveAll();
//TODO: We don't need set commands at all/for some of these
enum struct CBotCmd {
	int buttons;
	int impulse;
	float vel[3];
	float angles[3];
	int weapon;
	int subtype;
	int cmdnum;
	int tickcount;
	int seed;
	int mouse[2];
	void setButtons(int buttons){
		this.buttons = buttons;
	}
	void setImpulse(int impulse){
		this.impulse = impulse;
	}
    void setVel(float vel[3]){
        this.vel = vel;
    }
    void setAngles(float angles[3]){
        this.angles = angles;
    }
    void setWeapon(int weapon){
        this.weapon = weapon;
    }
    void setSubType(int subtype){
        this.subtype = subtype;
    }
    void setCmdnum(int cmdnum){
        this.cmdnum = cmdnum;
    }
    void setTickCount(int tickcount){
        this.tickcount = tickcount;
    }
    void setSeed(int seed){
        this.seed = seed;
    }
    void setMouse(int mouse[2]){
        this.mouse = mouse;
    }
}