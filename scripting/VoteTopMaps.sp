#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1

ConVar g_CvarAtivo = null;
char g_Map;
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
}

public void OnMapStart() 
{
	if(g_CvarAtivo)
	{
		return;
	}

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
		char mapName[128];
		PrintToServer("Teste %s", GetCurrentMap(mapName, sizeof(mapName)));
	}
	
	return Plugin_Continue;
}