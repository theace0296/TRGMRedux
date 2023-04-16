// private _fnc_scriptName = "TRGM_SERVER_fnc_setIEDEvent";
params ["_posOfAO",["_roadRange",2000],["_showMarker",false],["_forceTrap",false],["_objIED",nil],["_IEDType",nil],["_isFullMap",false]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer || isNil "_posOfAO") exitWith {};

if (_isFullMap) then {
    ["Loading Full Map Events : IED Event", true] call TRGM_GLOBAL_fnc_log;
} else {
    ["Loading Events : IED Event", true] call TRGM_GLOBAL_fnc_log;
};

if (isNil "_IEDType") then {
    _IEDType = selectRandom ["CAR","CAR","RUBBLE"];
};
private _ieds = nil;
If (_IEDType isEqualTo "CAR") then {_ieds = CivCars;};
If (_IEDType isEqualTo "RUBBLE") then {_ieds = TRGM_VAR_IEDFakeClassNames;};

private _nearestRoads = _posOfAO nearRoads _roadRange;
if (_isFullMap && _roadRange isEqualTo 2000) then {
    _nearestRoads = _posOfAO nearRoads 30000;
};

if !(count _nearestRoads > 0) exitWith {};

private _eventLocationPos = [0,0,0]; //getPos (selectRandom _nearestRoads);
private _eventPosFound = false;
private _iAttemptLimit = 5;
if (!isNil "TRGM_VAR_WarzonePos") then {
    waitUntil {
        _eventLocationPos = getPos (selectRandom _nearestRoads);
        if (_eventLocationPos distance TRGM_VAR_WarzonePos > 500) then {_eventPosFound = true;};
        _iAttemptLimit = _iAttemptLimit - 1;
        sleep 1;
        _eventPosFound || _iAttemptLimit <= 0;
    };
} else {
    _eventLocationPos = getPos (selectRandom _nearestRoads);
};

