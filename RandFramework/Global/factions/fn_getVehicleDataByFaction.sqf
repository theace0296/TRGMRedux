// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getVehicleDataByFaction";
params[["_factionClassName", "any"], ["_factionDispName", "any"]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


// _vehData = [faction_className, faction_displayName] call TRGM_GLOBAL_fnc_getVehicleDataByFaction;
// Param format: [faction_className, faction_displayName]
// Return format: [[unit1_className, unit1_dispName, unit1_category, unit1_isTransport, unit1_isArmed], ... , [unitN_className, unitN_dispName, unitN_category, unitN_isTransport, unitN_isArmed]]

if (_factionClassName isEqualTo "any" || _factionDispName isEqualTo "any") exitWith {};

if (isNil "TRGM_TEMPVAR_allVehicleUnits") then {
    call TRGM_GLOBAL_fnc_prePopulateUnitAndVehicleData;
};
(TRGM_TEMPVAR_allVehicleUnits getOrDefault [_factionClassName, []]) apply {[_x, ([_x] call TRGM_GLOBAL_fnc_getVehicleType)]};