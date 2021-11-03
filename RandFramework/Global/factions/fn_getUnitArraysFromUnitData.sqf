// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getUnitArraysFromUnitData";
params["_unitData"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

private _riflemen = [];
private _leaders = [];
private _atsoldiers = [];
private _aasoldiers = [];
private _engineers = [];
private _grenadiers = [];
private _medics = [];
private _autoriflemen = [];
private _snipers = [];
private _explosiveSpecs = [];
private _pilots = [];
private _uavOperators = [];
{
    _x params ["_unitClassName", "_unitType"];
    switch (_unitType) do {
        case "riflemen": {
            _riflemen pushBackUnique _unitClassName;
        };
        case "leaders": {
            _leaders pushBackUnique _unitClassName;
        };
        case "atsoldiers": {
            _atsoldiers pushBackUnique _unitClassName;
        };
        case "aasoldiers": {
            _aasoldiers pushBackUnique _unitClassName;
        };
        case "engineers": {
            _engineers pushBackUnique _unitClassName;
        };
        case "grenadiers": {
            _grenadiers pushBackUnique _unitClassName;
        };
        case "medics": {
            _medics pushBackUnique _unitClassName;
        };
        case "autoriflemen": {
            _autoriflemen pushBackUnique _unitClassName;
        };
        case "snipers": {
            _snipers pushBackUnique _unitClassName;
        };
        case "explosivespecs": {
            _explosiveSpecs pushBackUnique _unitClassName;
        };
        case "pilots": {
            _pilots pushBackUnique _unitClassName;
        };
        case "uavops": {
            _uavOperators pushBackUnique _unitClassName;
        };
        default {
            _riflemen pushBackUnique _unitClassName;
        };
    };
} forEach _unitData;

private _unitArray = [];
{
    if (count _x > 0) then {
        _unitArray pushBack _x;
    } else {
        _unitArray pushBack _riflemen;
    };
} forEach [_riflemen, _leaders, _atsoldiers, _aasoldiers, _engineers, _grenadiers, _medics, _autoriflemen, _snipers, _explosiveSpecs, _pilots, _uavOperators];
_unitArray;