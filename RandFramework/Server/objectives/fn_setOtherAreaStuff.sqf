// private _fnc_scriptName = "TRGM_SERVER_fnc_setOtherAreaStuff";
params ["_mainObjPos"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer) exitWith {};

if (isNil "_mainObjPos") then {_mainObjPos = TRGM_VAR_ObjectivePositions select 0;};

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

        if (!(surfaceIsWater _wp1PosTower) && !(surfaceIsWater _wp2PosTower) && !(surfaceIsWater _wp3PosTower) && !(surfaceIsWater _wp4PosTower)) then {
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

        private _trg = createTrigger ["EmptyDetector", position TRGM_VAR_TowerBuild];
        _trg setVariable ["DelMeOnNewCampaignDay",true];
        _trg setTriggerArea [100, 100, 0, false];
        private _sSTringPos = format["%1,%2", position TRGM_VAR_TowerBuild select 0, position TRGM_VAR_TowerBuild select 1];
        private _sTriggerString = "!alive(nearestObject [[" + _sSTringPos + "], '" + TRGM_VAR_TowerClassName + "'])";

        _trg setTriggerStatements [_sTriggerString, "TRGM_VAR_bCommsBlocked = true; publicVariable ""TRGM_VAR_bCommsBlocked""; [this] spawn TRGM_SERVER_fnc_commsBlocked;", ""];
    };
};

["Mission Events: CommsEND", true] call TRGM_GLOBAL_fnc_log;

if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    private _handle = [_mainObjPos,1900,false,false,nil, false] spawn TRGM_SERVER_fnc_setTargetEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    private _handle = [_mainObjPos,1900,false,false,nil, true] spawn TRGM_SERVER_fnc_setTargetEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

// if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
//     private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setATMineEvent;
//     waitUntil { sleep 5; scriptDone _handle; };
//     sleep 1;
// };

if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setDownCivCarEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (selectRandom TRGM_VAR_ChanceOfOccurance || !isNil("TRGM_VAR_ForceWarZoneLoc")) then {
    if (!isNil("TRGM_VAR_ForceWarZoneLoc")) then {
        private _handle = [TRGM_VAR_ForceWarZoneLoc,4] spawn TRGM_SERVER_fnc_setFireFightEvent;
        waitUntil { sleep 5; scriptDone _handle; };
    } else {
        private _handle = [_mainObjPos,4] spawn TRGM_SERVER_fnc_setFireFightEvent;
        waitUntil { sleep 5; scriptDone _handle; };
    };
    sleep 1;
};

if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setMedicalEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setDownedChopperEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setDownConvoyEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (selectRandom TRGM_VAR_ChanceOfOccurance) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setDownCivCarEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};



//these are more likely to show (instead of using TRGM_VAR_ChanceOfOccurance), as a lot of times, these are not a trap, just an empty vehicle or a pile of rubbish

if (random 1 < .66) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (random 1 < .66) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (random 1 < .66) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (random 1 < .66) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (random 1 < .66) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

if (random 1 < .66) then {
    private _handle = [_mainObjPos] spawn TRGM_SERVER_fnc_setIEDEvent;
    waitUntil { sleep 5; scriptDone _handle; };
    sleep 1;
};

["Loading Events : END", true] call TRGM_GLOBAL_fnc_log;

true;