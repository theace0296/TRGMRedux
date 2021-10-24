// private _fnc_scriptName = "TRGM_SERVER_fnc_badCivRemoveSearchAction";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


if(!hasInterface) exitWith {};

params ["_thisCiv"];
_thisCiv removeAction (_thisCiv getVariable "searchActionID");


true;