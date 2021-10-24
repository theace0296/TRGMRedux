// private _fnc_scriptName = "TRGM_GLOBAL_fnc_helicopterIsFlying";
params ["_vehicle"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



!(isTouchingGround _vehicle || (getPos _vehicle select 2 < 2 && speed _vehicle < 1));

