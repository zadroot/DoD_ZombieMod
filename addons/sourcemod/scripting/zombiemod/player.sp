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

InitPlayers()
{
	HookEvent("player_team",  Event_PlayerTeam,  EventHookMode_Pre);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("dod_stats_player_damage", Event_PlayerDamage, EventHookMode_Post);

	AddNormalSoundHook(OnNormalSoundPlayed);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_ShouldCollide, OnShouldCollide);
	
#if defined _SENDPROXYMANAGER_INC_
	if (g_bUseSendProxy)
	{
		SendProxy_Hook(client, "m_iTeamNum", Prop_Int, SendProxy_TeamNum);
	}
#endif

	g_ClientInfo[client][ClientInfo_KillsAsHuman] =
	g_ClientInfo[client][ClientInfo_KillsAsZombie] =
	g_ClientInfo[client][ClientInfo_Critter] =
	g_ClientInfo[client][ClientInfo_IsCritial] =
	g_ClientInfo[client][ClientInfo_SelectedClass] =
	g_ClientInfo[client][ClientInfo_HasCustomClass] =
	g_ClientInfo[client][ClientInfo_ShouldAutoEquip] = false;
	
	EmitSoundToClient(client, g_szSounds[Sound_JoinServer]);
}

// ADD CLASS SELECTION MENU

