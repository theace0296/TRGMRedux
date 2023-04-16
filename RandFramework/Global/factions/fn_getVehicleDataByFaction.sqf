// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getVehicleDataByFaction";
params[["_factionClassName", "any"], ["_factionDispName", "any"]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


// _vehData = [faction_className, faction_displayName] call TRGM_GLOBAL_fnc_getVehicleDataByFaction;
// Param format: [faction_className, faction_displayName]
// Return format: [[unit1_className, unit1_dispName, unit1_category, unit1_isTransport, unit1_isArmed], ... , [unitN_className, unitN_dispName, unitN_category, unitN_isTransport, unitN_isArmed]]

if (_factionClassName isEqualTo "any" || _factionDispName isEqualTo "any") exitWith {};

if (isNil "TRGM_TEMPVAR_allVehicleUnits") then {
    TRGM_TEMPVAR_allVehicleUnits = createHashMap;
    private _configPath = (configFile >> "CfgVehicles");
    for "_i" from 0 to (count _configPath - 1) do {
        private _element = _configPath select _i;
        if !(isClass _element) then { continue; };
        if (getNumber(_element >> "scope") isNotEqualTo 2) then { continue; };
        if (!(configName _element isKindOf "LandVehicle") && !(configName _element isKindOf "Air") && !(configName _element isKindOf "Ship")) then { continue; };
        if ([_element] call TRGM_GLOBAL_fnc_ignoreVehicle) then { continue; };
        private _factionList = TRGM_TEMPVAR_allVehicleUnits getOrDefault [getText(_element >> "faction"), [], true];
        _factionList pushBack (configName _element);
    };
    publicVariable "TRGM_TEMPVAR_allVehicleUnits";
};
(TRGM_TEMPVAR_allVehicleUnits getOrDefault [_factionClassName, []]) apply {[_x, ([_x] call TRGM_GLOBAL_fnc_getVehicleType)]};