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
	Menu_Main_KeepWeapons,
	Menu_Main_CreateClass,
	Menu_Main_ChangeCategory,
	Menu_Main_EquipClass
};

enum
{
	Menu_Primary_Garand,
	Menu_Primary_K98,
	Menu_Primary_Thompson,
	Menu_Primary_MP40,
	Menu_Primary_BAR,
	Menu_Primary_MP44,
	Menu_Primary_30Cal,
	Menu_Primary_MG42,
	Menu_Primary_Spring,
	Menu_Primary_K98_Scoped,
	Menu_Primary_Bazooka,
	Menu_Primary_Panzerschreck,
};

enum
{
	Menu_Pistol_Colt,
	Menu_Pistol_P38
};

enum
{
	Menu_Equipment_PistolAmmo,
	Menu_Equipment_PrimaryAmmo
};

enum
{
	Menu_ChangeCategory_Primary,
	Menu_ChangeCategory_Pistol,
	Menu_ChangeCategory_Equipment
};

enum
{
	Menu_KeepCustomClass_No,
	Menu_KeepCustomClass_Yes
};

enum EquipMenu
{
	Handle:Menu_Main,
	Handle:Menu_Primary,
	Handle:Menu_Pistol,
	Handle:Menu_Equipment,
	Handle:Menu_ChangeCategory,
	Handle:Menu_KeepCustomClass
};

new	g_EquipMenu[EquipMenu];

bool:IsPlayerValid(iClient)
{
	return !g_bBlockChangeClass && IsClientInGame(iClient) && IsPlayerAlive(iClient) && GetClientTeam(iClient) == Team_Allies;
}

InitEquipMenu()
{
	g_EquipMenu[Menu_Main] = CreateMenu(Handler_Main, MenuAction_DrawItem|MenuAction_Display);

	SetMenuTitle(g_EquipMenu[Menu_Main], "Equip Menu\n \n");

	AddMenuItem(g_EquipMenu[Menu_Main], NULL_STRING, "Keep Current Weapons\n \n");
	AddMenuItem(g_EquipMenu[Menu_Main], NULL_STRING, "Create Custom Class");
	AddMenuItem(g_EquipMenu[Menu_Main], NULL_STRING, "Change Category Item");
	AddMenuItem(g_EquipMenu[Menu_Main], NULL_STRING, "Equip Custom Class");

	SetMenuExitButton(g_EquipMenu[Menu_Main], false);

	g_EquipMenu[Menu_Primary] = CreateMenu(Handler_Primary, MenuAction_DrawItem|MenuAction_Display);

	SetMenuTitle(g_EquipMenu[Menu_Primary], "Equip Menu - Select Primary Weapon");

	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "M1 Garand");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "Karbiner 98K");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "Thompson");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "MP40");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "BAR");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "STG 44");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "Browning .30 Cal");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "MG42");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "Springfield");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "Karbiner 98K Scoped");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "Bazooka");
	AddMenuItem(g_EquipMenu[Menu_Primary], NULL_STRING, "Panzerschreck");

	SetMenuExitButton(g_EquipMenu[Menu_Primary], false);
	SetMenuExitBackButton(g_EquipMenu[Menu_Primary], true);

	g_EquipMenu[Menu_Pistol] = CreateMenu(Handler_Pistol, MenuAction_DrawItem|MenuAction_Display);

	SetMenuTitle(g_EquipMenu[Menu_Pistol], "Equip Menu - Select Pistol");

	AddMenuItem(g_EquipMenu[Menu_Pistol], NULL_STRING, "Colt 45");
	AddMenuItem(g_EquipMenu[Menu_Pistol], NULL_STRING, "P38");

	SetMenuExitButton(g_EquipMenu[Menu_Pistol], false);
	SetMenuExitBackButton(g_EquipMenu[Menu_Pistol], true);

	g_EquipMenu[Menu_Equipment] = CreateMenu(Handler_Equipment, MenuAction_DrawItem|MenuAction_Display);

	SetMenuTitle(g_EquipMenu[Menu_Equipment], "Equip Menu - Select Extra Equipment");

	AddMenuItem(g_EquipMenu[Menu_Equipment], NULL_STRING, "Extra Pistol Ammo (200%)");
	AddMenuItem(g_EquipMenu[Menu_Equipment], NULL_STRING, "Extra Primary Ammo (200%)");

	SetMenuExitButton(g_EquipMenu[Menu_Equipment], false);
	SetMenuExitBackButton(g_EquipMenu[Menu_Equipment], true);

	g_EquipMenu[Menu_ChangeCategory] = CreateMenu(Handler_ChangeCategory, MenuAction_DrawItem|MenuAction_Display);

	SetMenuTitle(g_EquipMenu[Menu_ChangeCategory], "Equip Menu - Change Category Item");

	AddMenuItem(g_EquipMenu[Menu_ChangeCategory], NULL_STRING, "Primary");
	AddMenuItem(g_EquipMenu[Menu_ChangeCategory], NULL_STRING, "Pistol");
	AddMenuItem(g_EquipMenu[Menu_ChangeCategory], NULL_STRING, "Equipment");

	SetMenuExitButton(g_EquipMenu[Menu_ChangeCategory], false);
	SetMenuExitBackButton(g_EquipMenu[Menu_ChangeCategory], true);

	g_EquipMenu[Menu_KeepCustomClass] = CreateMenu(Handler_KeepCustomClass, MenuAction_DrawItem|MenuAction_Display);

	SetMenuTitle(g_EquipMenu[Menu_KeepCustomClass], "Equip Menu - Remember choice?");

	AddMenuItem(g_EquipMenu[Menu_KeepCustomClass], NULL_STRING, "Yes");
	AddMenuItem(g_EquipMenu[Menu_KeepCustomClass], NULL_STRING, "No");

	SetMenuExitButton(g_EquipMenu[Menu_KeepCustomClass], false);
	SetMenuExitBackButton(g_EquipMenu[Menu_KeepCustomClass], true);
}

