// private _fnc_scriptName = "TRGM_GLOBAL_fnc_isLeaderOrAdmin";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


params ["_player"];

if (_player != player) exitWith {false;};

if !(hasInterface) exitWith {false;};

if ([player] call TRGM_CLIENT_fnc_isAdmin) exitWith {true;};

false;