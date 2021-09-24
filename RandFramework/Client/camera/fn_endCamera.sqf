format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


private _camera = player getVariable "TRGM_VAR_Camera";

titleText [localize "STR_TRGM2_mainInit_Loading", "BLACK FADED"];
_camera cameraEffect ["Terminate","back"];
["CameraTerminated", true] call TRGM_GLOBAL_fnc_log;

true;