#include <a_samp>
#include <sscanf2>
#include <streamer>
#include <dini>
#include <zcmd>

#define COLOR_ORANGE 0xFF9900AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_PURPLE 0xC2A2DAAA
#define COLOR_WHITE  0xFFFFFFFF

#define COLOR_FADE1 0xFFFFFFFF
#define COLOR_FADE2 0xC8C8C8C8
#define COLOR_FADE3 0xAAAAAAAA
#define COLOR_FADE4 0x8C8C8C8C
#define COLOR_FADE5 0x6E6E6E6E

#define MAX_SLOT 9
#define MAX_ITEM 3

enum pInfo
{
    pAdminLevel,
    pCash,
    pSkin,
}
new AccountsData[MAX_PLAYERS][pInfo];
new gPlayerLogged[MAX_PLAYERS];
new gLoginAttempts[MAX_PLAYERS];
new SlotInventory[MAX_PLAYERS][MAX_SLOT];
new AmmountItem[MAX_PLAYERS][MAX_ITEM];
new timer[MAX_PLAYERS];
new TravelCP[4];


enum
{
	DIALOG_REGISTER,
	DIALOG_LOGIN,
	DIALOG_INVENTORY,
	DIALOG_TRAVEL,
	DIALOG_UNUSED
}

#define SERVER_USER_FILE "Accounts/%s.ini"

