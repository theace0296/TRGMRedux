// private _fnc_scriptName = "TRGM_CLIENT_fnc_startingMove";
params [["_unit", objNull, [objNull]], ["_move", "AmovPercMstpSlowWrflDnon", [""]]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


if !(isNull _unit) then {
    _unit switchMove _move;
};
