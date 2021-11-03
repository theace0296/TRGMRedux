// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getUnitDataByFaction";
params[["_factionClassName", "any"], ["_factionDispName", "any"]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

// _unitData = [faction_className, faction_displayName] call TRGM_GLOBAL_fnc_getUnitDataByFaction;
// Param format: [faction_className, faction_displayName]
// Return format: [[unit1_className, unit1_type], ... , [unitN_className, unitN_type]]

if (_factionClassName isEqualTo "any" || _factionDispName isEqualTo "any") exitWith {};

private _unitConfigPaths = [];

private _configPath = (configFile >> "CfgVehicles");

for "_i" from 0 to (count _configPath - 1) do {

    private _element = _configPath select _i;

    if (isclass _element) then {
        if ((getText(_element >> "faction")) isEqualTo _factionClassName && {(getnumber(_element >> "scope")) isEqualTo 2 && {(configname _element) isKindOf "Man" && {!((configname _element) isKindOf "OPTRE_Spartan2_Soldier_Base")}}}) then {
            _unitConfigPaths pushbackunique _element;
        };
    };
};

(_unitConfigPaths select {!([_x] call TRGM_GLOBAL_fnc_ignoreUnit)}) apply {[configName _x, ([configName _x] call TRGM_GLOBAL_fnc_getUnitType)]};