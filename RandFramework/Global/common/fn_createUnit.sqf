params [["_group", grpNull, [grpNull]], ["_type", nil, [""]], ["_position", nil, [nil, objNull, grpNull, []]], ["_markers", [], [[]]], ["_placement", 0, [0]], ["_special", "NONE", [""]], ["_disableDynamicShowHide", false, [false]]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (isNull _group || _type isEqualTo "" || isNil "_position") exitWith {};

if !(_markers isEqualType []) then {
    _markers = [];
};

if !(_placement isEqualType 0) then {
    _placement = 0;
};

if !(_special in ["NONE", "FORM", "CAN_COLLIDE", "CARGO"]) then {
    _special = "NONE";''
};


_unit = _group createUnit [_type, _position, _markers, _placement, _special];

if (_unit isEqualTo leader _group && !_disableDynamicShowHide) then {
    [_unit] spawn TRGM_GLOBAL_fnc_dynamicShowHide;
};

_unit;
