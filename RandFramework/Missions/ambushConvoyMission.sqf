// private _fnc_scriptName = "MISSIONS_fnc_ambushConvoyMission";
//These are only ever called by the server!

MISSION_fnc_CustomRequired = { //used to set any required details for the AO (example, a wide open space or factory nearby)... if this is not found in AO, the engine will scrap the area and loop around again with a different location
//be careful about using this, some maps may not have what you require, so the engine will never satisfy the requirements here (example, if no airports are on a map and that is what you require)
    private ["_objectiveMainBuilding", "_centralAO_x", "_centralAO_y", "_result", "_flatPos"];
    _objectiveMainBuilding = _this select 0;
    _centralAO_x = _this select 1;
    _centralAO_y = _this select 2;

    _result = false;

    _flatPos = nil;
    _flatPos = [[_centralAO_x,_centralAO_y,0] , 10, 150, 10, 0, 0.3, 0,[],[[_centralAO_x,_centralAO_y],[_centralAO_x,_centralAO_y]]] call TRGM_GLOBAL_fnc_findSafePos;

    if ((_flatPos select 0) > 0) then {_result = true};
    //flatPosDebug = _flatPos;
    _result; //return value
};

MISSION_fnc_CustomVars = { //This is called before the mission function is called below, and the variables below can be adjusted for your mission
    _RequiresNearbyRoad = true;
    _roadSearchRange = 20; //this is how far out the engine will check to make sure a road is within range (if your objective requires a nearby road)
    _allowFriendlyIns = false;
    _MissionTitle = localize "STR_TRGM2_AmbushConvoyMissionTitle"; //this is what shows in dialog mission selection
};

