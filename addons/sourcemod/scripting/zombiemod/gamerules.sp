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

InitGameRules()
{
	HookEvent("dod_round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("dod_round_active", Event_RoundActive, EventHookMode_PostNoCopy);
}

public Event_RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_bModActive)
	{
		static const String:objectiveKillEnts[][] =
		{
			"dod_round_timer",
			"dod_bomb_target",
			"dod_capture_area"
		};

		static const String:teamBlockerKillEnts[][] =
		{
			"func_team_wall",
			"func_teamblocker"
		};

		new entity = -1;

		if (!g_bWhiteListed[WhiteList_Objectives])
		{
			SetNumControlPoints(0);

			// Remove all objective related entities
			for (new i; i < sizeof(objectiveKillEnts); i++)
			{
				while ((entity = FindEntityByClassname(entity, objectiveKillEnts[i])) != -1)
				{
					AcceptEntityInput(entity, "Kill");
				}
			}

			entity = -1;

			// Disable all bomb dispensers
			while ((entity = FindEntityByClassname(entity, "dod_bomb_dispenser")) != -1)
			{
				AcceptEntityInput(entity, "Disable");
			}

			entity = -1;

			// Hide all control point flags.
			while ((entity = FindEntityByClassname(entity, "dod_control_point")) != -1)
			{
				AcceptEntityInput(entity, "HideModel");
			}

			entity = -1;

			// Stop flag wave sound on all control points
			while ((entity = FindEntityByClassname(entity, "ambient_generic")) != -1)
			{
				decl String:soundFileName[PLATFORM_MAX_PATH];
				GetEntPropString(entity, Prop_Data, "m_iszSound", soundFileName, sizeof(soundFileName));

				if (StrEqual(soundFileName, "ambient/flag.wav"))
				{
					AcceptEntityInput(entity, "StopSound");
				}
			}

			if (g_hRoundTimer != INVALID_HANDLE)
			{
				KillTimer(g_hRoundTimer);

				g_hRoundTimer = INVALID_HANDLE;
			}

			CreateTimer(0.1, Timer_CreateRoundTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		}

		// Remove HDR tone-mapping controllers
		if (!g_bWhiteListed[WhiteList_Environment])
		{
			entity = -1;

			while ((entity = FindEntityByClassname(entity, "env_tonemap_controller")) != -1)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}

		// Remove trigger_hurts
		if (!g_bWhiteListed[WhiteList_TriggerHurts])
		{
			entity = -1;

			while ((entity = FindEntityByClassname(entity, "trigger_hurt")) != -1)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}

		// Remove team blockers
		if (!g_bWhiteListed[WhiteList_TeamBlockers])
		{
			entity = -1;

			for (new i; i < sizeof(teamBlockerKillEnts); i++)
			{
				while ((entity = FindEntityByClassname(entity, teamBlockerKillEnts[i])) != -1)
				{
					AcceptEntityInput(entity, "Kill");
				}
			}
		}

		entity = -1;

		// Remove scoring entities
		while ((entity = FindEntityByClassname(entity, "dod_scoring")) != -1)
		{
			AcceptEntityInput(entity, "Kill");
		}
	}
}

public Action:Timer_CreateRoundTimer(Handle:timer)
{
	if ((g_iRoundTimer = CreateEntityByName("dod_round_timer")) != -1)
	{
		SetTimeRemaining(g_iRoundTimer, g_ConVars[ConVar_Zombie_RoundTime][Value_Int]);

		PauseTimer(g_iRoundTimer);
	}
}

public Event_RoundActive(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_bModActive)
	{
		ResumeTimer(g_iRoundTimer);

		g_hRoundTimer = CreateTimer(1.0, Timer_RoundTimerThink, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

bool:CheckWinConditions()
{
	if (g_bRoundEnded)
	{
		return true;
	}

	new numHumans = GetHumanCount();

	if (!numHumans)
	{
		RoundEnd(Team_Axis);
	}
	else if (numHumans == 1 && !g_iLastHuman)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsClientSourceTV(i))
			{
				ZM_PrintToChat(i, "The last man standing has been beaconed!");

				EmitSoundToClient(i, g_szSounds[Sound_LastManStanding]);

				if (!g_iLastHuman && GetClientTeam(i) == Team_Allies)
				{
					g_iLastHuman = GetClientUserId(i);
				}
			}
		}
	}

	return g_bRoundEnded;
}

