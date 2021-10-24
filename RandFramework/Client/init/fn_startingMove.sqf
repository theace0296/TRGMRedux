// private _fnc_scriptName = "TRGM_CLIENT_fnc_startingMove";
params [["_unit", objNull, [objNull]], ["_move", "AmovPercMstpSlowWrflDnon", [""]]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


if !(isNull _unit) then {
    _unit switchMove _move;
};