new VehNames[212][] = 
{
	{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},
	{"Dumper"},{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},
	{"Pony"},{"Mule"},{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},
	{"Washington"},{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},
	{"Securicar"},{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},
	{"Previon"},{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
	{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},{"Speeder"},
	{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},{"Skimmer"},
	{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},{"Sanchez"},
	{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},{"Rustler"},{"ZR-350"},
	{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},{"Baggage"},{"Dozer"},
	{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},{"Jetmax"},{"Hotring"},
	{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},{"Mesa"},{"RC Goblin"},
	{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},{"Super GT"},{"Elegant"},
	{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},{"Tanker"},{"Roadtrain"},
	{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},{"NRG-500"},{"HPV1000"},
	{"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},{"Willard"},{"Forklift"},
	{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},{"Blade"},{"Freight"},{"Streak"},
	{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},{"Firetruck LA"},{"Hustler"},{"Intruder"},
	{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},
	{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},
	{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},{"Bandito"},{"Freight Flat"},{"Streak Carriage"},
	{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},
	{"Stafford"},{"BF-400"},{"Newsvan"},{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},
	{"Club"},{"Freight Carriage"},{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},
	{"Police Car (SFPD)"},{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},
	{"Phoenix"},{"shitGlendale"},{"shitSadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},
	{"Boxville"},{"Farm Plow"},{"Utility Trailer"}
};

stock OnPlayerDropItem(playerid, itemid , slot) 
{
	if(AmmountItem[playerid][itemid] > 1) 
	{
		AmmountItem[playerid][itemid] -= 1;
		return 1;
	}
	else if(AmmountItem[playerid][itemid] <= 1) 
	{
		AmmountItem[playerid][itemid] = 0;
		SlotInventory[playerid][slot] = 0;
	}
	cmd_inv(playerid, "");
	return 1;
}

stock OnPlayerUseItem(playerid, itemid , slot) 
{
	switch(itemid) 
	{
		case 1: GivePlayerWeapon(playerid, 24, 100);
		case 2: GivePlayerWeapon(playerid, 25, 100);
	}
	if(AmmountItem[playerid][itemid] > 1) 
	{
		AmmountItem[playerid][itemid] -= 1;
		return 1;
	}
	else if(AmmountItem[playerid][itemid] <= 1) 
	{
		AmmountItem[playerid][itemid] = 0;
		SlotInventory[playerid][slot] = 0;
	}
	return 1;
}

stock GetItemName(itemid) 
{
	new itemname[52];
	switch(itemid) 
	{
		case 0: itemname = "Empty Slots";
		case 1: itemname = "Deagle";
		case 2: itemname = "Shotgun";
	}
	return itemname;
}

stock ShowKazujiInventory(playerid)
{
	new slot[120];
	for(new i = 0;i< MAX_SLOT ; i++) 
	{
		if(SlotInventory[playerid][i] != 0)
		{
			format(slot, sizeof(slot), "%s\n%s\t%d", slot,GetItemName(SlotInventory[playerid][i]),AmmountItem[playerid][SlotInventory[playerid][i]]);
		}
	    else strcat(slot, "\nEmpty Slots");
	}
	format(slot, sizeof slot, "%s", slot);
	ShowPlayerDialog(playerid, DIALOG_INVENTORY, DIALOG_STYLE_LIST, "Kazuji - Inventory", slot, "Action", "Cancel");
	return 1;
}

main()
{
}

public OnGameModeInit()
{
	for(new i = 0; i < 299; i++)
	{
	  //if(IsValidSkin(i))
	  {
	    AddPlayerClass(i, 1673.6897, 1447.9009, 10.7847, 270, -1, -1, -1, -1, -1, -1);
	  }
	}
	TravelCP[0] = CreateDynamicCP(1705.0659,1429.3217,10.6406, 1.0, -1, -1, -1, 5.0);
	TravelCP[1] = CreateDynamicCP(-1428.1508,-288.8185,14.1484, 1.0, -1, -1, -1, 5.0);
	TravelCP[2] = CreateDynamicCP(1687.2902,-2247.5229,-2.6767, 1.0, -1, -1, -1, 5.0);
	new kazujiobj;
	kazujiobj = CreateObject(1229, 1705.507324, 1429.425170, 10.720623, 0.000000, 0.000000, 80.700012, 300.00);
	kazujiobj = CreateObject(1229, -1428.494506, -289.084075, 14.168437, 0.000000, 0.000000, -45.699985, 300.00);
	kazujiobj = CreateObject(1229, 1687.318603, -2247.953369, -2.496818, 0.000000, 0.000000, 0.000000, 300.00);
	UsePlayerPedAnims();
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetGameModeText("Rev 0.5.3");
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(AccountsData[playerid][pSkin] != 0)
	{
		return SpawnPlayer(playerid);
	}
    SetPlayerPos(playerid, 2426.8420, 1821.9703, 16.3222);
	SetPlayerCameraPos(playerid, 2422.4617, 1821.9310, 17.2204);
	SetPlayerCameraLookAt(playerid, 2426.8420, 1821.9703, 16.3222);
	SetPlayerFacingAngle(playerid, 92.0174);
	return 1;
}

public OnPlayerConnect(playerid)
{
    SetPlayerCameraPos(playerid, 1698.2495, 2464.7241, 80.1933);
	SetPlayerCameraLookAt(playerid, 1614.8538, 2304.3838, 10.8203);
	
	CreateDynamicMapIcon(2802.53, 2430.48, 19.53, 45, 0);
	CreateDynamicMapIcon(2337.48, 2453.28, 14.96, 30, 0);
	CreateDynamicMapIcon(2192.29, 1990.78, 12.27, 52, 0);
	CreateDynamicMapIcon(2518.65, 2033.39, 11.17, 21, 0);
	CreateDynamicMapIcon(2489.85, 918.43, 11.02, 21, 0);
	CreateDynamicMapIcon(2117.59, 898.24, 11.17, 52, 0);
	CreateDynamicMapIcon(2105.10, 2256.81, 11.02, 45, 0);
	CreateDynamicMapIcon(1934.58, 2306.77, 10.82, 52, 0);
	CreateDynamicMapIcon(1600.01, 2219.96, 10.82, 52, 0);
	CreateDynamicMapIcon(1657.01, 2190.71, 20.24, 27, 0);
	CreateDynamicMapIcon(2416.97, 1123.83, 9.32, 24, 0);
	CreateDynamicMapIcon(2557.12, 2063.86, 11.09, 6, 0);
	CreateDynamicMapIcon(1607.77, 1820.90, 10.82, 22, 0);
	CreateDynamicMapIcon(1654.61, 1732.78, 9.70, 45, 0);
	CreateDynamicMapIcon(2176.84, 922.72, 10.82, 18, 0);
	CreateDynamicMapIcon(1086.13, 1072.89, 10.83, 61, 0);
	CreateDynamicMapIcon(1671.31, 719.07, 15.38, 51, 0);
	CreateDynamicMapIcon(2150.71, 2734.73, 11.17, 52, 0);
	CreateDynamicMapIcon(1968.56, 2295.03, 16.45, 54, 0);
	
	gPlayerLogged[playerid] = 0;
 	new name[MAX_PLAYER_NAME], file[256];

    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), SERVER_USER_FILE, name);

    if (!dini_Exists(file))
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Roleplay Basic - Register", "Akun ini belum terdaftar, silahkan buat password!", "Register", "Quit");
    }
    if(fexist(file))
    {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Roleplay Basic - Login", "Akun ini sudah terdaftar, masukkan password Anda untuk login!", "Enter", "Quit");
    }
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new name[MAX_PLAYER_NAME], file[256];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), SERVER_USER_FILE, name);
    if(gPlayerLogged[playerid] == 1)
    {
		SavePlayer(playerid);
    }
    KillTimer(timer[playerid]);
    gPlayerLogged[playerid] = 0;
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_REGISTER)
    {
        if(!response) return Kick(playerid);
        if (!strlen(inputtext)) return
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Roleplay Basic - Register", "Akun ini belum terdaftar, silahkan buat password!", "Register", "Quit");
	    new name[MAX_PLAYER_NAME], file[256];
	    GetPlayerName(playerid, name, sizeof(name));
	    format(file, sizeof(file), SERVER_USER_FILE, name);
	    dini_Create(file);
	   	dini_IntSet(file, "Password", udb_hash(inputtext));
	    dini_IntSet(file, "AdminLevel", AccountsData[playerid][pAdminLevel] = 0);
	    dini_IntSet(file, "Money", AccountsData[playerid][pCash] = 10000);
	    dini_IntSet(file, "Skin", AccountsData[playerid][pSkin] = 0);

	    dini_FloatSet(file, "Health", 100);
	    dini_FloatSet(file, "Armour", 0);
	    dini_FloatSet(file, "PosX", 1673.6897);
	    dini_FloatSet(file, "PosY", 1447.9009);
	    dini_FloatSet(file, "PosZ", 10.7847);
	    dini_FloatSet(file, "PosAngle", 0);
	    gPlayerLogged[playerid] = 1;
    }
    if(dialogid == DIALOG_LOGIN)
    {
        new name[MAX_PLAYER_NAME], file[256];
        GetPlayerName(playerid, name, sizeof(name));
        format(file, sizeof(file), SERVER_USER_FILE, name);
        if(!response) return Kick(playerid);
        if (!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Roleplay Basic - Login", "Akun ini sudah terdaftar, masukkan password Anda untuk login!", "Enter", "Quit");
        new tmp;
        tmp = dini_Int(file, "Password");
        if(udb_hash(inputtext) != tmp) 
        {
            if(gLoginAttempts[playerid] > 1)
			{
			    gLoginAttempts[playerid] = 0;
				return Kick(playerid);
			}
            else
            {
	            new string[128];
				format(string, sizeof(string), "Anda telah memasukkan kata sandi yang salah, Attempts %i ", 2 - gLoginAttempts[playerid]);
	            SendClientMessage(playerid, COLOR_YELLOW, string);

	            gLoginAttempts[playerid]++;
	            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Roleplay Basic - Login", "Akun ini sudah terdaftar, masukkan password Anda untuk login!", "Enter", "Quit");
            }
        }
        else
        {
            gPlayerLogged[playerid] = 1;
            timer[playerid] = SetTimerEx("SavePlayer", 30000, true, "i", playerid);

            AccountsData[playerid][pAdminLevel] = dini_Int(file, "AdminLevel");
            AccountsData[playerid][pSkin] = dini_Int(file, "Skin");
            AccountsData[playerid][pCash] = dini_Int(file, "Money");
        }
    }
	if(dialogid == DIALOG_INVENTORY) 
	{
		if(response) 
		{
			if(listitem < 9) 
			{
				if(SlotInventory[playerid][listitem] != 0) 
				{
					OnPlayerUseItem(playerid, SlotInventory[playerid][listitem] , listitem);
				}
			}
		}
		else if(!response) 
		{
			if(listitem < 9) 
			{
				if(SlotInventory[playerid][listitem] != 0) 
				{
					OnPlayerDropItem(playerid, SlotInventory[playerid][listitem] , listitem);
				}
			}
		}
	}
	if(dialogid == DIALOG_TRAVEL)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
                    SetPlayerPos(playerid, 1687.2902,-2247.5229,-2.6767);
				}
				case 1:
				{
                    SetPlayerPos(playerid, -1421.3682,-287.0551,14.1484);
				}
				case 2:
				{
                    SetPlayerPos(playerid, 2426.8420, 1821.9703, 16.3222);
				}
			}
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
   	if(gPlayerLogged[playerid] == 0)
	{
	    return Kick(playerid);
	}
    new name[MAX_PLAYER_NAME], file[256];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), SERVER_USER_FILE, name);
    
    SetPlayerPos(playerid, dini_Float(file, "PosX"), dini_Float(file, "PosY"), dini_Float(file, "PosZ"));
    SetPlayerFacingAngle(playerid, dini_Float(file, "PosAngle"));
    SetPlayerHealth(playerid, dini_Float(file, "Health"));
    SetPlayerArmour(playerid, dini_Float(file, "Armour"));

   	if(AccountsData[playerid][pSkin] != 0)
	{
		return SetPlayerSkin(playerid, dini_Int(file, "Skin"));
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    new name[MAX_PLAYER_NAME], file[256];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), SERVER_USER_FILE, name);
    
    dini_FloatSet(file, "Health", 100);
    dini_FloatSet(file, "Armour", 0);
    
    dini_FloatSet(file, "PosX", 1579.5499);
	dini_FloatSet(file, "PosY", 1769.0642);
	dini_FloatSet(file, "PosZ", 10.8203);
	dini_FloatSet(file, "PosAngle", 90);
	
	ClearAnimations(playerid);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetVehiclePos(vehicleid, fX, fY, fZ+10);
	}
	else
	{
		SetPlayerPosFindZ(playerid, fX, fY, 999.0);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
	}
    return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if(checkpointid == TravelCP[0])
	{
		ShowPlayerDialog(playerid, DIALOG_TRAVEL, DIALOG_STYLE_LIST, "Kazuji - Travel", "Los Santos\nSan Fierro\nLas Venturas", "Pilih", "Batal");
	}
	if(checkpointid == TravelCP[1])
	{
		ShowPlayerDialog(playerid, DIALOG_TRAVEL, DIALOG_STYLE_LIST, "Kazuji - Travel", "Los Santos\nSan Fierro\nLas Venturas", "Pilih", "Batal");
	}
	if(checkpointid == TravelCP[2])
	{
		ShowPlayerDialog(playerid, DIALOG_TRAVEL, DIALOG_STYLE_LIST, "Kazuji - Travel", "Los Santos\nSan Fierro\nLas Venturas", "Pilih", "Batal");
	}
	return 1;
}
public OnPlayerText(playerid, text[])
{
	new pname[24], str[128];
	GetPlayerName(playerid, pname, 24);
	strreplace(pname, '_', ' ');
	format(str, sizeof(str), "%s says: %s", pname, text);
	ProxDetector(30.0, playerid, str, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5);
	return 0;
}

