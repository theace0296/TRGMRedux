// private _fnc_scriptName = "TRGM_GLOBAL_fnc_ignoreVehicle";
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

if (isNil "_configPath" || {isNull _configPath}) exitWith { true; };

private _badNames = ["designator", "sam_system"];
private _configName = configName _configPath;
private _rawDispName = call { getTextRaw(_configPath >> "displayName") }; // Sqflint doesn't understand getTextRaw yet, so this is a work around
private _fnc_dispNameOkay = { {[_x, _rawDispName] call BIS_fnc_inString || [_x, _configName] call BIS_fnc_inString} count _badNames isEqualTo 0 };

private _badCalloutNames = ["unknown", "_gl"];
private _rawCalloutName = call { getTextRaw(_configPath >> "textSingular") }; // Sqflint doesn't understand getTextRaw yet, so this is a work around
private _fnc_calloutNameOkay = { {[_x, _rawCalloutName] call BIS_fnc_inString} count _badCalloutNames isEqualTo 0 };

private _badCategories = ["drone", "storage", "submersibles"];
private _rawCategory = call { getTextRaw(configfile >> "CfgEditorSubcategories" >> getText(_configPath >> "editorSubcategory") >> "displayName") }; // Sqflint doesn't understand getTextRaw yet, so this is a work around
private _fnc_categoryOkay = { {[_x, _rawCategory] call BIS_fnc_inString} count _badCategories isEqualTo 0 };

if (getText(_configPath >> "vehicleClass") != "Training" && {call _fnc_dispNameOkay && {call _fnc_calloutNameOkay && {call _fnc_categoryOkay}}}) exitWith { false; };

true;
