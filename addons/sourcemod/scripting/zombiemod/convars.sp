/**
 * =============================================================================
 * Zombie Mod for Day of Defeat Source
 *
 * By: Andersso
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */

enum
{
	ConVar_Enabled,
	ConVar_WinLimit,
	ConVar_MinPlayers,
	ConVar_Zombie_RoundTime,
	ConVar_Human_MaxHealth,
	ConVar_Human_EquipMenu,
	ConVar_Zombie_Health,
	ConVar_Zombie_CritHPRefresh,
	ConVar_Zombie_Speed,
	ConVar_Zombie_MaxSpeed,
	ConVar_Beacon_Interval,

	ConVar_Size
};

enum ConVar
{
	Handle:ConVarHandle, // Handle of the convar

	Value_Int,           // Int value
	bool:Value_Bool,     // Bool value
	Float:Value_Float    // Float value
};

new g_ConVars[ConVar_Size][ConVar];

InitConVars()
{
	CreateConVar("sm_zombiemod_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);

	AddConVar(ConVar_Enabled,              CreateConVar("dod_zombiemod_enabled",          "1",    "Whether or not enable Zombie Mod",                       FCVAR_PLUGIN, true, 0.0, true, 1.0));
	AddConVar(ConVar_WinLimit,             CreateConVar("dod_zombiemod_winlimit",         "5",    "Maximum amount of rounds until mapchange",               FCVAR_PLUGIN, true, 1.0));
	AddConVar(ConVar_MinPlayers,           CreateConVar("dod_zombiemod_minplayers",       "3",    "Minumum amount of players to start Zombie Mod",          FCVAR_PLUGIN, true, 3.0, true, 32.0));
	AddConVar(ConVar_Zombie_RoundTime,     CreateConVar("dod_zombiemod_roundtime",        "600",  "How long time (in seconds) each round takes",            FCVAR_PLUGIN, true, 120.0));
	AddConVar(ConVar_Human_MaxHealth,      CreateConVar("dod_zombiemod_human_maxhealth",  "150",  "Maximum amount of health a human can have",              FCVAR_PLUGIN, true, 1.0));
	AddConVar(ConVar_Zombie_Health,        CreateConVar("dod_zombiemod_zombie_health",    "8000", "Amount of health a zombie will have on spawn",           FCVAR_PLUGIN, true, 1.0));
	AddConVar(ConVar_Zombie_CritHPRefresh, CreateConVar("dod_zombiemod_crit_hp_refresh",  "100",  "Amount of health a crit zombie will regenerate on kill", FCVAR_PLUGIN, true, 0.0, true, 100.0));
	AddConVar(ConVar_Zombie_Speed,         CreateConVar("dod_zombiemod_zombie_speed",     "0.65", "Amount of speed a zombie will have on spawn",            FCVAR_PLUGIN, true, 0.0));
	AddConVar(ConVar_Zombie_MaxSpeed,      CreateConVar("dod_zombiemod_zombie_maxspeed",  "0.85", "Maximum amount of speed a zombie can have",              FCVAR_PLUGIN, true, 0.0));
	AddConVar(ConVar_Beacon_Interval,      CreateConVar("dod_zombiemod_beacon_interval",  "8",    "Time beween toggleing beacon on last human",             FCVAR_PLUGIN, true, 1.0));
}

AddConVar(conVar, Handle:conVarHandle)
{
	g_ConVars[conVar][ConVarHandle] = conVarHandle;

	UpdateConVarValue(conVar);

	HookConVarChange(conVarHandle, OnConVarChange);
}

UpdateConVarValue(conVar)
{
	g_ConVars[conVar][Value_Int] = GetConVarInt(g_ConVars[conVar][ConVarHandle]);
	g_ConVars[conVar][Value_Bool] = GetConVarBool(g_ConVars[conVar][ConVarHandle]);
	g_ConVars[conVar][Value_Float] = GetConVarFloat(g_ConVars[conVar][ConVarHandle]);
}

public OnConVarChange(Handle:conVar, const String:oldValue[], const String:newValue[])
{
	for (new i; i < ConVar_Size; i++)
	{
		if (conVar == g_ConVars[i][ConVarHandle])
		{
			UpdateConVarValue(i);

			ConVarChanged(i);

			break;
		}
	}
}

ConVarChanged(conVar)
{
	switch (conVar)
	{
		case ConVar_Enabled:
		{
			if (g_bModActive && !g_ConVars[conVar][Value_Bool])
			{
				g_bModActive = false;

				SetRoundState(DoDRoundState_Restart);
			}
		}
	}
}