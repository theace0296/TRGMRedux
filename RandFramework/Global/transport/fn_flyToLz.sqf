/*     Script starting here  */
scopeName "FlyTo";

params [
    "_destinationPosition",
    ["_vehicle", objNull],
    ["_isPickup", false],
    ["_isHeloCast", false]
];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _radius = 900;
private _airEscort = false;
private _isHiddenObj = false;
//{
//    if ((_x distance2D _destinationPosition) < _radius) then {
//        _airEscort = true;
//    };
//} forEach TRGM_VAR_ClearedPositions;

private _mainAOPos = TRGM_VAR_ObjectivePositions select 0;
if (! isNil "_mainAOPos") then {
    if (_mainAOPos in TRGM_VAR_ClearedPositions  && (_mainAOPos distance2D _destinationPosition) < _radius) then {
        _airEscort = true;
    };
};

if (! isNil "_mainAOPos") then {
    if (_mainAOPos in TRGM_VAR_HiddenPossitions ) then {
        _isHiddenObj = true;
    };
};



//TRGM_VAR_ObjectivePositions

if (!alive _vehicle) then {
    breakOut "FlyTo";
};

{
    deleteWaypoint _x
} foreach waypoints group driver _vehicle;
units (group driver _vehicle) doFollow leader (group driver _vehicle);
{
    _x enableAI "MOVE";
    _x enableSimulation true;
} forEach units group driver _vehicle;
_vehicle setFuel 1;

//cleanup possible prevoius prevoious
deleteVehicle (_vehicle getVariable ["targetPad", objNull]);
deleteMarker (_vehicle getVariable ["lzMarker",""]);



/** New Tranport Mission starts here **/

// set mission number -> invalidates old instances of this script running.
private _thisMissionNr = (_vehicle getVariable ["missionNr",0]) + 1;
_vehicle setVariable ["missionNr", _thisMissionNr, true];

private _thisMission = [_vehicle,_thisMissionNr];

_cleanupMission = {
    params ["_mission"];

    private _markerName = str(_mission select 0) + "LZ" + str(_mission select 1);
    deleteMarker _markerName;
};

_vehicle setVariable ["targetPos",_destinationPosition,true];
private _driver = driver _vehicle;

/* Set landing zone map marker */

private _markerName = str(_vehicle) + "LZ" + str(_thisMissionNr);

private _mrkcustomLZ1 = createMarker [_markerName, _destinationPosition];
_mrkcustomLZ1 setMarkerShape "ICON";
_mrkcustomLZ1 setMarkerSize [1,1];
_mrkcustomLZ1 setMarkerColor "colorBLUFOR";
_mrkcustomLZ1 setMarkerType "hd_pickup";
_mrkcustomLZ1 setMarkerText (format ["LZ %1", [_vehicle] call TRGM_GLOBAL_fnc_getTransportName]);
_vehicle setVariable ["lzMarker",_mrkcustomLZ1,true];

private _heliPad = "Land_HelipadEmpty_F" createVehicle _destinationPosition; // invisible landingpad to specify exact landing position
_vehicle setVariable ["targetPad",_heliPad,true];

{
    deleteWaypoint _x
} foreach waypoints group _driver;

_vehicle setVariable ["landingInProgress",false,true];

