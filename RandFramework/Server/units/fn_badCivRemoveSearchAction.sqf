format["%1 called by %2", _fnc_scriptName, _fnc_scriptNameParent] call TRGM_GLOBAL_fnc_log;
if(!hasInterface) exitWith {};

params ["_thisCiv"];
_thisCiv removeAction (_thisCiv getVariable "searchActionID");


true;