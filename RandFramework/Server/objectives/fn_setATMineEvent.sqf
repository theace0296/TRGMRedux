params ["_posOfAO", ["_isFullMap", false]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _currentATFieldPos = [_posOfAO, 1000, 1700, 100, 0, 0.4, 0, TRGM_VAR_AreasBlacklist, [[0, 0, 0], [0, 0, 0]]] call TRGM_GLOBAL_fnc_findSafePos;

if (!(isnil "Istraining") || _isFullMap) then {
    _currentATFieldPos = [_posOfAO, 30000, 1700, 100, 0, 0.4, 0, TRGM_VAR_AreasBlacklist, [[0, 0, 0], [0, 0, 0]]] call TRGM_GLOBAL_fnc_findSafePos;
};

if (_currentATFieldPos select 0 != 0) then {
    TRGM_VAR_ATFieldPos pushBack _currentATFieldPos;

    private _minesPlaced = false;
    private _icountmines = 0;
    while {!_minesPlaced} do {
        private _xPos = (_currentATFieldPos select 0)-100;
        private _yPos = (_currentATFieldPos select 1)-100;
        private _randomPos = [_xPos+(random 200), _yPos+(random 200), 0];
        // APERSmine ATmine
        private _objmine = createmine [selectRandom["ATmine"], _randomPos, [], 0];
        if ("TEST" isEqualto "false") then {
            private _markerstrcache = createMarker [format ["CacheLoc%1", _icountmines], _randomPos];
            _markerstrcache setMarkerShape "ICON";
            _markerstrcache setMarkertype "hd_dot";
            _markerstrcache setMarkertext "";
        };
        _icountmines = _icountmines + 1;
        if (_icountmines >= 50) then {
            _minesPlaced = true
        };
        sleep 1;
    };

    if (random 1 < .20) then {
        [_currentATFieldPos, 200, 250] spawn TRGM_SERVER_fnc_createWaitingAmbush;
    };

    if (random 1 < .20) then {
        // if (true) then {
            private _mainVeh = createvehicle [selectRandom (call FriendlyScoutvehicles), _currentATFieldPos, [], 0, "NONE"];
            _mainVeh setDir (floor random 360);
            clearitemCargoGlobal _mainVeh;
            if (random 1 < .50) then {
                _mainVeh setHit ["wheel_1_1_steering", 1];
            };
            if (random 1 < .50) then {
                _mainVeh setHit ["wheel_1_2_steering", 1];
            };
            if (random 1 < .50) then {
                _mainVeh setHit ["wheel_2_1_steering", 1];
            };
            if (random 1 < .50) then {
                _mainVeh setHit ["wheel_2_2_steering", 1];
            };
            if (((_mainVeh getHit "wheel_1_1_steering") < 0.5) && ((_mainVeh getHit "wheel_1_2_steering") < 0.5) && ((_mainVeh getHit "wheel_2_1_steering") < 0.5) && ((_mainVeh getHit "wheel_2_2_steering") < 0.5)) then {
                _mainVeh setHit ["wheel_1_1_steering", 1];
            };

            private _pos1 = _mainVeh getPos [5, (floor random 360)];
            private _pos2 = _mainVeh getPos [5, (floor random 360)];
            private _group = creategroup TRGM_VAR_Friendlyside;
            private _sUnittype = selectRandom (call FriendlyCheckpointunits);

            private _guardUnit1 = [_group, _sUnittype, _pos1, [], 0, "NONE", true] call TRGM_GLOBAL_fnc_createUnit;
            if (isnil "_guardUnit1" || {
                isNull _guardUnit1
            }) then {
                while {
                    isnil "_guardUnit1" || {
                        isNull _guardUnit1
                    }
                } do {
                    _guardUnit1 = [_group, _sUnittype, _pos1, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    sleep 1;
                };
            };
            dostop [_guardUnit1];
            _guardUnit1 setDir (floor random 360);
            [_guardUnit1, "WATCH", "ASIS"] call BIS_fnc_ambientAnimCombat;

            private _guardUnit2 = [_group, _sUnittype, _pos2, [], 0, "NONE", true] call TRGM_GLOBAL_fnc_createUnit;
            if (isnil "_guardUnit2" || {
                isNull _guardUnit2
            }) then {
                while {
                    isnil "_guardUnit2" || {
                        isNull _guardUnit2
                    }
                } do {
                    _guardUnit2 = [_group, _sUnittype, _pos2, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    sleep 1;
                };
            };
            dostop [_guardUnit2];
            _guardUnit2 setDir (floor random 360);
            [_guardUnit2, "WATCH", "ASIS"] call BIS_fnc_ambientAnimCombat;

            [_guardUnit1, ["Ask if needs assistance", {
                private _guardUnit1 = _this select 0;
                if (alive _guardUnit1) then {
                    ["We are stranded in the middle of an AT mine area. please help move this car ovrt 100 meters in any direction from here!"] call TRGM_GLOBAL_fnc_notify;
                } else {
                    ["Is there a reason you are trying to talk to a dead guy??"] call TRGM_GLOBAL_fnc_notify;
                }
            }, [_guardUnit1]]] remoteExec ["addAction", 0, true];

            [_mainVeh, _guardUnit1, _group] spawn {
                private _mainVeh = _this select 0;
                private _guardUnit1 = _this select 1;
                private _group = _this select 2;
                private _bWaiting = true;
                private _bWavedone = false;
                while {_bWaiting} do {
                    sleep 1;
                    if (!(alive _mainVeh)) then {
                        _bWaiting = false;
                    } else {
                        if (!_bWavedone) then {
                            private _nearunits = nearestobjects [(getPos _guardUnit1), ["Man", "Car", "Helicopter"], 100];
                            // (driver ((nearestobjects [(getPos box1), ["car"], 20]) select 0)) in switchableunits
                            {
                                if ((driver _x) in switchableunits || (driver _x) in playableunits) then {
                                    _bWavedone = true;

                                    // [] spawn {};
                                    [[_guardUnit1, _group], {
                                        private _guardUnit1 = _this select 0;
                                        private _group = _this select 1;
                                        _guardUnit1 enableAI "anim";
                                        _guardUnit1 switchMove "";
                                        _guardUnit1 setBehaviour "CARELESS";
                                        _group setspeedMode "FULL";
                                        _guardUnit1 setunitPos "UP";
                                    }] remoteExec ["spawn", 0];
                                    sleep 0.5;
                                    if (alive _guardUnit1) then {
                                        private _dirtoplayer = ([_guardUnit1, _x] call BIS_fnc_Dirto);
                                        private _movetoPos = _guardUnit1 getPos [6, _dirtoplayer];
                                        _guardUnit1 domove _movetoPos;
                                        sleep 3;
                                        _guardUnit1 setDir _dirtoplayer;
                                        [_guardUnit1, ""] remoteExec ["switchMove", 0];
                                        sleep 0.1;
                                        [_guardUnit1, "Acts_JetsShooterNavigate_loop"] remoteExec ["switchMove", 0];
                                        _guardUnit1 disableAI "anim";
                                        [_guardUnit1] spawn {
                                            private _guardUnit1 = _this select 0;
                                            waitUntil {
                                                sleep 1;
                                                !alive(_guardUnit1)
                                            };
                                            [_guardUnit1, ""] remoteExec ["switchMove", 0];
                                        };
                                        sleep 20;
                                        _guardUnit1 enableAI "anim";
                                        _guardUnit1 switchMove "";
                                    };
                                };
                                if (_bWavedone) exitwith {
                                    true
                                };
                            } forEach _nearunits;
                        };
                        if (_bWavedone) then {
                            if ((_mainVeh distance _guardUnit1) > 100) then {
                                ["Thank you for your help"] call TRGM_GLOBAL_fnc_notifyGlobal;
                                [_guardUnit1] remoteExecCall ["removeAllActions", 0];
                                [0.2, "Helped a stranded friendly"] spawn TRGM_GLOBAL_fnc_adjustmaxBadPoints;
                                _bWaiting = false;
                            };
                        };
                    };
                    if (_bWaiting) then {
                        sleep 1;
                    };
                };
            };
        };
    };

    true;