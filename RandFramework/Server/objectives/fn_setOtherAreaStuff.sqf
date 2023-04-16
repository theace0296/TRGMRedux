// private _fnc_scriptName = "TRGM_SERVER_fnc_setOtherAreaStuff";
params ["_mainObjPos", "_iTaskIndex"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer) exitWith {};

if (isNil "_mainObjPos") then {_mainObjPos = TRGM_VAR_ObjectivePositions select 0;};

if (isNil "_iTaskIndex") then {_iTaskIndex = TRGM_VAR_ObjectivePositions findIf {_x isEqualTo _mainObjPos};};

call TRGM_SERVER_fnc_initMissionVars;

["Mission Events: CommsStart", true] call TRGM_GLOBAL_fnc_log;

//Check if radio tower is near
private _Towers = nearestObjects [_mainObjPos, TRGM_VAR_TowerBuildings, TRGM_VAR_TowerRadius];
_Towers = _Towers + nearestTerrainObjects [_mainObjPos, ["TRANSMITTER"], TRGM_VAR_TowerRadius, false];
private _TowersNear = [];
{
    if !(typeOf _x isEqualTo "") then {
        _TowersNear pushBackUnique _x;
    }
} forEach _Towers;

if (count _TowersNear > 0) then {
    private _TowerBuild = selectRandom _TowersNear;
    missionNamespace setVariable [format ["TRGM_VAR_CommsTower%1", _iTaskIndex], _TowerBuild, true];
    [_TowerBuild, [localize "STR_TRGM2_TRENDfncsetOtherAreaStuff_CheckEnemyComms",{["CommsTower", _this select 3 select 0] spawn TRGM_GLOBAL_fnc_showIntel;},[_iTaskIndex]]] remoteExec ["addAction", 0, true];
    (position _TowerBuild) params ["_TowerX", "_TowerY", "_TowerZ"];
    private _distanceHQ = getMarkerPos "mrkHQ" distance [_TowerX, _TowerY];

    private _towerMarkrer = createMarker [format["_markerEnemyComms%1",(floor(random 360))], [_TowerX, _TowerY]];
    _towerMarkrer setMarkerShape "ICON";
    _towerMarkrer setMarkerType "hd_unknown";
    _towerMarkrer setMarkerText "Intel";

    if (_distanceHQ > TRGM_VAR_SideMissionMinDistFromBase) then {
        TRGM_VAR_bHasCommsTower set [_iTaskIndex, true]; publicVariable "TRGM_VAR_bHasCommsTower";
        private _PatrolDist = 70;
        private _wayX = _TowerX;
        private _wayY = _TowerY;
        private _wp1PosTower = [ _wayX + _PatrolDist, _wayY + _PatrolDist, 0];
        private _wp2PosTower = [ _wayX + _PatrolDist, _wayY - _PatrolDist, 0];
        private _wp3PosTower = [ _wayX - _PatrolDist, _wayY - _PatrolDist, 0];
        private _wp4PosTower = [ _wayX - _PatrolDist, _wayY + _PatrolDist, 0];
        private _wp5PosTower = [ _wayX + _PatrolDist, _wayY + _PatrolDist, 0];

        if (!(surfaceIsWater _wp1PosTower) && !(surfaceIsWater _wp2PosTower) && !(surfaceIsWater _wp3PosTower) && !(surfaceIsWater _wp4PosTower)) then {
            //1 in (_maxGroups*2) chance of having an AA/AT guy
            private _DiamPatrolGroupTower = (createGroup [TRGM_VAR_EnemySide, true]);
                if (random 1 < .50) then {
                    [_DiamPatrolGroupTower, call sAAManToUse, [_wayX, _wayY], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    _iHasAA = 1;
                } else {
                    [_DiamPatrolGroupTower, call sATManToUse, [_wayX, _wayY], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    _iHasAT = 1;
                };
            [_DiamPatrolGroupTower, call sRiflemanToUse, [_wayX, _wayY], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
            if (random 1 < .50) then {[_DiamPatrolGroupTower, call sRiflemanToUse, [_wayX, _wayY], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;};
            if (random 1 < .50) then {[_DiamPatrolGroupTower, call sRiflemanToUse, [_wayX, _wayY], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;};
            if (random 1 < .50) then {[_DiamPatrolGroupTower, call sRiflemanToUse, [_wayX, _wayY], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;};
            if (random 1 < .50) then {[_DiamPatrolGroupTower, call sRiflemanToUse, [_wayX, _wayY], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;};
            [_DiamPatrolGroupTower] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
            private _wp1Tower = _DiamPatrolGroupTower addWaypoint [_wp1PosTower, 0];
            private _wp2Tower = _DiamPatrolGroupTower addWaypoint [_wp2PosTower, 0];
            private _wp3Tower = _DiamPatrolGroupTower addWaypoint [_wp3PosTower, 0];
            private _wp4Tower = _DiamPatrolGroupTower addWaypoint [_wp4PosTower, 0];
            private _wp5Tower = _DiamPatrolGroupTower addWaypoint [_wp5PosTower, 0];
            [_DiamPatrolGroupTower, 0] setWaypointSpeed "LIMITED";
            [_DiamPatrolGroupTower, 0] setWaypointBehaviour "SAFE";
            [_DiamPatrolGroupTower, 1] setWaypointSpeed "LIMITED";
            [_DiamPatrolGroupTower, 1] setWaypointBehaviour "SAFE";
            [_DiamPatrolGroupTower, 4] setWaypointType "CYCLE";
            _DiamPatrolGroupTower setBehaviour "SAFE";
        };

        private _trg = createTrigger ["EmptyDetector", [_TowerX, _TowerY, _TowerZ]];
        _trg setVariable ["DelMeOnNewCampaignDay",true];
        _trg setTriggerArea [100, 100, 0, false];
        private _sTriggerString = format["!alive(missionNamespace getVariable ['TRGM_VAR_CommsTower%1', objNull])", _iTaskIndex];

        _trg setTriggerStatements [_sTriggerString, format ["TRGM_VAR_bCommsBlocked set [%1, true]; publicVariable ""TRGM_VAR_bCommsBlocked""; [this] spawn TRGM_SERVER_fnc_commsBlocked;", _iTaskIndex], ""];
    };
};

["Mission Events: CommsEND", true] call TRGM_GLOBAL_fnc_log;

private _chanceOfOccurance = 0.2;
private _setOtherEventsHandles = [];

if (random 1 < _chanceOfOccurance) then {
    _chanceOfOccurance = _chanceOfOccurance - 0.05;
    private _handle = [_mainObjPos,1900,false,false,nil, false] spawn TRGM_SERVER_fnc_setTargetEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfOccurance) then {
    _chanceOfOccurance = _chanceOfOccurance - 0.05;
    private _handle = [_mainObjPos,1900,false,false,nil, true] spawn TRGM_SERVER_fnc_setTargetEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfOccurance) then {
    _chanceOfOccurance = _chanceOfOccurance - 0.05;
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setATMineEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfOccurance) then {
    _chanceOfOccurance = _chanceOfOccurance - 0.05;
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setDownCivCarEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfOccurance || !isNil("TRGM_VAR_ForceWarZoneLoc")) then {
    if (!isNil("TRGM_VAR_ForceWarZoneLoc")) then {
        private _handle = [TRGM_VAR_ForceWarZoneLoc,4] spawn TRGM_SERVER_fnc_setFireFightEvent;
        _setOtherEventsHandles pushBack _handle;
    } else {
        _chanceOfOccurance = _chanceOfOccurance - 0.05;
        private _handle = [_mainObjPos,4] spawn TRGM_SERVER_fnc_setFireFightEvent;
        _setOtherEventsHandles pushBack _handle;
    };
};

if (random 1 < _chanceOfOccurance) then {
    _chanceOfOccurance = _chanceOfOccurance - 0.05;
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setMedicalEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfOccurance) then {
    _chanceOfOccurance = _chanceOfOccurance - 0.05;
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setDownedChopperEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfOccurance) then {
    _chanceOfOccurance = _chanceOfOccurance - 0.05;
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setDownConvoyEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfOccurance) then {
    _chanceOfOccurance = _chanceOfOccurance - 0.05;
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setDownCivCarEvent;
    _setOtherEventsHandles pushBack _handle;
};



//these are more likely to show (instead of using TRGM_VAR_ChanceOfOccurance), as a lot of times, these are not a trap, just an empty vehicle or a pile of rubbish

private _chanceOfIEDEvent = 0.66;

if (random 1 < _chanceOfIEDEvent) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfIEDEvent) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfIEDEvent) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfIEDEvent) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfIEDEvent) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    _setOtherEventsHandles pushBack _handle;
};

if (random 1 < _chanceOfIEDEvent) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    _setOtherEventsHandles pushBack _handle;
};

waitUntil { sleep 1; ({ scriptDone _x; } count _setOtherEventsHandles) isEqualTo (count _setOtherEventsHandles); };

["Loading Events : END", true] call TRGM_GLOBAL_fnc_log;

true;