public OnClientDisconnect_Post(client)
{
	if (g_bModActive)
	{
		// If the disconnected player was critical, give the critter the kill and reward.
		if (g_ClientInfo[client][ClientInfo_IsCritial])
		{
			new critAttacker = GetClientOfUserId(g_ClientInfo[client][ClientInfo_Critter]);

			if (critAttacker)
			{
				AddPlayerKills(critAttacker, 1);
				GiveHumanReward(critAttacker);
			}
		}

		new numAllies = GetTeamClientCount(Team_Allies);
		new numAxis = GetTeamClientCount(Team_Axis);

		// Restart if there are not enough players.
		if (numAllies + numAxis <= g_ConVars[ConVar_MinPlayers][Value_Int])
		{
			g_bRoundEnded = true;

			CreateTimer(10.0, Timer_RestartRound, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		else if (numAxis == 0)
		{
			SelectZombie();

			SetPlayerState(g_iZombie, PlayerState_ObserverMode);
			ChangeClientTeam(g_iZombie, Team_Axis);

			PrintHintText(g_iZombie, "You are now a Zombie!");
			ZM_PrintToChatAll("Player %N is now a Zombie.", g_iZombie);
		}
		else if (numAllies == 0)
		{
			CheckWinConditions();
		}
	}
}

SetPlayerModel(client, model)
{
	if (g_szModel[model][0] != '\0')
	{
		SetEntityModel(client, g_szModel[model]);
	}
}

public Event_PlayerSpawn(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_ConVars[ConVar_Enabled][Value_Bool])
	{
		new clientUserId = GetEventInt(event, "userid");
		new client = GetClientOfUserId(clientUserId);

		g_ClientInfo[client][ClientInfo_Health] = MAX_HEALTH;
		g_ClientInfo[client][ClientInfo_WeaponCanUse] = true;

		if (!g_bModActive)
		{
			if (!g_bRoundEnded && g_ConVars[ConVar_MinPlayers][Value_Int] <= GetTeamClientCount(Team_Allies) + GetTeamClientCount(Team_Axis))
			{
				g_bRoundEnded = true;

				ZM_PrintToChatAll("Game commencing in 15 seconds!");

				CreateTimer(15.0, Timer_RestartRound, _, TIMER_FLAG_NO_MAPCHANGE);

				SetRoundState(DoDRoundState_Restart);
			}
		}
		else
		{
			switch (GetClientTeam(client))
			{
				case Team_Allies:
				{
					g_ClientInfo[client][ClientInfo_DamageScale] = 1.0;
					g_ClientInfo[client][ClientInfo_HasEquipped] = false;

					if (!g_bRoundEnded)
					{
						if (!g_ClientInfo[client][ClientInfo_ShouldAutoEquip])
						{
							CreateTimer(1.0, Timer_ShowEquipMenu, clientUserId, TIMER_FLAG_NO_MAPCHANGE);
						}
						else
						{
							Menu_PerformEquip(client);
						}

						new playerClass = GetPlayerClass(client);

						if (playerClass == PlayerClass_Rifleman
						|| playerClass  == PlayerClass_Support)
						{
							GivePlayerItem(client, "weapon_colt");
						}
						else if (playerClass == PlayerClass_Assault)
						{
							// Remove smoke grenade
							new weapon = GetPlayerWeaponSlot(client, Slot_Melee);

							if (weapon != INVALID_WEAPON)
							{
								RemovePlayerItem(client, weapon);
								AcceptEntityInput(weapon, "Kill");
							}

							GivePlayerItem(client, "weapon_amerknife");
						}
						else if (playerClass == PlayerClass_Rocket)
						{
							// Remove secondary weapon
							new weapon = GetPlayerWeaponSlot(client, Slot_Secondary);

							if (weapon != INVALID_WEAPON)
							{
								RemovePlayerItem(client, weapon);
								AcceptEntityInput(weapon, "Kill");
							}

							GivePlayerItem(client, "weapon_colt");
						}

						SetWeaponAmmo(client, Ammo_Colt, ExtraAmmoColt);
					}
				}
				case Team_Axis:
				{
					g_ClientInfo[client][ClientInfo_DamageScale] = FloatDiv(MAX_HEALTH, g_ConVars[ConVar_Zombie_Health][Value_Float]);
					g_ClientInfo[client][ClientInfo_IsCritial] = false;

					RemoveWeapons(client);
					GivePlayerItem(client, "weapon_spade");

					PlaySoundFromPlayer(client, g_szSounds[Sound_ZombieSpawn]);
					
					SetPlayerModel(client, Model_Zombie_Default);
					
					SetPlayerLaggedMovementValue(client, g_ConVars[ConVar_Zombie_Speed][Value_Float]);
				}
			}
		}
	}
}

public Action:Timer_ShowEquipMenu(Handle:timer, any:client)
{
	if ((client = GetClientOfUserId(client)) && GetClientTeam(client) == Team_Allies)
	{
		DisplayMenu(g_EquipMenu[Menu_Main], client, 30);
	}
}

public Action:Event_PlayerDeath(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_bModActive)
	{
		new clientUserId = GetEventInt(event, "userid");
		new client = GetClientOfUserId(clientUserId);
		new attackerUserId = GetEventInt(event, "attacker");
		new attacker = GetClientOfUserId(attackerUserId);

		if (GetEventBool(event, "dominated") || GetEventBool(event, "revenge"))
		{
			SetEventBool(event, "dominated", false);
			SetEventBool(event, "revenge", false);
			ResetDominations(attacker, client);
		}

		if (GetClientTeam(client) == Team_Allies)
		{
			SetEventString(event, "weapon", "crit");
			CreateTimer(0.1, Timer_SwitchToZombieTeam, clientUserId|(attackerUserId << 16), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			PlaySoundFromPlayer(client, g_szSounds[Sound_ZombieDeath]);

			new critAttacker = GetClientOfUserId(g_ClientInfo[client][ClientInfo_Critter]);

			if (critAttacker)
			{
				if (critAttacker != attacker)
				{
					AddPlayerKills(critAttacker, 1);

					SetEventInt(event, "attacker", g_ClientInfo[client][ClientInfo_Critter]);
					SetEventString(event, "weapon", "crit");

					if (attacker)
					{
						AddPlayerKills(attacker, -1);
					}
				}

				GiveHumanReward(critAttacker);

				g_ClientInfo[client][ClientInfo_Critter] = 0;

				g_ClientInfo[attacker][ClientInfo_KillsAsHuman]++;
			}
			else if (attacker && attacker != client)
			{
				GiveHumanReward(attacker);

				g_ClientInfo[attacker][ClientInfo_KillsAsHuman]++;
			}
		}
	}
}

public Action:Timer_SwitchToZombieTeam(Handle:timer, any:data)
{
	new client = data & 0x0000FFFF;
	new attacker = data >> 16;

	if ((client = GetClientOfUserId(client)))
	{
		ChangeClientTeam(client, Team_Axis);
	}

	if (!CheckWinConditions() && (attacker = GetClientOfUserId(attacker)) && attacker != client)
	{
		g_ClientInfo[attacker][ClientInfo_Critter] = 0;
		g_ClientInfo[attacker][ClientInfo_KillsAsZombie]++;

		if (IsPlayerAlive(attacker))
		{
			if (g_ClientInfo[attacker][ClientInfo_IsCritial] && g_ConVars[ConVar_Zombie_CritReward][Value_Int])
			{
				new newHealth = GetClientHealth(attacker) + g_ConVars[ConVar_Zombie_CritReward][Value_Int];
				
				SetEntityHealth(attacker, newHealth);
				g_ClientInfo[attacker][ClientInfo_Health] = FloatMul(g_ClientInfo[attacker][ClientInfo_DamageScale], float(newHealth));
				
				g_ClientInfo[attacker][ClientInfo_IsCritial] = false;
				
				ZM_PrintToChat(attacker, "You received a %ihp boost for your kill!", g_ConVars[ConVar_Zombie_CritReward][Value_Int]);
			}

			GiveZombieReward(attacker);
		}
	}
}

public Action:Event_PlayerTeam(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_bModActive)
	{
		CheckWinConditions();

		SetEventBroadcast(event, true);
	}
}

