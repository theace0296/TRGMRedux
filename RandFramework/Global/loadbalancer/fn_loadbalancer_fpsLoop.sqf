// private _fnc_scriptName = "TRGM_GLOBAL_fnc_loadbalancer_fpsLoop";
[] spawn {
    if (player != player) exitWith {};
    while {sleep 10; true} do {
        [player, diag_fps] call TRGM_GLOBAL_fnc_loadbalancer_setFps;
    };
};