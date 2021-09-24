format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


while {isMultiplayer && (TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_MAP_DRAW_DIRECT_ONLY_IDX isEqualTo 1)} do {
    waitUntil { sleep 5; ({private _ret = false; private _sTest = _x splitString "/"; if (count _sTest > 2 && {str(_sTest select 2) != str("5")}) then {_ret = true}; ret; } count allMapMarkers) > 0; };
    {
        deleteMarker _x;
    } forEach (allMapMarkers select {private _ret = false; private _sTest = _x splitString "/"; if (count _sTest > 2 && {str(_sTest select 2) != str("5")}) then {_ret = true}; ret; });
    sleep 5;
};