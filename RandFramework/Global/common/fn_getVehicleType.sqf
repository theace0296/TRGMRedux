// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getVehicleType";
params [["_type", "", [""]]];

private _returnType = "UnarmedCars";
if (isNil "_type" || { _type isEqualTo ""}) exitWith {_returnType;};

private _configPath = (configFile >> "CfgVehicles" >> _type);
if (isNil "_configPath") exitWith {_returnType;};

private _vehData = [_configPath] call TRGM_GLOBAL_fnc_getVehicleData;
if (isNil "_vehData" || {!(_vehData isEqualType [])}) exitWith {_returnType;};

_vehData params ["_className", "_dispName", "_rawDispName", "_calloutName", "_rawCalloutName", "_editorSubcategory", "_category", "_rawCategory", "_isTransport", "_isArmed"];

if (isNil "_className" || isNil "_dispName" || isNil "_calloutName" || isNil "_rawCategory" || [_configPath] call TRGM_GLOBAL_fnc_ignoreVehicle) then {
    _returnType = "UnarmedCars";
} else {
    if (_calloutName isEqualTo "mortar" || _className isKindOf "StaticMortar") then {
        _returnType = "Mortars";
    } else {
        if (_className isKindOf "StaticMGWeapon" || _className isKindOf "StaticGrenadeLauncher") then {
            _returnType = "Turrets";
        } else {
            private _typeFound = false;
            private _returnTypeMap = [
                ["Cars",      ["car", "truck", "mrap", "bike", "bicycle"]],
                ["Mortars",   ["mortar"]],
                ["Turrets",   ["turret", "static"]],
                ["Boats",     ["boat", "ship"]],
                ["Artillery", ["artillery", "arty"]],
                ["AntiAir",   ["_aa", "radar", "air defence"]],
                ["Planes",    ["plane"]],
                ["APCs",      ["apc", "ifv"]],
                ["Tanks",     ["tank", "armor"]],
                ["Helos",     ["helicopter"]]
            ];
            if (!_typeFound) then {
                {
                    private _searchText = _x;
                    if ([_searchText, _rawCategory] call BIS_fnc_inString) exitWith {
                        _typeFound = true;
                        private _mapIndex = _returnTypeMap findIf { _searchText in (_x select 1) };
                        _returnType = (_returnTypeMap select _mapIndex) select 0;
                        if (_returnType in ["Cars", "Helos"]) then {
                            if (_isArmed && !_isTransport) then {
                                _returnType = "Armed" + _returnType;
                            } else {
                                _returnType = "Unarmed" + _returnType;
                            };
                        };
                    };
                } forEach (flatten (_returnTypeMap apply { _x select 1}));
            };
            if (!_typeFound) then {
                {
                    private _searchText = _x;
                    if ([_searchText, _rawCalloutName] call BIS_fnc_inString) exitWith {
                        _typeFound = true;
                        private _mapIndex = _returnTypeMap findIf { _searchText in (_x select 1) };
                        _returnType = (_returnTypeMap select _mapIndex) select 0;
                        if (_returnType in ["Cars", "Helos"]) then {
                            if (_isArmed && !_isTransport) then {
                                _returnType = "Armed" + _returnType;
                            } else {
                                _returnType = "Unarmed" + _returnType;
                            };
                        };
                    };
                } forEach (flatten (_returnTypeMap apply { _x select 1}));
            };
        };
    };
};

// Possible return types are:
// [
//     "UnarmedCars",
//     "ArmedCars",
//     "Mortars",
//     "Turrets",
//     "Boats",
//     "Artillery",
//     "AntiAir",
//     "Planes",
//     "APCs",
//     "Tanks",
//     "ArmedHelos",
//     "UnarmedHelos",
// ]
_returnType;