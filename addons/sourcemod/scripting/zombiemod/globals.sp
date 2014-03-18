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

new	bool:g_bModActive,
#if defined _steamtools_included
	bool:g_bUseSteamTools,
#endif
#if defined _SENDPROXYMANAGER_INC_
	bool:g_bUseSendProxy,
#endif
	bool:g_bRoundEnded,
	bool:g_bBlockChangeClass,
	g_iZombie,
	g_iLastHuman,
	g_iRoundWins,
	g_iBeamSprite,
	g_iHaloSprite,
	g_iRoundTimer,
	g_iBeaconTicks,
	g_iNumZombieSpawns,
	Handle:g_hRoundTimer,
	Float:g_vecZombieSpawnOrigin[MAX_SPAWNPOINTS][3];

enum ClientInfo
{
	ClientInfo_KillsAsHuman,         // Total number of kills the player has as human.
	ClientInfo_KillsAsZombie,        // Total number of kills the player has as zombie.

	bool:ClientInfo_IsCritial,       // True if zombie is critical (only has 2 hp), false otherwise
	ClientInfo_Critter,              // Userid of the attacker that scored the crirital hit on the player.

	bool:ClientInfo_SelectedClass,   // True if player has selected a player class, false otherwise.

	ClientInfo_Pistol,               // The type of pistol the player has.
	ClientInfo_PrimaryWeapon,        // The type of primary wepaon the player has.
	ClientInfo_EquipmentItem,        // The type of equipment item the player has.
	bool:ClientInfo_HasCustomClass,  // True if the player has created a custom class, false otherwise.
	bool:ClientInfo_HasEquipped,     // True if the player has equipped once during the current round.
	bool:ClientInfo_ShouldAutoEquip, // True if the player has chosen to auto-equip with the custom class.

	Float:ClientInfo_DamageScale,    // The value that the damaged done to the player should be scaled down to.
	Float:ClientInfo_Health,         // The amount of health relative to the damage scale.

	bool:ClientInfo_WeaponCanUse     // If true the WeaponCanUse() hook will run, false otherwise.
};

new	g_ClientInfo[DOD_MAXPLAYERS + 1][ClientInfo];