CMD:inv(playerid, params[])
{
	ShowKazujiInventory(playerid);
	return 1;
}

CMD:wahyu(playerid, params[])
{
	SetPlayerSkin(playerid, 5);
	return 1;
}

CMD:additem(playerid, params[]) 
{
	new target,itemid,jumplah;
	if(sscanf(params, "udd", target,itemid,jumplah)) return SendClientMessage(playerid, -1, "/additem [playerid] [itemid] [jumplah]");
	if(itemid < 0 || itemid >  MAX_ITEM) return SendClientMessage(playerid, -1, "Hanya ada 1 sampai 3 item saja.");
	if(!IsPlayerConnected(target)) return SendClientMessage(playerid, -1, "Pemain tidak digame.");
	for(new i = 0 ; i < MAX_SLOT ; i++) 
	{
		if(SlotInventory[playerid][i] == itemid) 
		{
			AmmountItem[playerid][itemid] += jumplah;
			return 1;
		}
	    else if(SlotInventory[playerid][i] == 0) 
		{
	    	SlotInventory[playerid][i] = itemid;
	    	AmmountItem[playerid][itemid] = jumplah;
	    	return 1;
	    }
	}
	return 1;
}

CMD:kill(playerid, params[])
{
	if(IsPlayerConnected(playerid))
	{
    	return SetPlayerHealth(playerid, 0);
    }
    return 0;
}

