// private _fnc_scriptName = "TRGM_GLOBAL_fnc_prePopulateUnitAndVehicleData";

TRGM_TEMPVAR_allManUnits = createHashMap;
TRGM_TEMPVAR_allVehicleUnits = createHashMap;
private _configPath = (configFile >> "CfgVehicles");
for "_i" from 0 to (count _configPath - 1) do {
    private _element = _configPath select _i;
    if !(isClass _element) then { continue; };
    if (getNumber(_element >> "scope") isNotEqualTo 2) then { continue; };
    private _configName = configName _element;
    if (_configName isKindOf "Man" && !(_configName isKindOf "OPTRE_Spartan2_Soldier_Base")) then {
        if ([_element] call TRGM_GLOBAL_fnc_ignoreUnit) then { continue; };
        private _factionList = TRGM_TEMPVAR_allManUnits getOrDefault [getText(_element >> "faction"), [], true];
        _factionList pushBack _configName;
    };
    if (_configName isKindOf "LandVehicle" || _configName isKindOf "Air" || _configName isKindOf "Ship") then {
        if ([_element] call TRGM_GLOBAL_fnc_ignoreVehicle) then { continue; };
        private _factionList = TRGM_TEMPVAR_allVehicleUnits getOrDefault [getText(_element >> "faction"), [], true];
        _factionList pushBack _configName;
    };
};
publicVariable "TRGM_TEMPVAR_allManUnits";
publicVariable "TRGM_TEMPVAR_allVehicleUnits";

true;