"Initplayerlocal.sqf" call TRGM_GLOBAL_fnc_log;

waitUntil {
    sleep 1;
    !(isNull player) && { player isEqualTo player };
};

if (isNil "TRGM_VAR_serverFinishedInitGlobal")  then {TRGM_VAR_serverFinishedInitGlobal = false; publicVariable "TRGM_VAR_serverFinishedInitGlobal";};
waitUntil {
    sleep 0.1;
    TRGM_VAR_serverFinishedInitGlobal;
};

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