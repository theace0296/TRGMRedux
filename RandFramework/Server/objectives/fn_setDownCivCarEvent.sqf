// private _fnc_scriptName = "TRGM_SERVER_fnc_setDownCivCarEvent";
params ["_posOfAO",["_isFullMap",false]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer || isNil "_posOfAO") exitWith {};

if (_isFullMap) then {
    ["Loading Full Map Events : Down Car Event", true] call TRGM_GLOBAL_fnc_log;
} else {
    ["Loading Events : Down Car Event", true] call TRGM_GLOBAL_fnc_log;
};

private _vehs = CivCars;
private _nearestRoads = _posOfAO nearRoads 2000;
if (_isFullMap) then {
    _nearestRoads = _posOfAO nearRoads 30000;
};

if (count _nearestRoads > 0) then {
    private _eventLocationPos = getPos (selectRandom _nearestRoads);
    private _bIsTrap = random 1 < .40;
    private _thisAreaRange = 50;

    _nearestRoads = _eventLocationPos nearRoads _thisAreaRange;

    private _nearestRoad = nil;
    private _roadConnectedTo = nil;
    private _connectedRoad = nil;
    private _direction = nil;
    private _PosFound = false;
    private _iAttemptLimit = 5;
    private _direction = nil;

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

        private _mainVeh = createVehicle [selectRandom _vehs,_roadBlockSidePos,[],0,"NONE"];
        //_mainVeh setVehicleLock "LOCKED";
        private _mainVehDirection =  ([_direction,(selectRandom[0,-10,10])] call TRGM_GLOBAL_fnc_addToDirection);
        _mainVeh setDir _mainVehDirection;
        //_smoke = createvehicle ["test_EmptyObjectForSmoke",([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos),[],0,"CAN_COLLIDE"];
        //_smoke setpos ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
        clearItemCargoGlobal _mainVeh;

        private _expl1 = nil;
        private _expl2 = nil;
        private _expl3 = nil;

        if (_bIsTrap) then {
            _expl1 = "DemoCharge_Remote_Ammo" createVehicle position _mainVeh;
            _expl1 attachTo [_mainVeh, [0, -0.2, -1.65]];
            _expl1 setVectorDirAndUp [[0,0,-1],[0,1,0]];
            _mainVeh setVariable ["TRGM_VAR_expl1", _expl1, true];

            _expl2 = "DemoCharge_Remote_Ammo" createVehicle position _mainVeh;
            _expl2 attachTo [_mainVeh, [0, -0, -1.65]];
            _expl2 setVectorDirAndUp [[0,0,-1],[0,1,0]];
            _mainVeh setVariable ["TRGM_VAR_expl2", _expl2, true];

            _expl3 = "DemoCharge_Remote_Ammo" createVehicle position _mainVeh;
            _expl3 attachTo [_mainVeh, [0, -0.2, -1.65]];
            _expl3 setVectorDirAndUp [[0,0,-1],[0,1,0]];
            _mainVeh setVariable ["TRGM_VAR_expl3", _expl3, true];

            if (random 1 < .50) then {
                [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingAmbush;
                if (random 1 < .50) then {
                    [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
                };
            };
            if (random 1 < .33) then {
                [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
            };
            if (random 1 < .33) then {
                [_eventLocationPos] spawn TRGM_SERVER_fnc_createEnemySniper;
            };
        };

        private _vehPos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
        private _backOfVehArea = _vehPos getPos [10,([_mainVehDirection,selectRandom[170,180,190]] call TRGM_GLOBAL_fnc_addToDirection)];
        //_direction is direction of road
        //_mainVehDirection is direction of first veh
        //use these to lay down guys, cones, rubbish, barriers, lights etc...

        //[str(_backOfVehArea)] call TRGM_GLOBAL_fnc_notify;
        private _group = (createGroup [civilian, true]);
        private _downedCiv = [_group, selectRandom sCivilian,_backOfVehArea,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
        if (isNil "_downedCiv") exitWith {};
        [_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
        [_downedCiv, "Acts_CivilShocked_1"] remoteExec ["switchMove", 0];
        //_downedCiv playMoveNow "Acts_CivilInjuredGeneral_1"; //"AinjPpneMstpSnonWrflDnon";
        _downedCiv disableAI "anim";
        private _downedCivDirection = (floor(random 360));
        _downedCiv setDir (_downedCivDirection);
        _downedCiv addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}];

        [_downedCiv, [localize "STR_TRGM2_AskNeedsAssistanceAction",{
            private _downedCiv = _this select 0;
            if (isNil "_downedCiv") exitWith {};
            if (alive _downedCiv) then {
                [localize "STR_TRGM2_DownCivCar_Speach"] call TRGM_GLOBAL_fnc_notify;
            }
            else {
                [localize "STR_TRGM2_AttemptTalkToDeadGuy"] call TRGM_GLOBAL_fnc_notify;
            }
        },[_downedCiv]]] remoteExec ["addAction", 0, true];

        //set veh damage;
        //if (random 1 < .50) then {_mainVeh setHit ["engine",0.75];};
        if (random 1 < .50) then {_mainVeh setHit ["wheel_1_1_steering",1];};
        if (random 1 < .50) then {_mainVeh setHit ["wheel_1_2_steering",1];};
        if (random 1 < .50) then {_mainVeh setHit ["wheel_2_1_steering",1];};
        if (random 1 < .50) then {_mainVeh setHit ["wheel_2_2_steering",1];};
        if (((_mainVeh getHit "wheel_1_1_steering") < 0.5) && ((_mainVeh getHit "wheel_1_2_steering") < 0.5) && ((_mainVeh getHit "wheel_2_1_steering") < 0.5) && ((_mainVeh getHit "wheel_2_2_steering") < 0.5)) then {
            _mainVeh setHit ["wheel_1_1_steering",1];
        };



        [_mainVeh, _downedCiv, _group, _roadBlockPos, _bIsTrap] spawn {
            private _mainVeh = _this select 0;
            private _downedCiv = _this select 1;
            private _group = _this select 2;
            private _roadBlockPos = _this select 3;
            private _bIsTrap = _this select 4;
            private _bWaiting = true;
            private _bWaveDone = false;
            waitUntil {
                if (!(alive _mainVeh)) then {
                    _bWaiting = false;
                    private _runAwayTo = [0,0,0]; //_vehPos getPos [500,([_mainVeh, _downedCiv] call BIS_fnc_DirTo)];
                    _downedCiv enableAI "anim";
                    _downedCiv switchMove "";
                    _downedCiv setBehaviour "CARELESS";
                    _downedCiv doMove _runAwayTo;
                    _group setSpeedMode "FULL";
                    _downedCiv setUnitPos "UP";
                };
                if (!_bWaveDone && !(isNil "_downedCiv")) then {
                    private _nearUnits = nearestObjects [([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), ["Man","Car","Helicopter"], 100];
                    //(driver ((nearestObjects [([box1] call TRGM_GLOBAL_fnc_getRealPos), ["car"], 20]) select 0)) in switchableUnits
                    {
                        if ((driver _x) in switchableUnits || (driver _x) in playableUnits) then {
                            _bWaveDone = true;
                            [[_downedCiv,_roadBlockPos,_group],{
                                private _downedCiv = _this select 0;
                                private _roadBlockPos = _this select 1;
                                private _group = _this select 2;

                                if (isNil "_downedCiv") exitWith {};

                                _downedCiv enableAI "anim";
                                _downedCiv switchMove "";
                                _downedCiv setBehaviour "CARELESS";
                                _group setSpeedMode "FULL";
                                _downedCiv setUnitPos "UP";
                            }] remoteExec ["spawn", 0];
                            _downedCiv doMove _roadBlockPos;
                            sleep 3;
                            if (alive _downedCiv) then {
                                _downedCiv setDir ([_downedCiv, _x] call BIS_fnc_DirTo);
                                [_downedCiv, ""] remoteExec ["switchMove", 0];
                                sleep 0.1;
                                [_downedCiv, "Acts_JetsShooterNavigate_loop"] remoteExec ["switchMove", 0];
                                _downedCiv disableAI "anim";
                                [_downedCiv] spawn {
                                    private _downedCiv = _this select 0;
                                    if (isNil "_downedCiv") exitWith {};
                                    waitUntil {sleep 2; !alive(_downedCiv)};
                                    [_downedCiv, ""] remoteExec ["switchMove", 0];
                                };
                                sleep 15;
                                _downedCiv enableAI "anim";
                                _downedCiv switchMove "";
                            };
                        };
                        if (_bWaveDone) exitWith {true};
                    } forEach _nearUnits;
                };
                if (_bWaveDone) then {
                    //_bIsTrap
                    if (_bIsTrap && !(isNil "_downedCiv")) then {
                        _expl1 = _mainVeh getVariable "TRGM_VAR_expl1";
                        _expl2 = _mainVeh getVariable "TRGM_VAR_expl2";
                        _expl3 = _mainVeh getVariable "TRGM_VAR_expl3";
                        _nearUnits = nearestObjects [([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), ["Man"], 10];
                        {
                            if ((driver _x) in switchableUnits || (driver _x) in playableUnits || !(alive _downedCiv)) then {
                                _bWaiting = false;
                                if (alive _downedCiv) then {
                                    sleep (floor(random 60));
                                    _downedCiv enableAI "anim";
                                    _downedCiv switchMove "";
                                    _downedCiv setBehaviour "CARELESS";
                                    _group setSpeedMode "FULL";
                                    _downedCiv setUnitPos "UP";
                                    _downedCiv doMove (TRGM_VAR_ObjectivePositions select 0);
                                    sleep 3;
                                };
                                playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_downedCiv,false,getPosASL _downedCiv,0.5,1.5,0];
                                sleep 0.4;
                                playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_downedCiv,false,getPosASL _downedCiv,0.5,1.5,0];
                                sleep 0.4;
                                playSound3D ["A3\Sounds_F\sfx\beep_target.wss",_downedCiv,false,getPosASL _downedCiv,0.5,1.5,0];
                                sleep 1.5;
                                //do boooooom!!!!
                                if !(isNil "_expl1") then {_expl1 setDamage 1;};
                                if !(isNil "_expl2") then {_expl2 setDamage 1;};
                                if !(isNil "_expl3") then {_expl3 setDamage 1;};
                            };
                            if (!_bWaiting) exitWith {true};
                        } forEach _nearUnits;
                    }
                    else {
                        if (((_mainVeh getHit "wheel_1_1_steering") < 0.5) && ((_mainVeh getHit "wheel_1_2_steering") < 0.5) && ((_mainVeh getHit "wheel_2_1_steering") < 0.5) && ((_mainVeh getHit "wheel_2_2_steering") < 0.5)) then {
                            _bWaiting = false;
                            //removeAllActions _downedCiv;
                            //_group setSpeedMode "LIMITED";
                            //_downedCiv assignAsDriver _mainVeh;
                            //[_downedCiv] orderGetIn true;

                            [localize "STR_TRGM2_CivThanksForHelp"] call TRGM_GLOBAL_fnc_notifyGlobal;
                            [_downedCiv] remoteExecCall ["removeAllActions", 0];
                            [_group,"LIMITED"] remoteExecCall ["setSpeedMode", 0];
                            [_downedCiv,_mainVeh] remoteExecCall ["assignAsDriver", 0];
                            [[_downedCiv],true] remoteExecCall ["orderGetIn", 0];
                            [0.2, localize "STR_TRGM2_DownCivCar_Message"] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints;
                            sleep 10;
                            [_downedCiv,(TRGM_VAR_ObjectivePositions select 0)] remoteExecCall ["doMove", 0];
                        };
                    };
                };
                if (_bWaiting) then {
                    sleep 1;
                };
                !_bWaiting;
            };
        };
    };


};

//if trap, after waving, civ will wait until player close, then run off and set off bomb (will blow up if civ killed too) (run 2 seconds, beep then 1.5 seconds boom)
//         (ways to know if bomb,.... see it, civ runs, enemy spotted)

//can use this for IED, 50/50 if trigger man, very low chance of ambush,near zero chance of suicde bomber, addaction on floor in direction of trigger man confirming direction
//    if close to trigger man, get him to detonate car then run away (player gains rep if defused... so only if no trigger man, or trigger man is killed before detonating bomb)
//    car will go boom as soon as player near!!! (if trigger man alive)

true;