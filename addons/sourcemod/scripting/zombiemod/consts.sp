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

#define PLUGIN_NAME "DoD:S Zombie Mod"
#define PLUGIN_VERSION "0.6 BETA"
#define SCOREBOARD_MAX_ELEMENTS 5
#define MAX_WEAPON_LENGTH 24
#define DOD_MAXPLAYERS 33
#define MAX_SPAWNPOINTS 64
#define MAX_HEALTH 100.0
#define SOUND_BLIP "buttons/blip1.wav"
#define ZM_PRINT_FORMAT "\x079D0F0FZombie Mod\x01: %s"

enum
{
	Pistol_Invalid = -1,
	Pistol_Colt,
	Pistol_P38
};

enum
{
	Team_Unassigned,
	Team_Spectator,
	Team_Allies,
	Team_Axis,
	Team_Custom
};

enum
{
	Slot_Primary,
	Slot_Secondary,
	Slot_Melee,
	Slot_Grenade,

	Slot_Size
};

enum
{
	INVALID_WEAPON = -1,
	WeaponID_TNT,
	WeaponID_AmerKnife,
	WeaponID_Spade,
	WeaponID_Colt,
	WeaponID_P38,
	WeaponID_C96,
	WeaponID_Garand,
	WeaponID_M1Carbine,
	WeaponID_K98,
	WeaponID_Spring,
	WeaponID_K98_Scoped,
	WeaponID_Thompson,
	WeaponID_MP40,
	WeaponID_MP44,
	WeaponID_BAR,
	WeaponID_30Cal,
	WeaponID_MG42,
	WeaponID_Bazooka,
	WeaponID_Pschreck,
	WeaponID_Frag_US,
	WeaponID_Frag_Ger,
	WeaponID_Frag_US_Live,
	WeaponID_Frag_Ger_Live,
	WeaponID_Smoke_US,
	WeaponID_Smoke_Ger,
	WeaponID_Riflegren_US,
	WeaponID_Riflegren_Ger,
	WeaponID_Riflegren_US_Live,
	WeaponID_Riflegren_Ger_Live,
	WeaponID_Thompson_Punch,
	WeaponID_MP40_Punch,
	WeaponID_Garand_Zoomed,
	WeaponID_K98_Zoomed,
	WeaponID_Spring_Zoomed,
	WeaponID_K98_Scoped_Zoomed,
	WeaponID_30Cal_Undeployed,
	WeaponID_MG42_Undeployed,
	WeaponID_BAR_SemiAuto,
	WeaponID_MP44_SemiAuto
};

enum
{
	ClipSize_Colt = 7,
	ClipSize_P38 = 8,
	ClipSize_Garand = 8,
	ClipSize_K98 = 5,
	ClipSize_Thompson = 30,
	ClipSize_MP40 = 30,
	ClipSize_BAR = 20,
	ClipSize_MP44 = 30,
	ClipSize_30Cal = 150,
	ClipSize_MG42 = 250,
	ClipSize_Spring = 5,
	ClipSize_K98_Scoped = 5,
	ClipSize_Rocket = 1
};

enum
{
	DefaultAmmo_Colt = 28,
	DefaultAmmo_P38 = 32,
	DefaultAmmo_Garand = 80,
	DefaultAmmo_K98 = 60,
	DefaultAmmo_Thompson = 180,
	DefaultAmmo_MP40 = 180,
	DefaultAmmo_BAR = 240,
	DefaultAmmo_MP44 = 180,
	DefaultAmmo_30Cal = 300,
	DefaultAmmo_MG42 = 250,
	DefaultAmmo_Spring = 50,
	DefaultAmmo_K98_Scoped = 60,
	DefaultAmmo_Rocket = 4,
	DefaultAmmo_Riflegren_US = 2,
	DefaultAmmo_Riflegren_GER = 2
};

enum
{
	ExtraAmmoColt = 56,
	ExtraAmmoP38 = 56,
	ExtraAmmoGarand = 160,
	ExtraAmmoK98 = 120,
	ExtraAmmoThompson = 360,
	ExtraAmmoMP40 = 360,
	ExtraAmmoBAR = 360,
	ExtraAmmoMP44 = 360,
	ExtraAmmo30Cal = 450,
	ExtraAmmoMG42 = 500,
	ExtraAmmoSpring = 100,
	ExtraAmmoK98_Scoped = 120,
	ExtraAmmoRocket = 8,
	ExtraAmmoRiflegren_US = 3, // is equal to 4 in inventory...
	ExtraAmmoRiflegren_GER = 3
};