// private _fnc_scriptName = "TRGM_GLOBAL_fnc_debugDotMarker";


params ["_sText", "_pos"];

if (isNil "_sText" || isNil "_pos") exitWith {};

private _mrkDebug = createMarker [_sText, _pos];
_mrkDebug setMarkerShape "ICON";
_mrkDebug setMarkerType "hd_dot";
_mrkDebug setMarkerText _sText;


true;