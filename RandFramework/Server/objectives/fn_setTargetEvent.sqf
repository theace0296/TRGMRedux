// private _fnc_scriptName = "TRGM_SERVER_fnc_setTargetEvent";
params ["_posOfAO",["_roadRange",2000],["_showMarker",false],["_forceTrap",false],["_objTarget",nil],["_isCache",false],["_isMainTask",false]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer || isNil "_posOfAO") exitWith {};

["Loading Events : Target Event", true] call TRGM_GLOBAL_fnc_log;

call TRGM_SERVER_fnc_initMissionVars;

private _ieds = CivCars;
private _objectiveCreated = false;
private _nearestRoads = _posOfAO nearRoads _roadRange;

if (!_isCache && count _nearestRoads > 0) then {
    private _eventLocationPos = [0,0,0];
    private _eventPosFound = false;
    private _iAttemptLimit = 15;
    while {!_eventPosFound && _iAttemptLimit > 0} do {
        _iAttemptLimit = _iAttemptLimit - 1;
        _eventLocationPos = getPos (selectRandom _nearestRoads);
        private _farEnoughFromAo = _eventLocationPos distance _posOfAO > 500;
        private _farEnoughFromWarzone = true;
        if (!isNil "TRGM_VAR_WarzonePos") then {_farEnoughFromWarzone = (_eventLocationPos distance TRGM_VAR_WarzonePos > 500)};
        if (_isMainTask || (_farEnoughFromWarzone && _farEnoughFromAo)) then {_eventPosFound = true;};
    };
    if (!_eventPosFound) then {
        _eventLocationPos = getPos (selectRandom _nearestRoads);
    };

    if (_eventLocationPos select 0 > 0) then {
        private _thisAreaRange = 50;
        private _nearestRoads = _eventLocationPos nearRoads _thisAreaRange;

        private _nearestRoad = nil;
        private _roadConnectedTo = nil;
        private _connectedRoad = nil;
        private _direction = nil;
        private _PosFound = false;
        private _iAttemptLimit = 5;

        while {!_PosFound && _iAttemptLimit > 0 && count _nearestRoads > 0} do {
            _nearestRoad = selectRandom _nearestRoads;
            _roadConnectedTo = roadsConnectedTo _nearestRoad;
            if (count _roadConnectedTo > 0) then {
                _connectedRoad = _roadConnectedTo select 0;
                _direction = [_nearestRoad, _connectedRoad] call BIS_fnc_DirTo;
                _PosFound = true;
            } else {
                _iAttemptLimit = _iAttemptLimit - 1;
            };
        };

        if (_PosFound) then {
            _objectiveCreated = true;

            private _roadBlockPos =  getPos _nearestRoad;
            private _roadBlockSidePos = _nearestRoad getPos [3, ([_direction,90] call TRGM_GLOBAL_fnc_addToDirection)];
            private _mainVeh = nil;
            if (isNil "_objTarget") then {
                _mainVeh = createVehicle [selectRandom TargetVehicles,_roadBlockSidePos,[],50,"NONE"];
            } else {
                _mainVeh = _objTarget;
                _mainVeh setPos _roadBlockSidePos;
            };

            private _mainVehDirection =  ([_direction,(selectRandom[0,-10,10])] call TRGM_GLOBAL_fnc_addToDirection);
            _mainVeh setDir _mainVehDirection;
            clearItemCargoGlobal _mainVeh;

            //if not within 200 of main AO, then have patrol, and guards, if over 1k, then chance of checkpoint to
            if (_posOfAO distance ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos) > 150 ) then {
                if (_showMarker) then {
                    //here, make circle, and random
                    private _centerPos = _mainVeh getPos [ (random 150) , (random 360) ];
                    private _markerstrcacheZone = createMarker [format ["IEDLocZone%1",_centerPos select 0],_centerPos];
                    _markerstrcacheZone setMarkerShape "ELLIPSE";
                    _markerstrcacheZone setMarkerBrush "DIAGGRID";
                    _markerstrcacheZone setMarkerColor "ColorYellow";
                    _markerstrcacheZone setMarkerSize [150, 150];

                    // private _markerstrcache = createMarker [format ["IEDLoc%1",_centerPos select 0],_centerPos];
                    // _markerstrcache setMarkerShape "ICON";
                    // _markerstrcache setMarkerText localize "STR_TRGM2_TargetMarkerText";
                    // _markerstrcache setMarkerType "hd_dot";
                };

                private _posOfTarget = [_mainVeh] call TRGM_GLOBAL_fnc_getRealPos;

                if (random 1 < .33) then {
                    [_posOfTarget] spawn TRGM_SERVER_fnc_createEnemySniper;
                };

                private _spawnedUnitTarget1 = [((createGroup [TRGM_VAR_EnemySide, true])), (call sRiflemanToUse), _posOfTarget, [], 10, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                private _directionTarget1 = [_mainVeh,_spawnedUnitTarget1] call BIS_fnc_DirTo;
                _spawnedUnitTarget1 setDir _directionTarget1;
                _spawnedUnitTarget1 setFormDir _directionTarget1;

                private _spawnedUnitTarget2 = [((createGroup [TRGM_VAR_EnemySide, true])), (call sRiflemanToUse), _posOfTarget, [], 10, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                private _directionTarget2 = [_mainVeh,_spawnedUnitTarget2] call BIS_fnc_DirTo;
                _spawnedUnitTarget2 setDir _directionTarget2;
                _spawnedUnitTarget2 setFormDir _directionTarget2;

                private _thisAreaRange = 20;
                private _flatPos = [_posOfTarget , 0, 20, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_posOfTarget,_posOfTarget]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _posOfTarget) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = true;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = true;
                    private _thisIsDirectionAwayFromAO = true;
                    [_posOfTarget,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100,true,random 1 < .33,false] spawn TRGM_SERVER_fnc_setCheckpoint;
                };
            };
        };
    };
};

