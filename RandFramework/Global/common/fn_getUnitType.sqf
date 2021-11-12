// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getUnitType";
params [["_type", "", [""]]];


private _configPath = (configFile >> "CfgVehicles" >> _type);
private _unitData = [_configPath] call TRGM_GLOBAL_fnc_getUnitData;
_unitData params ["_className", "_dispName", "_rawDispName", "_icon", "_calloutName", "_isMedic", "_isEngineer", "_isExpSpecialist", "_isUAVHacker", "_role"];

private _returnType = "riflemen";
if (isNil "_className" || isNil "_dispName" || isNil "_rawDispName" || isNil "_icon" || isNil "_calloutName" || [_configPath] call TRGM_GLOBAL_fnc_ignoreUnit) then {
    _returnType = "riflemen";
} else {
    switch (toLower _icon) do {
        case "iconmanengineer":    { _returnType = "engineers"; };
        case "iconmanmedic":       { _returnType = "medics"; };
        case "iconmanexplosive":   { _returnType = "explosivespecs"; };
        case "iconmanleader":      { _returnType = "leaders"; };
        case "iconmanofficer":     { _returnType = "leaders"; };
        case "iconmanmg":          { _returnType = "autoriflemen"; };
        case "iconmanat":          { _returnType = (["atsoldiers", "aasoldiers"] select (({ ["AA", _x, true] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0) && !({ ["AT", _x, true] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0))); };
        default {
            if (_isEngineer isEqualTo 1)      then { _returnType = "engineers"; };
            if (_isMedic isEqualTo 1)         then { _returnType = "medics"; };
            if (_isExpSpecialist isEqualTo 1) then { _returnType = "explosivespecs"; };
            if (_isUAVHacker isEqualTo 1)     then { _returnType = "uavops"; };
            if ([_isEngineer, _isMedic, _isExpSpecialist, _isUAVHacker] isEqualTo [0,0,0,0]) then {
                switch (toLower _calloutName) do {
                    case "pilot": { _returnType = "pilots"; };
                    case "sniper": { _returnType = "snipers"; };
                    case "at soldier": { _returnType = (["atsoldiers", "aasoldiers"] select (({ ["AA", _x, true] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0) && !({ ["AT", _x, true] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0))); };
                    case "machinegunner": { _returnType = "autoriflemen"; };
                    case "officer": { _returnType = "leaders"; };
                    case "infantry";
                    default {
                        if ({ ["pilot", _x] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0) then {
                            _returnType = "pilots";
                        } else {
                            if ({ ["AT", _x, true] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0) then {
                                _returnType = "atsoldiers";
                            } else {
                                if ({ ["AA", _x, true] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0) then {
                                    _returnType = "aasoldiers";
                                } else {
                                    if ({ ["grenadier", _x] call BIS_fnc_inString || ["GL", _x, true] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0) then {
                                        _returnType = "grenadiers"; }
                                    else {
                                        if ({ ["scout", _x] call BIS_fnc_inString || ["sniper", _x] call BIS_fnc_inString || ["marksman", _x] call BIS_fnc_inString || ["ghillie", _x] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0) then {
                                            _returnType = "snipers";
                                        } else {
                                            if ({ ["machinegunner", _x] call BIS_fnc_inString || ["autorifleman", _x] call BIS_fnc_inString } count [_role, _className, _rawDispName] > 0) then {
                                                _returnType = "autoriflemen";
                                            } else {
                                                _returnType = "riflemen";
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
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