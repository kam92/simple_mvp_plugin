#include <amxmodx>  
#include <amxmisc>  
#include <hamsandwich>
#include <cstrike>

#if AMXX_VERSION_NUM < 183
#include <dhudmessage>
#endif

new g_iKills[33],
    g_iHS[33],
    Float:g_fDmg[33]  

public plugin_init()  
{  
    register_plugin("Player of the Round", "1.0", "yes")  
    RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage")  
    register_event("DeathMsg", "OnPlayerKilled", "a")  
    register_logevent("OnRoundEnd", 2, "1=Round_End")  
}  

public client_disconnect(id)  
{  
    g_iKills[id] = 0 
    g_iHS[id] = 0
    g_fDmg[id] = 0.0
}

public OnTakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)  
{  
    if(is_user_connected(iAttacker) && iAttacker != iVictim && is_user_connected(iVictim))
    {
        if(cs_get_user_team(iAttacker) != cs_get_user_team(iVictim))  
            g_fDmg[iAttacker] += fDamage
        else
            g_fDmg[iAttacker] -= fDamage
    }
}

public OnPlayerKilled()
{  
    new iAttacker = read_data(1), iVictim = read_data(2)  
      
    if(is_user_connected(iAttacker) && iAttacker != iVictim && is_user_connected(iVictim))
    {
        if(cs_get_user_team(iAttacker) != cs_get_user_team(iVictim))
        {
            g_iKills[iAttacker]++
            
            if(read_data(3))
                g_iHS[iAttacker]++
        }
        else
        {
            g_iKills[iAttacker]--
            
            if(read_data(3))
                g_iHS[iAttacker]--
        }
    }
}

public OnRoundEnd()
{
    new id = get_best_player()
    
    if(id == -1)
        return
        
    new szName[32]  
    get_user_name(id, szName, charsmax(szName)) 

	set_dhudmessage(0,255,0,-1,0.26,1)
	show_dhudmessage(0,"MVP:^n%s matou %i  (%i HS | %.1f Dano)", szName, g_iKills[id], g_iHS[id], g_fDmg[id])
				
    client_print(0, print_chat, "MVP: %s matou %i  (%i HS | %.1f Dano)", szName, g_iKills[id], g_iHS[id], g_fDmg[id])
    
    arrayset(g_iKills, 0, sizeof(g_iKills))
    arrayset(g_iHS, 0, sizeof(g_iHS))
    
    for(new i; i < sizeof(g_fDmg); i++)
        g_fDmg[i] = 0.0
}

get_best_player()
{
    new iPlayers[32], iPnum, id
    get_players(iPlayers, iPnum)
    
    for(new i, iPlayer; i < iPnum; i++)
    {
        iPlayer = iPlayers[i]
        
        if(g_iKills[iPlayer] > g_iKills[id])
            id = iPlayer
        else if(g_iKills[iPlayer] == g_iKills[id])
        {
            if(g_fDmg[iPlayer] > g_fDmg[id])
                id = iPlayer
        }
    }
    
    return g_iKills[id] ? id : -1
} 