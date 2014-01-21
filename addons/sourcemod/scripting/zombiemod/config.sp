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
	Sound_JoinServer,
	Sound_ZombiesWin,
	Sound_ZombiesStart,
	Sound_ZombieSpawn,
	Sound_ZombieDeath,
	Sound_ZombieCritical,
	Sound_HumansWin,
	Sound_LastManStanding,
	Sound_End,
	Sound_FinishHim,

	Sound_Size
};

enum
{
	Model_Zombie_Default,
	Model_Zombie_Custom1,
	Model_Zombie_Custom2,
	Model_Zombie_Custom3,
	Model_Zombie_Custom4,
	Model_Zombie_Custom5,
	Model_Zombie_Custom6,

	Model_Size
};

enum
{
	Overlay_HumansWin,
	Overlay_ZombiesWin,

	Overlay_Size
};

enum
{
	WhiteList_Objectives,
	WhiteList_Environment,
	WhiteList_TriggerHurts,
	WhiteList_TeamBlockers,

	WhiteList_Size
};

static const String:g_szSoundKeyNames[Sound_Size][] =
{
	"Sound_JoinServer",
	"Sound_Zombies_Win",
	"Sound_Zombies_Start",
	"Sound_Zombie_Spawn",
	"Sound_Zombie_Death",
	"Sound_Zombie_Critical",
	"Sound_Humans_Win",
	"Sound_LastManStanding",
	"Sound_End",
	"Sound_FinishHim"
};

static const String:g_szModelKeyNames[Model_Size][] =
{
	"Model_Zombie_Default",
	"Model_Zombie_Custom1",
	"Model_Zombie_Custom2",
	"Model_Zombie_Custom3",
	"Model_Zombie_Custom4",
	"Model_Zombie_Custom5",
	"Model_Zombie_Custom6"
};

static const String:g_szOverlayKeyNames[Overlay_Size][] =
{
	"Overlay_Humans_Win",
	"Overlay_Zombies_Win"
};

new	String:g_szSounds[Sound_Size][PLATFORM_MAX_PATH];
new	String:g_szModel[Model_Size][PLATFORM_MAX_PATH];
new	String:g_szOverlay[Overlay_Size][PLATFORM_MAX_PATH];

static const String:g_szMaterialExtensions[][] = { "vmt", "vtf" };

new	bool:g_bWhiteListed[WhiteList_Size];

LoadConfig()
{
	decl String:path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/zombiemod.cfg");

	if (FileExists(path))
	{
		decl String:buffer[PLATFORM_MAX_PATH];

		new Handle:kv = CreateKeyValues("ZombieMod");

		FileToKeyValues(kv, path);

		if (KvJumpToKey(kv, "Sounds"))
		{
			for (new i; i < Sound_Size; i++)
			{
				KvGetString(kv, g_szSoundKeyNames[i], g_szSounds[i], PLATFORM_MAX_PATH);

				if (g_szSounds[i][0] != '\0')
				{
					Format(buffer, sizeof(buffer), "sound/%s", g_szSounds[i]);

					if (FileExists(buffer, true))
					{
						PrecacheSound(g_szSounds[i]);

						AddFileToDownloadsTable(buffer);
					}
				}
			}
		}

		KvRewind(kv);

		if (KvJumpToKey(kv, "Overlays"))
		{
			for (new i; i < Overlay_Size; i++)
			{
				KvGetString(kv, g_szOverlayKeyNames[i], g_szOverlay[i], PLATFORM_MAX_PATH);

				if (g_szOverlay[i][0] != '\0')
				{
					for (new x; x < sizeof(g_szMaterialExtensions); x++)
					{
						Format(buffer, sizeof(buffer), "materials/%s.%s", g_szOverlay[i], g_szMaterialExtensions[x]);

						if (FileExists(buffer, true))
						{
							AddFileToDownloadsTable(buffer);
						}
					}
				}
			}
		}

		KvRewind(kv);

		if (KvJumpToKey(kv, "Models"))
		{
			for (new i; i < Model_Size; i++)
			{
				KvGetString(kv, g_szModelKeyNames[i], g_szModel[i], PLATFORM_MAX_PATH);

				if (g_szModel[i][0] != '\0')
				{
					PrecacheModel(g_szModel[i]);
				}
			}
		}

		CloseHandle(kv);
	}
	else
	{
		LogError("Unable to open config file: \"%s\" !", path);
	}

	BuildPath(Path_SM, path, sizeof(path), "configs/zombiemod_whitelist.cfg");

	if (FileExists(path))
	{
		new Handle:kv = CreateKeyValues("ZombieMod_WhiteList");

		FileToKeyValues(kv, path);

		decl String:mapName[PLATFORM_MAX_PATH];
		GetCurrentMap(mapName, sizeof(mapName));

		if (KvJumpToKey(kv, mapName, false))
		{
			g_bWhiteListed[WhiteList_Objectives] = KvGetNum(kv, "Objectives");
			g_bWhiteListed[WhiteList_Environment] = KvGetNum(kv, "Environment");
			g_bWhiteListed[WhiteList_TriggerHurts] = KvGetNum(kv, "TriggerHurts");
			g_bWhiteListed[WhiteList_TeamBlockers] = KvGetNum(kv, "TeamBlockers");
		}
		else
		{
			for (new i; i < WhiteList_Size; i++)
			{
				g_bWhiteListed[i] = false;
			}
		}

		CloseHandle(kv);
	}
	else
	{
		LogError("Unable to open config file: \"%s\" !", path);
	}

	LoadConfig_ModelFiles();
}

LoadConfig_ModelFiles()
{
	decl String:path[PLATFORM_MAX_PATH], Handle:file;
	BuildPath(Path_SM, path, sizeof(path), "configs/zombiemod_modelfiles.cfg");

	if ((file = OpenFile(path, "r")) != INVALID_HANDLE)
	{
		decl String:line[PLATFORM_MAX_PATH];

		while (!IsEndOfFile(file) && ReadFileLine(file, line, sizeof(line)))
		{
			if (StrContains(line, "//", true) != -1)
			{
				SplitString(line, "//", line, sizeof(line));
			}

			TrimString(line);

			if (line[0] != '\0')
			{
				if (FileExists(line, true))
				{
					AddFileToDownloadsTable(line);
				}
				else
				{
					LogError("Unable to find file: \"%s\" !", line);
				}
			}
		}

		CloseHandle(file);
	}
	else
	{
		LogError("Unable to open config file: \"%s\" !", path);
	}
}