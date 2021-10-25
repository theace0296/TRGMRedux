// private _fnc_scriptName = "TRGM_GLOBAL_fnc_callNearbyPatrol";
params [
    ["_FirstPos", []],
    ["_iTaskIndex", 0],
    ["_bIsMainObjective", false],
    ["_thisThis", objNull],
    ["_thisThisList", []]
];



if !(isServer) exitWith {};

if (_FirstPos isEqualTo []) exitWith {};
if (isNull _thisThis) exitWith {};
if (_thisThisList isEqualTo []) exitWith {};

private _MainObjectivePos = TRGM_VAR_ObjectivePositions select _iTaskIndex;
if (isNil "_MainObjectivePos") then {_MainObjectivePos = TRGM_VAR_ObjectivePositions select 0;};

format["Spotted: %1", _thisThisList] call TRGM_GLOBAL_fnc_log;

if (TRGM_VAR_FireFlares) then {
    //gives 3 second delay before firing up flare, and also, will wait 10 seconds before firing up more
    TRGM_VAR_FlareCounter = TRGM_VAR_FlareCounter - 1;
    if (TRGM_VAR_FlareCounter isEqualTo 10) then {
        private _centPos = _FirstPos;
        private _FirstFlarePos = _centPos getPos [(floor random 150),(floor random 360)];
        private _SecondFlarePos = _centPos getPos [(floor random 150),(floor random 360)];
        [_FirstFlarePos] spawn TRGM_GLOBAL_fnc_fireAOFlares;
        sleep 0.5;
        [_SecondFlarePos] spawn TRGM_GLOBAL_fnc_fireAOFlares;

    };
    if (TRGM_VAR_FlareCounter isEqualTo 0) then {
        TRGM_VAR_FlareCounter = 30;
    };
};

private _SpottedUnits = _thisThisList select { alive _x && isPlayer _x };

if (_SpottedUnits isEqualTo []) exitWith {};

private _SpottedUnit = selectRandom _SpottedUnits;
_SpottedUnitPos = [_SpottedUnit] call TRGM_GLOBAL_fnc_getRealPos;

//so trigger will only be active for one second... inside this class we how many times its been called agasint the sideindex to decide if we continue (each side has its own trigger, so will be called multiple times if players sptted in multiple areas)
//two counters, one to count if to use reinforcments/air support etc... and the other to make sure we dont call patrol to move to pos every second (need to give the patrol at least 30 seconds to move before relocate waypoints)
TRGM_VAR_TimeSinceLastSpottedAction = time; publicVariable "TRGM_VAR_TimeSinceLastSpottedAction";

private _maxPatrolSearch = 2000;

private _SpottedUnitCount = { _x distance _SpottedUnit < 200 } count units group _SpottedUnit;

