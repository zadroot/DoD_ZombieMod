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
	RewardType_None,
	RewardType_PrimaryAmmo,
	RewardType_Health,
	RewardType_SecondaryAmmo,

	Rewards_Size
};

enum WeaponInfo
{
	DoDWeaponAmmo:WI_Ammo,
	WI_MaxAmmo,
	WI_ClipSize
};

static const g_WeaponInfo[][WeaponInfo] =
{
	{ Ammo_Garand, ExtraAmmoGarand,     ClipSize_Garand     },
	{ Ammo_K98,    ExtraAmmoK98,        ClipSize_K98        },
	{ Ammo_SubMG,  ExtraAmmoThompson,   ClipSize_Thompson   },
	{ Ammo_SubMG,  ExtraAmmoMP40,       ClipSize_MP40       },
	{ Ammo_BAR,    ExtraAmmoBAR,        ClipSize_BAR        },
	{ Ammo_SubMG,  ExtraAmmoMP44,       ClipSize_MP44       },
	{ Ammo_30Cal,  ExtraAmmo30Cal,      ClipSize_30Cal      },
	{ Ammo_MG42,   ExtraAmmoMG42,       ClipSize_MG42       },
	{ Ammo_Spring, ExtraAmmoSpring,     ClipSize_Spring     },
	{ Ammo_K98,    ExtraAmmoK98_Scoped, ClipSize_K98_Scoped },
	{ Ammo_Rocket, ExtraAmmoRocket,     ClipSize_Rocket     }, // Bazooka
	{ Ammo_Rocket, ExtraAmmoRocket,     ClipSize_Rocket     }  // Panzerschreck
};

static const String:g_szPrimaryWeapons[][] =
{
	"garand",
	"k98",
	"thompson",
	"mp40",
	"bar",
	"mp44",
	"30cal",
	"mg42",
	"spring",
	"k98_scoped",
	"bazooka",
	"pschreck"
};

GiveHumanReward(client)
{
	new Handle:array = CreateArray();

	PushArrayCell(array, RewardType_PrimaryAmmo);
	PushArrayCell(array, RewardType_Health);
	PushArrayCell(array, RewardType_SecondaryAmmo);

	for (new i = 1; i < Rewards_Size; i++)
	{
		new randArray = GetRandomInt(0, GetArraySize(array) - 1);

		if (HumanReward_GiveReward(client, GetArrayCell(array, randArray)))
		{
			CloseHandle(array);
			return;
		}

		RemoveFromArray(array, randArray);
	}

	CloseHandle(array);

	//ZM_PrintToChat(client, "You already have max damage resistance and ammo!");
}

bool:HumanReward_GiveReward(client, reward)
{
	switch (reward)
	{
		case RewardType_PrimaryAmmo:
		{
			return HumanReward_PrimaryAmmo(client);
		}

		case RewardType_Health:
		{
			return HumanReward_Health(client);
		}

		case RewardType_SecondaryAmmo:
		{
			return HumanReward_PistolAmmo(client);
		}
	}

	return false;
}

bool:HumanReward_PrimaryAmmo(client)
{
	new weapon = GetPlayerWeaponSlot(client, Slot_Primary);

	if (weapon != INVALID_WEAPON)
	{
		decl String:className[MAX_WEAPON_LENGTH];
		GetEdictClassname(weapon, className, sizeof(className));

		for (new i; i < sizeof(g_szPrimaryWeapons); i++)
		{
			if (StrEqual(className[7], g_szPrimaryWeapons[i])) // Skip the first 7 characters in className to avoid comparing the "weapon_" prefix.
			{
				new ammoAmount = GetWeaponAmmo(client, g_WeaponInfo[i][WI_Ammo]);

				if (ammoAmount < g_WeaponInfo[i][WI_MaxAmmo])
				{
					SetWeaponAmmo(client, g_WeaponInfo[i][WI_Ammo], ammoAmount + g_WeaponInfo[i][WI_ClipSize]);

					ZM_PrintToChat(client, "You received extra primary ammo for killing a zombie.");

					return true;
				}
			}
		}
	}

	return false;
}

bool:HumanReward_PistolAmmo(client)
{
	new maxAmmo = 56;

	if (g_ClientInfo[client][ClientInfo_EquipmentItem] == Menu_Equipment_PistolAmmo)
	{
		maxAmmo += 10;
	}

	new pistol = GetPlayerPistol(client);

	if (pistol != Pistol_Invalid)
	{
		new DoDWeaponAmmo:weaponAmmo, clipSize;

		if (pistol == Pistol_Colt)
		{
			weaponAmmo = Ammo_Colt;
			clipSize = ClipSize_Colt;
		}
		else //if (pistol == Pistol_P38)
		{
			weaponAmmo = Ammo_P38;
			clipSize = ClipSize_P38;
		}

		if (GetWeaponAmmo(client, weaponAmmo) < maxAmmo)
		{
			SetWeaponAmmo(client, weaponAmmo, GetWeaponAmmo(client, weaponAmmo) + clipSize);

			ZM_PrintToChat(client, "You received extra pistol ammo for killing a zombie.");
			return true;
		}
	}

	return false;
}

bool:HumanReward_Health(client)
{
	if (g_ClientInfo[client][ClientInfo_DamageScale] > 0.6)
	{
		g_ClientInfo[client][ClientInfo_DamageScale] -= 0.1;

		ZM_PrintToChat(client, "You received 10%% damage resistance for killing a zombie.");

		return true;
	}

	if (GetClientHealth(client) <= 90)
	{
		g_ClientInfo[client][ClientInfo_Health] += 10.0;
		SetEntityHealth(client, GetClientHealth(client) + 10);

		ZM_PrintToChat(client, "You received 10%% health for killing a zombie.");

		return true;
	}

	return false;
}

GiveZombieReward(client)
{
	new Float:LMV = GetPlayerLaggedMovementValue(client);

	if (LMV < g_ConVars[ConVar_Zombie_MaxSpeed][Value_Float])
	{
		SetPlayerLaggedMovementValue(client, LMV * 1.1);

		ZM_PrintToChat(client, "You received a 10%% speed boost for killing a human.");
	}
	/* else
	{
		ZM_PrintToChat(client, "You already have max speed!");
	} */
}