public Event_PlayerDamage(Handle:event, String:name[], bool:dontBrodcast)
{
	if (g_bModActive)
	{
		new client = GetClientOfUserId(GetEventInt(event, "victim"));

		new attackerUserId = GetEventInt(event, "attacker");
		new attacker = GetClientOfUserId(attackerUserId);

		if (GetClientTeam(client) == Team_Axis && attacker
		&& !g_ClientInfo[client][ClientInfo_IsCritial]
		&& GetEventInt(event, "hitgroup") == 1)
		{
			new weaponId = GetEventInt(event, "weapon");
			switch (weaponId)
			{
				case
					WeaponID_AmerKnife,
					WeaponID_Colt,
					WeaponID_P38,
					WeaponID_Spring,
					WeaponID_K98_Scoped,
					WeaponID_Bazooka,
					WeaponID_Pschreck,
					WeaponID_Thompson_Punch,
					WeaponID_MP40_Punch:
				{
					// Don't change this, when a players health is 1 the game sometimes fucks up and the players view-offset drops down to the floor, like if you were a crushed midget.
					// Plus, the health bar looks bad.
					SetEntityHealth(client, 2);
					g_ClientInfo[client][ClientInfo_Health] = FloatMul(g_ClientInfo[client][ClientInfo_DamageScale], 2.0);

					g_ClientInfo[client][ClientInfo_Critter] = attackerUserId;
					g_ClientInfo[client][ClientInfo_IsCritial] = true;
					
					decl Float:vecVelocity[3], Float:vecClientEyePos[3], Float:vecAttackerEyePos[3];

					GetClientEyePosition(client, vecClientEyePos);
					GetClientEyePosition(attacker, vecAttackerEyePos);

					MakeVectorFromPoints(vecAttackerEyePos, vecClientEyePos, vecVelocity);
					NormalizeVector(vecVelocity, vecVelocity);
					ScaleVector(vecVelocity, 400.0);

					PopHelmet(client, vecVelocity, vecClientEyePos);

					PlaySoundFromPlayer(client, g_szSounds[Sound_ZombieCritical]);

					EmitSoundToClient(attacker, g_szSounds[Sound_FinishHim]);
					PrintCenterText(attacker, "FINISH HIM!");

					ZM_PrintToChat(client, "You got hit by a fatal shot, take cover!");
				}
			}
		}
	}
}

public Action:OnPopHelmet(client, Float:vecVelocity[3], Float:vecOrigin[3])
{
	return g_bModActive && !g_ClientInfo[client][ClientInfo_IsCritial] && GetClientTeam(client) == Team_Axis ? Plugin_Handled : Plugin_Continue;
}