if (_SpottedUnitCount > 0) then {
    //========First take care of additional support (reinforcements, air to air/ground support etc... based on the type of threat the enemy have spotted)
    private _bAllowPatrolChange = true;
    private _bAllowNextMortarRounds = true;
    private _PatrolMoveCount = 0;
    private _InfCount = 0;
    private _TankCount = 0;
    private _AirCount = 0;
    private _MortarAllowedCount = 0;

    private _PatrolMoveMaxCount = 300; // 5 mins
    private _NextMortarMaxCount = 120; // 2 mins
    private _InfMaxCount = 240; //4 mins before scount, then another four mins for reinforcements
    private _TankMaxCount = 240;
    private _AirMaxCount = 240;
    private _bInfSpottedAction = false;
    private _bTankSpottedAction = false;
    private _bAirSpottedAction = false;
    if (_bIsMainObjective) then {
        _InfMaxCount = 60;
        _TankMaxCount = 120;
        _AirMaxCount = 120;
    };
    private _commsDown = TRGM_VAR_bCommsBlocked select _iTaskIndex;
    if (!(isNil "_commsDown") && {_commsDown}) then {
        _InfMaxCount = 600; //10 mins
        _TankMaxCount = 600;
        _AirMaxCount = 600;
    };
    private _currentAODetail = nil;
    {
        if (_x select 0 isEqualTo _iTaskIndex) then {
            _currentAODetail = _x;
            _PatrolMoveCount = (_x select 5);
            if (_PatrolMoveCount > 0) then {
                _bAllowPatrolChange = false;
            }
            else {
                _bAllowPatrolChange = true;
            };
            _PatrolMoveCount = _PatrolMoveCount + 1;
            _x set [5,_PatrolMoveCount];
            if (_PatrolMoveCount isEqualTo _PatrolMoveMaxCount) then {
                _x set [5,0];
            };

            _MortarAllowedCount = (_x select 6);
            if (_MortarAllowedCount > 0) then {
                _bAllowNextMortarRounds = false;
            }
            else {
                _bAllowNextMortarRounds = true;
            };
            if (_MortarAllowedCount > 0) then {
                _MortarAllowedCount = _MortarAllowedCount + 1;
                _x set [6,_MortarAllowedCount];
            };

            if (_MortarAllowedCount >= _NextMortarMaxCount) then {
                _x set [6,0];
            };


            if (!(vehicle _SpottedUnit isKindOf "Car") && !(vehicle _SpottedUnit isKindOf "Air") && !(vehicle _SpottedUnit isKindOf "Ship")) then {  //if not a tank or air unit, then just treat as though its a "Man" kindOf... was worried about playins being in car or another type not checekd which wouldnt fire this spotted script)
                if (_x select 1 > -1) then {
                    _InfCount = (_x select 1) + 1;
                    _x set [1,_InfCount];
                    if (_InfCount isEqualTo _InfMaxCount) then {
                        if (!(_x select 4)) then { //if scount not called in this AO
                            _x set [4,True];
                            _x set [1,0];
                            if ((_bIsMainObjective && random 1 < .50) || (!_bIsMainObjective && random 1 < .33)) then {
                                [_SpottedUnitPos, 3] spawn TRGM_GLOBAL_fnc_enemyAirSupport;
                            };
                        }
                        else {
                            _bInfSpottedAction = true;
                            _x set [1,-1];
                        };

                    };
                };
            };
            if (vehicle _SpottedUnit isKindOf "Car" || vehicle _SpottedUnit isKindOf "Ship") then {
                if (_x select 2 > -1) then {
                    _TankCount = (_x select 2) + 1;
                    _x set [2,_TankCount];
                    if (_TankCount isEqualTo _TankMaxCount) then {
                        _bTankSpottedAction = true;
                        _x set [2,-1];
                    };
                };
            };
            if (vehicle _SpottedUnit isKindOf "Air") then {
                if (_x select 3 > -1) then {
                    _AirCount = (_x select 3) + 1;
                    _x set [3,_AirCount];
                    if (_AirCount isEqualTo _AirMaxCount) then {
                        _bAirSpottedAction = true;
                        _x set [3,-1];
                    };
                };
            };
        };
    } forEach TRGM_VAR_AODetails;
    publicVariable "TRGM_VAR_AODetails";

    if (!(isNil "_currentAODetail")) then {
        sleep 5; //wait 5 seconds before enemy react

        if (_bInfSpottedAction) then {
                if (_bIsMainObjective) then {
                    [TRGM_VAR_EnemySide, call TRGM_GETTER_fnc_aGetReinforceStartPos, _MainObjectivePos, 3, true, false, false, false, false, false] spawn TRGM_GLOBAL_fnc_reinforcements;
                    if (call TRGM_GETTER_fnc_bMoreReinforcements) then {
                        sleep 5;
                        [TRGM_VAR_EnemySide, call TRGM_GETTER_fnc_aGetReinforceStartPos, _MainObjectivePos, 3, true, false, false, false, false, false] spawn TRGM_GLOBAL_fnc_reinforcements;
                    };
                    TRGM_VAR_ParaDropped = true; publicVariable "TRGM_VAR_ParaDropped";
                }
                else {
                    [TRGM_VAR_EnemySide, call TRGM_GETTER_fnc_aGetReinforceStartPos, _SpottedUnitPos, 3, true, false, false, false, false, false] spawn TRGM_GLOBAL_fnc_reinforcements;
                    if (call TRGM_GETTER_fnc_bMoreReinforcements) then {
                        sleep 5;
                        [TRGM_VAR_EnemySide, call TRGM_GETTER_fnc_aGetReinforceStartPos, _MainObjectivePos, 3, true, false, false, false, false, false] spawn TRGM_GLOBAL_fnc_reinforcements;
                    };
                };

        };

        if (_bTankSpottedAction) then {
            [_SpottedUnitPos, 2] spawn TRGM_GLOBAL_fnc_enemyAirSupport;
            TRGM_LOCAL_fnc_airSiren = {
                private _firstPosP = _this select 0;
                private _iLoopSirenCount = 0;
                while {_iLoopSirenCount < 5} do {
                    _iLoopSirenCount = _iLoopSirenCount + 1;
                    private _missiondir = call { private "_arr"; _arr = toArray str missionConfigFile; _arr resize (count _arr - 15); toString _arr };
                    playSound3D [_missiondir + "RandFramework\Sounds\Siren.ogg",nil,false,_firstPosP,1.5,1,0];

                    sleep 40;
                };
            };
            [_FirstPos] spawn TRGM_LOCAL_fnc_airSiren;
        };

        if (_bAirSpottedAction) then {
            [_SpottedUnitPos, 1] spawn TRGM_GLOBAL_fnc_enemyAirSupport;
            TRGM_LOCAL_fnc_airSiren = {
                private _firstPosP = _this select 0;
                private _iLoopSirenCount = 0;
                while {_iLoopSirenCount < 5} do {
                    _iLoopSirenCount = _iLoopSirenCount + 1;
                    _missiondir = call { private "_arr"; _arr = toArray str missionConfigFile; _arr resize (count _arr - 15); toString _arr };
                    playSound3D [_missiondir + "RandFramework\Sounds\Siren.ogg",nil,false,_firstPosP,1.5,1,0];

                    sleep 40;
                };
            };
            [_FirstPos] spawn TRGM_LOCAL_fnc_airSiren;
        };

        //==============Now the generic spotted action to send a patrol to investigate of they have spotted inf ================================================
        if ((vehicle _SpottedUnit isKindOf "Car") && _bAllowPatrolChange) then {
            if  ((_SpottedUnitCount > 0)) then {
                private _nearestATs = nearestObjects [_SpottedUnitPos, [(call sATMan),(call sATManMilitia)], _maxPatrolSearch];

                if (count _nearestATs > 0) then {

                    private _nearestTL = _nearestATs select 0;
                    while {(count (waypoints group _nearestTL)) > 0} do {
                        deleteWaypoint ((waypoints group _nearestTL) select 0);
                    };

                    group _nearestTL setCombatMode "RED";
                    group _nearestTL setFormation "WEDGE";
                    group _nearestTL setSpeedMode "FULL";
                    private _SpottedWP1a = group _nearestTL addWaypoint [getPos _nearestTL,0,0];
                        _SpottedWP1a setWaypointType "MOVE";
                    _SpottedWP1a setWaypointSpeed "FULL";
                    _SpottedWP1a setWaypointBehaviour "AWARE";
                    _SpottedWP1a setWaypointFormation "WEDGE";
                    private _SpottedWP1a2 = group _nearestTL addWaypoint [_SpottedUnitPos,0,1];
                    _SpottedWP1a2 setWaypointSpeed "FULL";
                    private _SpottedWP1b = group _nearestTL addWaypoint [_FirstPos,7,2];
                    _SpottedWP1b setWaypointType "CYCLE";
                    group _nearestTL setCombatMode "RED";
                    group _nearestTL setFormation "WEDGE";
                    group _nearestTL setSpeedMode "FULL";
                };
                if (random 1 < .50) then {

                    private _nearestTanks = nearestObjects [_SpottedUnitPos, [(call sTank3Tank)], 4000];
                    if (count _nearestTanks > 0) then {
                        private _nearestTank = selectRandom _nearestTanks;
                        private _nearestTLTankwPosArray = waypoints group _nearestTank;

                        while {(count (waypoints group _nearestTank)) > 0} do {
                            deleteWaypoint ((waypoints group _nearestTank) select 0);
                        };
                        private _SpottedWP5a = group _nearestTank addWaypoint [_SpottedUnitPos,10];
                        _SpottedWP5a setWaypointType "SAD";
                        _SpottedWP5a setWaypointSpeed "FULL";
                        _SpottedWP5a setWaypointBehaviour "AWARE";
                    };
                };
            };
        };


        //mortar script
        if  ((_SpottedUnitCount > 0) && _bAllowNextMortarRounds && !TRGM_VAR_bMortarFiring) then {
            private _bFiredMortar = false;
            _currentAODetail set [6,1];  //commence counting now fired... when reach zero again, we will wait until round fired again
            private _nearestMortars = nearestObjects [_SpottedUnitPos,(call sMortar) + (call sMortarMilitia),_maxPatrolSearch];
            private _ChancesOfFireMortar = .66;
            private _iRoundsToFire = 1;

            private _playerClose = [];
            {
                if ((_x distance _SpottedUnit) < 10) then {
                    _playerClose pushback _x;
                };
            } foreach allPlayers;
            private _nearplayercount = count _playerClose;
            if (_nearplayercount > selectRandom [3,4]) then {_ChancesOfFireMortar = 1; _iRoundsToFire = 2};
            if (count _nearestMortars > 0 && speed _SpottedUnit < 1 && random 1 <= _ChancesOfFireMortar && _SpottedUnit distance _MainObjectivePos > 200) then {
                private _menNear = nearestObjects [player, ["Man"], 1250];
                private _bAllowMortar = true;
                private _SpotterFound = false;
                private _Spotter = nil;
                {
                    if ((([_SpottedUnit] call TRGM_GLOBAL_fnc_getRealPos) distance ([_x] call TRGM_GLOBAL_fnc_getRealPos)) < 55 && side _x isEqualTo TRGM_VAR_EnemySide) then {
                        _bAllowMortar = false; //enemy units are too close to spotted unit to call mortar
                    }
                    else {
                        if (!_SpotterFound && (([_SpottedUnit] call TRGM_GLOBAL_fnc_getRealPos) distance ([_x] call TRGM_GLOBAL_fnc_getRealPos)) > 55 && side _x isEqualTo TRGM_VAR_EnemySide) then {

                            private _cansee = [objNull, "VIEW"] checkVisibility [eyePos _x, eyePos _SpottedUnit];
                            sleep 0.6;
                            if (_cansee > 0.2) then {
                                sleep 3;
                                _SpotterFound = true;
                                _Spotter = _x;
                            };
                        };
                    };

                } forEach _menNear;
                if (_SpotterFound) then {
                    _Spotter call BIS_fnc_ambientAnim__terminate;
                    _Spotter playMoveNow "Acts_listeningToRadio_loop";
                    _Spotter disableAI "anim";
                    private _startPos = [_SpottedUnit] call TRGM_GLOBAL_fnc_getRealPos;

                    sleep 7;
                    if (alive(_Spotter)) then {
                        _Spotter enableAI "anim";
                        _Spotter playMoveNow "Acts_listeningToRadio_out";
                        private _endPos = [_SpottedUnit] call TRGM_GLOBAL_fnc_getRealPos;
                        private _dDistance = _startPos distance _endPos;

                        if (_dDistance < 7 && _bAllowMortar) then {
                            private _nearestMortar = _nearestMortars select 0;
                            private _Ammo = getArtilleryAmmo [_nearestMortar] select 0;
                            TRGM_VAR_bMortarFiring = true;
                            publicVariable "TRGM_VAR_bMortarFiring";
                            private _iFiredCount = 0;
                            while {_iFiredCount < _iRoundsToFire} do {
                                _iFiredCount = _iRoundsToFire + 1;
                                private _TargetPos = [(_SpottedUnitPos select 0)+(75 * sin floor(random 360)),(_SpottedUnitPos select 1)+(75 * cos floor(random 360))];
                                [_nearestMortar, [_TargetPos, _Ammo, 1]] remoteExec ["commandArtilleryFire", -2, false];
                                sleep 3;
                            };
                            TRGM_VAR_bMortarFiring = false;
                            publicVariable "TRGM_VAR_bMortarFiring";
                            _currentAODetail set [6,1];  //commence counting now fired... when reach zero again, we will wait until round fired again
                            _bFiredMortar = true;
                        };
                    };

                };

            };
            if (!_bFiredMortar) then {
                _currentAODetail set [6,0];  //reset to zero as nothing was fired this attempt
            };
        };

        if (!(vehicle _SpottedUnit isKindOf "Car") && !(vehicle _SpottedUnit isKindOf "Air") && _bAllowPatrolChange) then {

            if (TRGM_VAR_bBaseHasChopper && {!(isNil "TRGM_VAR_EnemyBaseChopperPilot") && {!(isNull TRGM_VAR_EnemyBaseChopperPilot)}}) then {

                while {(count (waypoints group TRGM_VAR_EnemyBaseChopperPilot)) > 0} do {
                    deleteWaypoint ((waypoints group TRGM_VAR_EnemyBaseChopperPilot) select 0);
                };
                //EnemyBaseChopper set waypoint to spotted location then AO then RTB
                //GETIN NEAREST
                //EnemyBaseChopperPilot
                private _EnemyBaseChopperWP0 = group TRGM_VAR_EnemyBaseChopperPilot addWaypoint [[TRGM_VAR_EnemyBaseChopperPilot] call TRGM_GLOBAL_fnc_getRealPos,0,1];
                _EnemyBaseChopperWP0 setWaypointType "GETIN NEAREST";
                _EnemyBaseChopperWP0 setWaypointSpeed "FULL";

                private _EnemyBaseChopperWP1 = group TRGM_VAR_EnemyBaseChopperPilot addWaypoint [[_SpottedUnit] call TRGM_GLOBAL_fnc_getRealPos,0,1];
                _EnemyBaseChopperWP1 setWaypointType "SENTRY";
                _EnemyBaseChopperWP1 setWaypointSpeed "LIMITED";
                _EnemyBaseChopperWP1 setWaypointBehaviour "AWARE";

                _EnemyBaseChopperWP1 = group TRGM_VAR_EnemyBaseChopperPilot addWaypoint [[_SpottedUnit] call TRGM_GLOBAL_fnc_getRealPos,0,1];
                _EnemyBaseChopperWP1 setWaypointType "MOVE";
                _EnemyBaseChopperWP1 setWaypointSpeed "LIMITED";
                _EnemyBaseChopperWP1 setWaypointBehaviour "AWARE";

                _EnemyBaseChopperWP1 = group TRGM_VAR_EnemyBaseChopperPilot addWaypoint [[TRGM_VAR_baseHeliPad] call TRGM_GLOBAL_fnc_getRealPos,0,2];
                _EnemyBaseChopperWP1 setWaypointType "MOVE";
                _EnemyBaseChopperWP1 setWaypointSpeed "FULL";
                _EnemyBaseChopperWP1 setWaypointStatements ["true", "(vehicle this) LAND 'LAND';"];
            };

            if  ((_SpottedUnitCount > 0)) then {
                private _nearestTLs = nearestObjects [_SpottedUnitPos, [(call sTeamleader),(call sTeamleaderMilitia)], _maxPatrolSearch];
                if (count _nearestTLs > 0) then {
                    private _nearestTL = _nearestTLs select 0;
                    while {(count (waypoints group _nearestTL)) > 0} do {
                        deleteWaypoint ((waypoints group _nearestTL) select 0);
                    };

                    group _nearestTL setCombatMode "RED";
                    group _nearestTL setFormation "WEDGE";
                    group _nearestTL setSpeedMode "FULL";
                    private _SpottedWP1a = group _nearestTL addWaypoint [getPos _nearestTL,0,0];
                        _SpottedWP1a setWaypointType "MOVE";
                    _SpottedWP1a setWaypointSpeed "FULL";
                    _SpottedWP1a setWaypointBehaviour "AWARE";
                    _SpottedWP1a setWaypointFormation "WEDGE";
                    private _SpottedWP1a2 = group _nearestTL addWaypoint [_SpottedUnitPos,0,1];
                    _SpottedWP1a2 setWaypointSpeed "FULL";
                    private _SpottedWP1b = group _nearestTL addWaypoint [_FirstPos,7,2];
                    _SpottedWP1b setWaypointType "CYCLE";
                    group _nearestTL setCombatMode "RED";
                    group _nearestTL setFormation "WEDGE";
                    group _nearestTL setSpeedMode "FULL";
                };

                if (random 1 < .50) then {
                    private _nearestTanks = nearestObjects [_SpottedUnitPos, [(call sTank1ArmedCar),(call sTank2APC),(call sTank3Tank),(call sTank1ArmedCarMilitia),(call sTank2APCMilitia),(call sTank3TankMilitia)], 3000];
                    if (count _nearestTanks > 0) then {
                        private _nearestTank = selectRandom _nearestTanks;
                        private _nearestTLTankwPosArray = waypoints group _nearestTank;

                        while {(count (waypoints group _nearestTank)) > 0} do {
                            deleteWaypoint ((waypoints group _nearestTank) select 0);
                        };
                        private _SpottedWP5a = group _nearestTank addWaypoint [_SpottedUnitPos,10];
                        _SpottedWP5a setWaypointType "SAD";
                        _SpottedWP5a setWaypointSpeed "FULL";
                        _SpottedWP5a setWaypointBehaviour "AWARE";
                    };
                };
            };
            private _anyTLsCheckAlive = nearestObjects [_SpottedUnitPos, [(call sTeamleader),(call sTeamleaderMilitia)], 3000];
            {
                if (!(alive _x)) then {
                    deleteVehicle _x;
                }
            } forEach _anyTLsCheckAlive;
        };
    };
};
