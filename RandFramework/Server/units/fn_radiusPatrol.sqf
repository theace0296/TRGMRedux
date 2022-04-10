// private _fnc_scriptName = "TRGM_SERVER_fnc_radiusPatrol";
params ["_sidePos","_distFromCent", "_unitCounts","_IncludTeamLeader",["_InsurgentSide", EAST]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _unitCount = selectRandom _unitCounts;
private _group = (createGroup [_InsurgentSide, true]);
private _wayX = (_sidePos select 0);
private _wayY = (_sidePos select 1);

private _wp1Pos = [ _wayX + _distFromCent, _wayY + _distFromCent, 0];
private _wp1bPos = [ _wayX + _distFromCent, _wayY, 0];
private _wp2Pos = [ _wayX + _distFromCent, _wayY - _distFromCent, 0];
private _wp2bPos = [ _wayX, _wayY - _distFromCent, 0];
private _wp3Pos = [ _wayX - _distFromCent, _wayY - _distFromCent, 0];
private _wp3bPos = [ _wayX - _distFromCent, _wayY, 0];
private _wp4Pos = [ _wayX - _distFromCent, _wayY + _distFromCent, 0];
private _wp4bPos = [ _wayX, _wayY + _distFromCent, 0];
private _wp5Pos = [ _wayX + _distFromCent, _wayY + _distFromCent, 0];

//Adjust waypoints so they are not in water
private _iToReduce = 10;
waitUntil {
    _wp1Pos = [ _wayX + (_distFromCent - _iToReduce), _wayY + (_distFromCent - _iToReduce), 0];
    _wp5Pos = [ _wayX + (_distFromCent - _iToReduce), _wayY + (_distFromCent - _iToReduce), 0];
    _iToReduce = _iToReduce + 10;
    sleep 1;
    !(surfaceIsWater _wp1Pos);
};
_iToReduce = 10;
waitUntil {
    _wp2Pos = [ _wayX + (_distFromCent - _iToReduce), _wayY - (_distFromCent - _iToReduce), 0];
    _iToReduce = _iToReduce + 10;
    sleep 1;
    !(surfaceIsWater _wp2Pos);
};
_iToReduce = 10;
waitUntil {
    _wp3Pos = [ _wayX - (_distFromCent - _iToReduce), _wayY - (_distFromCent - _iToReduce), 0];
    _iToReduce = _iToReduce + 10;
    sleep 1;
    !(surfaceIsWater _wp3Pos);
};
_iToReduce = 10;
waitUntil {
    _wp4Pos = [ _wayX - (_distFromCent - _iToReduce), _wayY + (_distFromCent - _iToReduce), 0];
    _iToReduce = _iToReduce + 10;
    sleep 1;
    !(surfaceIsWater _wp4Pos);
};
_iToReduce = 10;
waitUntil {
    _wp1bPos = [ _wayX + (_distFromCent - _iToReduce), _wayY, 0];
    _iToReduce = _iToReduce + 10;
    sleep 1;
    !(surfaceIsWater _wp1bPos);
};
_iToReduce = 10;
waitUntil {
    _wp2bPos = [ _wayX, _wayY - (_distFromCent - _iToReduce), 0];
    _iToReduce = _iToReduce + 10;
    sleep 1;
    !(surfaceIsWater _wp2bPos);
};
_iToReduce = 10;
waitUntil {
    _wp3bPos = [ _wayX - (_distFromCent - _iToReduce), _wayY, 0];
    _iToReduce = _iToReduce + 10;
    sleep 1;
    !(surfaceIsWater _wp3bPos);
};
_iToReduce = 10;
waitUntil {
    _wp4bPos = [ _wayX, _wayY + (_distFromCent - _iToReduce), 0];
    _iToReduce = _iToReduce + 10;
    sleep 1;
    !(surfaceIsWater _wp4bPos);
};

//Spawn in units

_iCount = 0; //_unitCount
waitUntil {
    [_wayX,_wayY,_group,_iCount,_IncludTeamLeader] call TRGM_SERVER_fnc_spawnPatrolUnit;
    _iCount = _iCount + 1;
    sleep 1;
    _iCount > _unitCount;
};
[_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;

//add the waypoints (will start at a random one so it doesnt always start at the same pos (mainly for if we have more than one patrol), and cycle through them all)
private _iWaypointCount = selectRandom[1,2,3,4,5,6,7,8,9];
private _bWaypointsAdded = false;
private _iWaypointLoopCount = 1;
waitUntil {
    if (_iWaypointCount isEqualTo 1) then {
        _wp1 = _group addWaypoint [_wp1Pos, 0];
    };
    if (_iWaypointCount isEqualTo 2) then {
        _wp1b = _group addWaypoint [_wp1bPos, 0];
    };
    if (_iWaypointCount isEqualTo 3) then {
        _wp2 = _group addWaypoint [_wp2Pos, 0];
    };
    if (_iWaypointCount isEqualTo 4) then {
        _wp2b = _group addWaypoint [_wp2bPos, 0];
    };
    if (_iWaypointCount isEqualTo 5) then {
        _wp3 = _group addWaypoint [_wp3Pos, 0];
    };
    if (_iWaypointCount isEqualTo 6) then {
        _wp3b = _group addWaypoint [_wp3bPos, 0];
    };
    if (_iWaypointCount isEqualTo 7) then {
        _wp4 = _group addWaypoint [_wp4Pos, 0];
    };
    if (_iWaypointCount isEqualTo 8) then {
        _wp4b = _group addWaypoint [_wp4bPos, 0];
    };
    if (_iWaypointCount isEqualTo 9) then {
        _wp5 = _group addWaypoint [_wp5Pos, 0];
    };
    _iWaypointCount = _iWaypointCount + 1;
    _iWaypointLoopCount = _iWaypointLoopCount + 1;

    if (_iWaypointLoopCount isEqualTo 10) then {
        _bWaypointsAdded = true;
    };

    if (_iWaypointCount isEqualTo 10) then {
        _iWaypointCount = 1;
    };

    sleep 1;
    _bWaypointsAdded;
};
[_group, 0] setWaypointSpeed "LIMITED";
[_group, 0] setWaypointBehaviour "SAFE";
[_group, 1] setWaypointSpeed "LIMITED";
[_group, 1] setWaypointBehaviour "SAFE";
[_group, 8] setWaypointType "CYCLE";
_group setBehaviour "SAFE";

true;