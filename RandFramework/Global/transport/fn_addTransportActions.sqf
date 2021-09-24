params [["_vehicles",[]]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


{ [_x] spawn TRGM_GLOBAL_fnc_addTransportActionsVehicle; } forEach _vehicles;
[_vehicles] spawn TRGM_GLOBAL_fnc_addTransportActionsPlayer;

true;