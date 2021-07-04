format["%1 called by %2", _fnc_scriptName, _fnc_scriptNameParent] call TRGM_GLOBAL_fnc_log;

if (!isMultiplayer) exitWith {true;};

if (!isNil "TRGM_VAR_AdminPlayer" && !isNull TRGM_VAR_AdminPlayer) exitwith { player isEqualTo TRGM_VAR_AdminPlayer;};

if ((call BIS_fnc_admin) != 0) exitWith {true;};

if (str player isEqualTo "sl") exitWith {true;};

false;