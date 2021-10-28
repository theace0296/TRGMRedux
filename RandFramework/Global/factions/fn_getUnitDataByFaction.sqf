// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getUnitDataByFaction";
params[["_factionClassName", "any"], ["_factionDispName", "any"]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


// _unitData = [faction_className, faction_displayName] call TRGM_GLOBAL_fnc_getUnitDataByFaction;
// Param format: [faction_className, faction_displayName]
// Return format: [[unit1_className, unit1_dispName, unit1_icon, unit1_calloutName, unit1_isMedic, unit1_isEngineer, unit1_isExpSpecialist, unit1_isUAVHacker], ... , [unitN_className, unitN_dispName, unitN_icon, unitN_isMedic, unitN_isEngineer, unitN_isExpSpecialist, unitN_isUAVHacker]]
// Useful Info:
// These were the common unit icons between the FIA and RHS MSV factions, the display name with them is the FIA display name.
// ["iconMan","Rifleman"],["iconMan","Rifleman (Light)"],["iconMan","Grenadier"],["iconMan","Marksman"],["iconMan","Ammo Bearer"],["iconMan","Rifleman (Unarmed)"],["iconMan","Sharpshooter"],
// ["iconManAT","Rifleman (AT)"],["iconManAT","Rifleman (Light AT)"],
// ["iconManEngineer","Engineer"],
// ["iconManLeader","Squad Leader"],["iconManLeader","Team Leader"],
// ["iconManMedic","Combat Life Saver"],
// ["iconManMG","Autorifleman"],
// ["iconManOfficer","Officer"]

// [["iconMan"],["iconManAT"],["iconManMG"],["iconManLeader"],["iconManOfficer"],["iconManEngineer"],["iconManMedic"],["iconManExplosive"],["iconManVirtual"]] - CSAT Unique Icons
// [["iconMan"],["iconManAT"],["iconManMG"],["iconManLeader"],["iconManOfficer"],["iconManEngineer"],["iconManMedic"],["iconManExplosive"]] - FIA Unique Icons
// [["iconMan"],["iconManAT"],["iconManMG"],["iconManLeader"],["iconManOfficer"],["iconManEngineer"],["iconManMedic"]] - MSV/VDV Unique Icons


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

private _units = [];

{
    // We are using "icon" instead of "role" because the icon is better for determining unit role, since, for example, RHS doesn't correctly label the unit role.
    // Also, discard VR, Unarmed, Survivor, Story, and Parade units (Using vr[space] seems to catch the vr units correctly without getting false-positives)
    private _badNames = ["vr ", "unarmed", "survivor", "story", "competitor", "parade dress"];
    private _displayName = getText(_x >> "displayName");
    private _fnc_displayNameOkay = { {[_x, _displayName] call BIS_fnc_inString} count _badNames isEqualTo 0 };
    if (getText(_x >> "icon") != "iconManVirtual" && { call _fnc_displayNameOkay }) then {
        _units pushBack [(configname _x), getText(_x >> "displayName"), getText(_x >> "icon"), getText(_x >> "textSingular"), getNumber(_x >> "attendant"), getNumber(_x >> "engineer"), getNumber(_x >> "canDeactivateMines"), getNumber(_x >> "uavHacker")];
    };
} forEach _unitConfigPaths;

_units;