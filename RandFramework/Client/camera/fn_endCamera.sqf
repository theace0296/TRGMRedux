// private _fnc_scriptName = "TRGM_CLIENT_fnc_endCamera";
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _camera = player getVariable "TRGM_VAR_Camera";

titleText [localize "STR_TRGM2_mainInit_Loading", "BLACK FADED"];
_camera cameraEffect ["Terminate","back"];
["CameraTerminated", true] call TRGM_GLOBAL_fnc_log;

true;