CMD:me(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /me <action>");
   	new sendername[32], string[128];
    GetPlayerName(playerid, sendername, sizeof(sendername));
    strreplace(sendername, '_', ' ');
	format(string, sizeof(string), "%s %s", sendername, params);
	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	return 1;
}

CMD:b(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /b <OOC Information>");
   	new sendername[32], string[128];
    GetPlayerName(playerid, sendername, sizeof(sendername));
    strreplace(sendername, '_', ' ');
	format(string, sizeof(string), "%s: (( %s ))", sendername, params);
	ProxDetector(30.0, playerid, string, COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE,COLOR_WHITE);
	return 1;
}

CMD:ooc(playerid, params[])
{
	new sendername[32], string[128];
    GetPlayerName(playerid, sendername, sizeof(sendername));
    strreplace(sendername, '_', ' ');
    format(string, sizeof(string), "%s | [%s]", sendername, params);
    SendClientMessageToAll(COLOR_WHITE, string);
    return 1;
}

CMD:v(playerid, params[])
{
	if(IsPlayerConnected(playerid))
	{
		if (isnull(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /(v)ehicle <vehicle name>");
		new Float:x, Float:y, Float:z, vehicle, id;
	 	id = GetVehicleModelIDFromName(params);
	 	if(id == -1) return SendClientMessage(playerid, COLOR_YELLOW, "Invalid vehicle name.");
		GetPlayerPos(playerid, x, y, z);
		vehicle = CreateVehicle(id, x, y, z, 0, 0, 0, -1);
		PutPlayerInVehicle(playerid, vehicle, 0);
		return SendClientMessage(playerid, COLOR_ORANGE, "Anda menspawn kendaraan");
	}
	return 0;
}

CMD:stats(playerid, params[])
{
	if(IsPlayerConnected(playerid))
	{
		new string[128], Float:health, Float:armour;
		GetPlayerHealth(playerid,health);
		GetPlayerArmour(playerid,armour);
		format(string, sizeof(string), "Detail\tAmmount\nHealth\t%0.f\nArmour\t%0.f\nMoney\t%i", health, armour, AccountsData[playerid][pCash]);
		ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_TABLIST, "Roleplay Basic - Stats", string, "Oke", "Tutup");
	}
	return 1;
}

CMD:dcp(playerid, params[])
{
	if(IsPlayerConnected(playerid))
	{
 		SendClientMessage(playerid, COLOR_WHITE, "Semua checkpoint sudah di hapus!");
	    return DisablePlayerCheckpoint(playerid);
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}
/* ANTI FLOOD
new commanddelay[MAX_PLAYERS];
public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(gPlayerLogged[playerid] == 1)
	{
		if(commanddelay[playerid]-gettime() > 0)
		{
	  		SendClientMessage(playerid, 0xFF0000AA, "Anda harus menunggu beberapa detik sebelum memasukkan perintah lain.");
			return 0;
		}
		commanddelay[playerid] = gettime() + 3;
		return 1;
	}
	return 0;
}*/

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if((newkeys & KEY_YES))
	{
	    ShowKazujiInventory(playerid);
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

IsValidSkin(skinid)
{
  	#define  MAX_BAD_SKINS 24
  	new badSkins[MAX_BAD_SKINS] =
  	{
		0, 3, 4, 5, 6, 8, 42, 65, 74, 86, 119, 149, 208, 268, 273, 289, 165
	};
  	if (skinid < 0 || skinid > 299) return false;
  	for (new i = 0; i < MAX_BAD_SKINS; i++) 
	{ 
		if (skinid == badSkins[i]) return false; 
	}
  	#undef MAX_BAD_SKINS
	return 1;
}

ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i))
            {
                GetPlayerPos(i, posx, posy, posz);
                tempposx = (oldposx -posx);
                tempposy = (oldposy -posy);
                tempposz = (oldposz -posz);
                if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
                {
                    if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16)))
                    {
                        SendClientMessage(i, col1, string);
                    }
                    else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))
                    {
                        SendClientMessage(i, col2, string);
                    }
                    else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
                    {
                        SendClientMessage(i, col3, string);
                    }
                    else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
                    {
                        SendClientMessage(i, col4, string);
                    }
                    else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
                    {
                        SendClientMessage(i, col5, string);
                    }
                }
            }
        }
    }
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

