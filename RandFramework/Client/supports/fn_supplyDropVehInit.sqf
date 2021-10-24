// private _fnc_scriptName = "TRGM_CLIENT_fnc_supplyDropVehInit";

format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


[0.1,localize "STR_TRGM2_SupplyDropVehInit_Hint"] spawn TRGM_GLOBAL_fnc_adjustBadPoints;