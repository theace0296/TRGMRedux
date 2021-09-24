format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


params ["_player"];

if (_player != player) exitWith {false;};

if !(hasInterface) exitWith {false;};

if ([player] call TRGM_CLIENT_fnc_isAdmin) exitWith {true;};

false;