RoundEnd(winningTeam)
{
	new bool:winLimitReached = ++g_iRoundWins >= g_ConVars[ConVar_WinLimit][Value_Int];

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsClientSourceTV(i))
		{
			if (g_iLastHuman)
			{
				StopSound(i, SNDCHAN_AUTO, g_szSounds[Sound_LastManStanding]);
			}

			if (winLimitReached)
			{
				EmitSoundToClient(i, g_szSounds[Sound_End]);
				ZM_PrintToChat(i, "Win-limit reached! Changing map...");
			}
			else if (winningTeam == Team_Allies)
			{
				EmitSoundToClient(i, g_szSounds[Sound_HumansWin]);
				ScreenOverlay(i, g_szOverlay[Overlay_HumansWin]);
			}
			else if (winningTeam == Team_Axis)
			{
				EmitSoundToClient(i, g_szSounds[Sound_ZombiesWin]);
				ScreenOverlay(i, g_szOverlay[Overlay_ZombiesWin]);
			}
		}
	}

	g_bRoundEnded = true;

	if (winLimitReached)
	{
		decl String:buffer[64];

		new Handle:topHumanKills = CreateArray(), Handle:topZombieKills = CreateArray();

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsClientSourceTV(i))
			{
				if (g_ClientInfo[i][ClientInfo_KillsAsHuman])
				{
					PushArrayCell(topHumanKills, i);
				}

				if (g_ClientInfo[i][ClientInfo_KillsAsZombie])
				{
					PushArrayCell(topZombieKills, i);
				}
			}
		}

		new Handle:topScorePanel = CreatePanel();

		SetPanelTitle(topScorePanel, "Top scores");
		DrawPanelText(topScorePanel, "\n \nHumans:");

		new topHumanArraySize = GetArraySize(topHumanKills);

		if (topHumanArraySize)
		{
			SortADTArrayCustom(topHumanKills, SortByKillsAsHuman);

			if (topHumanArraySize > SCOREBOARD_MAX_ELEMENTS)
			{
				topHumanArraySize = SCOREBOARD_MAX_ELEMENTS;
			}

			for (new i; i < topHumanArraySize; i++)
			{
				new client = GetArrayCell(topHumanKills, i);

				GetClientName(client, buffer, sizeof(buffer));
				Format(buffer, sizeof(buffer), "%i. %s (%i Kills)", i++, buffer, g_ClientInfo[client][ClientInfo_KillsAsHuman]);

				DrawPanelText(topScorePanel, buffer);
			}
		}
		else
		{
			DrawPanelText(topScorePanel, "<None>");
		}

		DrawPanelText(topScorePanel, "\n \nZombies:");

		new topZombieArraySize = GetArraySize(topZombieKills);

		if (topZombieArraySize)
		{
			SortADTArrayCustom(topZombieKills, SortByKillsAsZombie);

			if (topZombieArraySize > SCOREBOARD_MAX_ELEMENTS)
			{
				topZombieArraySize = SCOREBOARD_MAX_ELEMENTS;
			}

			for (new i; i < topZombieArraySize; i++)
			{
				new client = GetArrayCell(topZombieKills, i);

				GetClientName(client, buffer, sizeof(buffer));
				Format(buffer, sizeof(buffer), "%i. %s	(%i Kills)", i + 1, buffer, g_ClientInfo[client][ClientInfo_KillsAsZombie]);

				DrawPanelText(topScorePanel, buffer);
			}
		}
		else
		{
			DrawPanelText(topScorePanel, "<None>");
		}

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsClientSourceTV(i))
			{
				SendPanelToClient(topScorePanel, i, MenuHandler_Dummy, 10);
			}
		}

		CloseHandle(topHumanKills);
		CloseHandle(topZombieKills);
		CloseHandle(topScorePanel);

		CreateTimer(10.0, Timer_EndGame, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		CreateTimer(10.0, Timer_RestartRound, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public SortByKillsAsHuman(client, target, Handle:array, Handle:handle)
{
	return g_ClientInfo[client][ClientInfo_KillsAsHuman] >= g_ClientInfo[target][ClientInfo_KillsAsHuman];
}

public SortByKillsAsZombie(client, target, Handle:array, Handle:handle)
{
	return g_ClientInfo[client][ClientInfo_KillsAsZombie] >= g_ClientInfo[target][ClientInfo_KillsAsZombie];
}

public MenuHandler_Dummy(Handle:panel, MenuAction:menuAction, param1, param2)
{
	return;
}

public Action:OnAddWaveTime(index, &Float:delay)
{
	return g_bModActive ? Plugin_Handled : Plugin_Continue;
}

public Action:Timer_RoundTimerThink(Handle:timer)
{
	if (g_bRoundEnded)
	{
		PauseTimer(g_iRoundTimer);

		g_hRoundTimer = INVALID_HANDLE;

		return Plugin_Stop;
	}

	new timeRemaining = RoundFloat(GetTimeRemaining(g_iRoundTimer)) - 1;

	if (!g_bBlockChangeClass && (g_ConVars[ConVar_Zombie_RoundTime][Value_Int] - timeRemaining == 60))
	{
		g_bBlockChangeClass = true;
	}

	if (g_iLastHuman)
	{
		new lastHuman = GetClientOfUserId(g_iLastHuman);

		new interval = g_ConVars[ConVar_Beacon_Interval][Value_Int];

		if (lastHuman && g_iBeaconTicks++ % (interval * 2) >= interval)
		{
			decl Float:vecPosition[3];
			GetClientAbsOrigin(lastHuman, vecPosition);

			vecPosition[2] += 10.0;

			TE_SetupBeamRingPoint(vecPosition, 10.0, 550.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.6, 10.0, 0.5, { 0, 255, 0, 255 }, 10, 0);
			TE_SendToAll();

			EmitAmbientSound(SOUND_BLIP, vecPosition, lastHuman, SNDLEVEL_RAIDSIREN);
		}
	}

	switch (timeRemaining)
	{
		case 0:
		{
			RoundEnd(Team_Allies);

			g_hRoundTimer = INVALID_HANDLE;

			return Plugin_Stop;
		}

		case 60, 120:
		{
			FlashTimer(timeRemaining);
		}
	}

	return Plugin_Continue;
}

public Action:Timer_EndGame(Handle:timer)
{
	new entity = CreateEntityByName("game_end", -1);

	if (entity != -1)
	{
		AcceptEntityInput(entity, "EndGame");
	}
	else
	{
		LogError("Unable to create entity: \"game_end\" !");
	}
}

public Action:Timer_RestartRound(Handle:timer)
{
	if (g_ConVars[ConVar_MinPlayers][Value_Int] <= GetTeamClientCount(Team_Allies) + GetTeamClientCount(Team_Axis))
	{
		g_iLastHuman = g_iBeaconTicks = g_bBlockChangeClass = false;

		g_bModActive = true;

		SelectZombie();

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsClientSourceTV(i))
			{
				RemoveScreenOverlay(i);

				if (i != g_iZombie && GetClientTeam(i) > Team_Spectator)
				{
					// This prevents the players from committing suicide
					SetPlayerState(i, PlayerState_ObserverMode);

					ChangeClientTeam(i, Team_Allies);
				}
			}
		}

		if (GetClientTeam(g_iZombie) != Team_Axis)
		{
			SetPlayerState(g_iZombie, PlayerState_ObserverMode);
			ChangeClientTeam(g_iZombie, Team_Axis);
		}
	}
	else
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsClientSourceTV(i))
			{
				RemoveScreenOverlay(i);
			}
		}

		if (g_hRoundTimer != INVALID_HANDLE)
		{
			KillTimer(g_hRoundTimer);

			g_hRoundTimer = INVALID_HANDLE;
		}

		new entity = FindEntityByClassname(-1, "dod_round_timer");

		// Round-timers are preserved on round restarts, and therefore it needs to get removed when the mod is inactive.
		if (entity != -1)
		{
			AcceptEntityInput(entity, "Kill");
		}

		g_bModActive = false;
	}

	g_bRoundEnded = false;

	SetRoundState(DoDRoundState_Restart);
}