public Handler_Main(Handle:menu, MenuAction:menuAction, client, param)
{
	switch (menuAction)
	{
		case MenuAction_DrawItem:
		{
			if (param == Menu_Main_EquipClass)
			{
				return g_ClientInfo[client][ClientInfo_HasCustomClass] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
			}
		}

		case MenuAction_Select:
		{
			if (IsPlayerValid(client))
			{
				switch (param)
				{
					case Menu_Main_CreateClass:
					{
						DisplayMenu(g_EquipMenu[Menu_Primary], client, MENU_TIME_FOREVER);
					}

					case Menu_Main_ChangeCategory:
					{
						DisplayMenu(g_EquipMenu[Menu_ChangeCategory], client, MENU_TIME_FOREVER);
					}

					case Menu_Main_EquipClass:
					{
						Menu_PerformEquip(client);
					}
				}
			}
		}
	}

	return 0;
}

public Handler_Primary(Handle:menu, MenuAction:menuAction, client, param)
{
	switch (menuAction)
	{
		case MenuAction_DrawItem:
		{
			switch (param)
			{
				case Menu_Primary_30Cal, Menu_Primary_MG42:
				{
					return GetPlayerClass(client) == PlayerClass_Machinegunner ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
				}
			}
		}

		case MenuAction_Select:
		{
			if (IsPlayerValid(client))
			{
				g_ClientInfo[client][ClientInfo_PrimaryWeapon] = param;

				DisplayMenu(g_EquipMenu[Menu_Pistol], client, MENU_TIME_FOREVER);
			}
		}

		case MenuAction_Cancel:
		{
			if (param == MenuCancel_ExitBack)
			{
				DisplayMenu(g_EquipMenu[Menu_Main], client, MENU_TIME_FOREVER);
			}
		}
	}

	return 0;
}

public Handler_Pistol(Handle:menu, MenuAction:menuAction, client, param)
{
	switch (menuAction)
	{
		case MenuAction_Select:
		{
			if (IsPlayerValid(client))
			{
				g_ClientInfo[client][ClientInfo_Pistol] = param;
				DisplayMenu(g_EquipMenu[Menu_Equipment], client, MENU_TIME_FOREVER);
			}
		}

		case MenuAction_Cancel:
		{
			if (param == MenuCancel_ExitBack)
			{
				DisplayMenu(g_EquipMenu[Menu_Primary], client, MENU_TIME_FOREVER);
			}
		}
	}

	//return 0;
}

