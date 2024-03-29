// private _fnc_scriptName = "TRGM_GLOBAL_fnc_para";
params [["_units", []]];

if (!(_units isEqualType []) && {!(_units isEqualTypeAll objNull)}) exitWith {};

{
    [_x, vehicle _x] remoteExecCall ["disableCollisionWith", _x];

    [[_x], {
        params ["_unit"];
        _unit allowDamage false;
        unassignVehicle _unit;
        moveOut _unit;
    }] remoteExec ["call", _x];

    if (vehicle _x != _x) then { deleteVehicle _x; };

    [[_x], {
        params ["_unit"];
        waitUntil { ([_unit] call TRGM_GLOBAL_fnc_getRealPos) select 2 < 250};
        private _chute = createVehicle ["Steerable_Parachute_F", getPosATL _unit, [], 0, "CAN_COLLIDE"];
        _chute attachTo [_unit,[0,0,0]];
        detach _chute;
        _unit moveInDriver _chute;
        _unit allowDamage true;
    }] remoteExecCall ["spawn", _x];
} forEach _units;