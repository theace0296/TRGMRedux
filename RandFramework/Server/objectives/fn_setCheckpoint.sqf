// private _fnc_scriptName = "TRGM_SERVER_fnc_setCheckpoint";
params [
    "_thisAOPos",
    "_thisPosAreaOfCheckpoint",
    ["_thisAreaRange", 100],
    ["_thisRoadonly", true],
    ["_thisside", east],
    ["_thisUnittypes", []],
    ["_thisAllowBarakade", false],
    ["_thisIsdirectionAwayfromAO", true],
    ["_thisIsCheckPoint", false], // only used to store possitions in our checkpointareas and sentryareas arrays
    ["_thisScoutvehicles", []],
    ["_thisAreaAroundCheckpointSpacing", 50],
    ["_AllowAnimation", true],
    ["_AllowVeh", true],
    ["_AllowTurrent", true],
    ["_isforceTents", false]
];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (isnil "_thisAOPos" || isnil "_thisPosAreaOfCheckpoint") exitwith {};

if (_thisUnittypes isEqualto []) then {
    _thisside = east;
    _thisUnittypes = [(call sRifleman), (call sRifleman), (call sRifleman), (call sMachineGunMan), (call sEngineer), (call sEngineer), (call sMedic), (call sAAMan)];
};

if (_thisScoutvehicles isEqualto []) then {
    _thisside = east;
    _thisScoutvehicles = (call UnarmedScoutvehicles);
};

private _startPos = _thisPosAreaOfCheckpoint;
private _nearestroads = _startPos nearRoads _thisAreaRange;

private _nearestroad = nil;
private _roadConnectedto = nil;

private _connectedRoad = nil;
private _direction = nil;

private _PosFound = false;
private _iAttemptLimit = 5;

if (_thisRoadonly) then {
    while {!_PosFound && _iAttemptLimit > 0 && count _nearestroads > 0} do {
        _nearestroad = selectRandom _nearestroads;
        _roadConnectedto = roadsConnectedto _nearestroad;
        if (count _roadConnectedto isEqualto 2) then {
            _connectedRoad = _roadConnectedto select 0;
            private _generaldirection = [_thisAOPos, _nearestroad] call BIS_fnc_Dirto;
            private _direction1 = [_nearestroad, _connectedRoad] call BIS_fnc_Dirto;
            private _direction2 = _direction1-180;
            if (_direction2 < 0) then {
                _direction2 = _direction2 + 360
            };
            _direction = 0;

            private _dif1 = 0;
            private _dif1A = _direction1 - _generaldirection;
            if (_dif1A < 0) then {
                _dif1A = _dif1A + 360
            };
            private _dif1B = _generaldirection - _direction1;
            if (_dif1B < 0) then {
                _dif1B = _dif1B + 360
            };
            if (_dif1A < _dif1B) then {
                _dif1 = _dif1A;
            } else {
                _dif1 = _dif1B;
            };

            private _dif2 = 0;
            private _dif2A = _direction2 - _generaldirection;
            if (_dif2A < 0) then {
                _dif2A = _dif2A + 360
            };
            private _dif2B = _generaldirection - _direction2;
            if (_dif2B < 0) then {
                _dif2B = _dif2B + 360
            };
            if (_dif2A < _dif2B) then {
                _dif2 = _dif2A;
            } else {
                _dif2 = _dif2B;
            };

            // [format["AOAwayDir:%1 - dir1:%2 - dir2:%3 \nDif1:%4 - dif2:%5", _generaldirection, _direction1, _direction2, _dif1, _dif2]] call TRGM_GLOBAL_fnc_notify;
            // sleep 5;

            if (_dif1 < _dif2) then {
                _direction = _direction1
            } else {
                _direction = _direction2
            };
            _PosFound = true;
        } else {
            // run loop again
            // ["too many roads"] call TRGM_GLOBAL_fnc_notify;

            _iAttemptLimit = _iAttemptLimit - 1;
        };
    };
};

