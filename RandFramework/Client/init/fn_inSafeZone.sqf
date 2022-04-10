// private _fnc_scriptName = "TRGM_CLIENT_fnc_inSafeZone";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (isNil "TRGM_VAR_PlayersHaveLeftStartingArea") then {TRGM_VAR_PlayersHaveLeftStartingArea = false; publicVariable "TRGM_VAR_PlayersHaveLeftStartingArea";};
waitUntil {
    if !(((getMarkerPos "mrkHQ") distance player) < TRGM_VAR_PunishmentRadius) then {
        TRGM_VAR_PlayersHaveLeftStartingArea =  true; publicVariable "TRGM_VAR_PlayersHaveLeftStartingArea";
    };
    sleep 10;
    TRGM_VAR_PlayersHaveLeftStartingArea;
};