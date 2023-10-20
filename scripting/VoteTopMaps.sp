#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1

ConVar g_CvarAtivo = null;
char g_MapName[128];
Database hDatabase = null;

Menu g_MenuPrincipal;

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
	g_MenuPrincipal = ContrutorMenu();
}

public void OnMapStart() 
{
	if(g_CvarAtivo)
	{
		return;
	}

}

Menu ContrutorMenu()
{
	GetCurrentMap(g_MapName, sizeof(g_MapName));
	Menu menu = new Menu(MenuPrincipal);

	menu.SetTitle("Como você avalia o mapa %s ?",g_MapName);
	menu.AddItem("5", "MUITO TOP");
	menu.AddItem("4", "BOM");
	menu.AddItem("3", "ACEITAVEL");
	menu.AddItem("2", "NORMAL");
	menu.AddItem("1", "RUIM");

	return menu;
}

public void gravaAvaliacao(char nota[32], char mapa[128], char steamid[128])
{
	char query[255];
	FormatEx(query, sizeof(query), "INSERT IGNORE INTO AvaliaMapa(mapa, nota, steamid) VALUES ('%s','%s','%s')",mapa,nota,steamid);
	hDatabase.Query(T_GravaAvaliacao, query);
}

public void T_GravaAvaliacao(Database db, DBResultSet results, const char[] error, any data) {}

public int MenuPrincipal(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
			{
				char item[32],steamid[128];
				menu.GetItem(param2, item, sizeof(item));
				GetClientAuthId(param1, AuthId_Steam2, steamid, sizeof(steamid));
				gravaAvaliacao(item,g_MapName,steamid);
				PrintToChat(param1, "Obrigado por avaliar!");
			}

		case MenuAction_End: {}
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
		PrintToServer("Conectado ao DB");
	}
}

void StartSQL()
{
	Database.Connect(GotDatabase, "VoteTopMap");
}

public Action Comando_Chat(int id,int args )
{
	char comando[128];
	GetCmdArgString( comando, sizeof( comando ) - 1 );
	StripQuotes(comando);
	TrimString(comando);

	if(StrEqual(comando, "!avaliar"))
	{
		g_MenuPrincipal.Display(id, MENU_TIME_FOREVER);
	}
	
	return Plugin_Continue;
}