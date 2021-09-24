params ["_sidePos","_distFromCent", "_unitCounts","_IncludTeamLeader",["_InsurgentSide", EAST],["_buildingCount", 8]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _unitCount = selectRandom _unitCounts;
private _group = createGroup _InsurgentSide;
private _flatPos = [_sidePos , 100, _distFromCent, 4, 0, 0.5, 0,[],[[0,0,0],[0,0,0]]] call TRGM_GLOBAL_fnc_findSafePos;
private _wayX = (_flatPos select 0);
private _wayY = (_flatPos select 1);
private _allBuildings = nearestObjects [_sidePos, TRGM_VAR_BasicBuildings, _distFromCent];

//Spawn in units
private _iCount = 0; //_unitCount
while {_iCount <= _unitCount} do
{
    [_wayX,_wayY,_group,_iCount,_IncludTeamLeader] call TRGM_SERVER_fnc_spawnPatrolUnit;
    _iCount = _iCount + 1;
    sleep 5;
};

//set waypoints to other buildings
private _iCountWaypoints = 0;
while {_iCountWaypoints <= _buildingCount} do
{
    private _randBuilding2 = selectRandom _allBuildings; //pick one building from our buildings array
    private _allBuildingPos2 = _randBuilding2 buildingPos -1;

    private _wpSideBuildingPatrol = nil;
    try {
        private _wayPosInit = selectRandom _allBuildingPos2;
        if (!isNil "_wayPosInit") then {
            _wpSideBuildingPatrol = _group addWaypoint [_wayPosInit, 0]; //This line has error "0 eleemnts provided, 3 expected"
        }
    } catch {
        [format ["Script issue: %1",selectRandom _allBuildingPos2]] call TRGM_GLOBAL_fnc_notify;
    };
    [_group, _iCountWaypoints] setWaypointSpeed "LIMITED";
    [_group, _iCountWaypoints] setWaypointBehaviour "SAFE";
    if (_iCountWaypoints isEqualTo _buildingCount) then{[_group, 8] setWaypointType "CYCLE";};
    _iCountWaypoints = _iCountWaypoints + 1;
    sleep 5;
};
_group setBehaviour "SAFE";

true;