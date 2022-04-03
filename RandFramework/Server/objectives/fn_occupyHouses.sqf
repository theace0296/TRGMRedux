// private _fnc_scriptName = "TRGM_SERVER_fnc_occupyHouses";
params ["_sidePos", "_distFromCent", "_unitCounts", ["_InsurgentSide", EAST], ["_bThisMissionCivsOnly", false]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


call TRGM_SERVER_fnc_initMissionVars;

private _unitCount = selectRandom _unitCounts;

private _iCount = 0; //_unitCount
private _allBuildings = nil;
private _sAreaMarkerName = nil;
private _randBuilding = nil;

if (!_bThisMissionCivsOnly) then {
    while {_iCount <= _unitCount} do
    {
        _allBuildings = nearestObjects [_sidePos, ["House"] + TRGM_VAR_BasicBuildings, _distFromCent];
        //_allBuildings = nearestObjects [_sidePos, ["house"], _distFromCent];
        _randBuilding = selectRandom _allBuildings;
        if (!isNil "_randBuilding") then {
            private _randBuildingPos = getPos _randBuilding;
            if ((_randBuilding distance getMarkerPos "mrkHQ") > TRGM_VAR_BaseAreaRange && !(_randBuildingPos in TRGM_VAR_OccupiedHousesPos)) then { //"mrkHQ", TRGM_VAR_BaseAreaRange
            //if ((_randBuilding distance getMarkerPos "mrkHQ") > TRGM_VAR_BaseAreaRange) then { //"mrkHQ", TRGM_VAR_BaseAreaRange

                TRGM_VAR_OccupiedHousesPos = TRGM_VAR_OccupiedHousesPos + [_randBuildingPos];
                //[format["test:%1",(_randBuilding distance getMarkerPos "mrkHQ")]] call TRGM_GLOBAL_fnc_notify;
                //sleep 1;

                private _thisGroup = (createGroup [_InsurgentSide, true]);
                [_thisGroup, (call sRiflemanToUse), position _randBuilding, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                if (random 1 < .50) then {[_thisGroup, (call sRiflemanToUse), position _randBuilding, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;};
                private _teamLeaderUnit = [_thisGroup, (call sTeamleaderToUse),_randBuildingPos,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                [_thisGroup] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
                [_randBuildingPos, units group _teamLeaderUnit, -1, true, false,true] spawn TRGM_SERVER_fnc_zenOccupyHouse;

                private _iCountNoOfCPs = selectRandom[0,0,0,0,1];  //number of checkpoints (so high chance of not being any, or one may be near an occupied building)
                if ((_sidePos distance _randBuilding) > 400) then {_iCountNoOfCPs = selectRandom[0,0,1];};
                //spawn inner random sentrys
                //if (!_bIsMainObjective) then {_iCountNoOfCPs = selectRandom [0,1];};
                if (_iCountNoOfCPs > 0) then {_dAngleAdustPerLoop = 360 / _iCountNoOfCPs;};
                while {_iCountNoOfCPs > 0} do {
                    private _thisAreaRange = 50;
                    private _checkPointGuidePos = _sidePos;
                    _iCountNoOfCPs = _iCountNoOfCPs - 1;
                    private _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                    if !(_flatPos isEqualTo _checkPointGuidePos) then {
                        private _thisPosAreaOfCheckpoint = _flatPos;
                        private _thisRoadOnly = false;
                        private _thisSide = TRGM_VAR_EnemySide;
                        private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                        private _thisAllowBarakade = false;
                        private _thisIsDirectionAwayFromAO = true;
                        [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,false,(call UnarmedScoutVehicles),50,false] spawn TRGM_SERVER_fnc_setCheckpoint;
                    };
                    sleep 1;
                };
            };
        };
        _iCount = _iCount + 1;
    };
};


true;