format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};

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