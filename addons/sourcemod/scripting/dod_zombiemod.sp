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

#include <sdktools>
#include <sdkhooks>
#include <dodhooks>

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#tryinclude <sendproxy>

/**
 * Don't change the order of these!
 */
#include "zombiemod/consts.sp"
#include "zombiemod/globals.sp"
#include "zombiemod/util.sp"
#include "zombiemod/offsets.sp"
#include "zombiemod/convars.sp"
#include "zombiemod/config.sp"
#include "zombiemod/gamerules.sp"
#include "zombiemod/equipmenu.sp"
#include "zombiemod/killrewards.sp"
#include "zombiemod/player.sp"
#include "zombiemod/commands.sp"

public Plugin:myinfo =
{
	name        = PLUGIN_NAME,
	author      = "Andersso & Root, Colster",
	description = "Zombie Mod for Day of Defeat: Source",
	version     = PLUGIN_VERSION,
	url         = "http://www.dodsplugins.com/"
};


public OnPluginStart()
{
#if defined _steamtools_included
	if (LibraryExists("SteamTools"))
	{
		g_bUseSteamTools = true;
	}
#endif

#if defined _SENDPROXYMANAGER_INC_
	if (GetExtensionFileStatus("sendproxy.ext") == EXTStatus_Okay)
	{
		g_bUseSendProxy = true;
	}
#endif

	InitOffsets();
	InitConVars();
	InitEquipMenu();
	InitPlayers();
	InitCommands();
	InitGameRules();

	AutoExecConfig(true, "zombiemod_config", "zombiemod");
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("Steam_SetGameDescription");
	MarkNativeAsOptional("SendProxy_Hook");
}

public OnConfigsExecuted()
{
#if defined _steamtools_included
	if (g_bUseSteamTools)
	{
		Steam_SetGameDescription(PLUGIN_NAME);
	}
#endif

	g_iRoundWins = g_iNumZombieSpawns = g_bModActive = g_bRoundEnded = false;

	g_hRoundTimer = INVALID_HANDLE;

	LoadConfig();

	new entity = -1;

	if (!g_bWhiteListed[WhiteList_Environment])
	{
		SetLightStyle(0, "c");
		DispatchKeyValue(0, "skyname", "sky_borealis01");

		if ((entity = FindEntityByClassname(entity, "env_sun")) != -1)
		{
			AcceptEntityInput(entity, "TurnOff");
		}
	}

	PrecacheSound(SOUND_BLIP);

	g_iBeamSprite = PrecacheModel("materials/sprites/laser.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/halo01.vmt");

	while ((entity = FindEntityByClassname(entity, "info_player_axis")) != -1)
	{
		GetEntityOrigin(entity, g_vecZombieSpawnOrigin[g_iNumZombieSpawns++]);

		if (g_iNumZombieSpawns >= MAX_SPAWNPOINTS)
		{
			LogError("Spawn point limit reached!");
			break;
		}
	}
}