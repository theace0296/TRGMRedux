// private _fnc_scriptName = "TRGM_GLOBAL_fnc_commsSide";
params ["_speaker","_text"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _target = [0, -2] select isMultiplayer;
[_speaker,_text] remoteExecCall ["sideChat",_target,false];

true;