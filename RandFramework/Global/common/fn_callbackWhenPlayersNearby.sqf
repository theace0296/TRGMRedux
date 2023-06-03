// private _fnc_scriptName = "TRGM_GLOBAL_fnc_callbackWhenPlayersNearby";
params [["_pos", nil], ["_radius", nil], ["_code", nil], ["_args", []]];

if (isNil "_pos" || isNil "_radius" || isNil "_code") exitWith {};

private _onFootDistance = ["DynamicSimulationDistance", 2500] call BIS_fnc_getParamValue;
private _inVehicleMultiplier = ["DynamicSimulationMultiplier", 2] call BIS_fnc_getParamValue;
private _dynamicSimDisabled = (_onFootDistance isEqualTo 9999) || (_inVehicleMultiplier isEqualTo 9999);

if !(_dynamicSimDisabled) then {
    private _ran = false;
    waitUntil {
        sleep 10;
        private _allPlayers = allPlayers - entities "HeadlessClient_F";
        ({ (_x distance _pos) <= _radius; } count _allPlayers) > 0;
    };
    _args spawn _code;
} else {
    _args spawn _code;
};
