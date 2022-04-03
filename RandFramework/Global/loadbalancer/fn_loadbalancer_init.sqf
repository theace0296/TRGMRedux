// private _fnc_scriptName = "TRGM_GLOBAL_fnc_loadbalancer_init";
[] spawn {
    while {sleep 10; true} do {
        call TRGM_GLOBAL_fnc_loadbalancer_aggregate;
    };
};