// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getUnitDataByFaction";
params[["_factionClassName", "any"], ["_factionDispName", "any"]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

// _unitData = [faction_className, faction_displayName] call TRGM_GLOBAL_fnc_getUnitDataByFaction;
// Param format: [faction_className, faction_displayName]
// Return format: [[unit1_className, unit1_type], ... , [unitN_className, unitN_type]]

if (_factionClassName isEqualTo "any" || _factionDispName isEqualTo "any") exitWith {};

if (isNil "TRGM_TEMPVAR_allManUnits") then {
    TRGM_TEMPVAR_allManUnits = createHashMap;
    private _configPath = (configFile >> "CfgVehicles");
    for "_i" from 0 to (count _configPath - 1) do {
        private _element = _configPath select _i;
        if !(isClass _element) then { continue; };
        if (getNumber(_element >> "scope") isNotEqualTo 2) then { continue; };
        if !(configName _element isKindOf "Man") then { continue; };
        if (configName _element isKindOf "OPTRE_Spartan2_Soldier_Base") then { continue; };
        if ([_element] call TRGM_GLOBAL_fnc_ignoreUnit) then { continue; };
        private _factionList = TRGM_TEMPVAR_allManUnits getOrDefault [getText(_element >> "faction"), [], true];
        _factionList pushBack (configName _element);
    };
    publicVariable "TRGM_TEMPVAR_allManUnits";
};

(TRGM_TEMPVAR_allManUnits getOrDefault [_factionClassName, []]) apply {[_x, ([_x] call TRGM_GLOBAL_fnc_getUnitType)]};