// private _fnc_scriptName = "TRGM_GLOBAL_fnc_dynamicShowHide";
params ["_object"];

if (isNil "_object") exitWith {};

private _onFootDistance = ["DynamicSimulationDistance", 2500] call BIS_fnc_getParamValue;
private _inVehicleMultiplier = ["DynamicSimulationMultiplier", 2] call BIS_fnc_getParamValue;
private _dynamicSimDisabled = (_onFootDistance isEqualTo 9999) || (_inVehicleMultiplier isEqualTo 9999);

if !(_dynamicSimDisabled) then {
    waitUntil {
        private _allPlayers = allPlayers - entities "HeadlessClient_F";
        private _playersNearby = ({ private _minDistance = _onFootDistance; if !(vehicle _x isEqualTo _x) then {_minDistance = _onFootDistance * _inVehicleMultiplier;}; (_x distance _object) < _minDistance; } count _allPlayers) > 0;
        private _objectOwner = _object getVariable ["TRGM_VAR_groupClientOwner", 2];
        if (_playersNearby || !(vehicle _object isEqualTo _object)) then {
            {
                [_x, true] remoteExec ["enableSimulationGlobal", _objectOwner];
                [_x, false] remoteExec ["hideObjectGlobal", _objectOwner];
            } forEach ([[_object], units group _object] select (_object isKindOf "Man"));
        } else {
            {
                [_x, false] remoteExec ["enableSimulationGlobal", _objectOwner];
                [_x, true] remoteExec ["hideObjectGlobal", _objectOwner];
            } forEach ([[_object], units group _object] select (_object isKindOf "Man"));
        };
        sleep 10;
        !(alive _object);
    };
    {
        [_x, true] remoteExec ["enableSimulationGlobal", _object getVariable ["TRGM_VAR_groupClientOwner", 2]];
        [_x, false] remoteExec ["hideObjectGlobal", _object getVariable ["TRGM_VAR_groupClientOwner", 2]];
    } forEach ([[_object], units group _object] select (_object isKindOf "Man"));
};
