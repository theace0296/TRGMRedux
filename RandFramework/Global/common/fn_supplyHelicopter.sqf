// private _fnc_scriptName = "TRGM_GLOBAL_fnc_supplyHelicopter";
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


params ["_finishedVariable", "_finishedValue", "_side", "_spawnPos", "_exitPos", "_destPos", "_unit"];

format["SupplyHelicopter: %1, %2, %3, %4, %5, %6, %7", _finishedVariable, _finishedValue, _side, _spawnPos, _exitPos, _destPos, _unit] call TRGM_GLOBAL_fnc_log;

if (isNil "_finishedVariable" || isNil "_finishedValue" || isNil "_side" || isNil "_spawnPos" || isNil "_exitPos" || isNil "_destPos") exitWith {
    hint "Supply Helicopter failed!";
    if !(isNil "_finishedVariable" && isNil "_finishedValue") then {
        missionNamespace setVariable [_finishedVariable, _finishedValue, true];
    };
};

private _airToUse = (selectRandom HVTChoppers);
switch (_side) do {
    case WEST: { _airToUse = (call ReinforceVehicleFriendly); };
    case EAST: { _airToUse = (call ReinforceVehicle); };
    case INDEPENDENT: { _airToUse = (call ReinforceVehicleMilitia); };
    default {};
};
private _heloGroup = createGroup _side;
private _airDropHelo = createVehicle [_airToUse, [(_spawnPos select 0), (_spawnPos select 1)], [], 0, "FLY"];

[_heloGroup, _airDropHelo, true] call TRGM_GLOBAL_fnc_createVehicleCrew;

_airDropHelo flyInHeight 200;
_airDropHelo allowDamage false;
_heloGroup enableAttack false;
_heloGroup setBehaviour "CARELESS";
_heloGroup setCombatMode "BLUE";
{
    _airDropHelo disableAi "TARGET";
    _airDropHelo disableAi "AUTOTARGET";
    _airDropHelo disableAi "FSM";
    _airDropHelo setCaptive true;
} forEach crew _airDropHelo;

_airDropHelo setVariable ["TRGM_VAR_DroppedCrate", false];

private _v1wp1 = _heloGroup addWaypoint [[(_spawnPos select 0), (_spawnPos select 1)], 100];
[_heloGroup, 0] setWaypointStatements ["true", "(vehicle this) flyInHeight 200;"];
[_heloGroup, 0] setWaypointSpeed "FULL";
[_heloGroup, 0] setWaypointBehaviour "COMBAT";

private _v1wp2 = _heloGroup addWaypoint [[(_destPos select 0), (_destPos select 1)], 100];
[_heloGroup, 1] setWaypointStatements ["true", "(vehicle this) flyInHeight 200; "];
[_heloGroup, 1] setWaypointSpeed "FULL";

private _v1wp3 = _heloGroup addWaypoint [[(_exitPos select 0), (_exitPos select 1)], 100];
[_heloGroup, 2] setWaypointStatements ["true", "(vehicle this) flyInHeight 200; (vehicle this) setVariable ['TRGM_VAR_DroppedCrate', true];"];
[_heloGroup, 2] setWaypointSpeed "FULL";

waitUntil {
    sleep 5;
    _airDropHelo getVariable ["TRGM_VAR_DroppedCrate", false];
};
sleep 1;

private _supplyObjectDummy = "B_supplyCrate_f" createVehicle[0, 0, 200];
_supplyObjectDummy allowDamage false;
_supplyObjectDummy setPos[(_destPos select 0), (_destPos select 1), 200];

waitUntil {
    sleep 5;
    ([_supplyObjectDummy] call TRGM_GLOBAL_fnc_getRealPos) select 2 < 75
};

private _para = "B_Parachute_02_F" createVehicle [(_destPos select 0), (_destPos select 1), 100];
_supplyObjectDummy attachTo [_para, [0, 0, -1]];
_para setPos [(_destPos select 0), (_destPos select 1), 100];

waitUntil {
    sleep 5;
    ([_supplyObjectDummy] call TRGM_GLOBAL_fnc_getRealPos) select 2 >= 0 && ([_supplyObjectDummy] call TRGM_GLOBAL_fnc_getRealPos) select 2 <= 3
};

detach _supplyObjectDummy;
sleep 0.1;
deleteVehicle _para;

private _finalPos = getPosATL _supplyObjectDummy;
sleep 0.1;
deleteVehicle _supplyObjectDummy;

"SmokeShellBlue" createVehicle _finalPos;
sleep 0.1;
private _supplyObject = "B_supplyCrate_f" createVehicle _finalPos;
if !(isNil "_unit") then {
    [_supplyObject, (units group _unit)] call TRGM_GLOBAL_fnc_initAmmoBox;
};
_supplyObject allowDamage false;
[_supplyObject] call TRGM_GLOBAL_fnc_setVehicleUpright;
_supplyObject allowDamage true;

_airDropHelo setVariable ["TRGM_VAR_DroppedCrate", false];

{
    deleteVehicle _x;
}
forEach crew _airDropHelo + [_airDropHelo];
deleteGroup _heloGroup;

missionNamespace setVariable [_finishedVariable, _finishedValue, true];

true;