if (_eventLocationPos select 0 > 0) then {

    private _bIsTrap = random 1 < .33;
    if (_forceTrap) then {
        _bIsTrap = true;
    };

    private _bHasHidingAmbush = false;
    private _thisAreaRange = 50;
    private _nearestRoads = _eventLocationPos nearRoads _thisAreaRange;

    private _nearestRoad = nil;
    private _roadConnectedTo = nil;
    private _connectedRoad = nil;
    private _direction = nil;
    private _PosFound = false;
    private _iAttemptLimit = 5;

    waitUntil {
        _nearestRoad = selectRandom _nearestRoads;
        _roadConnectedTo = roadsConnectedTo _nearestRoad;
        if (count _roadConnectedTo > 0) then {
            _connectedRoad = _roadConnectedTo select 0;
            _direction = [_nearestRoad, _connectedRoad] call BIS_fnc_DirTo;
            _PosFound = true;
        } else {
            _iAttemptLimit = _iAttemptLimit - 1;
        };
        sleep 1;
        _PosFound || _iAttemptLimit <= 0 || count _nearestRoads <= 0;
    };
    if (_PosFound) then {
        private _roadBlockPos =  getPos _nearestRoad;
        private _roadBlockSidePos = _nearestRoad getPos [3, ([_direction,90] call TRGM_GLOBAL_fnc_addToDirection)];

        private _mainVeh = nil;
        if (isNil "_objIED") then {
            _mainVeh = createVehicle [selectRandom _ieds,_roadBlockSidePos,[],0,"NONE"];
        } else {
            _mainVeh = _objIED;
            _mainVeh setPos _roadBlockSidePos;
        };
        _mainVeh setVariable ["isDefused",false];
        private _mainVehDirection =  ([_direction,(selectRandom[0,-10,10])] call TRGM_GLOBAL_fnc_addToDirection);
        _mainVeh setDir _mainVehDirection;
        clearItemCargoGlobal _mainVeh;

        if (_showMarker) then {
            private _markerstrcache = createMarker [format ["IEDLoc%1",_eventLocationPos select 0],([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos)];
            _markerstrcache setMarkerShape "ICON";
            if (_bIsTrap) then {
                _markerstrcache setMarkerText localize "STR_TRGM2_IEDMarkerText";
            } else {
                _markerstrcache setMarkerText "";
            };
            _markerstrcache setMarkerType "hd_dot";
        };


        [
            _mainVeh,                                            // Object the action is attached to
            localize "STR_TRGM2_IEDSearchIED",                                        // Title of the action
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",    // Idle icon shown on screen
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",    // Progress icon shown on screen
            "_this distance _target < 5",                        // Condition for the action to be shown
            "_caller distance _target < 5",                        // Condition for the action to progress
            {},                                                    // Code executed when action starts
            {
                params ["_thisVeh", "_caller", "_actionId", "_arguments", "_progress", "_maxProgress"];
                private _IEDType = _arguments params ["_bIsTrap", "_IEDType"];
                private _alarmActive = _thisVeh getVariable ["alarmActive",false];
                if (floor (random 30) isEqualTo 0 && _IEDType isEqualTo "CAR" && !_alarmActive) then {
                    [_thisVeh] spawn {
                        private _thisVeh = _this select 0;
                        _thisVeh setVariable ["alarmActive",true, true];
                        private _beepLimit = 20;
                        private _endLoop = false;
                        waitUntil {
                            playSound3D ["a3\sounds_f\weapons\horns\truck_horn_2.wss", _thisVeh];
                            sleep 1;
                            _beepLimit = _beepLimit - 1;
                            if (_beepLimit < 1) then {_endLoop = true;};
                            _endLoop || !(alive _thisVeh) || !(_thisVeh getVariable ["alarmActive", false])
                        };
                    };
                };
            },            // Code executed on every progress tick
            {
                params ["_thisVeh", "_thisPlayer", "_actionId", "_arguments"];
                _arguments params ["_bIsTrap", "_IEDType"];
                if (_thisPlayer getVariable "unitrole" != "Engineer" && random 1 < .60) then {
                    [localize "STR_TRGM2_IEDSearchFailed"] call TRGM_GLOBAL_fnc_notify;
                } else {
                    [_thisVeh] remoteExec ["removeAllActions", 0, true];
                    [_thisVeh, _actionId] remoteExec ["BIS_fnc_holdActionRemove", 0, true];
                    if (_bIsTrap) then {
                        [localize "STR_TRGM2_IEDSearchFound"] call TRGM_GLOBAL_fnc_notify;
                        [
                            _thisVeh,                                            // Object the action is attached to
                            localize "STR_TRGM2_IEDDefuse",                                        // Title of the action
                            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",    // Idle icon shown on screen
                            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",    // Progress icon shown on screen
                            "_this distance _target < 5",                        // Condition for the action to be shown
                            "_caller distance _target < 5",                        // Condition for the action to progress
                            {},                                                    // Code executed when action starts
                            {},            // Code executed on every progress tick
                            {
                                params ["_thisVeh", "_thisPlayer", "_actionId", "_arguments"];
                                _arguments params ["_bIsTrap", "_IEDType"];
                                [_thisVeh] remoteExec ["removeAllActions", 0, true];
                                [_thisVeh, _actionId] remoteExec ["BIS_fnc_holdActionRemove", 0, true];
                                if (_thisPlayer getVariable "unitrole" != "Engineer" && random 1 < .25) then {
                                    [localize "STR_TRGM2_IEDOhOh"] call TRGM_GLOBAL_fnc_notify;
                                    sleep 1;
                                    playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                    sleep 0.6;
                                    playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                    sleep 0.5;
                                    playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                    sleep 0.4;
                                    playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                    sleep 0.3;
                                    playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                    sleep 0.2;
                                    playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                    sleep 0.1;
                                    playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_thisVeh,false,getPosASL _thisVeh,0.5,1.5,0];
                                    sleep 1;
                                    //BOOM
                                    private _type = selectRandom ["Bomb_03_F","Missile_AA_04_F","M_Mo_82mm_AT_LG","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo"];
                                    private _li_aaa = _type createVehicle ([_thisVeh] call TRGM_GLOBAL_fnc_getRealPos);
                                    _li_aaa setDamage 1;
                                    sleep 1;
                                    _thisVeh setVariable ["isDefused",true, true];
                                    sleep 4;
                                    [localize "STR_TRGM2_IEDOneWay"] call TRGM_GLOBAL_fnc_notifyGlobal;
                                } else {
                                    _thisVeh setVariable ["isDefused",true, true];
                                    [0.2, localize "STR_TRGM2_IEDDefused"] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints;
                                    [localize "STR_TRGM2_IEDDefused"] call TRGM_GLOBAL_fnc_notifyGlobal;
                                };
                            },                // Code executed on completion
                            {},                                                    // Code executed on interrupted
                            [],                                // Arguments passed to the scripts as _this select 3
                            6,                            // Action duration [s]
                            100,                                                    // Priority
                            false,                                                // Remove on completion
                            false                                                // Show in unconscious state
                        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _thisVeh];    // MP compatible implementation
                    } else {
                        [localize "STR_TRGM2_IEDNoneFound"] call TRGM_GLOBAL_fnc_notify;
                    };
                };
            },                // Code executed on completion
            {},                                                    // Code executed on interrupted
            [_bIsTrap,_IEDType],                                // Arguments passed to the scripts as _this select 3
            6,                                                    // Action duration [s]
            90,                                                    // Priority
            false,                                                // Remove on completion
            false                                                // Show in unconscious state
        ] remoteExec ["BIS_fnc_holdActionAdd", 0, _mainVeh];    // MP compatible implementation


        private _spawnedUnit = nil;
        if (_bIsTrap) then {
            if (random 1 < .25) then {
                [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingAmbush;
                _bHasHidingAmbush = true;
            };
            if (random 1 < .20) then {
                [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
            };
            if (random 1 < .50) then {
                [_eventLocationPos] spawn TRGM_SERVER_fnc_createEnemySniper;
            };

            private _allowAPTraps = true;
            private _mainVehPos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
            {
                if (_x distance _mainVehPos < 800) then {
                    _allowAPTraps = false;
                };
            } forEach TRGM_VAR_ObjectivePositions;
            if (random 1 < .33 && _allowAPTraps) then {
                private _minesPlaced = false;
                private _iCountMines = 20;
                _mainVehPos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
                waitUntil {
                    private _xPos = (_mainVehPos select 0)-40;
                    private _yPos = (_mainVehPos select 1)-40;
                    private _randomPos = [_xPos+(random 80),_yPos+(random 80),0];
                    if (!isOnRoad _randomPos) then {
                        //APERSMine ATMine
                        private _objMine = createMine [selectRandom["APERSMine"], _randomPos, [], 0];
                    };
                    _iCountMines = _iCountMines - 1;
                    sleep 1;
                    _iCountMines <= 0;
                };
            };
        };

        _mainVeh setFuel 0;
        if (random 1 < .50) then {_mainVeh setHit ["wheel_1_1_steering",1];};
        if (random 1 < .50) then {_mainVeh setHit ["wheel_1_2_steering",1];};
        if (random 1 < .50) then {_mainVeh setHit ["wheel_2_1_steering",1];};
        if (random 1 < .50) then {_mainVeh setHit ["wheel_2_2_steering",1];};
        _mainVeh setDamage selectRandom[0,0.7];

        [_mainVeh, _bIsTrap, _roadBlockSidePos] spawn {
            private _mainVeh = _this select 0;
            private _bIsTrap = _this select 1;
            private _roadBlockSidePos = _this select 2;
            private _bWaiting = true;
            waitUntil {
                if (!(alive _mainVeh) || _mainVeh getVariable ["isDefused",false]) then {
                    _bWaiting = false;
                };

                if (_bIsTrap) then {
                    //LandVehicle
                    if (alive _mainVeh) then {
                        private _nearUnits = nearestObjects [(_roadBlockSidePos), ["LandVehicle"], 10];
                        {
                            if (((driver _x) in switchableUnits || (driver _x) in playableUnits) && (alive _mainVeh)) then {
                                private _type = selectRandom ["Bomb_03_F","Missile_AA_04_F","M_Mo_82mm_AT_LG","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo"];
                                private _li_aaa = _type createVehicle ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
                                _li_aaa setDamage 1;
                                _mainVeh setVariable ["isDefused",true, true];
                                [localize "STR_TRGM2_IEDOmteresting"] call TRGM_GLOBAL_fnc_notifyGlobal;
                            };
                            if (!_bWaiting) exitWith {true};
                        } forEach _nearUnits;
                    };
                };
                if (_bWaiting) then {
                    sleep 5;
                };
                !_bWaiting;
            };
        }

    };
} else {
    if (!isNil "_objIED") then {
        deleteVehicle _objIED;
    };
};

true;