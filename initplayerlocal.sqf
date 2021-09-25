"Initplayerlocal.sqf" call TRGM_GLOBAL_fnc_log;

if (isNil "TRGM_VAR_serverFinishedInitGlobal")  then {TRGM_VAR_serverFinishedInitGlobal = false; publicVariable "TRGM_VAR_serverFinishedInitGlobal";};
waitUntil {sleep 5; TRGM_VAR_serverFinishedInitGlobal;};

private _initVarsHandle = [] spawn TRGM_GLOBAL_fnc_initGlobalVars;
waitUntil { sleep 5; scriptDone _initVarsHandle; };

CODEINPUT = [];

if (hasInterface) then {
   [] spawn TRGM_CLIENT_fnc_main;
};