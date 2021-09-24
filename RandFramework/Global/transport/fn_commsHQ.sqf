// private _fnc_scriptName = "TRGM_GLOBAL_fnc_commsHQ";
params ["_text"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


[HQMan,_text] call TRGM_GLOBAL_fnc_commsSide;

true;