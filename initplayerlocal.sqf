"Initplayerlocal.sqf" call TRGM_GLOBAL_fnc_log;
call TRGM_GLOBAL_fnc_initGlobalVars;

_actChooseMission = -1;

CODEINPUT = [];

if (hasInterface) then {
   [] spawn TRGM_CLIENT_fnc_main;
};