// private _fnc_scriptName = "TRGM_GLOBAL_fnc_supplyHelicopter";
params ["_finishedVariable", "_finishedValue", "_side", "_spawnPos", "_exitPos", "_destPos", "_unit"];

format["SupplyHelicopter: %1, %2, %3, %4, %5, %6, %7", _finishedVariable, _finishedValue, _side, _spawnPos, _exitPos, _destPos, _unit] call TRGM_GLOBAL_fnc_log;

if (isNil "_finishedVariable" || isNil "_finishedValue" || isNil "_side" || isNil "_spawnPos" || isNil "_exitPos" || isNil "_destPos") exitWith {
    hint "Supply Helicopter failed!";
    if !(isNil "_finishedVariable" && isNil "_finishedValue") then {
        missionNamespace setVariable [_finishedVariable, _finishedValue, true];
    };
};

try {
    private _airToUse = (selectRandom HVTChoppers);
    switch (_side) do {
        case WEST: { _airToUse = (call ReinforceVehicleFriendly); };
        case EAST: { _airToUse = (call ReinforceVehicle); };
        case INDEPENDENT: { _airToUse = (call ReinforceVehicleMilitia); };
        default {};
    };
    private _heloGroup = (createGroup [_side, true]);
    private _airDropHelo = createVehicle [_airToUse, [(_spawnPos select 0), (_spawnPos select 1)], [], 0, "FLY"];

    [_heloGroup, _airDropHelo, true] call TRGM_GLOBAL_fnc_createVehicleCrew;

    _airDropHelo flyInHeight 200;
    _airDropHelo allowDamage false;
    _heloGroup enableAttack false;
    _heloGroup setBehaviour "CARELESS";
    _heloGroup setCombatMode "BLUE";
    {
        _x disableAi "TARGET";
        _x disableAi "AUTOTARGET";
        _x disableAi "FSM";
        _x setCaptive true;
    } forEach crew _airDropHelo;

    _airDropHelo doMove [(_spawnPos select 0), (_spawnPos select 1), 200];
    waitUntil {
        sleep 2;
        (_airDropHelo distance2D [(_spawnPos select 0), (_spawnPos select 1), 200]) < 100;
    };

    _airDropHelo doMove [(_destPos select 0), (_destPos select 1), 200];
    waitUntil {
        sleep 2;
        (_airDropHelo distance2D [(_destPos select 0), (_destPos select 1), 200]) < 100;
    };

    _airDropHelo doMove [(_exitPos select 0), (_exitPos select 1), 200];
    sleep 1;

    private _supplyObjectDummy = "B_supplyCrate_f" createVehicle[0, 0, 200];
    _supplyObjectDummy allowDamage false;
    _supplyObjectDummy setPos[(_destPos select 0), (_destPos select 1), 200];

    waitUntil {
        sleep 1;
        ([_supplyObjectDummy] call TRGM_GLOBAL_fnc_getRealPos) select 2 < 75
    };

    private _para = "B_Parachute_02_F" createVehicle [(_destPos select 0), (_destPos select 1), 100];
    _supplyObjectDummy attachTo [_para, [0, 0, -1]];
    _para setPos [(_destPos select 0), (_destPos select 1), 100];

    waitUntil {
        sleep 1;
        ([_supplyObjectDummy] call TRGM_GLOBAL_fnc_getRealPos) select 2 >= 0 && ([_supplyObjectDummy] call TRGM_GLOBAL_fnc_getRealPos) select 2 <= 5
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
    try {
        if !(isNil "_unit") then {
            [_supplyObject, (units group _unit)] call TRGM_GLOBAL_fnc_initAmmoBox;
        };
    } catch {};
    _supplyObject allowDamage false;
    [_supplyObject] call TRGM_GLOBAL_fnc_setVehicleUpright;
    _supplyObject allowDamage true;

    {
        deleteVehicle _x;
    }
    forEach crew _airDropHelo + [_airDropHelo];
    deleteGroup _heloGroup;
} catch {};

missionNamespace setVariable [_finishedVariable, _finishedValue, true];

true;