// private _fnc_scriptName = "TRGM_CLIENT_fnc_supplyDropCrateInit";

format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


[_this select 0] call TRGM_GLOBAL_fnc_initAmmoBox;