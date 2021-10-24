// private _fnc_scriptName = "TRGM_GLOBAL_fnc_isOnlyBoardCrewOnboard";
params ["_vehicle"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


private _boardCrew = group driver _vehicle;
{
    alive _x && group _x != _boardCrew;
} count (crew _vehicle) isEqualTo 0;