"Initplayerlocal.sqf" call TRGM_GLOBAL_fnc_log;

if (isNil "TRGM_VAR_serverFinishedInitGlobal")  then {TRGM_VAR_serverFinishedInitGlobal = false; publicVariable "TRGM_VAR_serverFinishedInitGlobal";};
waitUntil {TRGM_VAR_serverFinishedInitGlobal;};

private _initVarsHandle = [] spawn TRGM_GLOBAL_fnc_initGlobalVars;
waitUntil { sleep 5; scriptDone _initVarsHandle; };

CODEINPUT = [];


if (!hasInterface && !isDedicated) then {
    call TRGM_GLOBAL_fnc_loadbalancer_fpsLoop;
};
if (hasInterface) then {
   call TRGM_GLOBAL_fnc_loadbalancer_fpsLoop;
   [] spawn TRGM_CLIENT_fnc_main;
};