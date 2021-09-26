// private _fnc_scriptName = "TRGM_GLOBAL_fnc_makeNPC";


params ["_units"];

if (isNil "_units") exitWith {};

if !(_units isEqualType []) then {
    _units = [_units];
};

{
    private _unit = _x;
    _unit setCaptive true;
    _unit setBehaviour "CARELESS";
    {_unit disableAI _x} forEach ["TARGET", "AUTOTARGET", "FSM", "SUPPRESSION", "CHECKVISIBLE", "AUTOCOMBAT", "COVER"];
} forEach _units;

true;