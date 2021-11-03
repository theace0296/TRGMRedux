// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getUnitData";
params [["_configOrNameOrObject", configNull, [configNull, "", objNull]]];

private _configPath = [];

switch (typeName _configOrNameOrObject) do {
    case "STRING": {
        _configPath = configFile >> "CfgVehicles" >> _configOrNameOrObject;
    };
    case "OBJECT": {
        _configPath = configFile >> "CfgVehicles" >> (typeOf _configOrNameOrObject);
    };
    case "CONFIG": {
        _configPath = _configOrNameOrObject;
    };
    default {};
};

if (isNil "_configPath" || {isNull _configPath || {!(isClass _configPath)}}) exitWith {};

[
    configName _configPath,
    getText(_configPath >> "displayName"),
    getTextRaw(_configPath >> "displayName"),
    getText(_configPath >> "icon"),
    getText(_configPath >> "textSingular"),
    getNumber(_configPath >> "attendant"),
    getNumber(_configPath >> "engineer"),
    getNumber(_configPath >> "canDeactivateMines"),
    getNumber(_configPath >> "uavHacker"),
    getText(_configPath >> "role")
];