if (!_thisRoadonly || !_PosFound) then {
    _thisRoadonly = false;
    _thisIsCheckPoint = false;
    private _generaldirection = [_thisAOPos, _thisPosAreaOfCheckpoint] call BIS_fnc_Dirto;
    private _diradd = 0;
    if (random 1 < .50) then {
        _diradd = floor(random 40);
    } else {
        _diradd = -floor(random 40);
    };
    _direction = ([_generaldirection, _diradd] call TRGM_GLOBAL_fnc_addtodirection);
    _PosFound = true;
    // [format["DIR:%1", _direction]] call TRGM_GLOBAL_fnc_notify;
    // sleep 3;
};

if (_PosFound) then {
    if (!_thisIsdirectionAwayfromAO) then {
        _direction = ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection);
    };
    private _RoadsideBarricadesHigh = ["land_Barricade_01_4m_F"];
    private _RoadsideBarricadesLow = ["land_BagFence_Long_F", "land_BagBunker_Small_F"];
    private _FullRoadBarricades = ["land_Barricade_01_10m_F"];
    private _DefensiveObjects = ["land_Barricade_01_4m_F", "land_BagFence_Long_F"];

    private _initItem = nil;
    private _BarriertoUse = "";

    private _iBarricadetype = selectRandom ["HIGH", "FULL", "LOW", "LOW"];

    private _roadBlockPos = nil;
    private _roadBlocksidePos = nil;

    private _NoroadsorBuildingsNear = false;

    if (_thisRoadonly) then {
        _roadBlockPos = getPos _nearestroad;
        _roadBlocksidePos = _nearestroad getPos [10, ([_direction, 90] call TRGM_GLOBAL_fnc_addtodirection)];
    } else {
        private _flatPos = [_thisPosAreaOfCheckpoint, 0, 50, 20, 0, 0.2, 0, [], [_thisPosAreaOfCheckpoint, _thisPosAreaOfCheckpoint]] call TRGM_GLOBAL_fnc_findSafePos;
        _roadBlockPos = _flatPos;
        _roadBlocksidePos = _flatPos;
        private _allRoadsNear = _flatPos nearRoads 500;
        private _nearestHousecount = count(nearestobjects [_flatPos, ["building"], 400]);
        if (count _allRoadsNear isEqualto 0 && _nearestHousecount isEqualto 0) then {
            _NoroadsorBuildingsNear = true;
        };
    };

    if ({
        _x distance _roadBlockPos < 250 && side _x != _thisside
    } count allunits > 0) exitwith {
        false;
    };

    if (_thisIsCheckPoint && _thisside isEqualto TRGM_VAR_Enemyside) then {
        // TRGM_VAR_CheckPointAreas
        TRGM_VAR_CheckPointAreas = TRGM_VAR_CheckPointAreas + [[_roadBlockPos, _thisAreaAroundCheckpointSpacing]];
        // the, _thisAreaAroundCheckpointSpacing is for when we use TRGM_GLOBAL_fnc_findSafePos to make sure no other road block is within 100 meters
        publicVariable "TRGM_VAR_CheckPointAreas";
    } else {
        if (_thisside isEqualto TRGM_VAR_Enemyside) then {
            // TRGM_VAR_SentryAreas
            TRGM_VAR_SentryAreas = TRGM_VAR_SentryAreas + [[_roadBlockPos, _thisAreaAroundCheckpointSpacing]];
            publicVariable "TRGM_VAR_SentryAreas"
        };
    };

    if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
        TRGM_VAR_friendlySentryCheckpointPos = TRGM_VAR_friendlySentryCheckpointPos + [_roadBlockPos];
        publicVariable "TRGM_VAR_friendlySentryCheckpointPos";
    };

    private _slope = abs(((getTerrainHeightASL _roadBlocksidePos)) - ((getTerrainHeightASL _roadBlockPos)));
    if (_slope > 0.6) then {
        _iBarricadetype = "FULL";
        // if slope too much, then bunker and other barricades on side of road will have gap on one side
    };

    private _nearestHouseObjectDist = (nearestobject [_roadBlocksidePos, "building"]) distance _roadBlocksidePos;
    // _nearestWallObjectDist = (nearestobject [_roadBlocksidePos, "wall"]) distance _roadBlocksidePos;
    // [format["nearestWallObjectDist: %1", _nearestHouseObjectDist]] call TRGM_GLOBAL_fnc_notify;
    // sleep 2;
    if (_nearestHouseObjectDist < 10) then {
        _iBarricadetype = "FULL";
        // if slope too much, then bunker and other barricades on side of road will have gap on one side
    };
    if (_NoroadsorBuildingsNear) then {
        _iBarricadetype = "LOW";
    };
    if (!_thisAllowBarakade) then {
        _iBarricadetype = "NONE";
    };

    if (_iBarricadetype isEqualto "HIGH") then {
        _initItem = selectRandom _RoadsideBarricadesHigh createvehicle _roadBlocksidePos;
        _initItem setDir ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection);
    };
    if (_iBarricadetype isEqualto "FULL") then {
        _initItem = selectRandom _FullRoadBarricades createvehicle _roadBlockPos;
        _initItem setDir ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection);
    };
    if (_iBarricadetype isEqualto "LOW") then {
        _initItem = selectRandom _RoadsideBarricadesLow createvehicle _roadBlocksidePos;
        _initItem setDir ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection);

        if (_thisside isEqualto TRGM_VAR_Enemyside && _AllowTurrent) then {
            _NearTurret1 = createvehicle [selectRandom (call CheckPointTurret), _initItem getPos [1, _direction+180], [], 0, "CAN_COLLIDE"];
            _NearTurret1 setDir (_direction);
            [_thisside, _NearTurret1] call TRGM_GLOBAL_fnc_createvehiclecrew;
        };
    };
    if (_iBarricadetype isEqualto "NONE") then {
        // if none, then either use flag or defensive object
        // flagCarrierTakistan_EP1, flagCarrierTKMilitia_EP1
        if (!(isOnRoad _roadBlocksidePos) && random 1 < .50) then {
            _initItem = selectRandom _DefensiveObjects createvehicle _roadBlocksidePos;
            _initItem setDir ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection);
        } else {
            _initItem = "land_HelipadEmpty_F" createvehicle _roadBlocksidePos;
            _initItem setDir ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection);
        };
    };
    if (!TRGM_VAR_ISUNSUNG) then {
        if (_iBarricadetype != "NONE" && random 1 < .50) then {
            [_initItem, _thisside] spawn {
                private _initItem = _this select 0;
                private _thisside = _this select 1;
                while {alive(_initItem)} do {
                    private _soundtoPlay = selectRandom TRGM_VAR_EnemyradioSounds;
                    if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
                        _soundtoPlay = selectRandom TRGM_VAR_FriendlyradioSounds
                    };
                    playSound3D ["A3\Sounds_F\sfx\radio\" + _soundtoPlay + ".wss", _initItem, false, getPosASL _initItem, 0.5, 1, 0];
                    sleep selectRandom [10, 15, 20, 30];
                };
            };
        };
    };

    private _bHasParkedCar = false;
    private _ParkedCar = nil;
    if (_AllowVeh && (random 1 < .75 || _thisside isEqualto TRGM_VAR_Friendlyside)) then {
        private _behindBlockPos = _initItem getPos [10, ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection)];
        private _flatPos = [_behindBlockPos, 0, 10, 10, 0, 0.5, 0, [], [_behindBlockPos, _behindBlockPos], selectRandom _thisScoutvehicles] call TRGM_GLOBAL_fnc_findSafePos;
        private _ParkedCar = selectRandom _thisScoutvehicles createvehicle _flatPos;
        _ParkedCar setDir (floor(random 360));
        sleep 0.1;
        if (damage _ParkedCar > 0) then {
            _bHasParkedCar = false;
            deletevehicle _ParkedCar;
        };
        _bHasParkedCar = true;
    };
    if (_NoroadsorBuildingsNear) then {
        if (random 1 < .75 || _isforceTents) then {
            private _behindBlockPos = _initItem getPos [15, ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection)];
            private _flatPos = [_behindBlockPos, 0, 15, 10, 0, 0.5, 0, [], [_behindBlockPos, _behindBlockPos], "land_TentA_F"] call TRGM_GLOBAL_fnc_findSafePos;
            private _Tent1 = "land_TentA_F" createvehicle _flatPos;
            _Tent1 setDir (floor(random 360));

            private _flatPos2 = [([_Tent1] call TRGM_GLOBAL_fnc_getRealPos), 0, 10, 10, 0, 0.5, 0, [], [_behindBlockPos, _behindBlockPos], "land_TentA_F"] call TRGM_GLOBAL_fnc_findSafePos;
            private _Tent2 = "land_TentA_F" createvehicle _flatPos2;
            _Tent2 setDir (floor(random 360));

            private _flatPos3 = [([_Tent1] call TRGM_GLOBAL_fnc_getRealPos), 0, 10, 10, 0, 0.5, 0, [], [_behindBlockPos, _behindBlockPos], "Campfire_burning_F"] call TRGM_GLOBAL_fnc_findSafePos;
            private _Tent3 = "Campfire_burning_F" createvehicle _flatPos2;
            _Tent3 setDir (floor(random 360));

            private _flatPos4 = [([_Tent1] call TRGM_GLOBAL_fnc_getRealPos), 0, 10, 10, 0, 0.5, 0, [], [_behindBlockPos, _behindBlockPos], "land_Woodpile_F"] call TRGM_GLOBAL_fnc_findSafePos;
            private _Tent4 = "land_Woodpile_F" createvehicle _flatPos2;
            _Tent4 setDir (floor(random 360));
        }
    };
    private _behindBlockPos2 = _initItem getPos [3, ([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection)];
    if (random 1 < .75) then {
        private _flatPos = [_behindBlockPos2, 0, 5, 7, 0, 0.5, 0, [], [_behindBlockPos2, _behindBlockPos2], "land_PortableLight_single_F"] call TRGM_GLOBAL_fnc_findSafePos;
        private _FloodLight = "land_PortableLight_single_F" createvehicle _flatPos;
        _FloodLight setDir (([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection));
    };
    // land_PortableLight_single_F

    if (TRGM_VAR_ISUNSUNG) then {
        if (random 1 < .66) then {
            private _flatPos = [_behindBlockPos2, 0, 5, 7, 0, 0.5, 0, [], [_behindBlockPos2, _behindBlockPos2]] call TRGM_GLOBAL_fnc_findSafePos;
            private _radio = nil;
            if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
                _radio = selectRandom ["uns_radio2_radio", "uns_radio2_transitor", "uns_radio2_transitor02"] createvehicle _flatPos;
            } else {
                _radio = selectRandom ["uns_radio2_transitor_NVA", "uns_radio2_transitor_NVA", "uns_radio2_nva_radio", "uns_radio2_recorder"] createvehicle _flatPos;
            };
            _radio setDir (([_direction, 180] call TRGM_GLOBAL_fnc_addtodirection));
        };
    };

    // _pos1 = _initItem getPos [3, 100];
    private _pos1 = _initItem getPos [3, ([_direction, 100] call TRGM_GLOBAL_fnc_addtodirection)];

    private _pos2 = _initItem getPos [4, ([_direction, 80] call TRGM_GLOBAL_fnc_addtodirection)];
    private _group = creategroup _thisside;
    _group setFormDir _direction;

    private _sUnittype = selectRandom _thisUnittypes;
    private _guardUnit1 = [_group, _sUnittype, _pos1, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
    if (isNil "_guardUnit1" || {isNull _guardUnit1}) then {
        private _iterations = 0;
        while {(isNil "_guardUnit1" || {isNull _guardUnit1}) && {_iterations < 10}} do {
            _guardUnit1 = [_group, _sUnittype, _pos1, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _iterations = _iterations + 1;
        };
    };
    if (!(isNil "_guardUnit1") && {!(isNull _guardUnit1)}) then {
        if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
            [_guardUnit1] call TRGM_GLOBAL_fnc_makeNPC;
        };
        dostop [_guardUnit1];
        _guardUnit1 setDir (_direction);
        if (_AllowAnimation) then {
            [_guardUnit1, "WATCH", "ASIS"] call BIS_fnc_ambientAnimCombat;
        };
    };

    if (random 1 < .66) then {
        _sUnittype = selectRandom _thisUnittypes;
        private _guardUnit2 = [_group, _sUnittype, _pos2, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
        if (isNil "_guardUnit2" || {isNull _guardUnit2}) then {
            private _iterations = 0;
            while {(isNil "_guardUnit2" || {isNull _guardUnit2}) && {_iterations < 10}} do {
                _guardUnit2 = [_group, _sUnittype,_pos2,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                _iterations = _iterations + 1;
            };
        };
        if (!(isNil "_guardUnit2") && {!(isNull _guardUnit2)}) then {
            if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
                [_guardUnit2] call TRGM_GLOBAL_fnc_makeNPC;
            };
            [_guardUnit2] call TRGM_GLOBAL_fnc_makeNPC;
            dostop [_guardUnit2];
            _guardUnit2 setDir (_direction);
        };
    } else {
        private _pos3 = [_behindBlockPos2, 0, 10, 10, 0, 0.5, 0, [], [_behindBlockPos2, _behindBlockPos2]] call TRGM_GLOBAL_fnc_findSafePos;
        private _pos4 = [_behindBlockPos2, 0, 10, 10, 0, 0.5, 0, [], [_behindBlockPos2, _behindBlockPos2]] call TRGM_GLOBAL_fnc_findSafePos;

        private _chatDir1 = [_pos3, _pos4] call BIS_fnc_Dirto;
        private _chatDir2 = [_pos4, _pos3] call BIS_fnc_Dirto;

        private _group2 = creategroup _thisside;
        _group2 setFormDir _chatDir1;
        private _group3 = creategroup _thisside;
        _group3 setFormDir _chatDir2;

        private _sUnittype = selectRandom _thisUnittypes;
        private _guardUnit3 = [_group2, _sUnittype, _pos3, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
        if (isNil "_guardUnit3" || {isNull _guardUnit3}) then {
            private _iterations = 0;
            while {(isNil "_guardUnit3" || {isNull _guardUnit3}) && {_iterations < 10}} do {
                _guardUnit3 = [_group2, _sUnittype, _pos3, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                _iterations = _iterations + 1;
            };
        };
        if (!(isNil "_guardUnit3") && {!(isNull _guardUnit3)}) then {
            if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
                [_guardUnit3] call TRGM_GLOBAL_fnc_makeNPC;
            };
            dostop [_guardUnit3];
            _guardUnit3 setDir (_chatDir1);
        };

        _sUnittype = selectRandom _thisUnittypes;
        private _guardUnit4 = [_group3, _sUnittype, _pos4, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
        if (isNil "_guardUnit4" || {isNull _guardUnit4}) then {
            private _iterations = 0;
            while {(isNil "_guardUnit4" || {isNull _guardUnit4}) && {_iterations < 10}} do {
                _guardUnit4 = [_group3, _sUnittype, _pos4, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                _iterations = _iterations + 1;
            };
        };
        if (!(isNil "_guardUnit4") && {!(isNull _guardUnit4)}) then {
            if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
                [_guardUnit4] call TRGM_GLOBAL_fnc_makeNPC;
            };
            dostop [_guardUnit4];
            _guardUnit4 setDir (_chatDir2);

            // [_guardUnit3, "Stand", "ASIS"] call BIS_fnc_ambientAnimCombat;

            if (_AllowAnimation) then {
                if (!_bHasParkedCar) then {
                    [_guardUnit4, "Stand_IA", "ASIS"] call BIS_fnc_ambientAnimCombat;
                } else {
                    if !(isNil "_ParkedCar") then {
                        private _Leandir = ([direction _ParkedCar, 45] call TRGM_GLOBAL_fnc_addtodirection);
                        _group3 setFormDir _Leandir;
                        dostop [_guardUnit4];
                        _guardUnit4 setDir (_Leandir);
                        sleep 0.1;
                        private _LeanPos = _ParkedCar getPos [1, _Leandir];
                        sleep 0.1;
                        _guardUnit4 setPos _LeanPos;
                        sleep 0.1;
                        [_guardUnit4, "LEAN", "ASIS"] call BIS_fnc_ambientAnimCombat;
                    };
                };
            };
        };
    };

    private _group4 = creategroup _thisside;
    private _sCheckpointguyname = format["objCheckpointguyname%1", (floor(random 999999))];

    private _pos5 = [_behindBlockPos2, 0, 10, 10, 0, 0.5, 0, [], [_behindBlockPos2, _behindBlockPos2], _sUnittype] call TRGM_GLOBAL_fnc_findSafePos;

    private _guardUnit5 = [_group4, _sUnittype, _pos5, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
    if (isNil "_guardUnit5" || {isNull _guardUnit5}) then {
        private _iterations = 0;
        while {(isNil "_guardUnit5" || {isNull _guardUnit5}) && {_iterations < 10}} do {
            _guardUnit5 = [_group4, _sUnittype, _pos5, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _iterations = _iterations + 1;
        };
    };
    if (!(isNil "_guardUnit5") && {!(isNull _guardUnit5)}) then {
        if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
            [_guardUnit5] call TRGM_GLOBAL_fnc_makeNPC;
        };
        _guardUnit5 setVariable [_sCheckpointguyname, _guardUnit5, true];
        missionnamespace setVariable [_sCheckpointguyname, _guardUnit5];
        if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
            private _isHiddenObj = false;
            private _mainAOPos = TRGM_VAR_ObjectivePositions select 0;
            if !(isNil "_mainAOPos") then {
                if (_mainAOPos in TRGM_VAR_HiddenPossitions) then {
                    _isHiddenObj = true;
                };
            };

            if (!_isHiddenObj) then {
                private _checkPointname = (format [localize "str_TRGM2_setCheckpoint_markertextformat", ([count TRGM_VAR_friendlySentryCheckpointPos] call TRGM_GETTER_fnc_sGetPhoneticname)]);
                [_guardUnit5, [localize "str_TRGM2_setCheckpoint_Ask", {
                    _this spawn TRGM_SERVER_fnc_speaktoFriendlyCheckpoint;
                }, [_pos5, _checkPointname], 0, true, true, "", "_this isEqualto player && alive _target"]] remoteExec ["addAction", 0, true];
                if (_thisside isEqualto TRGM_VAR_Friendlyside) then {
                    private _markername = _checkPointname;
                    if (call TRGM_GETTER_fnc_bCheckpointRespawnEnabled) then {
                        _markername = format ["respawn_west_%1", _checkPointname];
                    };
                    private _test = createMarker [_markername, _roadBlockPos];
                    _test setMarkerShape "ICON";
                    _test setMarkertype "b_inf";
                    _test setMarkertext _checkPointname;
                };
            };
        };
        TRGM_local_fnc_walkingGuyLoop = {
            private _objManname = _this select 0;
            private _thisinitPos = _this select 1;
            private _thisside = _this select 2;
            private _objMan = missionnamespace getVariable _objManname;

            group _objMan setspeedMode "LIMITED";
            if !(_thisside isEqualto TRGM_VAR_Friendlyside) then {
                group _objMan setBehaviour "SAFE";
            };

            while {
                alive(_objMan) && {
                    behaviour _objMan isEqualto "SAFE"
                }
            } do {
                [_objManname, _thisinitPos, _objMan, 35] spawn TRGM_SERVER_fnc_hvtWalkAround;
                sleep 2;
                waitUntil {
                    sleep 1;
                    speed _objMan < 0.5
                };
                sleep 10;
            };
        };
        [_sCheckpointguyname, _pos5, _thisside] spawn TRGM_local_fnc_walkingGuyLoop;
    };
};

true;