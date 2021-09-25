// private _fnc_scriptName = "TRGM_SERVER_fnc_setOtherAreaStuff";
///*orangestest

format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


call TRGM_SERVER_fnc_initMissionVars;
private _mainObjPos = TRGM_VAR_ObjectivePositions select 0;

["Mission Events: Comms 10", true] call TRGM_GLOBAL_fnc_log;

//Check if radio tower is near
private _Towers = nearestObjects [_mainObjPos, TRGM_VAR_TowerBuildings, TRGM_VAR_TowerRadius];
_Towers = _Towers + nearestTerrainObjects [_mainObjPos, ["TRANSMITTER"], TRGM_VAR_TowerRadius, false];
private _TowersNear = [];
{
    if !(typeOf _x isEqualTo "") then {
        _TowersNear pushBackUnique _x;
    }
} forEach _Towers;

["Mission Events: Comms 9", true] call TRGM_GLOBAL_fnc_log;
if (count _TowersNear > 0) then {
    ["Mission Events: Comms 8", true] call TRGM_GLOBAL_fnc_log;
    TRGM_VAR_TowerBuild = selectRandom _TowersNear;
    publicVariable "TRGM_VAR_TowerBuild";
    [TRGM_VAR_TowerBuild, [localize "STR_TRGM2_TRENDfncsetOtherAreaStuff_CheckEnemyComms",{[TRGM_VAR_IntelShownType, "CommsTower"] spawn TRGM_GLOBAL_fnc_showIntel;},[TRGM_VAR_TowerBuild]]] remoteExec ["addAction", 0, true];
    TRGM_VAR_TowerClassName = typeOf TRGM_VAR_TowerBuild;
    publicVariable "TRGM_VAR_TowerBuild";
    private _TowerX = position TRGM_VAR_TowerBuild select 0;
    private _TowerY = position TRGM_VAR_TowerBuild select 1;
    private _distanceHQ = getMarkerPos "mrkHQ" distance [_TowerX, _TowerY];

    private _towerMarkrer = createMarker [format["_markerEnemyComms%1",(floor(random 360))], [_TowerX, _TowerY]];
    _towerMarkrer setMarkerShape "ICON";
    _towerMarkrer setMarkerType "hd_unknown";
    _towerMarkrer setMarkerText "Intel";

    ["Mission Events: Comms 7", true] call TRGM_GLOBAL_fnc_log;
    if (_distanceHQ > TRGM_VAR_SideMissionMinDistFromBase) then {
        TRGM_VAR_bHasCommsTower =  true; publicVariable "TRGM_VAR_bHasCommsTower";
        TRGM_VAR_CommsTowerPos =  [_TowerX, _TowerY]; publicVariable "TRGM_VAR_CommsTowerPos";
        private _PatrolDist = 70;
        private _wayX = _TowerX;
        private _wayY = _TowerY;
        private _wp1PosTower = [ _wayX + _PatrolDist, _wayY + _PatrolDist, 0];
        private _wp2PosTower = [ _wayX + _PatrolDist, _wayY - _PatrolDist, 0];
        private _wp3PosTower = [ _wayX - _PatrolDist, _wayY - _PatrolDist, 0];
        private _wp4PosTower = [ _wayX - _PatrolDist, _wayY + _PatrolDist, 0];
        private _wp5PosTower = [ _wayX + _PatrolDist, _wayY + _PatrolDist, 0];

        ["Mission Events: Comms 6", true] call TRGM_GLOBAL_fnc_log;
        if (!(surfaceIsWater _wp1PosTower) && !(surfaceIsWater _wp2PosTower) && !(surfaceIsWater _wp3PosTower) && !(surfaceIsWater _wp4PosTower)) then {
            ["Mission Events: Comms 5", true] call TRGM_GLOBAL_fnc_log;
            //1 in (_maxGroups*2) chance of having an AA/AT guy

            private _DiamPatrolGroupTower = createGroup TRGM_VAR_EnemySide;
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
        ["Mission Events: Comms 4", true] call TRGM_GLOBAL_fnc_log;

        ["Mission Events: Comms 3", true] call TRGM_GLOBAL_fnc_log;

        private _trg = createTrigger ["EmptyDetector", position TRGM_VAR_TowerBuild];
        _trg setVariable ["DelMeOnNewCampaignDay",true];
        _trg setTriggerArea [100, 100, 0, false];
        private _sSTringPos = format["%1,%2", position TRGM_VAR_TowerBuild select 0, position TRGM_VAR_TowerBuild select 1];
        private _sTriggerString = "!alive(nearestObject [[" + _sSTringPos + "], '" + TRGM_VAR_TowerClassName + "'])";

        _trg setTriggerStatements [_sTriggerString, "TRGM_VAR_bCommsBlocked = true; publicVariable ""TRGM_VAR_bCommsBlocked""; [this] spawn TRGM_SERVER_fnc_commsBlocked;", ""];
        ["Mission Events: Comms 2", true] call TRGM_GLOBAL_fnc_log;

        ["Mission Events: Comms 1", true] call TRGM_GLOBAL_fnc_log;
    };
};

["Mission Events: CommsEND", true] call TRGM_GLOBAL_fnc_log;

private _eventsHandles = [];

["Loading Events : 15", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos,1900,false,false,nil, false] spawn TRGM_SERVER_fnc_setTargetEvent);
    sleep 1;
};

