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

InitCommands()
{
	AddCommandListener(CommandListener_TimeLeft, "timeleft");
	AddCommandListener(CommandListener_JoinTeam, "jointeam");
	AddCommandListener(CommandListener_DropAmmo, "dropammo");
}

ShowTimeleft()
{
	ZM_PrintToChatAll("Rounds played: %i of %i before map-change.", g_iRoundWins, g_ConVars[ConVar_WinLimit][Value_Int]);
}

public Action:OnClientSayCommand(client, const String:command[], const String:sArgs[])
{
	decl String:text[13];
	Format(text, sizeof(text), sArgs); // strcopy is evil
	StripQuotes(text);

	if (StrEqual(text,    "timeleft", false)
	||  StrEqual(text[1], "timeleft", false))
	{
		ShowTimeleft();
	}
	else if (GetClientTeam(client) == Team_Allies
	&& (StrEqual(text[1], "equipmenu", false)
	|| StrEqual(text,     "equipmenu", false)))
	{
		g_ClientInfo[client][ClientInfo_ShouldAutoEquip] = false;

		if (!g_bBlockChangeClass)
		{
			if (!g_ClientInfo[client][ClientInfo_HasEquipped])
			{
				DisplayMenu(g_EquipMenu[Menu_Main], client, 30);
			}
			else
			{
				ZM_PrintToChat(client, "You can use equip-menu only once per spawn!");
			}
		}
		else
		{
			ZM_PrintToChat(client, "90 seconds has passed, you cannot equip any more!");
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:CommandListener_TimeLeft(client, const String:command[], numArgs)
{
	ShowTimeleft();

	return Plugin_Handled;
}

RedisplayTeamSelection(client, const String:message[])
{
	PrintCenterText(client, message);
	ClientCommand(client, "changeteam");
}

public Action:CommandListener_JoinTeam(client, const String:command[], numArgs)
{
	if (client && 0 < numArgs < 2)
	{
		decl String:arg[8];
		GetCmdArg(1, arg, sizeof(arg));

		new desiredTeam = StringToInt(arg);

		if (g_bModActive)
		{
			switch (desiredTeam)
			{
				case Team_Unassigned: // Auto-assign
				{
					RedisplayTeamSelection(client, "You cannot Auto-Assign");

					return Plugin_Handled;
				}

				case Team_Spectator:
				{
					RedisplayTeamSelection(client, "You cannot join Spectators");

					return Plugin_Handled;
				}

				case Team_Allies:
				{
					switch (GetClientTeam(client))
					{
						case Team_Unassigned, Team_Spectator:
						{
							ChangeClientTeam(client, Team_Axis);

							return Plugin_Handled;
						}

						case Team_Axis:
						{
							RedisplayTeamSelection(client, "You cannot join Humans at this time");

							return Plugin_Handled;
						}
					}
				}

				case Team_Axis:
				{
					ChangeClientTeam(client, Team_Axis);

					return Plugin_Handled;
				}
			}
		}
		else if (desiredTeam == Team_Allies) // Bypass team balance.
		{
			ChangeClientTeam(client, Team_Allies);

			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action:CommandListener_DropAmmo(client, const String:command[], numArgs)
{
	return g_bModActive && GetClientTeam(client) == Team_Axis ? Plugin_Handled : Plugin_Continue;
}