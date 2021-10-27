// private _fnc_scriptName = "TRGM_CLIENT_fnc_onlyAllowDirectMapDraw";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


while {isMultiplayer && (call TRGM_GETTER_fnc_bMapDrawDirectOnly)} do {
    waitUntil { ({private _ret = false; private _sTest = _x splitString "/"; if (count _sTest > 2 && {str(_sTest select 2) != str("5")}) then {_ret = true}; ret; } count allMapMarkers) > 0; };
    {
        deleteMarker _x;
    } forEach (allMapMarkers select {private _ret = false; private _sTest = _x splitString "/"; if (count _sTest > 2 && {str(_sTest select 2) != str("5")}) then {_ret = true}; ret; });
    sleep 5;
};