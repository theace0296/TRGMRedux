// private _fnc_scriptName = "TRGM_SERVER_fnc_setDownedChopperEvent";
params ["_mainObjPos",["_isFullMap",false]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer || isNil "_mainObjPos") exitWith {};

if (_isFullMap) then {
    ["Loading Full Map Events : Down Chopper Event", true] call TRGM_GLOBAL_fnc_log;
} else {
    ["Loading Events : Down Chopper Event", true] call TRGM_GLOBAL_fnc_log;
};

call TRGM_SERVER_fnc_initMissionVars;

private _iVictimType = selectRandom [0,1,2];  //0=reporter, 1=medic, 2=friendlyPilot
private _completedMessage = localize (format ["STR_TRGM2_DownedChopper_CompletedMessage%1", _iVictimType]);
private _PointsAdjustMessage = localize (format ["STR_TRGM2_DownedChopper_PointsAdjustMessage%1", _iVictimType]);
private _sVictim = selectRandom ([Reporters, Paramedics, FriendlyVictims] select _iVictimType);
private _sVictimVeh = selectRandom ([ReporterChoppers, AirAmbulances, FriendlyVictimVehs] select _iVictimType);

private _bloodPools = ["BloodPool_01_Large_New_F","BloodSplatter_01_Large_New_F"];
private _flatPos = [_mainObjPos , 200, 2000, 1, 0, 0.5, 0,[],[[0,0,0],[0,0,0]],_sVictimVeh] call TRGM_GLOBAL_fnc_findSafePos;
if (_isFullMap) then {
    private _nearestRoads = _mainObjPos nearRoads 30000;
    if (count _nearestRoads > 0) then {
        private _thisDownedChopperCenter = getPos (selectRandom _nearestRoads);
        _flatPos = [_thisDownedChopperCenter , 100, 2000, 1, 0, 0.5, 0,[],[[0,0,0],[0,0,0]]] call TRGM_GLOBAL_fnc_findSafePos;
    };
};


if ((_flatPos select 0) isEqualTo 0 && (_flatPos select 1) isEqualTo 0) exitWith {};

private _aaaX = _flatPos select 0;
private _aaaY = _flatPos select 1;


