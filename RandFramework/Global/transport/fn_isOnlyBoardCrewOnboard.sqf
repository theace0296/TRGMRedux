params ["_vehicle"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


private _boardCrew = group driver _vehicle;
{
    alive _x && group _x != _boardCrew;
} count (crew _vehicle) isEqualTo 0;