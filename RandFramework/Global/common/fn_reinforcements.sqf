// private _fnc_scriptName = "TRGM_GLOBAL_fnc_reinforcements";
/* ---------------------------------------------------------------------------------------------------------

File: reinforcements.sqf
Author: Iceman77

Description:
A function that will create a fully manned helo which inserts infantry units into an AO.

Parameter(s):
_this select 0 <side> - EAST, WEST, INDEPENDENT
_this select 1 <string> - Marker: (spawn position of the helo)
_this select 2 <string> - Marker: (Landing Zone for the helo)
_this select 3 <number> - Skill Setting: (1,2,3,4 >> 1 = Noob AI -- 4 = Deadly Ai)
_this select 4 <bool> - SAD Mode: (True = Seek & destroy mode enabled. False = Patrol Mode Enabled)
_this select 5 <bool> - Body Deletion: (True = delete dead Bodies of the reinforcements, False = let the dead bodies stay on the battlefield)
_this select 6 <bool> - Cycle Mode: (True = ON, False = OFF)
_this select 7 <bool> - Paradrop: (True = Enabled, False = Disabled)
_this select 8 <bool> - Debug Mode: (True = Enabled, False = Disabled)
_this select 8 <bool> - Use standard reinforcements delay: (True = Use alternate delay, False = Use standard delay)
_this select 9 <bool> - No delay: (True = Call immediately, False = Use delay)

Usage:
_nul = [SIDE, "string", "string", number, bool, bool, bool, bool, bool, bool, bool] spawn TRGM_GLOBAL_fnc_reinforcements; >>
_nul = [EAST, "spawnMrk", "LZMrk", 2, true, true, true, true, false, false, false] spawn TRGM_GLOBAL_fnc_reinforcements; <<

 ---------------------------------------------------------------------------------------------------------*/



FPSMAX=60; //60 FPS max
FPSLIMIT=15; // 15 FPS min
MAXDELAY=5; // 5 sec max delay
private _AdditionalUnitCreationDelay = ((abs(FPSMAX - diag_fps) / (FPSMAX - FPSLIMIT))^2) * MAXDELAY;

//arguments definitions
params [
    ["_side", EAST],
    ["_spawnMrk", [0,0,0]],
    ["_LZMrk", [0,0,0]],
    ["_skill", 3],
    ["_sadMode", true],
    ["_bodyDelete", true],
    ["_cycleMode", false],
    ["_paraDrop", false],
    ["_debugMode", false],
    ["_useStandardDelay", true],
    ["_noDelay", false]
];

if ((_LZMrk select 0) isEqualTo 0 && (_LZMrk select 1) isEqualTo 0) exitWith {};

if (!isServer) exitWith {};

sleep(_AdditionalUnitCreationDelay);

if !(_noDelay) then {
    if (TRGM_VAR_ReinforcementsCalled > 4) exitWith {};
    TRGM_VAR_ReinforcementsCalled = TRGM_VAR_ReinforcementsCalled + 1; publicVariable "TRGM_VAR_ReinforcementsCalled";
    if (_useStandardDelay && {(time - TRGM_VAR_TimeLastReinforcementsCalled) < (call TRGM_GETTER_fnc_iGetSpottedDelay)}) exitWith {};
    if (!_useStandardDelay && {(time - TRGM_VAR_TimeSinceAdditionalReinforcementsCalled) < (call TRGM_GETTER_fnc_iGetSpottedDelay * 1.5)}) exitWith {}; //Using 1.5 multiplier for the delay so the main and additional triggers don't fire at the same time.

    if (_useStandardDelay) then {
        TRGM_VAR_TimeLastReinforcementsCalled = time;
        publicVariable "TRGM_VAR_TimeLastReinforcementsCalled";
    } else {
        TRGM_VAR_TimeSinceAdditionalReinforcementsCalled = time;
        publicVariable "TRGM_VAR_TimeSinceAdditionalReinforcementsCalled";
    };
};

private _heloCrew = createGroup _side;

//set the scope of local variables that are defined in other scope(s), so they can be used over the entire script
private ["_helo","_infgrp"];

