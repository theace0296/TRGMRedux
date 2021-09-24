// private _fnc_scriptName = "TRGM_SERVER_fnc_aoCampCreator";

format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


if (isServer) then {

    private _mainAOPos = TRGM_VAR_ObjectivePositions select 0;
    TRGM_VAR_HQPos = getMarkerPos "mrkHQ";

    private _flatPos = nil;
    if (isNil "TRGM_VAR_AOCampLocation") then {
        _flatPos = [_mainAOPos , 1300, 1700, 8, 0, 0.3, 0,TRGM_VAR_AreasBlackList,[TRGM_VAR_HQPos,TRGM_VAR_HQPos]] call TRGM_GLOBAL_fnc_findSafePos;
        if (str(_flatPos) isEqualTo "[0,0,0]") then {_flatPos = [_mainAOPos , 1300, 2000, 8, 0, 0.4, 0,TRGM_VAR_AreasBlackList,[TRGM_VAR_HQPos,TRGM_VAR_HQPos]] call TRGM_GLOBAL_fnc_findSafePos;};
    //"Marker1" setMarkerPos _flatPos;
    }
    else {
        _flatPos = TRGM_VAR_AOCampLocation;
    };

    private _nearestAOStartRoads = _flatPos nearRoads 60;
    private _bAOStartRoadFound = false;
    if (count _nearestAOStartRoads > 0) then {
        _bAOStartRoadFound = true;

        private _thisPosAreaOfCheckpoint = _flatPos;
        private _thisRoadOnly = true;
        private _thisSide = TRGM_VAR_FriendlySide;
        private _thisUnitTypes = (call FriendlyCheckpointUnits);
        private _thisAllowBarakade = true;
        private _thisIsDirectionAwayFromAO = false;
        [_flatPos,_flatPos,50,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call FriendlyScoutVehicles),500] spawn TRGM_SERVER_fnc_setCheckpoint;
    };

    ["Mission Setup: 5", true] call TRGM_GLOBAL_fnc_log;

    TRGM_VAR_AOCampPos = _flatPos;
    publicVariable "TRGM_VAR_AOCampPos";
    private _markerFastResponseStart = createMarker ["mrkFastResponseStart", _flatPos];
    _markerFastResponseStart setMarkerShape "ICON";

    private _hideAoMarker = false;
    if (!isNil "TRGM_VAR_HideAoMarker") then {
        _hideAoMarker = TRGM_VAR_HideAoMarker;
    };
    if (_hideAoMarker) then {
        _markerFastResponseStart setMarkerType "empty";
    }
    else {
        _markerFastResponseStart setMarkerType "hd_dot";
    };

    _markerFastResponseStart setMarkerText (localize "STR_TRGM2_startInfMission_KiloCamp");
    //k1Car1 setPos _flatPos;
    //k1Car2 setPos _flatPos;

    private _behindBlockPos = _flatPos;
    private _flatPosCampFire = _behindBlockPos;

    if (!TRGM_VAR_AOCampOnlyAmmoBox) then {
        if (!_bAOStartRoadFound) then {

            private _campFire = "Campfire_burning_F" createVehicle _flatPosCampFire;
            _campFire setDir (floor(random 360));

            private _flatPosTent1 = [_flatPosCampFire , 5, 10, 5, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],"Land_TentA_F"] call TRGM_GLOBAL_fnc_findSafePos;
            private _Tent1 = "Land_TentA_F" createVehicle _flatPosTent1;
            _Tent1 setDir (floor(random 360));

            private _flatPos2 = [_flatPosCampFire , 5, 10, 5, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],"Land_TentA_F"] call TRGM_GLOBAL_fnc_findSafePos;
            private _Tent2 = "Land_TentA_F" createVehicle _flatPos2;
            _Tent2 setDir (floor(random 360));

            [_Tent1, [localize "STR_TRGM2_startInfMission_RemoveVehicleFromTent",{_veh = selectRandom TRGM_VAR_SmallTransportVehicle createVehicle (getPos (_this select 0));}]] remoteExec ["addAction", 0];
            [_Tent2, [localize "STR_TRGM2_startInfMission_RemoveVehicleFromTent",{_veh = selectRandom TRGM_VAR_SmallTransportVehicle createVehicle (getPos (_this select 0));}]] remoteExec ["addAction", 0];
            //_Tent1 addAction [localize "STR_TRGM2_startInfMission_RemoveVehicleFromTent",{_veh = selectRandom TRGM_VAR_SmallTransportVehicle createVehicle (getPos (_this select 0));}];
            //_Tent2 addAction [localize "STR_TRGM2_startInfMission_RemoveVehicleFromTent",{_veh = selectRandom TRGM_VAR_SmallTransportVehicle createVehicle (getPos (_this select 0));}];

            private _flatPos4 = [_flatPosCampFire , 5, 10, 5, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],"Land_WoodPile_F"] call TRGM_GLOBAL_fnc_findSafePos;
            private _Tent4 = "Land_WoodPile_F" createVehicle _flatPos4;
            _Tent4 setDir (floor(random 360));
        };



        if (TRGM_VAR_iMissionIsCampaign) then {
            private _flatPos4b = [_flatPosCampFire , 5, 10, 3, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],endMissionBoard2] call TRGM_GLOBAL_fnc_findSafePos;
            endMissionBoard2 setPos _flatPos4b;
            private _boardDirection = [_flatPosCampFire, endMissionBoard2] call BIS_fnc_DirTo;
            endMissionBoard2 setDir _boardDirection;

        };

        private _flatPos5 = [_flatPosCampFire, 12, 30, 12, 0, 0.5, 0,[],[[0,0,0],[0,0,0]],selectRandom (call FriendlyFastResponseVehicles)] call TRGM_GLOBAL_fnc_findSafePos;
        //_car1 = selectRandom (call FriendlyFastResponseVehicles) createVehicle _flatPos5;
        private _car1 = createVehicle [selectRandom (call FriendlyFastResponseVehicles), _flatPos5, [], 50, "NONE"];
        _car1 allowDamage false;
        _car1 setDir (floor(random 360));

        private _flatPos6 = [_flatPosCampFire, 12, 30, 12, 0, 0.5, 0,[],[[0,0,0],[0,0,0]],selectRandom (call FriendlyFastResponseVehicles)] call TRGM_GLOBAL_fnc_findSafePos;
        //_car2 = selectRandom (call FriendlyFastResponseVehicles) createVehicle _flatPos6;
        private _car2 = createVehicle [selectRandom (call FriendlyFastResponseVehicles), _flatPos5, [], 50, "NONE"];
        _car2 allowDamage false;
        _car2 setDir (floor(random 360));

        sleep 1;
        _car1 allowDamage true;
        _car2 allowDamage true;

        [_car1, [localize "STR_TRGM2_startInfMission_UnloadDingy",{[_this select 0, _this select 1, _this select 2, _this select 3] spawn TRGM_GLOBAL_fnc_unloadDingy;}]] remoteExec ["addAction", 0];
        [_car2, [localize "STR_TRGM2_startInfMission_UnloadDingy",{[_this select 0, _this select 1, _this select 2, _this select 3] spawn TRGM_GLOBAL_fnc_unloadDingy;}]] remoteExec ["addAction", 0];
        [_car1,TRGM_VAR_FastResponseCarItems] call bis_fnc_initAmmoBox;
        [_car2,TRGM_VAR_FastResponseCarItems] call bis_fnc_initAmmoBox;
    };

    private _flatPos7 = [_flatPosCampFire, 5, 12, 5, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos],"C_T_supplyCrate_F"] call TRGM_GLOBAL_fnc_findSafePos;
    private _AmmoBox1 = "C_T_supplyCrate_F" createVehicle _flatPos7;
    _AmmoBox1 allowDamage false;
    _AmmoBox1 setDir (floor(random 360));

    [_AmmoBox1] call TRGM_GLOBAL_fnc_initAmmoBox;

    ["Mission Setup: 4", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;
    if (TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_VIRTUAL_ARSENAL_IDX isEqualTo 1) then {
        [_AmmoBox1, [localize "STR_TRGM2_startInfMission_VirtualArsenal",{["Open",true] spawn BIS_fnc_arsenal}]] remoteExec ["addAction", 0];
    };

    if (TRGM_VAR_ISUNSUNG) then {
        private _radio = selectRandom ["uns_radio2_radio","uns_radio2_transitor","uns_radio2_transitor02"] createVehicle _flatPos7;
    };

    ["Mission Setup: 3.7", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;

    //sl setPos [7772.8,20744.6,0];
    /*HERE WHY THIS CAUSE MASSIVE SLOWDOWN??????????????????????????????????????? */
    // _flatPosUnits = _flatPosCampFire;
    // ["Mission Setup: 3.5", true] call TRGM_GLOBAL_fnc_log;
    // sleep 1;

    // _flatPosUnits = [_flatPosCampFire, 8, 17, 10, 0, 0.5, 0,[],[_behindBlockPos,_behindBlockPos]] call TRGM_GLOBAL_fnc_findSafePos;

    // ["Mission Setup: 3.3", true] call TRGM_GLOBAL_fnc_log;
    // sleep 1;

    /* HERE ... why when this is uncommented does it cause slowdown?????
    //try create seperate file, and run this manually after fully loaded???

    //AOCampPos
    if (!isnil "sl") then {sl setPos _flatPosUnits};
    ["Mission Setup: 3.1.7", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;

    if (!isnil "k1_2") then {k1_2 setPos _flatPosUnits};
    ["Mission Setup: 3.1.6", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;

    if (!isnil "k1_3") then {k1_3  setPos _flatPosUnits};
    ["Mission Setup: 3.1.5", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;

    if (!isnil "k1_4") then {k1_4  setPos _flatPosUnits};
    ["Mission Setup: 3.1.4", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;

    if (!isnil "k1_5") then {k1_5  setPos _flatPosUnits};
    ["Mission Setup: 3.1.3", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;

    if (!isnil "k1_6") then {k1_6  setPos _flatPosUnits};
    ["Mission Setup: 3.1.2", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;

    if (!isnil "k1_7") then {k1_7  setPos _flatPosUnits};
    ["Mission Setup: 3.1.1", true] call TRGM_GLOBAL_fnc_log;
    sleep 1;
    //*/

    // TRGM_VAR_MissionLoaded =  true; publicVariable "TRGM_VAR_MissionLoaded";

    ["Mission Setup: 3", true] call TRGM_GLOBAL_fnc_log;
    [""] remoteExecCall ["Hint", 0];
};

true;