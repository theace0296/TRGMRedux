// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getVehicleData";
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
    (configname _configPath),
    getText(_configPath >> "displayName"),
    getTextRaw(_configPath >> "displayName"),
    getText(_configPath >> "textSingular"),
    getTextRaw(_configPath >> "textSingular"),
    getText(_configPath >> "editorSubcategory"),
    getText(configfile >> "CfgEditorSubcategories" >> getText(_configPath >> "editorSubcategory") >> "displayName"),
    getTextRaw(configfile >> "CfgEditorSubcategories" >> getText(_configPath >> "editorSubcategory") >> "displayName"),
    (configname _configPath) call TRGM_GLOBAL_fnc_isTransport,
    (configname _configPath) call TRGM_GLOBAL_fnc_isArmed
];
