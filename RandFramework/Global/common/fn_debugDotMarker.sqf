format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};

params ["_sText", "_pos"];

if (isNil "_sText" || isNil "_pos") exitWith {};

private _mrkDebug = createMarker [_sText, _pos];
_mrkDebug setMarkerShape "ICON";
_mrkDebug setMarkerType "hd_dot";
_mrkDebug setMarkerText _sText;


true;