public Handler_Equipment(Handle:menu, MenuAction:menuAction, client, param)
{
	switch (menuAction)
	{
		case MenuAction_Select:
		{
			if (IsPlayerValid(client))
			{
				g_ClientInfo[client][ClientInfo_EquipmentItem] = param;

				DisplayMenu(g_EquipMenu[Menu_KeepCustomClass], client, MENU_TIME_FOREVER);
			}
		}

		case MenuAction_Cancel:
		{
			if (param == MenuCancel_ExitBack)
			{
				DisplayMenu(g_EquipMenu[Menu_Pistol], client, MENU_TIME_FOREVER);
			}
		}
	}

	//return 0;
}

public Handler_ChangeCategory(Handle:menu, MenuAction:menuAction, client, param)
{
	switch (menuAction)
	{
		case MenuAction_Select:
		{
			if (IsPlayerValid(client))
			{
				switch (param)
				{
					case Menu_ChangeCategory_Primary:
					{
						DisplayMenu(g_EquipMenu[Menu_Primary], client, MENU_TIME_FOREVER);
					}
					case Menu_ChangeCategory_Pistol:
					{
						DisplayMenu(g_EquipMenu[Menu_Pistol], client, MENU_TIME_FOREVER);
					}
					case Menu_ChangeCategory_Equipment:
					{
						DisplayMenu(g_EquipMenu[Menu_Equipment], client, MENU_TIME_FOREVER);
					}
				}
			}
		}

		case MenuAction_Cancel:
		{
			if (param == MenuCancel_ExitBack)
			{
				DisplayMenu(g_EquipMenu[Menu_Main], client, MENU_TIME_FOREVER);
			}
		}
	}

	//return 0;
}

public Handler_KeepCustomClass(Handle:menu, MenuAction:menuAction, client, param)
{
	switch (menuAction)
	{
		case MenuAction_Select:
		{
			if (IsPlayerValid(client))
			{
				g_ClientInfo[client][ClientInfo_ShouldAutoEquip] = param ? false : true;

				Menu_PerformEquip(client);
			}
		}

		case MenuAction_Cancel:
		{
			if (param == MenuCancel_ExitBack)
			{
				DisplayMenu(g_EquipMenu[Menu_Equipment], client, MENU_TIME_FOREVER);
			}
		}
	}

	//return 0;
}

Menu_PerformEquip(client)
{
	g_ClientInfo[client][ClientInfo_HasCustomClass] = true;
	g_ClientInfo[client][ClientInfo_HasEquipped] = true;

	RemoveWeapons(client);

	GivePlayerItem(client, "weapon_amerknife");

	Menu_Equip_Primary(client);
	Menu_Equip_Pistol(client);

	switch (g_ClientInfo[client][ClientInfo_EquipmentItem])
	{
		case Menu_Equipment_PistolAmmo:
		{
			Menu_Equip_PistolAmmo(client);
		}

		case Menu_Equipment_PrimaryAmmo:
		{
			Menu_Equip_PrimaryAmmo(client);
		}
	}
}

Menu_Equip_Primary(client)
{
	switch (g_ClientInfo[client][ClientInfo_PrimaryWeapon])
	{
		case Menu_Primary_Garand:
		{
			GivePlayerItem(client, "weapon_garand");
			SetWeaponAmmo(client, Ammo_Garand, DefaultAmmo_Garand);

			GivePlayerItem(client, "weapon_riflegren_us");
			SetWeaponAmmo(client, Ammo_Riflegren_US, DefaultAmmo_Riflegren_US);
		}

		case Menu_Primary_K98:
		{
			GivePlayerItem(client, "weapon_k98");
			SetWeaponAmmo(client, Ammo_K98, DefaultAmmo_K98);

			GivePlayerItem(client, "weapon_riflegren_ger");
			SetWeaponAmmo(client, Ammo_Riflegren_GER, DefaultAmmo_Riflegren_GER);
		}

		case Menu_Primary_Thompson:
		{
			GivePlayerItem(client, "weapon_thompson");
			SetWeaponAmmo(client, Ammo_SubMG, DefaultAmmo_Thompson);
		}

		case Menu_Primary_MP40:
		{
			GivePlayerItem(client, "weapon_mp40");
			SetWeaponAmmo(client, Ammo_SubMG, DefaultAmmo_MP40);
		}

		case Menu_Primary_BAR:
		{
			GivePlayerItem(client, "weapon_bar");
			SetWeaponAmmo(client, Ammo_BAR, DefaultAmmo_BAR);
		}

		case Menu_Primary_MP44:
		{
			GivePlayerItem(client, "weapon_mp44");
			SetWeaponAmmo(client, Ammo_SubMG, DefaultAmmo_MP44);
		}

		case Menu_Primary_30Cal:
		{
			GivePlayerItem(client, "weapon_30cal");
			SetWeaponAmmo(client, Ammo_30Cal, DefaultAmmo_30Cal);
		}

		case Menu_Primary_MG42:
		{
			GivePlayerItem(client, "weapon_mg42");
			SetWeaponAmmo(client, Ammo_MG42, DefaultAmmo_MG42);
		}

		case Menu_Primary_Spring:
		{
			GivePlayerItem(client, "weapon_spring");
			SetWeaponAmmo(client, Ammo_Spring, DefaultAmmo_Spring);
		}

		case Menu_Primary_K98_Scoped:
		{
			GivePlayerItem(client, "weapon_k98_scoped");
			SetWeaponAmmo(client, Ammo_K98, DefaultAmmo_K98_Scoped);
		}

		case Menu_Primary_Bazooka:
		{
			GivePlayerItem(client, "weapon_bazooka");
			SetWeaponAmmo(client, Ammo_Rocket, DefaultAmmo_Rocket);
		}

		case Menu_Primary_Panzerschreck:
		{
			GivePlayerItem(client, "weapon_pschreck");
			SetWeaponAmmo(client, Ammo_Rocket, DefaultAmmo_Rocket);
		}
	}
}