private _emergencyLand = false;
private _waypointIndex = 0;
/* Set Waypoint,Takeoff */
if (!_airEscort) then {
    private _iSaftyCount = 500;
    private _bHalfWayWaypoint = false;
    private _DirAtoB = [[_vehicle] call TRGM_GLOBAL_fnc_getRealPos, _destinationPosition] call BIS_fnc_DirTo;
    private _AvoidZonePos = TRGM_VAR_ObjectivePositions select 0;

    if (! isNil "_AvoidZonePos" ) then {
        private _stepPos = [_vehicle] call TRGM_GLOBAL_fnc_getRealPos;
        private _stepDistLeft = _vehicle distance _destinationPosition;
        private _bEndSteps = false;
        while {!_bEndSteps && _iSaftyCount > 0} do {
            _iSaftyCount = _iSaftyCount - 1;
            _stepPos = _stepPos getPos [100,_DirAtoB];
            _stepDistToAO = _stepPos distance _AvoidZonePos;
            _stepDistLeft = _stepPos distance _destinationPosition;

            if (false) then {
                private _markerNameSteps = str(_vehicle) + "Step_" + str(500 - _iSaftyCount);
                private _mrkcustomSteps = createMarker [_markerNameSteps, _stepPos];
                _mrkcustomSteps setMarkerShape "ICON";
                _mrkcustomSteps setMarkerSize [1,1];
                _mrkcustomSteps setMarkerType "hd_dot";
                _mrkcustomSteps setMarkerText ("Step " + str(_stepDistLeft));
                sleep 0.1;
                [str(_iSaftyCount)] call TRGM_GLOBAL_fnc_notify;
            };

            if (_stepDistToAO < 1000) then {
                if (_isHiddenObj) then {
                    _bEndSteps = true;
                    _destinationPosition = _stepPos;
                    _emergencyLand = true;
                }
                else {
                    _bEndSteps = true;
                    private _divertDirectionA = ([_DirAtoB,80] call TRGM_GLOBAL_fnc_addToDirection);
                    private _newPosA = _AvoidZonePos getPos [2000,_divertDirectionA];
                    private _divertDirectionB = ([_DirAtoB,-80] call TRGM_GLOBAL_fnc_addToDirection);
                    private _newPosB = _AvoidZonePos getPos [2000,_divertDirectionB];
                    private _totalDistA = (_vehicle distance _newPosA) + (_newPosA distance _destinationPosition);
                    private _totalDistB = (_vehicle distance _newPosB) + (_newPosB distance _destinationPosition);
                    private _newPos = nil;
                    if (_totalDistA < _totalDistB) then {
                        _newPos = _newPosA;
                    }
                    else {
                        _newPos = _newPosB;
                    };
                    _waypointIndex = _waypointIndex + 1;
                    private _flyToLZMid = group _driver addWaypoint [_newPos,0,0];
                    _flyToLZMid setWaypointType "MOVE";
                    _flyToLZMid setWaypointSpeed "FULL";
                    _flyToLZMid setWaypointBehaviour "CARELESS";
                    _flyToLZMid setWaypointCombatMode "BLUE";
                    _flyToLZMid setWaypointCompletionRadius 1000;
                };
            };
            if (_stepDistLeft < 300) then {
                _bEndSteps = true;
            };
        };
    }
};

private _flyToLZ = group _driver addWaypoint [_destinationPosition,0,_waypointIndex];
_flyToLZ setWaypointType "MOVE";
_flyToLZ setWaypointSpeed "FULL";
_flyToLZ setWaypointBehaviour "CARELESS";
_flyToLZ setWaypointCombatMode "BLUE";
_flyToLZ setWaypointCompletionRadius 100;
if (_isHeloCast) then {
    _flyToLZ setWaypointStatements ["true", "(vehicle this) flyInHeight 5; (vehicle this) setVariable [""landingInProgress"",true,true]; [(vehicle this)] spawn TRGM_GLOBAL_fnc_helocastLanding;"];
} else {
    _flyToLZ setWaypointStatements ["true", "(vehicle this) land 'GET IN'; (vehicle this) setVariable [""landingInProgress"",true,true]"];
};

//also, further above, set AOISHIDDEN

if (_airEscort) then {
    private _escortPilot = driver chopper2;
    {
        deleteWaypoint _x
    } foreach waypoints group _escortPilot;
    private _escortFlyToLZ = group _escortPilot addWaypoint [_destinationPosition,0,0];
    _escortFlyToLZ setWaypointBehaviour "AWARE";
    _escortFlyToLZ setWaypointCombatMode "RED";
    _escortFlyToLZ setWaypointType "LOITER";
    _escortFlyToLZ setWaypointLoiterType "CIRCLE";
    _escortFlyToLZ setWaypointSpeed "FULL";
};