//Debug output of the passed arguments
if (_debugMode) then {
    sleep 1;
    [format ["Debug mode is enabled %1 (SP ONLY!!). Mapclick teleport, invincibility and marker tracking are enabled.", name player]] call TRGM_GLOBAL_fnc_notify;
    player globalChat format ["Side: %1", _side];
    player globalChat format ["Spawn Position: %1 ", _spawnMrk];
    player globalChat format ["Landing Zone: %1", _LZMrk];
    player globalChat format ["AI Skill: %1", _skill];
    player globalChat format ["SAD Mode: %1", _sadMode];
    player globalChat format ["Body Deletion: %1", _bodyDelete];
    player globalChat format ["Cycle Mode: %1", _cycleMode];
    player globalChat format ["Debug Mode: %1", _debugMode];
    player globalChat format ["Use standard delay: %1", _useStandardDelay];
};

//Side Check to spawn appropriate helicopter & cargo
switch (_side) do {
    case WEST : {
        _infgrp = createGroup WEST;

        [_infgrp, (call fTeamleader),    [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call fGrenadier),     [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call fMedic),         [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call fRifleman),      [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call fMachineGunMan), [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        _helo = createVehicle [(call ReinforceVehicleFriendly), _spawnMrk, [], 0, "FLY"];
    };
    case EAST : {
        _infgrp = createGroup EAST;

        [_infgrp, (call sTeamleader),    [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call sGrenadier),     [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call sMedic),         [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call sRifleman),      [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call sMachineGunMan), [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        _helo = createVehicle [(call ReinforceVehicle), _spawnMrk, [], 0, "FLY"];
    };
    case INDEPENDENT : {
        _infgrp = createGroup INDEPENDENT;

        [_infgrp, (call sTeamleaderMilitia),    [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call sGrenadierMilitia),     [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call sMedicMilitia),         [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call sRiflemanMilitia),      [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        [_infgrp, (call sMachineGunManMilitia), [0,0], [], 5, "NONE"] call TRGM_GLOBAL_fnc_createUnit; sleep(_AdditionalUnitCreationDelay);
        _helo = createVehicle [(call ReinforceVehicleMilitia), _spawnMrk, [], 0, "FLY"];
    };
};

//Debug output of the helo + cargo
if (_debugMode) then {
    player globalChat format ["Helo Array: %1", _helo];
    player globalChat format ["Cargo Group: %1", _infGrp];
};

//Set the infantry groups skill levels (_skill is a 1 based index, so use _skill - 1 for selecting on a zero based index)
if (_skill > 4) then {_skill = 4;};
if (_skill < 1) then {_skill = 1;};
{
    _x setSkill["general",        [1.0, 1.0, 1.0, 1.0] select (_skill - 1)];
    _x setSkill["aimingAccuracy", [0.2, 0.3, 0.3, 0.4] select (_skill - 1)];
    _x setSkill["aimingShake",    [0.2, 0.3, 0.4, 0.5] select (_skill - 1)];
    _x setSkill["aimingSpeed",    [0.7, 0.7, 1.0, 1.0] select (_skill - 1)];
    _x setSkill["endurance",      [0.1, 0.2, 0.5, 0.5] select (_skill - 1)];
    _x setSkill["spotDistance",   [0.1, 0.2, 0.3, 0.5] select (_skill - 1)];
    _x setSkill["spotTime",       [0.1, 0.2, 0.3, 0.5] select (_skill - 1)];
    _x setSkill["courage",        [1.0, 1.0, 1.0, 1.0] select (_skill - 1)];
    _x setSkill["reloadspeed",    [0.1, 0.2, 0.7, 1.0] select (_skill - 1)];
    _x setSkill["commanding",     [0.5, 0.7, 1.0, 1.0] select (_skill - 1)];
} forEach units _infGrp;

//Assign the crew to a group & assign cargo to the helo
[_side, _helo, true] call TRGM_GLOBAL_fnc_createVehicleCrew;
{[_x] joinSilent _heloCrew;} forEach crew _helo;
_heloCrew enableAttack false;
_heloCrew setBehaviour "CARELESS";
_heloCrew setCombatMode "BLUE";
{
    _x disableAi "TARGET";
    _x disableAi "AUTOTARGET";
    _x disableAi "FSM";
    _x setCaptive true;
} forEach crew _helo;
{_x assignAsCargo _helo; _x moveInCargo _helo;} forEach units _infgrp;
_infgrp deleteGroupWhenEmpty true;
_heloCrew deleteGroupWhenEmpty true;

//Debug output of the total crew count (cargo counts as crew too)
if (_debugMode) then {player globalChat format ["Helicopter Total Crew Count: %1", count crew _helo];};

//Enable body deletion if the _bodyDelete parameter is passed as true
if (_bodyDelete) then {
    {_x addMPEventhandler ["MPKilled",{[(_this select 0)] spawn TRGM_GLOBAL_fnc_deleteTrash}]} forEach crew _helo + [_helo];
};

//Find a flat position around the LZ marker & create an HPad there.
private _flatPos = [_LZMrk , 0, 600, 20, 0, 0.3, 0, [],[_LZMrk,_LZMrk], _helo] call TRGM_GLOBAL_fnc_findSafePos;
private _hPad = createVehicle ["Land_HelipadEmpty_F", _flatPos, [], 0, "NONE"];
private _hPadPos = getPos _hPad;

//Debug output map markers
private ["_mrkPos","_mrkLZ","_mrkHelo","_mrkinf","_mrkTarget"];
if (_debugMode) then {
    private _color = [(((side leader _infGrp) call bis_fnc_sideID) call bis_fnc_sideType),true] call bis_fnc_sidecolor;

    private _mrkPos = createMarker [format ["%1", random 10000], _flatPos];
    _mrkPos setMarkerShape "ICON";
    _mrkPos setMarkerType "mil_objective";
    _mrkPos setMarkerSize [1,1];
    _mrkPos setMarkerColor _color;
    _mrkPos setMarkerText "Actual LZ";

    private _mrkLZ = createMarker [format ["%1", random 10000], _LZMrk];
    _mrkLZ  setMarkerShape "ICON";
    _mrkLZ  setMarkerType "mil_dot";
    _mrkLZ  setMarkerSize [1,1];
    _mrkLZ  setMarkerColor _color;
    _mrkLZ  setMarkerText "LZ Area";

    private _mrkHelo = createMarker [format ["%1", random 10000], getPosATL _helo];
    _mrkHelo setMarkerShape "ICON";
    _mrkHelo setMarkerType "o_air";
    _mrkHelo setMarkerSize [1,1];
    _mrkHelo setMarkerColor _color;
    _mrkHelo setMarkerText format ["%1", _helo];

    private _mrkInf = createMarker [format ["%1", random 10000], getPosATL leader _infGrp];
    _mrkInf setMarkerShape "ICON";
    _mrkInf setMarkerType "mil_dot";
    _mrkInf setMarkerSize [1,1];
    _mrkInf setMarkerColor _color;

    [_helo, _infGrp, _mrkHelo, _mrkInf] spawn {
        while {{alive _x} count units (_this select 1) > 0 || canMove (_this select 0)} do {
            (_this select 2) setMarkerPos getPosATL (_this select 0);
            (_this select 3) setMarkerPos getPosATL leader (_this select 1);
            sleep 1;
        };
    };
};


//Give the helicopter an unload waypoint onto the hpad

if (!_paraDrop) then {
    _helo doMove [(_hPadPos select 0), (_hPadPos select 1), 200];
    waitUntil {sleep 2; (_helo distance2D [(_hPadPos select 0), (_hPadPos select 1), 200]) < 200;};
    _helo land "GET OUT";

    //wait until the helicopter is touching the ground before ejecting the cargo
    waitUntil {sleep 2; !([_helo] call TRGM_GLOBAL_fnc_helicopterIsFlying) || {!canMove _helo}};
    {unAssignVehicle _x; _x action ["eject", vehicle _x]; sleep 0.5;} forEach units _infgrp; //Eject the cargo
} else {
    //disable collision to avoid deaths and setup the paradrop
    {_x disableCollisionWith _helo} forEach units _infGrp;
    _helo flyInHeight 200;
    _helo doMove [(_hPadPos select 0), (_hPadPos select 1), 200];
    waitUntil {sleep 2; (_helo distance2D [(_hPadPos select 0), (_hPadPos select 1), 200]) < 200;};

    [units _infGrp] spawn TRGM_GLOBAL_fnc_para;
};

//wait until cargo is empty & if _sadMode is passed as true, then add a SAD WP on the nearest enemy.. else, go into patrol mode
waitUntil {sleep 2; [_helo] call TRGM_GLOBAL_fnc_isOnlyBoardCrewOnboard;};
if (_debugMode) then {player globalChat format ["Helo Cargo Count: %1", {alive _x && (_x in _helo)} count (units _infGrp)];};

_helo doMove [0, 0, 200];

[_helo, _heloCrew] spawn {
    waitUntil {sleep 2; (_helo distance2D [(_hPadPos select 0), (_hPadPos select 1), 200]) > 3000;};
    private _helo = _this select 0;
    private _heloGroup = _this select 1;
    {
        deleteVehicle _x;
    }
    forEach crew _helo + [_helo];
    deleteGroup _heloGroup;
};

if (_debugMode) then {
    {deleteMarker _x;} forEach [_mrkLZ, _mrkPos];
};

if (_sadMode) then {
    if (_debugMode) then {player globalChat "Scanning for targets to enable SAD Mode";};
    private _nearestEnemies = [];
    private _nearestMen = nearestObjects [getPosATL leader _infGrp, ["Man"], 1000];
        {
            if ( (side _x getFriend (side leader (_infGrp))) < 0.6 && {side _x != CIVILIAN} ) then {
                _nearestEnemies = _nearestEnemies + [_x];
            };
        } forEach _nearestMen;

        if (count _nearestEnemies > 0) then {
            private _enemy = _nearestEnemies call bis_fnc_selectRandom;
            private _attkPos = [_enemy, random 100, random 360] call BIS_fnc_relPos;
            private _infWp = _infGrp addWaypoint [_attkPos, 0];
            _infWp setWaypointType "SAD";
            _infWp setWaypointBehaviour "AWARE";
            _infWp setWaypointCombatMode "RED";
            _infWp setWaypointSpeed "FULL";

                if (_debugMode) then {
                player globalChat "Target Found. Setting SAD waypoint";
                private _colorTarget = [(((side _enemy) call bis_fnc_sideID) call bis_fnc_sideType),true] call bis_fnc_sidecolor;
                private _mrkTarget = createMarker [format ["%1", random 10000], _attkPos];
                _mrkTarget setMarkerShape "ICON";
                _mrkTarget setMarkerType "mil_dot";
                _mrkTarget setMarkerSize [1,1];
                _mrkTarget setMarkerColor _colorTarget;
                _mrkTarget setMarkerText "SAD Target Area";
            };

        } else {
            [_infGrp, getPosATL (leader _infGrp), 200] call BIS_fnc_taskPatrol;
            if (_debugMode) then {player globalChat "No targets found. Patrol mode enabled";};

        };

} else {
    [_infGrp, getPosATL (leader _infGrp), 200] call BIS_fnc_taskPatrol;
    if (_debugMode) then {player globalChat "Patrol Mode";};
};

// Cycle mode gets a bit too intense for most situations, commenting out to avoid usage...
// IF _cycleMode is passed as true, then re-run the function (this function!), else do nothing.
// if (_cycleMode) then {
//     waitUntil {{alive _x} count units _infgrp + [_helo] isEqualTo 0};
//     if (_debugMode) then {
//         player globalChat "Patrol and helicopter dead";
//         {deleteMarker _x;} forEach [_mrkHelo, _mrkinf, _mrkTarget];
//     };
//     if (_debugMode) then {player globalChat "New Reinforcements created";};
//     [_side, _spawnMrk, _LZMrk, _skill, _sadMode, _bodyDelete, false, _debugMode, _useStandardDelay] spawn TRGM_GLOBAL_fnc_reinforcements;
// };

TRGM_VAR_ReinforcementsCalled = TRGM_VAR_ReinforcementsCalled - 1; publicVariable "TRGM_VAR_ReinforcementsCalled";

// Function End
true;