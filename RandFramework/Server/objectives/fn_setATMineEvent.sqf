// private _fnc_scriptName = "TRGM_SERVER_fnc_setATMineEvent";
params ["_posOfAO", ["_isFullMap", false]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer || isNil "_posOfAO") exitWith {};

if (_isFullMap) then {
    ["Loading Full Map Events : AT Mine Event", true] call TRGM_GLOBAL_fnc_log;
} else {
    ["Loading Events : AT Mine Event", true] call TRGM_GLOBAL_fnc_log;
};

private _nearestRoads = (_posOfAO nearRoads 3000) select {((getPos _x) distance _posOfAO) >= 1000 && !((getPos _x) in (TRGM_VAR_AreasBlackList + TRGM_VAR_ATFieldPos))};
if (!(isnil "Istraining") || _isFullMap) then {
    _nearestRoads = (_posOfAO nearRoads 30000) select {((getPos _x) distance _posOfAO) >= 1000 && !((getPos _x) in (TRGM_VAR_AreasBlackList + TRGM_VAR_ATFieldPos))};
};

if !(count _nearestRoads > 0) exitWith {};

private _currentATFieldPos = getPos (selectRandom _nearestRoads);

TRGM_VAR_ATFieldPos pushBack _currentATFieldPos;
publicVariable "TRGM_VAR_ATFieldPos";

private _minesPlaced = false;
private _icountmines = 0;
waitUntil {
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
    _minesPlaced;
};

if (random 1 < .20) then {
    [_currentATFieldPos, 200, 250] spawn TRGM_SERVER_fnc_createWaitingAmbush;
};

if (random 1 < .20) then {
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
    private _group = (createGroup [TRGM_VAR_Friendlyside, true]);
    private _sUnittype = selectRandom (call FriendlyCheckpointunits);

    private _guardUnit1 = [_group, _sUnittype, _pos1, [], 0, "NONE", true] call TRGM_GLOBAL_fnc_createUnit;
    if (isnil "_guardUnit1" || {isNull _guardUnit1}) then {
        waitUntil {
            _guardUnit1 = [_group, _sUnittype, _pos1, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
            !(isNil "_guardUnit1") && !(isNull _guardUnit1);
        };
    };
    dostop [_guardUnit1];
    _guardUnit1 setDir (floor random 360);
    [_guardUnit1, "WATCH", "ASIS"] call BIS_fnc_ambientAnimCombat;

    private _guardUnit2 = [_group, _sUnittype, _pos2, [], 0, "NONE", true] call TRGM_GLOBAL_fnc_createUnit;
    if (isnil "_guardUnit2" || {isNull _guardUnit2}) then {
        waitUntil {
            _guardUnit2 = [_group, _sUnittype, _pos2, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
            !(isNil "_guardUnit2") && !(isNull _guardUnit2);
        };
    };
    dostop [_guardUnit2];
    _guardUnit2 setDir (floor random 360);
    [_guardUnit2, "WATCH", "ASIS"] call BIS_fnc_ambientAnimCombat;

    [_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;

    [_guardUnit1, [localize "STR_TRGM2_AskNeedsAssistanceAction", {
        private _guardUnit1 = _this select 0;
        if (alive _guardUnit1) then {
            [localize "STR_TRGM2_StandedMoveVehicle"] call TRGM_GLOBAL_fnc_notify;
        } else {
            [localize "STR_TRGM2_AttemptTalkToDeadGuy"] call TRGM_GLOBAL_fnc_notify;
        }
    }, [_guardUnit1]]] remoteExec ["addAction", 0, true];

    [_mainVeh, _guardUnit1, _group] spawn {
        private _mainVeh = _this select 0;
        private _guardUnit1 = _this select 1;
        private _group = _this select 2;
        private _bWaiting = true;
        private _bWavedone = false;
        waitUntil {
            if (!(alive _mainVeh)) then {
                _bWaiting = false;
            } else {
                if (!_bWavedone) then {
                    private _nearunits = nearestobjects [(getPos _guardUnit1), ["Man", "Car", "Helicopter"], 100];
                    {
                        if ((driver _x) in switchableunits || (driver _x) in playableunits) then {
                            _bWavedone = true;
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
                                        sleep 2;
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
                        [localize "STR_TRGM2_CivThanksForHelp"] call TRGM_GLOBAL_fnc_notifyGlobal;
                        [_guardUnit1] remoteExecCall ["removeAllActions", 0];
                        [0.2, localize "STR_TRGM2_MiniTaskHelpedCiv"] spawn TRGM_GLOBAL_fnc_adjustmaxBadPoints;
                        _bWaiting = false;
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

true;