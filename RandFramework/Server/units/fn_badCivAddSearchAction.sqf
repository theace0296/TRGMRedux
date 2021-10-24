// private _fnc_scriptName = "TRGM_SERVER_fnc_badCivAddSearchAction";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


if(!hasInterface) exitWith {};

params ["_thisCiv"];

private _actionID = _thisCiv addaction [localize "STR_TRGM2_civillians_fnbadCivAddSearchAction_Button",{_this spawn TRGM_SERVER_fnc_badCivSearch}, nil,1.5,true,true,"","true",5];
_thisCiv setVariable ["searchActionID",_actionID];

true;