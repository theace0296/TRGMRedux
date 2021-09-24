params [["_type", "", [""]]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


if !(_side in [WEST, INDEPENDENT, EAST]) exitWith { ""; };

private _configPath = (configFile >> "CfgVehicles" >> _type);
[_type, getText(_configPath >> "displayName"), getText(_configPath >> "icon"), getText(_configPath >> "textSingular"), getNumber(_configPath >> "attendant"), getNumber(_configPath >> "engineer"), getNumber(_configPath >> "canDeactivateMines"), getNumber(_configPath >> "uavHacker")] params ["_className", "_dispName", "_icon", "_calloutName", "_isMedic", "_isEngineer", "_isExpSpecialist", "_isUAVHacker"];

private _returnType = "riflemen";
if (isNil "_className" ||isNil "_dispName" || isNil "_icon" || isNil "_calloutName") then {

} else {
    if (["Ass.", _dispName] call BIS_fnc_inString || ["Asst", _dispName] call BIS_fnc_inString || ["Assi", _dispName] call BIS_fnc_inString || ["Story", _dispName] call BIS_fnc_inString || ["Support", _className] call BIS_fnc_inString || ["Crew", _className] call BIS_fnc_inString) then {
        _returnType = "riflemen";
    } else {
        switch (_icon) do {
            case "iconManEngineer":     { _returnType = "engineers"; };
            case "iconManMedic":      { _returnType = "medics"; };
            case "iconManExplosive": { _returnType = "explosivespecs"; };
            case "iconManLeader":     { _returnType = "leaders"; };
            case "iconManOfficer":     { _returnType = "leaders"; };
            case "iconManMG":         { _returnType = "autoriflemen"; };
            case "iconManAT":         { if (["AA", _dispName, true] call BIS_fnc_inString || ["AA", _className] call BIS_fnc_inString) then { _returnType = "aasoldiers"; } else { _returnType = "atsoldiers"; }; };
            default {
                if (_isEngineer isEqualTo 1) then { _returnType = "engineers"; };
                if (_isMedic isEqualTo 1) then { _returnType = "medics"; };
                if (_isExpSpecialist isEqualTo 1) then { _returnType = "explosivespecs"; };
                if (_isUAVHacker isEqualTo 1) then { _returnType = "uavops"; };
                if (["Auto", _dispName, true] call BIS_fnc_inString || ["Machine", _dispName, true] call BIS_fnc_inString) then { _returnType = "autoriflemen"; };
                if (_calloutName isEqualTo "AT soldier") then { if (["AA", _dispName, true] call BIS_fnc_inString || ["AA", _className] call BIS_fnc_inString) then { _returnType = "aasoldiers"; } else { _returnType = "atsoldiers"; }; };
                if ((_icon isEqualTo "iconMan")) then { if (_calloutName isEqualTo "sniper") then { _returnType = "snipers"; } else { if (["Grenadier", _dispName] call BIS_fnc_inString || ["Grenadier", _className] call BIS_fnc_inString) then { _returnType = "grenadiers"; } else { if (["Pilot", _dispName] call BIS_fnc_inString || ["Pilot", _className] call BIS_fnc_inString) then { _returnType = "pilots"; } else { _returnType = "riflemen"; }; }; }; };
            };
        };
    };
};

// Possible return types are:
// [
//     "riflemen",
//     "leaders",
//     "atsoldiers",
//     "aasoldiers",
//     "engineers",
//     "grenadiers",
//     "medics",
//     "autoriflemen",
//     "snipers",
//     "explosivespecs",
//     "pilots",
//     "uavops",
// ]
_returnType;