if (_isCache) then {

    private _buildings = nearestObjects [_posOfAO, TRGM_VAR_BasicBuildings, _roadRange];
    private _infBuilding = selectRandom _buildings;
    private _eventPosFound = false;
    private _iAttemptLimit = 15;
    while {!_eventPosFound && _iAttemptLimit > 0} do {
        _iAttemptLimit = _iAttemptLimit - 1;
        _infBuilding = selectRandom _buildings;
        private _eventLocationPos = getPos _infBuilding;
        private _farEnoughFromAo = _eventLocationPos distance _posOfAO > 500;
        private _farEnoughFromWarzone = true;
        if (!isNil "TRGM_VAR_WarzonePos") then {_farEnoughFromWarzone = (_eventLocationPos distance TRGM_VAR_WarzonePos > 500)};
        if (_isMainTask || (_farEnoughFromWarzone && _farEnoughFromAo)) then {_eventPosFound = true;};
    };
    if (!_eventPosFound) then {
        _infBuilding = selectRandom _buildings;
    };
    _infBuilding setDamage 0;
    private _allBuildingPos = _infBuilding buildingPos -1;
    private _inf1X = position _infBuilding select 0;
    private _inf1Y = position _infBuilding select 1;

    if (count _allBuildingPos > 2) then {
        _objectiveCreated = true;
        private _mainVeh = nil;
        if (isNil "_objTarget") then {
            _mainVeh = createVehicle [selectRandom TargetCaches,[0,0,500],[],0,"NONE"];
        } else {
            _mainVeh = _objTarget;
        };
        _mainVeh setPosATL (selectRandom _allBuildingPos);

        private _posCache = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);

        if (_showMarker) then {
            private _markerstrcache = createMarker [format ["IEDLoc%1",_posCache select 0],_posCache];
            _markerstrcache setMarkerShape "ICON";
            _markerstrcache setMarkerText localize "STR_TRGM2_TargetMarkerText";
            _markerstrcache setMarkerType "hd_dot";
        };

        if (random 1 < .33) then {
            [_posCache] spawn TRGM_SERVER_fnc_createEnemySniper;
        };

        private _thisAreaRange = 20;
        private _flatPos = [_posCache , 0, 20, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_posCache,_posCache]] call TRGM_GLOBAL_fnc_findSafePos;
        if !(_flatPos isEqualTo _posCache) then {
            private _thisPosAreaOfCheckpoint = _flatPos;
            private _thisRoadOnly = false;
            private _thisSide = TRGM_VAR_EnemySide;
            private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
            private _thisAllowBarakade = false;
            private _thisIsDirectionAwayFromAO = false;
            [_posCache,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100,true,random 1 < .33,false] spawn TRGM_SERVER_fnc_setCheckpoint;
        };

        //two guards at door!!!
        private _building = (nearestBuilding _posCache);
        if !(isNil "_building") then {
            private _spawnedUnit = [((createGroup [TRGM_VAR_EnemySide, true])), (call sRiflemanToUse), [-135,-253,0], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _spawnedUnit setpos (_building buildingExit 0);

            private _direction = [_building,_spawnedUnit] call BIS_fnc_DirTo;
            _spawnedUnit setDir _direction;
            _spawnedUnit setFormDir _direction;

            private _i = 1;
            private _minDis = 7;
            private _doLoop = true;
            private _checkedPositions = [];
            while {_doLoop && _i < 20} do
            {
                private _newPos = (_building buildingExit _i);
                private _allowed = true;
                {
                    if !(_x distance _newPos > _minDis) then {
                        _allowed = false;
                    };
                } forEach _checkedPositions;
                _checkedPositions pushBack _newPos;
                if (_allowed) then {
                    //_doLoop = false;
                    private _spawnedUnit2 = [((createGroup [TRGM_VAR_EnemySide, true])), (call sRiflemanToUse), _newPos, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    private _direction2 = [_building,_spawnedUnit2] call BIS_fnc_DirTo;
                    _spawnedUnit2 setDir _direction2;
                    _spawnedUnit2 setFormDir _direction2;
                };
                _i = _i + 1;
            };

            private _spawnedUnit3 = [((createGroup [TRGM_VAR_EnemySide, true])), (call sRiflemanToUse), [-135,-253,0], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
            [getPos _building, [_spawnedUnit3], -1, false, false,false] spawn TRGM_SERVER_fnc_zenOccupyHouse;

            if (random 1 < .50) then {
                private _spawnedUnit4 = [((createGroup [TRGM_VAR_EnemySide, true])), (call sRiflemanToUse), [-135,-253,0], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                [getPos _building, [_spawnedUnit4], -1, false, false,false] spawn TRGM_SERVER_fnc_zenOccupyHouse;
            };
        };
    } else {
        _objectiveCreated = false;
    };
};

if (!_objectiveCreated) then {
    private _flatPosPolice1 = nil;
    if (_isMainTask) then {
        _flatPosPolice1 = [_posOfAO , 20, 400, 10, 0, 0.5, 0,[],[_posOfAO,_posOfAO]] call TRGM_GLOBAL_fnc_findSafePos;
    } else {
        private _eventPosFound = false;
        private _iAttemptLimit = 15;
        while {!_eventPosFound && _iAttemptLimit > 0} do {
            _iAttemptLimit = _iAttemptLimit - 1;
            _flatPosPolice1 = [_posOfAO , 500, 1500, 10, 0, 0.5, 0,[],[_posOfAO,_posOfAO]] call TRGM_GLOBAL_fnc_findSafePos;
            private _farEnoughFromWarzone = true;
            if (!isNil "TRGM_VAR_WarzonePos") then {_farEnoughFromWarzone = (_flatPosPolice1 distance TRGM_VAR_WarzonePos > 500)};
            if (_isMainTask || _farEnoughFromWarzone) then {_eventPosFound = true;};
        };
        if (!_eventPosFound) then {
            _flatPosPolice1 = [_posOfAO , 500, 1500, 10, 0, 0.5, 0,[],[_posOfAO,_posOfAO]] call TRGM_GLOBAL_fnc_findSafePos;
        };
    };

    private _mainVeh = nil;
    if (isNil "_objTarget") then {
        _mainVeh = createVehicle [selectRandom TargetCaches,_flatPosPolice1,[],50,"NONE"];
    } else {
        _objTarget setPos _flatPosPolice1;
        _mainVeh = _objTarget;
    };

    private _posObj = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
    if (_posOfAO distance ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos) > 150 ) then {
        //if we failed the above trying to find a pos, then if we place in random place, just show marker
        private _markerstrcache = createMarker [format ["IEDLoc%1",_posObj select 0],_posObj];
        _markerstrcache setMarkerShape "ICON";
        _markerstrcache setMarkerText localize "STR_TRGM2_TargetMarkerText";
        _markerstrcache setMarkerType "hd_dot";
    };

    private _thisAreaRange = 20;
    private _flatPos = [_posObj , 0, 20, 5, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_posObj,_posObj]] call TRGM_GLOBAL_fnc_findSafePos;
    if !(_flatPos isEqualTo _posObj) then {
        private _thisPosAreaOfCheckpoint = _flatPos;
        private _thisRoadOnly = false;
        private _thisSide = TRGM_VAR_EnemySide;
        private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
        private _thisAllowBarakade = true;
        private _thisIsDirectionAwayFromAO = true;
        [_posObj,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100,true,random 1 < .33,false,true] spawn TRGM_SERVER_fnc_setCheckpoint;
    };

    if (random 1 < .33) then {
        [_posObj] spawn TRGM_SERVER_fnc_createEnemySniper;
    };

    private _spawnedUnitTarget1 = [((createGroup [TRGM_VAR_EnemySide, true])), (call sRiflemanToUse), _posObj, [], 10, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
    private _directionTarget1 = [_mainVeh,_spawnedUnitTarget1] call BIS_fnc_DirTo;
    _spawnedUnitTarget1 setDir _directionTarget1;
    _spawnedUnitTarget1 setFormDir _directionTarget1;

    private _spawnedUnitTarget2 = [((createGroup [TRGM_VAR_EnemySide, true])), (call sRiflemanToUse), _posObj, [], 10, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
    private _directionTarget2 = [_mainVeh,_spawnedUnitTarget2] call BIS_fnc_DirTo;
    _spawnedUnitTarget2 setDir _directionTarget2;
    _spawnedUnitTarget2 setFormDir _directionTarget2;

    private _NoRoadsOrBuildingsNear = false;
    private _nearestHouseCount = count(nearestObjects [_posObj, ["building"],400]);
    if (_nearestHouseCount isEqualTo 0) then {_NoRoadsOrBuildingsNear = true;};

    if (_NoRoadsOrBuildingsNear) then {
        private _centerPos = _mainVeh getPos [ (random 150) , (random 360) ];
        private _markerstrcacheZone = createMarker [format ["IEDLocZone%1",_centerPos select 0],_centerPos];
        _markerstrcacheZone setMarkerShape "ELLIPSE";
        _markerstrcacheZone setMarkerBrush "DIAGGRID";
        _markerstrcacheZone setMarkerColor "ColorYellow";
        _markerstrcacheZone setMarkerSize [150, 150];
    };
};

true;