if (random 1 < .20) then {
    [_flatPos] spawn TRGM_SERVER_fnc_createWaitingAmbush;
    if (random 1 < .25) then {
        [_flatPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
    };
};
if (random 1 < .20) then {
    [_flatPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
};
if (random 1 < .33) then {
    [_flatPos] spawn TRGM_SERVER_fnc_createEnemySniper;
};

private _wreck = _sVictimVeh createVehicle _flatPos;
_wreck setDamage [1,false];
if (random 1 < .50 && (call TRGM_GETTER_fnc_bAllowAOFires)) then {
    private _objFlame1 = createVehicle ["test_EmptyObjectForFireBig", _flatPos, [], 0, "CAN_COLLIDE"];
};


//spawn inner sentry
private _HasEnemy = false;
private _iCount = selectRandom[0,1,2];
waitUntil {
    _HasEnemy = true;
    private _thisAreaRange = 20;
    private _checkPointGuidePos = _flatPos;
    _iCount = _iCount - 1;
    private _flatPosSentry = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
    if !(_flatPosSentry isEqualTo _checkPointGuidePos) then {
        private _thisPosAreaOfCheckpoint = _flatPosSentry;
        private _thisRoadOnly = false;
        private _thisSide = TRGM_VAR_EnemySide;
        private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
        private _thisAllowBarakade = false;
        private _thisIsDirectionAwayFromAO = true;
        [_flatPos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100] spawn TRGM_SERVER_fnc_setCheckpoint;
    };
    sleep 1;
    _iCount <= 0;
};

private _flatPos2 = [_flatPos , 10, 25, 3, 0, 0.5, 0,[],[[0,0,0],[0,0,0]],_sVictim] call TRGM_GLOBAL_fnc_findSafePos;
private _group = (createGroup [civilian, true]);
private _downedCiv = [_group, _sVictim,_flatPos2,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
private _iterations = 0;
waitUntil {
    _downedCiv = [_group, _sVictim,_flatPos2,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
    _iterations = _iterations + 1;
    (!(isNil "_downedCiv") && !(isNull _downedCiv)) || _iterations >= 5;
};
if (isNil "_downedCiv") exitWith {};
[_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;

[_downedCiv,[localize "STR_TRGM2_fnpostinit_JoinGroup",{
    private _civ = _this select 0;
    private _player = _this select 1;
    [_civ] join (group _player);
    _civ enableAI "MOVE";
    _civ removeAction 0;
    _civ switchMove "Acts_ExecutionVictim_Unbow";
    _civ enableAI "anim";
}]] remoteExecCall ["addAction", 0];

_downedCiv setDamage 0.8;
_downedCiv setHitPointDamage ["hitLegs", 1];
[_downedCiv, "Acts_CivilInjuredGeneral_1"] remoteExec ["switchMove", 0];

_downedCiv disableAI "anim";
private _downedCivDirection = (floor(random 360));
_downedCiv setDir (_downedCivDirection);
_downedCiv addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}];
private _bloodPool1 = createVehicle [selectRandom _bloodPools, ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), [], 0, "CAN_COLLIDE"];
_bloodPool1 setDir (floor(random 360));
[_downedCiv, [localize "STR_TRGM2_DownedChopper_SpeakTo",{[localize "STR_TRGM2_DownedChopper_Speach"] call TRGM_GLOBAL_fnc_notify;},[_downedCiv]]] remoteExec ["addAction", 0, true];

private _trialDir = (floor(random 360));
private _trialPos = (getPos _bloodPool1) getPos [3,_trialDir];
private _bloodTrail1 = createVehicle ["BloodTrail_01_New_F", _trialPos, [], 0, "CAN_COLLIDE"];
_bloodTrail1 setDir _trialDir;

[_downedCiv,[localize "STR_TRGM2_fnpostinit_Carry",{
    private _civ = _this select 0;
    private _player = _this select 1;
    [_civ, _player] spawn TRGM_GLOBAL_fnc_carryAndJoinWounded;
}]] remoteExecCall ["addAction", 0];

[_downedCiv] spawn {
    private _downedCiv = _this select 0;
    if (isNil "_downedCiv") exitWith {};
    while{!(isNil "_downedCiv") && alive _downedCiv} do {
        private _woundedSound = selectRandom WoundedSounds;
        [_downedCiv,_woundedSound] remoteExecCall ["say3D", 0];
        sleep selectRandom [2,2.5,3];
    }
};

[_downedCiv] spawn {
    private _downedCiv = _this select 0;
    if (isNil "_downedCiv") exitWith {};
    while{!(isNil "_downedCiv") && alive _downedCiv} do {
        private _flareposX = ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos) select 0;
        private _flareposY = ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos) select 1;
        private _flare1 = "F_40mm_red" createvehicle [_flareposX+20,_flareposY+20, 250]; _flare1 setVelocity [0,0,-10];
        sleep selectRandom [600];
    }
};

private _markerEventMedi = createMarker [format["_markerEventRescue%1",(floor(random 360))], ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos)];
_markerEventMedi setMarkerShape "ICON";
_markerEventMedi setMarkerType "hd_dot";
_markerEventMedi setMarkerText (localize "STR_TRGM2_distressSignal_military");

[_downedCiv, _completedMessage, _PointsAdjustMessage] spawn {
    private _downedCiv = _this select 0;
    private _completedMessage = _this select 1;
    private _PointsAdjustMessage = _this select 2;
    if (isNil "_downedCiv") exitWith {};
    private _doLoop = true;
    waitUntil {
        if (!(isNil "_downedCiv") && !alive(_downedCiv)) then {
            _doLoop = false;
        };
        if (_downedCiv distance (getMarkerPos "mrkHQ") < 300) then {
            _doLoop = false;
            [_completedMessage] call TRGM_GLOBAL_fnc_notifyGlobal;
            [0.3, _PointsAdjustMessage] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints;
            [_downedCiv] join grpNull;
            deleteVehicle _downedCiv;
        };
        sleep 10;
        !_doLoop;
    };
};

true;