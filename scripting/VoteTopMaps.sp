#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma semicolon 1

ConVar g_CvarAtivo = null;
char g_MapName[64];
Database hDatabase = null;

public Plugin myinfo =
{
	name = "Vote Top Maps by CZS CTRL+C++",
	author = "CTRL+C++",
	description = "Script para votar nos mapas e definir rank para auxiliar na hora do votemap",
	version = "1.0.0",
	url = "https://czsbrasil.com.br"
};


public void OnPluginStart()
{
	g_CvarAtivo = CreateConVar("sm_votetopmaps_enable", "1", "Ativar o plugin");
	RegConsoleCmd( "say", Comando_Chat);
	RegConsoleCmd( "say_team", Comando_Chat);
	AutoExecConfig(true, "sm_votetopmaps");
	StartSQL();
	HookEvent("round_start", RoundStart);
	HookEvent("player_spawn", PlayerSpawn);
	GetCurrentMap(g_MapName, sizeof(g_MapName));
}

public void PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	GetCurrentMap(g_MapName, sizeof(g_MapName));
}

public void RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	GetCurrentMap(g_MapName, sizeof(g_MapName));
}

public void OnMapStart() 
{
	if(g_CvarAtivo)
	{
		return;
	}
	GetCurrentMap(g_MapName, sizeof(g_MapName));
}

public Action Comando_Chat(int id,int args )
{
	char comando[128];
	GetCmdArgString( comando, sizeof( comando ) - 1 );
	StripQuotes(comando);
	TrimString(comando);

	if(StrEqual(comando, "!avaliar"))
	{
		Handle hMenu = CreateMenu(MenuPrincipal);
		decl String:sBuffer[255];
		Format(sBuffer, sizeof(sBuffer), "Como você avalia o mapa %s ?",g_MapName);

		SetMenuTitle(hMenu, sBuffer);
		AddMenuItem(hMenu, "5", "MUITO TOP");
		AddMenuItem(hMenu, "4", "BOM");
		AddMenuItem(hMenu, "3", "ACEITAVEL");
		AddMenuItem(hMenu, "2", "NORMAL");
		AddMenuItem(hMenu, "1", "RUIM");

		DisplayMenu(hMenu, id, MENU_TIME_FOREVER);
	}
	
	return Plugin_Continue;
}

public void gravaAvaliacao(char nota[32], char mapa[64], char steamid[128])
{
	char query[255];
	FormatEx(query, sizeof(query), "INSERT INTO AvaliaMapa (mapa, nota, steamid) VALUES ('%s', '%s', '%s')ON DUPLICATE KEY UPDATE nota = CASE WHEN VALUES(nota) <> nota THEN VALUES(nota) ELSE nota END;",mapa,nota,steamid);
	hDatabase.Query(T_GravaAvaliacao, query);
}

public void T_GravaAvaliacao(Database db, DBResultSet results, const char[] error, any data) {}

public int MenuPrincipal(Handle hMenu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
			{
				char item[32],steamid[128], temp[250];
				GetMenuItem(hMenu, param2, item, sizeof(temp));

				GetClientAuthId(param1, AuthId_Steam2, steamid, sizeof(steamid));
				gravaAvaliacao(item,g_MapName,steamid);
				PrintToChat(param1, "[CZSAVALIAMAPA] Obrigado por avaliar o mapa!");
			}

		case MenuAction_End: {
			CloseHandle(hMenu);
		}
	}

	return 0;
}

public void GotDatabase(Database db, const char[] error, any data)
{
	if (db == null)
	{
		LogError("Erro para acessar o banco de dados: %s", error);
	}
	else
	{
		hDatabase = db;
		PrintToServer("Conectado ao DB avalia mapa");
	}
}

void StartSQL()
{
	Database.Connect(GotDatabase, "VoteTopMap");
}
