// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getVehicleDataByFaction";
params[["_factionClassName", "any"], ["_factionDispName", "any"]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


// _vehData = [faction_className, faction_displayName] call TRGM_GLOBAL_fnc_getVehicleDataByFaction;
// Param format: [faction_className, faction_displayName]
// Return format: [[unit1_className, unit1_dispName, unit1_category, unit1_isTransport, unit1_isArmed], ... , [unitN_className, unitN_dispName, unitN_category, unitN_isTransport, unitN_isArmed]]

if (_factionClassName isEqualTo "any" || _factionDispName isEqualTo "any") exitWith {};

private _vehConfigPaths = [];

private _configPath = (configFile >> "CfgVehicles");

for "_i" from 0 to (count _configPath - 1) do {

    private _element = _configPath select _i;

    if (isclass _element) then {
        if ((getText(_element >> "faction")) isEqualTo _factionClassName && {(getnumber(_element >> "scope")) isEqualTo 2 && {((configname _element) isKindOf "LandVehicle" || (configname _element) isKindOf "Air"|| (configname _element) isKindOf "Ship")}}) then {
            _vehConfigPaths pushbackunique _element;
        };
    };
};

(_vehConfigPaths select {!([_x] call TRGM_GLOBAL_fnc_ignoreVehicle)}) apply {[configName _x, ([configName _x] call TRGM_GLOBAL_fnc_getVehicleType)]};