["Loading Events : 14", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos,1900,false,false,nil, true] spawn TRGM_SERVER_fnc_setTargetEvent);
    sleep 1;
};

["Loading Events : 13", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setATMineEvent);
    sleep 1;
};

["Loading Events : 12", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setDownCivCarEvent);
    sleep 1;
};

["Loading Events : 11", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setATMineEvent);
    sleep 1;
};
["Loading Events : 10", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance || !isNil("TRGM_VAR_ForceWarZoneLoc")) then {
    if (!isNil("TRGM_VAR_ForceWarZoneLoc")) then {
        _eventsHandles pushBack ([TRGM_VAR_ForceWarZoneLoc,4] spawn TRGM_SERVER_fnc_setFireFightEvent);
    } else {
        _eventsHandles pushBack ([_mainObjPos,4] spawn TRGM_SERVER_fnc_setFireFightEvent);
    };
    sleep 1;
};
["Loading Events : 9", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setMedicalEvent);
    sleep 1;
};
["Loading Events : 8", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setDownedChopperEvent);
    sleep 1;
};
["Loading Events : 7", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setDownConvoyEvent);
    sleep 1;
};
["Loading Events : 6", true] call TRGM_GLOBAL_fnc_log;
if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setDownCivCarEvent);
    sleep 1;
};



//these are more likely to show (instead of using TRGM_VAR_ChanceOfOccurance), as a lot of times, these are not a trap, just an empty vehicle or a pile of rubbish
["Loading Events : 5", true] call TRGM_GLOBAL_fnc_log;
if (random 1 < .66) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent);
    sleep 1;
};
["Loading Events : 4", true] call TRGM_GLOBAL_fnc_log;
if (random 1 < .66) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent);
    sleep 1;
};
["Loading Events : 3", true] call TRGM_GLOBAL_fnc_log;
if (random 1 < .66) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent);
    sleep 1;
};
["Loading Events : 2", true] call TRGM_GLOBAL_fnc_log;
if (random 1 < .66) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent);
    sleep 1;
};
["Loading Events : 1", true] call TRGM_GLOBAL_fnc_log;
if (random 1 < .66) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent);
    sleep 1;
};
["Loading Events : 0", true] call TRGM_GLOBAL_fnc_log;
if (random 1 < .66) then {
    _eventsHandles pushBack ([_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent);
    sleep 1;
};

waitUntil { sleep 5; ({scriptDone _x;} count _eventsHandles) isEqualTo (count _eventsHandles); };

["Loading Events : END", true] call TRGM_GLOBAL_fnc_log;

//worldName call BIS_fnc_mapSize << equals the width in meters
//altis is 30720
//kujari is 16384 wide
//STratis is 8192
private _mapSizeTxt = "LARGE";
private _mapSize = worldName call BIS_fnc_mapSize;
if (_mapSize < 13000) then {
    _mapSizeTxt = "MEDIUM"
};
if (_mapSize < 10000) then {
    _mapSizeTxt = "SMALL"
};

if (TRGM_VAR_IsFullMap) then {
    ["Loading Full Map Events : BEGIN", true] call TRGM_GLOBAL_fnc_log;
    private _fullMapEventsHandles = [];

    _fullMapEventsHandles pushBack ([_mainObjPos,true] spawn TRGM_SERVER_fnc_setDownCivCarEvent);
    _fullMapEventsHandles pushBack ([_mainObjPos,true] spawn TRGM_SERVER_fnc_setDownedChopperEvent);
    _fullMapEventsHandles pushBack ([_mainObjPos,true] spawn TRGM_SERVER_fnc_setATMineEvent);
    _fullMapEventsHandles pushBack ([_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent);
    _fullMapEventsHandles pushBack ([_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent);

    if (_mapSizeTxt isEqualTo "MEDIUM" || _mapSizeTxt isEqualTo "LARGE") then {
        _fullMapEventsHandles pushBack ([_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent);
        _fullMapEventsHandles pushBack ([_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent);
        _fullMapEventsHandles pushBack ([_mainObjPos,true] spawn TRGM_SERVER_fnc_setATMineEvent);
    };
    if (_mapSizeTxt isEqualTo "LARGE") then {
        _fullMapEventsHandles pushBack ([_mainObjPos,true] spawn TRGM_SERVER_fnc_setDownCivCarEvent);
        _fullMapEventsHandles pushBack ([_mainObjPos,true] spawn TRGM_SERVER_fnc_setDownedChopperEvent);
        _fullMapEventsHandles pushBack ([_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent);
    };

    waitUntil { sleep 5; ({scriptDone _x;} count _fullMapEventsHandles) isEqualTo (count _fullMapEventsHandles); };

    ["Loading Full Map Events : END", true] call TRGM_GLOBAL_fnc_log;

};

true;