// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getTransportName";
params ["_vehicle"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


groupId group driver _vehicle;