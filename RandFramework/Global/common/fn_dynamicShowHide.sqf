params ["_object"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (isNil "_object") exitWith {};

private _onFootDistance = ["DynamicSimulationDistance", 2500] call BIS_fnc_getParamValue;
private _inVehicleMultiplier = ["DynamicSimulationMultiplier", 2] call BIS_fnc_getParamValue;
private _dynamicSimDisabled = (_onFootDistance isEqualTo 9999) || (_inVehicleMultiplier isEqualTo 9999);

if !(_dynamicSimDisabled) then {
    while {alive _object} do {
        private _allPlayers = allPlayers - entities "HeadlessClient_F";
        private _playersNearby = ({ private _minDistance = _onFootDistance; if !(vehicle _x isEqualTo _x) then {_minDistance = _onFootDistance * _inVehicleMultiplier;}; (_x distance _object) < _minDistance; } count _allPlayers) > 0;
        if (_playersNearby || !(vehicle _object isEqualTo _object)) then {
            { [_x, true] remoteExec ["enableSimulationGlobal", 2]; [_x, false] remoteExec ["hideObjectGlobal", 2]; } forEach ([[_object], units group _object] select (_object isKindOf "Man"));
        } else {
            { [_x, false] remoteExec ["enableSimulationGlobal", 2]; [_x, true] remoteExec ["hideObjectGlobal", 2]; } forEach ([[_object], units group _object] select (_object isKindOf "Man"));
        };
        sleep floor random [20, 30, 60];
    };
    { [_x, true] remoteExec ["enableSimulationGlobal", 2]; [_x, false] remoteExec ["hideObjectGlobal", 2]; } forEach ([[_object], units group _object] select (_object isKindOf "Man"));
};
