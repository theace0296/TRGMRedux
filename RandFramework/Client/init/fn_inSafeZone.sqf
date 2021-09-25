// private _fnc_scriptName = "TRGM_CLIENT_fnc_inSafeZone";
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


while {true} do {
    if !(((getMarkerPos "mrkHQ") distance player) < TRGM_VAR_PunishmentRadius) then {
        TRGM_VAR_PlayersHaveLeftStartingArea =  true; publicVariable "TRGM_VAR_PlayersHaveLeftStartingArea";
    };
    sleep 1;
};