forward GetVehicleModelIDFromName(vehname[]);
public GetVehicleModelIDFromName(vehname[])
{
	for(new i = 0; i < 211; i++)
	{
		if (strfind(VehNames[i], vehname, true) != -1) return i + 400;
	}
	return -1;
}

stock udb_hash(buf[]) 
{
	new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}

forward SavePlayer(playerid);
public SavePlayer(playerid)
{
	new name[MAX_PLAYER_NAME], file[256];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), SERVER_USER_FILE, name);
    if(gPlayerLogged[playerid] == 1)
    {
  		new Float:x, Float:y, Float:z, Float:angle, Float:health, Float:armour, playerskin;
		GetPlayerPos(playerid, x, y, z);
		GetPlayerHealth(playerid,health);
		GetPlayerArmour(playerid, armour);
		GetPlayerFacingAngle(playerid, angle);

        dini_IntSet(file, "Money", AccountsData[playerid][pCash]);
        dini_IntSet(file, "AdminLevel", AccountsData[playerid][pAdminLevel]);

        dini_FloatSet(file, "Health",health);
        dini_FloatSet(file, "Armour",armour);
        dini_FloatSet(file, "PosX", x);
        dini_FloatSet(file, "PosY", y);
        dini_FloatSet(file, "PosAngle", angle);

        playerskin = GetPlayerSkin(playerid);
        dini_IntSet(file, "Skin", playerskin);
        return 1;
    }
    gPlayerLogged[playerid] = 0;
    return 0;
}

stock SetPlayerMoney(playerid, cash)
{
  ResetPlayerMoney(playerid);
  return GivePlayerMoney(playerid, cash);
}

stock strreplace(string[], find, replace)
{
    for(new i=0; string[i]; i++)
    {
        if(string[i] == find)
        {
            string[i] = replace;
        }
    }
}
