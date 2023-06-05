// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getUnitDataByFaction";
params[["_factionClassName", "any"], ["_factionDispName", "any"]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

// _unitData = [faction_className, faction_displayName] call TRGM_GLOBAL_fnc_getUnitDataByFaction;
// Param format: [faction_className, faction_displayName]
// Return format: [[unit1_className, unit1_type], ... , [unitN_className, unitN_type]]

if (_factionClassName isEqualTo "any" || _factionDispName isEqualTo "any") exitWith {};

if (isNil "TRGM_TEMPVAR_allManUnits") then {
    call TRGM_GLOBAL_fnc_prePopulateUnitAndVehicleData;
};

(TRGM_TEMPVAR_allManUnits getOrDefault [_factionClassName, []]) apply {[_x, ([_x] call TRGM_GLOBAL_fnc_getUnitType)]};