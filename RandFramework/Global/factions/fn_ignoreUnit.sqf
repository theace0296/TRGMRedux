// private _fnc_scriptName = "TRGM_GLOBAL_fnc_ignoreUnit";
params [["_configPath", configNull, [configNull]]];

if (isNil "_configPath" || {isNull _configPath}) exitWith { true; };

private _badWeapons = ["Throw", "Put"];
private _fnc_weaponsOkay = { !(getArray(_configPath >> "weapons") isEqualTo _badWeapons); };

private _badIcons = ["iconmanvirtual"];
private _icon = getText(_configPath >> "icon");
private _fnc_iconsOkay = { !((toLower _icon) in _badIcons) };

private _badRoles = ["unarmed", "assistant"];
private _role = getText(_configPath >> "role");
private _fnc_rolesOkay = { {[_x, _role] call BIS_fnc_inString} count _badRoles isEqualTo 0 };

private _badClassNames = ["support", "crew"];
private _className = configName _configPath;
private _fnc_classNameOkay = { {[_x, _className] call BIS_fnc_inString} count _badClassNames isEqualTo 0 };

if (call _fnc_weaponsOkay && {call _fnc_iconsOkay && {call _fnc_rolesOkay && {call _fnc_classNameOkay}}}) exitWith { false; };

true;
