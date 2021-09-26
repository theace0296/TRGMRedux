// private _fnc_scriptName = "TRGM_GLOBAL_fnc_addToDirection";
params ["_origDirection","_addToDirection"];

if (isNil "_origDirection" || isNil "_addToDirection") exitWith {};

private _iResult = _origDirection + _addToDirection;
if (_iResult > 360) then {
    _iResult = _iResult - 360;
};
if (_origDirection+_addToDirection < 0) then {
    _iResult = 360 + _iResult;
};
_iResult;