public Action:OnJoinClass(client, &playerClass)
{
	if (g_bModActive)
	{
		if (GetClientTeam(client) == Team_Allies)
		{
			if (g_bBlockChangeClass)
			{
				ZM_PrintToChat(client, "90 seconds of the round has passed, you cannot change class any more!");

				return Plugin_Handled;
			}
		}
		else
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action:OnEnterPlayerState(client, &playerState)
{
	// Blocks the class menu from being displayed
	if (g_bModActive && playerState == PlayerState_PickingClass)
	{
		// This prevents the class selection menu to pop up on all team changes.
		// It is however displayed once for allied players, allowing them to decide witch class to.
		if (GetClientTeam(client) == Team_Allies && !g_ClientInfo[client][ClientInfo_SelectedClass])
		{
			g_ClientInfo[client][ClientInfo_SelectedClass] = true;
			return Plugin_Continue;
		}
		
		if (GetDesiredPlayerClass(client) == PlayerClass_None)
		{
			SetDesiredPlayerClass(client, PlayerClass_Assault);
		}
		
		playerState = PlayerState_ObserverMode;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:OnVoiceCommand(client, &voiceCommand)
{
	// Block zombies from making voice commands.
	return g_bModActive && GetClientTeam(client) == Team_Axis ? Plugin_Handled : Plugin_Continue;
}

public Action:OnPlayerRespawn(client)
{
	g_ClientInfo[client][ClientInfo_WeaponCanUse] = false;
}

public Action:OnNormalSoundPlayed(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (g_bModActive && entity && entity <= MaxClients)
	{
		// Block all german pain and round start sounds.
		if (GetClientTeam(entity) == Team_Axis
		&& (StrContains(sample, "pain", false) != -1
		|| StrContains(sample, "player/german/startround", false) != -1))
		{
			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}

public Action:OnWeaponCanUse(client, weapon)
{
	if (g_bModActive && g_ClientInfo[client][ClientInfo_WeaponCanUse])
	{
		decl String:className[MAX_WEAPON_LENGTH];
		GetEdictClassname(weapon, className, sizeof(className));
		
		if (GetClientTeam(client) == Team_Axis)
		{
			static const String:allowedZombieWeapons[][] =
			{
				"spade",
				"frag_us_live",
				"frag_ger_live",
				"riflegren_us_live",
				"riflegren_ger_live"
			};
			
			for (new i; i < sizeof(allowedZombieWeapons); i++)
			{
				if (StrEqual(className[7], allowedZombieWeapons[i])) // Skip the first 7 characters in className to avoid comparing the "weapon_" prefix.
				{
					return Plugin_Continue;
				}
			}

			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damageType)
{
	if (g_bModActive)
	{
		if (attacker && attacker < MaxClients && GetClientTeam(client) == Team_Axis && IsInZombieSpawn(client))
		{
			PrintHintText(attacker, "You cannot hurt zombies while they are in spawn!");

			return Plugin_Handled;
		}

		if (g_ClientInfo[client][ClientInfo_DamageScale] != 1.0)
		{
			static damageAccumulatorOffset;

			if (!damageAccumulatorOffset && (damageAccumulatorOffset = FindDataMapOffs(client, "m_flDamageAccumulator")) == -1)
			{
				LogError("Error: Failed to obtain offset: \"m_flDamageAccumulator\"!");
				return Plugin_Continue;
			}
			
			damage *= g_ClientInfo[client][ClientInfo_DamageScale];

			new Float:newHealth = g_ClientInfo[client][ClientInfo_Health] - damage;
			
			// Is the player supposed to die?
			if (newHealth <= 0.0)
			{
				// Set the damage required to kill the player.
				damage = float(GetEntData(client, g_iOffset_Health)) + GetEntDataFloat(client, damageAccumulatorOffset);

				return Plugin_Changed;
			}

			// Will the health go down to zero?
			if (float(GetEntData(client, g_iOffset_Health)) + GetEntDataFloat(client, damageAccumulatorOffset) - damage <= 0)
			{
				g_ClientInfo[client][ClientInfo_Health] = newHealth;

				return Plugin_Handled;
			}

			// Correct the players health.
			SetEntData(client, g_iOffset_Health, RoundFloat(g_ClientInfo[client][ClientInfo_Health]), _, true);

			g_ClientInfo[client][ClientInfo_Health] = newHealth;

			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

public bool:OnShouldCollide(client, collisionGroup, contentsMask, bool:originalResult)
{
	return g_bModActive ? true : originalResult;
}

#if defined _SENDPROXYMANAGER_INC_
public Action:SendProxy_TeamNum(client, const String:PropName[], &value, element)
{
	if (g_bModActive && IsPlayerAlive(client))
	{
		value = Team_Custom;

		return Plugin_Changed;
	}

	return Plugin_Continue;
}
#endif