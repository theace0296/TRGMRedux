// private _fnc_scriptName = "TRGM_GLOBAL_fnc_loadbalancer_aggregate";
private _allHeadlessClients = entities "HeadlessClient_F";
private _allPlayers = allPlayers - _allHeadlessClients;

private _allHeadlessClientsWeighted = flatten (_allHeadlessClients apply {[owner _x, linearConversion [25, 60, _x getVariable ["TRGM_VAR_ClientFps", 0], 0, 1, true]]});
private _allPlayersWeighted = flatten (_allPlayers apply {[owner _x,  linearConversion [25, 60, _x getVariable ["TRGM_VAR_ClientFps", 0], 0, 1, true]]});

// update arrays
missionNamespace setVariable ["TRGM_VAR_HC_FpsWeighted", _allHeadlessClientsWeighted];
missionNamespace setVariable ["TRGM_VAR_Players_FpsWeighted", _allPlayersWeighted];
