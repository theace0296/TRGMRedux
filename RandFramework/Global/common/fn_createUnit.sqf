params ["_group", "_type", "_position", ["_markers", []], ["_placement", 0], ["_special", "NONE"], ["_disableDynamicShowHide", false]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (isNil "_group" || isNil "_type" || isNil "_position" || !(_markers isEqualType []) || !(_placement isEqualType 0) || !(_special isEqualType "NONE")) exitWith {};

_unit = _group createUnit [_type, _position, _markers, _placement, _special];

if (_unit isEqualTo leader _group && !_disableDynamicShowHide) then {
    [_unit] spawn TRGM_GLOBAL_fnc_dynamicShowHide;
};

_unit;