Menu_Equip_PrimaryAmmo(client)
{
	switch (g_ClientInfo[client][ClientInfo_PrimaryWeapon])
	{
		case Menu_Primary_Garand:
		{
			SetWeaponAmmo(client, Ammo_Garand, ExtraAmmoGarand);
			SetWeaponAmmo(client, Ammo_Riflegren_US, ExtraAmmoRiflegren_US);
		}

		case Menu_Primary_K98:
		{
			SetWeaponAmmo(client, Ammo_K98, ExtraAmmoK98);
			SetWeaponAmmo(client, Ammo_Riflegren_GER, ExtraAmmoRiflegren_GER);
		}

		case Menu_Primary_Thompson:
		{
			SetWeaponAmmo(client, Ammo_SubMG, ExtraAmmoThompson);
		}

		case Menu_Primary_MP40:
		{
			SetWeaponAmmo(client, Ammo_SubMG, ExtraAmmoMP40);
		}

		case Menu_Primary_BAR:
		{
			SetWeaponAmmo(client, Ammo_BAR, ExtraAmmoBAR);
		}

		case Menu_Primary_MP44:
		{
			SetWeaponAmmo(client, Ammo_SubMG, ExtraAmmoMP44);
		}

		case Menu_Primary_30Cal:
		{
			SetWeaponAmmo(client, Ammo_30Cal, ExtraAmmo30Cal);
		}

		case Menu_Primary_MG42:
		{
			SetWeaponAmmo(client, Ammo_MG42, ExtraAmmoMG42);
		}

		case Menu_Primary_Spring:
		{
			SetWeaponAmmo(client, Ammo_Spring, ExtraAmmoSpring);
		}

		case Menu_Primary_K98_Scoped:
		{
			SetWeaponAmmo(client, Ammo_K98, ExtraAmmoK98_Scoped);
		}

		case Menu_Primary_Bazooka:
		{
			SetWeaponAmmo(client, Ammo_Rocket, ExtraAmmoRocket);
		}

		case Menu_Primary_Panzerschreck:
		{
			SetWeaponAmmo(client, Ammo_Rocket, ExtraAmmoRocket);
		}
	}
}

Menu_Equip_Pistol(client)
{
	switch (g_ClientInfo[client][ClientInfo_Pistol])
	{
		case Menu_Pistol_Colt:
		{
			GivePlayerItem(client, "weapon_colt");
			SetWeaponAmmo(client, Ammo_Colt, DefaultAmmo_Colt);
		}

		case Menu_Pistol_P38:
		{
			GivePlayerItem(client, "weapon_p38");
			SetWeaponAmmo(client, Ammo_P38, DefaultAmmo_P38);
		}
	}
}

Menu_Equip_PistolAmmo(client)
{
	switch (g_ClientInfo[client][ClientInfo_Pistol])
	{
		case Menu_Pistol_Colt:
		{
			SetWeaponAmmo(client, Ammo_Colt, ExtraAmmoColt);
		}

		case Menu_Pistol_P38:
		{
			SetWeaponAmmo(client, Ammo_P38, ExtraAmmoP38);
		}
	}
}