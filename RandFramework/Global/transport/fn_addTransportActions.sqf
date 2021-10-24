// private _fnc_scriptName = "TRGM_GLOBAL_fnc_addTransportActions";
params [["_vehicles",[]]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (call TRGM_GETTER_fnc_bTransportEnabled) then {
    { [_x] spawn TRGM_GLOBAL_fnc_addTransportActionsVehicle; } forEach _vehicles;
    [_vehicles] spawn TRGM_GLOBAL_fnc_addTransportActionsPlayer;
};

true;