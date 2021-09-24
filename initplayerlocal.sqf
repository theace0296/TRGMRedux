"Initplayerlocal.sqf" call TRGM_GLOBAL_fnc_log;

if (isNil "TRGM_VAR_serverFinishedInitGlobal")  then {TRGM_VAR_serverFinishedInitGlobal = false; publicVariable "TRGM_VAR_serverFinishedInitGlobal";};
waitUntil {sleep 5; TRGM_VAR_serverFinishedInitGlobal;};

call TRGM_GLOBAL_fnc_initGlobalVars;

CODEINPUT = [];

if (hasInterface) then {
   [] spawn TRGM_CLIENT_fnc_main;
};