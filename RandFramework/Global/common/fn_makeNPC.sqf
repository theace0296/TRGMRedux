format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
params ["_units"];

if (isNil "_units") exitWith {};

if !(_units isEqualType []) then {
    _units = [_units];
};

{
    _unit = _x;
    _unit setCaptive true;
    _unit setBehaviour "CARELESS";
    {_unit disableAI _x} forEach ["TARGET", "AUTOTARGET", "FSM", "SUPPRESSION", "COMBAT", "CHECKVISIBLE", "AUTOCOMBAT", "COVER"];
} forEach _units;

true;