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

ZM_PrintToChat(client, const String:format[], any:...)
{
	decl String:buffer[192];
	VFormat(buffer, sizeof(buffer), format, 3);

	PrintToChat(client, ZM_PRINT_FORMAT, buffer);
}

ZM_PrintToChatAll(const String:format[], any:...)
{
	decl String:buffer[192];
	VFormat(buffer, sizeof(buffer), format, 2);

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			PrintToChat(i, ZM_PRINT_FORMAT, buffer);
		}
	}
}

bool:IsInZombieSpawn(client)
{
	decl Float:vecOrigin[3];
	GetClientAbsOrigin(client, vecOrigin);

	for (new i; i < g_iNumZombieSpawns; i++)
	{
		if (GetVectorDistance(vecOrigin, g_vecZombieSpawnOrigin[i], false) <= 400.0)
		{
			return true;
		}
	}

	return false;
}

ScreenOverlay(client, const String:material[])
{
	return ClientCommand(client, "r_screenoverlay \"%s\"", material);
}

RemoveScreenOverlay(client)
{
	return ClientCommand(client, "r_screenoverlay 0");
}

RemoveWeapons(client)
{
	for (new i; i < Slot_Size; i++)
	{
		new weapon = GetPlayerWeaponSlot(client, i);

		if (weapon != INVALID_WEAPON)
		{
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
		}
	}
}

FlashTimer(timeRemaining)
{
	new Handle:event = CreateEvent("dod_timer_flash", true);

	if (event != INVALID_HANDLE)
	{
		SetEventInt(event, "time_remaining", timeRemaining);

		FireEvent(event);
	}
}

GetPlayerPistol(client)
{
	new weapon = GetPlayerWeaponSlot(client, Slot_Secondary);

	if (weapon != INVALID_WEAPON)
	{
		decl String:className[MAX_WEAPON_LENGTH];
		GetEdictClassname(weapon, className, sizeof(className));

		if (StrEqual(className[7], "colt"))
		{
			return Pistol_Colt;
		}

		if (StrEqual(className[7], "p38"))
		{
			return Pistol_P38;
		}
	}

	return Pistol_Invalid;
}

PlaySoundFromPlayer(client, const String:sample[])
{
	decl Float:vecPosition[3];
	GetClientEyePosition(client, vecPosition);

	EmitAmbientSound(sample, vecPosition, client, SNDLEVEL_SCREAMING);
}

AddPlayerKills(client, amount)
{
	static fragOffset;

	if ((fragOffset = FindDataMapOffs(client, "m_iFrags")) == -1)
	{
		LogError("Unable to find datamap offset: \"m_iFrags\" !");

		return;
	}

	SetEntData(client, fragOffset, GetEntData(client, fragOffset) + amount, _, true);
}

GetHumanCount()
{
	new numHumans;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsClientSourceTV(i) && GetClientTeam(i) == Team_Allies)
		{
			numHumans++;
		}
	}

	return numHumans;
}

SelectZombie()
{
	new Handle:clientArray = CreateArray();

	for (new i = 1; i <= MaxClients; i++)
	{
		if (i != g_iZombie && IsClientInGame(i) && !IsClientSourceTV(i) && GetClientTeam(i) > Team_Spectator)
		{
			PushArrayCell(clientArray, i);
		}
	}

	new arraySize = GetArraySize(clientArray);

	if (arraySize)
	{
		g_iZombie = GetArrayCell(clientArray, arraySize >= 2 ? GetURandomInt() % (arraySize - 1) : 0);
	}
	else
	{
		LogError("Failed to select zombie");
	}

	CloseHandle(clientArray);
}