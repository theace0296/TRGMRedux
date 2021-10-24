// private _fnc_scriptName = "TRGM_GLOBAL_fnc_checkMissionIdActive";
params ["_vehicle","_checkToMissionNumber"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


(_checkToMissionNumber isEqualTo (_vehicle getVariable ["missionNr",-1]));