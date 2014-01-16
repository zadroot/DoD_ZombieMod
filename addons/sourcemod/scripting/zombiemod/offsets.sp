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

enum DoDWeaponAmmo
{
	Ammo_Colt = 4,
	Ammo_P38 = 8,
	Ammo_C96 = 12,
	Ammo_Garand = 16,
	Ammo_K98 = 20,
	Ammo_M1Carbine = 24,
	Ammo_Spring = 28,
	Ammo_SubMG = 32, // Thompson, MP40, MP44
	Ammo_BAR = 36,
	Ammo_30Cal = 40,
	Ammo_MG42 = 44,
	Ammo_Rocket = 48,
	Ammo_Frag_US = 52,
	Ammo_Frag_GER = 56,
	Ammo_Frag_US_Live = 60,
	Ammo_FragG_GER_Live = 64,
	Ammo_Smoke_US = 68,
	Ammo_Smoke_GER = 72,
	Ammo_Smoke_US_Live = 76,
	Ammo_Smoke_GER_Live = 80,
	Ammo_Riflegren_US = 84,
	Ammo_Riflegren_GER = 88,
	Ammo_Riflegren_US_Live = 92,
	Ammo_Riflegren_Ger_Live = 96
};

new	g_iOffset_Ammo,
	g_iOffset_Origin,
	g_iOffset_Health,
	g_iOffset_LaggedMovementValue,
	g_iOffset_bPlayerDominatingMe,
	g_iOffset_bPlayerDominated;

InitOffsets()
{
	if ((g_iOffset_Ammo = FindSendPropOffs("CBasePlayer", "m_iAmmo")) == -1)
	{
		SetFailState("Failed to obtain offset: \"m_iAmmo\"!");
	}

	if ((g_iOffset_Origin = FindSendPropOffs("CBaseEntity", "m_vecOrigin")) == -1)
	{
		SetFailState("Failed to obtain offset: \"m_vecOrigin \"!");
	}

	if ((g_iOffset_Health = FindSendPropOffs("CBasePlayer", "m_iHealth")) == -1)
	{
		SetFailState("Failed to obtain offset: \"m_iHealth\"!");
	}

	if ((g_iOffset_LaggedMovementValue = FindSendPropOffs("CBasePlayer", "m_flLaggedMovementValue")) == -1)
	{
		SetFailState("Failed to obtain offset: \"m_flLaggedMovementValue\"!");
	}

	if ((g_iOffset_bPlayerDominatingMe = FindSendPropInfo("CDODPlayer", "m_bPlayerDominatingMe")) == -1)
	{
		SetFailState("Unable to find prop offset: \"m_bPlayerDominatingMe\"!");
	}

	if ((g_iOffset_bPlayerDominated = FindSendPropInfo("CDODPlayer", "m_bPlayerDominated")) == -1)
	{
		SetFailState("Unable to find prop offset: \"m_bPlayerDominated\"!");
	}
}

SetWeaponAmmo(client, DoDWeaponAmmo:weaponAmmo, amount)
{
	return SetEntData(client, g_iOffset_Ammo + _:weaponAmmo, amount, _, true);
}

GetWeaponAmmo(client, DoDWeaponAmmo:weaponAmmo)
{
	return GetEntData(client, g_iOffset_Ammo + _:weaponAmmo);
}

GetEntityOrigin(entity, Float:vector[3])
{
	return GetEntDataVector(entity, g_iOffset_Origin, vector);
}

Float:GetPlayerLaggedMovementValue(client)
{
	return GetEntDataFloat(client, g_iOffset_LaggedMovementValue);
}

SetPlayerLaggedMovementValue(client, const Float:value)
{
	return SetEntDataFloat(client, g_iOffset_LaggedMovementValue, value, true);
}

ResetDominations(attacker, client)
{
	SetEntData(client, g_iOffset_bPlayerDominatingMe + attacker, 0, 1, true);
	SetEntData(attacker, g_iOffset_bPlayerDominated + client, 0, 1, true);
}