if (!([_vehicle] call TRGM_GLOBAL_fnc_helicopterIsFlying)) then {
    private _locationText = [position _vehicle,true] call TRGM_GLOBAL_fnc_getLocationName;
    private _text = format [localize "STR_TRGM2_transport_fnflyToLz_ClearTakeoff", [_vehicle] call TRGM_GLOBAL_fnc_getTransportName,_locationText];
    [_text] call TRGM_GLOBAL_fnc_commsHQ;
};

if (!([_vehicle] call TRGM_GLOBAL_fnc_helicopterIsFlying)) then {
    waitUntil {sleep 5; (!([_vehicle] call TRGM_GLOBAL_fnc_helicopterIsFlying)) || !(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)};
    if (!(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)) then {
        [_thisMission] call _cleanupMission;
        breakOut "FlyTo";
    };
    sleep 2;

    [_vehicle,localize "STR_TRGM2_transport_fnflyToLz_OffWeGo"] call TRGM_GLOBAL_fnc_commsPilotToVehicle;
} else {
    [_vehicle,localize "STR_TRGM2_transport_fnflyToLz_Diverting"]call TRGM_GLOBAL_fnc_commsPilotToVehicle;
};

/* Landing done **/

waitUntil { sleep 5; ((_vehicle getVariable ["landingInProgress",false]) || !(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)); };
if (!(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)) then {
    _vehicle land "NONE";
    [_thisMission] call _cleanupMission;
    breakOut "FlyTo";
};

waitUntil { sleep 5; ((!([_vehicle] call TRGM_GLOBAL_fnc_helicopterIsFlying)) || (([_vehicle] call TRGM_GLOBAL_fnc_helicopterIsFlying) && _isHeloCast) || {!canMove _vehicle} || !(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)); };
if (!(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)) then {
    _vehicle land "NONE";
    [_thisMission] call _cleanupMission;
    breakOut "FlyTo";
};

sleep 2;

/* Post landing,cleanup */
{
    deleteWaypoint _x
} foreach waypoints _driver;

if (!_isPickup) then {
    [_vehicle, localize "STR_TRGM2_transport_fnflyToLz_ReachLZ_Out"] call TRGM_GLOBAL_fnc_commsPilotToVehicle;
}
else {
    [driver _vehicle,localize "STR_TRGM2_transport_fnflyToLz_ReachLZ_In"] call TRGM_GLOBAL_fnc_commsSide;
};


sleep 5;

/* wait for empty helicopter */

if (!_isPickup) then {
    waitUntil { sleep 5; ([_vehicle] call TRGM_GLOBAL_fnc_isOnlyBoardCrewOnboard) || !(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive) }; // helicopter empty except pilot + crew

    if (!(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)) then {
        _vehicle land "NONE";
        [_thisMission] call _cleanupMission;
        breakOut "FlyTo";
    };
    /* RTB */
    [_vehicle,_thisMission] spawn TRGM_GLOBAL_fnc_flyToBase;
}
else {
    waitUntil { sleep 5; !([_vehicle] call TRGM_GLOBAL_fnc_isOnlyBoardCrewOnboard) || !(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive) }; // helicopter has passengers (not just pilot + crew)
    if (!(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)) then {
        _vehicle land "NONE";
        [_thisMission] call _cleanupMission;
        breakOut "FlyTo";
    };
    if (!(_thisMission call TRGM_GLOBAL_fnc_checkMissionIdActive)) then {
        /* RTB */
        [_vehicle,_thisMission] spawn TRGM_GLOBAL_fnc_flyToBase;
    }
    else {
        [_vehicle, localize "STR_TRGM2_transport_fnflyToLz_WelcomeAboard"] call TRGM_GLOBAL_fnc_commsPilotToVehicle;
    };
};

sleep 4;

[_thisMission] call _cleanupMission;

true;