MISSION_fnc_CustomMission = { //This function is the main script for your mission, some if the parameters passed in must not be changed!!!
    /*
     * Parameter Descriptions
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     * _markerType                 : The marker type to be used, you can set the type of marker below, but if the player has selected to hide mission locations, then your marker will not show.
     * _objectiveMainBuilding      : DO NOT EDIT THIS VALUE (this is the main building location selected within your AO)
     * _centralAO_x                : DO NOT EDIT THIS VALUE (this is the X coord of the AO)
     * _centralAO_y                : DO NOT EDIT THIS VALUE (this is the Y coord of the AO)
     * _roadSearchRange            : DO NOT EDIT THIS VALUE (this is the search range for a valid road, set previously in MISSION_fnc_CustomVars)
     * _bCreateTask                : DO NOT EDIT THIS VALUE (this is determined by the player, if the player selected to play a hidden mission, the task is not created!)
     * _iTaskIndex                 : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the index of the task used to determine mission/task completion!)
     * _bIsMainObjective           : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the boolean if the mission is a Heavy or Standard mission!)
     * _args                       : These are additional arguments that might be required for the mission, for an example, see the Destroy Vehicles Mission.
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    params ["_markerType","_objectiveMainBuilding","_centralAO_x","_centralAO_y","_roadSearchRange", "_bCreateTask", "_iTaskIndex", "_bIsMainObjective", ["_args", []]];
    if (_markerType != "empty") then { _markerType = "hd_unknown"; }; // Set marker type here...

    private _hasInformant = random 1 < .50;

    [_hasInformant, _markerType, _objectiveMainBuilding, _centralAO_x, _centralAO_y, _roadSearchRange, _bCreateTask, _iTaskIndex, _bIsMainObjective, _args] spawn {
        params ["_hasInformant", "_markerType","_objectiveMainBuilding","_centralAO_x","_centralAO_y","_roadSearchRange", "_bCreateTask", "_iTaskIndex", "_bIsMainObjective", ["_args", []]];

        _poshVehPos = nil;
        _nearestRoad = nil;
        _direction = nil;
        _nearestRoad = [getPos _objectiveMainBuilding, _roadSearchRange, []] call BIS_fnc_nearestRoad;
        _roadConnectedTo = roadsConnectedTo _nearestRoad;
        if (count _roadConnectedTo > 0) then {
            _connectedRoad = _roadConnectedTo select 0;
            _direction = [_nearestRoad, _connectedRoad] call BIS_fnc_DirTo;
            _poshVehPos = getPos _nearestRoad;
        }
        else {
            _flatPos = nil;
            _flatPos = [getPos _objectiveMainBuilding, 10, 100, 10, 0, 0.3, 0,[],[getPos _objectiveMainBuilding,getPos _objectiveMainBuilding]] call TRGM_GLOBAL_fnc_findSafePos;
            _poshVehPos = _flatPos;
        };

        _convoyStartPosition = [0,0,0];
        waitUntil {
            _convoyStartPosition = [[[getPos _objectiveMainBuilding, 3000]], ["water"], {isOnRoad _this && ((getPos _objectiveMainBuilding) distance _this) > 2000}] call BIS_fnc_randomPos;
            _convoyStartPosition select 0 isNotEqualTo 0 && _convoyStartPosition select 1 isNotEqualTo 0
        };
        _convoyNearestRoad = [_convoyStartPosition, _roadSearchRange, []] call BIS_fnc_nearestRoad;
        _convoyRoadsConnected = roadsConnectedTo _convoyNearestRoad;
        if (count _convoyRoadsConnected > 0) then {
            _convoyConnectedRoad = _convoyRoadsConnected select 0;
            _convoyDirection = [_convoyNearestRoad, _convoyConnectedRoad] call BIS_fnc_DirTo;
            _convoyStartPosition = getPos _convoyNearestRoad;
        }
        else {
            _flatPos = nil;
            _flatPos = [_convoyStartPosition, 10, 100, 10, 0, 0.3, 0,[],[_convoyStartPosition,_convoyStartPosition]] call TRGM_GLOBAL_fnc_findSafePos;
            _convoyStartPosition = _flatPos;
        };

        _convoyStopPositons = [];
        convoyPath = [];
        (calculatePath ["wheeled_APC","safe",_convoyStartPosition,_poshVehPos]) addEventHandler ["PathCalculated", {
            {
                convoyPath pushBack _x;
            } forEach (_this select 1);
        }];

        waitUntil { sleep 2; count convoyPath > 0; };

        {
            if (_forEachIndex mod 25 isEqualTo 0) then {
                private _stopPosition = _x;
                _convoyStopPositons pushBack _stopPosition;
                private _stopMarker = createMarker [format["ConvoyStop%1_%2",count _convoyStopPositons,_iTaskIndex], _stopPosition];
                _stopMarker setMarkerShape "ICON";
                _stopMarker setMarkerType "mil_marker";
                _stopMarker setMarkerText format[localize "STR_TRGM2_Convoy_Stop_N", count _convoyStopPositons];
            };
        } forEach convoyPath;

        convoyPath = nil;

        _convoyVehicleClasses = [call sTank1ArmedCar, selectRandom (call UnarmedScoutVehicles), selectRandom (call UnarmedScoutVehicles), selectRandom (call UnarmedScoutVehicles), call sTank1ArmedCar];
        _HVTGuys = InformantClasses + InterogateOfficerClasses + WeaponDealerClasses;
        _mainHVTClass = selectRandom _HVTGuys;
        _HVTGuys = _HVTGuys - [_mainHVTClass];
        _meetingVehs = (HVTCars + HVTVans) select {getNumber(configFile >> "CfgVehicles" >> _x >> "transportSoldier") >= 3};
        _convoySpeed = 40;
        _convoySeperation = 25;
        _pushThrough = true;

        _convoyArr = [
            TRGM_VAR_EnemySide, // Side of created convoy group
            _convoyVehicleClasses, // Classnames of vehicles to create for convoy (size of this array is also the number of vehicles created)
            _convoyStartPosition, // Spawn position of convoy
            _poshVehPos, // Final destination of convoy
            _mainHVTClass, // Classname of HVT unit
            selectRandom _meetingVehs, // Classname of HVT car
            [selectRandom _HVTGuys, selectRandom _HVTGuys], // Classnames of HVT guards (size of this array is also the number of guards created for HVT, NOTE: Driver is not a "guard" so a safe number of guards is two because we're using vehicles that can hold at least 3 passengers. In this case, two guards and the hvt!)
            _convoyStopPositons, // Additional positions the convoy should move through (using the calculatePath function above allows these to be "natural" points the convoy would drive through)
            _convoySpeed, // Top speed of the convoy
            _convoySeperation, // Distance between convoy vehicles
            _pushThrough // Whether the convoy should stop driving if they encounter contact
        ] call TRGM_GLOBAL_fnc_createConvoy;
        _convoyArr params ["_hvtGroup", "_convoyVehicles", "_hvtVehicle", "_mainHVT", "_finalwp"];

        _sTargetName = format["objInformant%1",_iTaskIndex]; //ignore that it is "objInformant", all objectives have this name, do not change this!
        _mainHVT setVariable [_sTargetName, _mainHVT, true];
        missionNamespace setVariable [_sTargetName, _mainHVT];
        [_mainHVT, [localize "STR_TRGM2_This_Is_Our_Target","{[localize ""STR_TRGM2_This_Is_Our_Target""] call TRGM_GLOBAL_fnc_notify; }",[],10,true,true,"","_this distance _target < 3"]] remoteExec ["addAction", 0, true];
        _mainHVT setCaptive true;
        removeAllWeapons _mainHVT;

        _guardUnit3 = selectRandom ((crew vehicle _mainHVT - [_mainHVT, driver vehicle _mainHVT]) select {typeOf(_x) in (InformantClasses + InterogateOfficerClasses + WeaponDealerClasses)});
        if (!isNil "_guardUnit3") then {
            _sTargetName2 = format["objInformant2_%1",_iTaskIndex];
            _guardUnit3 setVariable [_sTargetName2, _guardUnit3, true];
            missionNamespace setVariable [_sTargetName2, _guardUnit3];
            if (_hasInformant) then {
                [_guardUnit3, [localize "STR_TRGM2_This_Is_Our_Friendly_Agent","{[localize ""STR_TRGM2_This_Is_Our_Friendly_Agent""] call TRGM_GLOBAL_fnc_notify; }",[],10,true,true,"","_this distance _target < 3"]] remoteExec ["addAction", 0, true];
                _guardUnit3 setCaptive true;
                removeAllWeapons _guardUnit3;
            };
        };

        {
            [_x, false] remoteExec ["enableSimulationGlobal", 2];
            [_x, true] remoteExec ["hideObjectGlobal", 2];
            _x setDamage 0;
            _x allowDamage false;
        } forEach units _hvtGroup;
        {
            [_x, false] remoteExec ["enableSimulationGlobal", 2];
            [_x, true] remoteExec ["hideObjectGlobal", 2];
            _x setDamage 0;
            _x allowDamage false;
        } forEach _convoyVehicles;

        waitUntil {sleep 2; TRGM_VAR_bAndSoItBegins && TRGM_VAR_CustomObjectsSet && TRGM_VAR_PlayersHaveLeftStartingArea};

        _iWait = (420 * (_iTaskIndex + 1)) + floor(random 300);
        sleep floor(random 120);
        _sMessageOne = format[localize "STR_TRGM2_ConvoyDueToDepartAt", (daytime  + (_iWait/3600) call BIS_fnc_timeToString)];
        [[TRGM_VAR_FriendlySide, "HQ"],_sMessageOne] remoteExec ["sideChat", 0];
        [_sMessageOne] call TRGM_GLOBAL_fnc_notifyGlobal;

        private _convoyTimerHandle = [_iWait, _iTaskIndex, localize "STR_TRGM2_Time_Until_Convoy_Departs"] spawn TRGM_GLOBAL_fnc_timerGlobal;
        waitUntil {scriptDone _convoyTimerHandle};

        {
            [_x, true] remoteExec ["enableSimulationGlobal", 2];
            [_x, false] remoteExec ["hideObjectGlobal", 2];
            _x setDamage 0;
            _x allowDamage true;
        } forEach _convoyVehicles;
        {
            [_x, true] remoteExec ["enableSimulationGlobal", 2];
            [_x, false] remoteExec ["hideObjectGlobal", 2];
            _x setDamage 0;
            _x allowDamage true;
        } forEach units _hvtGroup;

        _sMessageTwo = format[localize "STR_TRGM2_OnTheWayToAO_PositionMarkedOnMap",name _mainHVT];
        [[TRGM_VAR_FriendlySide, "HQ"],_sMessageTwo] remoteExec ["sideChat", 0];
        [_sMessageTwo] call TRGM_GLOBAL_fnc_notifyGlobal;

        _mrkMeetingHVTMarker = nil;
        _mrkMeetingHVTMarker = createMarker [format["HVT%1",_iTaskIndex], [_hvtVehicle] call TRGM_GLOBAL_fnc_getRealPos];
        _mrkMeetingHVTMarker setMarkerShape "ICON";
        _mrkMeetingHVTMarker setMarkerType "o_inf";
        _mrkMeetingHVTMarker setMarkerText format["HVT %1",name(_mainHVT)];
        [_mainHVT, _hvtVehicle,_mrkMeetingHVTMarker] spawn {
            private _mainHVT = _this select 0;
            private _hvtVehicle = _this select 1;
            private _mrkMeetingHVTMarker = _this select 2;
            waitUntil {
                _mrkMeetingHVTMarker setMarkerPos ([_hvtVehicle] call TRGM_GLOBAL_fnc_getRealPos);
                sleep 5;
                !(alive _hvtVehicle) || !(alive _mainHVT);
            };
        };

        if (_hasInformant && !isNil "_guardUnit3") then {
            [_guardUnit3] spawn {
                private _guardUnit3 = _this select 0;
                waitUntil { sleep 2; vehicle _guardUnit3 isEqualTo _guardUnit3; };
                _guardUnit3 switchMove "Acts_JetsCrewaidLCrouch_in";
                _guardUnit3 disableAI "anim";
                sleep 2.2;
                _guardUnit3 switchMove "Acts_JetsCrewaidLCrouch_out";
                _guardUnit3 enableAI "anim";
                sleep 3;
                _guardUnit3 switchMove "";
                _guardUnit3 call BIS_fnc_ambientAnim__terminate;
            };
            _guardUnit3 setVariable ["MainObjective", _mainHVT, true];
            _guardUnit3 addEventHandler ["Killed", {[((_this select 0) getVariable "MainObjective"), "failed", localize "STR_TRGM2_AmbushConvoyFailedAgentKilledMissionBoard", localize "STR_TRGM2_AmbushConvoyFailedAgentKilledMissionHint", 0.8] spawn TRGM_SERVER_fnc_updateTask; }];
        };

        _mainHVT setVariable ["ObjectiveParams", [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
        missionNamespace setVariable [format ["missionObjectiveParams%1", _iTaskIndex], [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
        [_mainHVT, _iTaskIndex, _bIsMainObjective] spawn {
            private _mainHVT = _this select 0;
            private _iTaskIndex = _this select 1;
            private _bIsMainObjective = _this select 2;
            waitUntil {
                private _mainHVTTrigger = _mainHVT getVariable "TRGM_VAR_hvtTrigger";
                if (!isNil "_mainHVTTrigger") then {
                    deleteVehicle _mainHVTTrigger;
                };
                _mainHVTTrigger = nil;
                _mainHVTTrigger = createTrigger ["EmptyDetector", [_mainHVT] call TRGM_GLOBAL_fnc_getRealPos];
                _mainHVTTrigger setVariable ["DelMeOnNewCampaignDay",true];
                _mainHVTTrigger setTriggerArea [1250, 1250, 0, false];
                _mainHVTTrigger setTriggerActivation [TRGM_VAR_FriendlySideString, format["%1 D", TRGM_VAR_EnemySideString], true];
                _mainHVTTrigger setTriggerStatements ["this && {(time - TRGM_VAR_TimeSinceLastSpottedAction) > (call TRGM_GETTER_fnc_iGetSpottedDelay)}", format["nul = [%1, %2, %3, thisTrigger, thisList] spawn TRGM_GLOBAL_fnc_callNearbyPatrol;",[_mainHVT] call TRGM_GLOBAL_fnc_getRealPos,_iTaskIndex, _bIsMainObjective], ""];
                _mainHVT setVariable ["TRGM_VAR_hvtTrigger", _mainHVTTrigger, true];
                sleep 30;
                !(alive _mainHVT);
            };
            _mainHVTTrigger = _mainHVT getVariable "TRGM_VAR_hvtTrigger";
            if (!isNil "_mainHVTTrigger") then {
                deleteVehicle _mainHVTTrigger;
            };
        };

        if (_bIsMainObjective) then { //if mainobjective (i.e. heavy mission or final campaign mission) we will require team to get document from corpse
            [_mainHVT, [localize "STR_TRGM2_AmbushConvoyMission_TakeDocument",{(_this select 0) spawn TRGM_SERVER_fnc_updateTask;},[_iTaskIndex,_bCreateTask],10,true,true,"","_this distance _target < 3"]] remoteExec ["addAction", 0, true];
        }
        else { //if single mission or side then we can pass this task as soon as HVT is killed
            _mainHVT addEventHandler ["Killed", {(_this select 0) spawn TRGM_SERVER_fnc_updateTask;}];
        };
    };

    _MissionTitle = localize "STR_TRGM2_AmbushConvoyMissionTitle";    //you can adjust this here to change what shows as marker and task text
    _sTaskDescription = localize "STR_TRGM2_AmbushConvoyMissionDescription";
        //adjust this based on veh? and man? if van then if car then?
        //or just random description that will fit all situations??
    if (_bIsMainObjective) then {
        sTaskDescription = _sTaskDescription + (localize "STR_TRGM2_AmbushConvoyMissionDescription2");
    };
    if (_hasInformant) then {
        _sTaskDescription = _sTaskDescription + (localize "STR_TRGM2_AmbushConvoyMissionDescription3");
    };
    _sTaskDescription = _sTaskDescription + (localize "STR_TRGM2_AmbushConvoyMissionDescription4");
};

publicVariable "MISSION_fnc_CustomRequired";
publicVariable "MISSION_fnc_CustomVars";
publicVariable "MISSION_fnc_CustomMission";
