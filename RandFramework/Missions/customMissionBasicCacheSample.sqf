//These are only ever called by the server!

//useful variables
//base location
//mission task locations
//friendly AO camp location
//checkpoint locations and sentry postions
//cleared locations (i.e. AOs that had a task completed)
private _MISSION_LOCAL_fnc_CustomRequired = { //used to set any required details for the AO (example, a wide open space or factory nearby)... if this is not found in AO, the engine will scrap the area and loop around again with a different location
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

private _MISSION_LOCAL_fnc_CustomVars = { //This is called before the mission function is called below, and the variables below can be adjusted for your mission
    _RequiresNearbyRoad = true;
    _roadSearchRange = 250; //this is how far out the engine will check to make sure a road is within range (if your objective requires a nearby road)
    _MissionTitle = "Meeting Assassination";
    _allowFriendlyIns = false;
};

private _MISSION_LOCAL_fnc_CustomMission = { //This function is the main script for your mission, some if the parameters passed in must not be changed!!!
    /*
     * Parameter Descriptions
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     * _markerType                 : The marker type to be used, you can set the type of marker below, but if the player has selected to hide mission locations, then your marker will not show.
     * _objectiveMainBuilding     : DO NOT EDIT THIS VALUE (this is the main building location selected within your AO)
     * _centralAO_x             : DO NOT EDIT THIS VALUE (this is the X coord of the AO)
     * _centralAO_y             : DO NOT EDIT THIS VALUE (this is the Y coord of the AO)
     * _roadSearchRange         : DO NOT EDIT THIS VALUE (this is the search range for a valid road, set previously in _MISSION_LOCAL_fnc_CustomVars)
     * _bCreateTask             : DO NOT EDIT THIS VALUE (this is determined by the player, if the player selected to play a hidden mission, the task is not created!)
     * _iTaskIndex                 : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the index of the task used to determine mission/task completion!)
     * _bIsMainObjective         : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the boolean if the mission is a Heavy or Standard mission!)
     * _args                     : These are additional arguments that might be required for the mission, for an example, see the Destroy Vehicles Mission.
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    params ["_markerType","_objectiveMainBuilding","_centralAO_x","_centralAO_y","_roadSearchRange", "_bCreateTask", "_iTaskIndex", "_bIsMainObjective", ["_args", []]];

    if (_markerType != "empty") then { _markerType = "hd_unknown"; }; // Set marker type here...

    _nearestRoad = nil;
    _nearestRoad = [[_centralAO_x,_centralAO_y], _roadSearchRange, []] call BIS_fnc_nearestRoad;
    _roadConnectedTo = nil;
    _roadConnectedTo = roadsConnectedTo _nearestRoad;
    _objVehicle = selectRandom sideResarchTruck createVehicle [0,0,500];
    _objVehicle setPosATL getPosATL _nearestRoad;

    _objVehicle setVariable ["ObjectiveParams", [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
    missionNamespace setVariable [format ["missionObjectiveParams%1", _iTaskIndex], [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
    [_objVehicle, [localize "STR_TRGM2_startInfMission_MissionTitle2_Button", {_this spawn TRGM_GUI_fnc_downloadData;}, [localize "STR_TRGM2_downloadData_title", true, "TRGM_SERVER_fnc_updateTask", []], 0, true, true, "", "_this isEqualTo player"]] remoteExec ["addAction", 0, true];

    if (count _roadConnectedTo > 0) then {
        _connectedRoad = _roadConnectedTo select 0;
        _direction = [_nearestRoad, _connectedRoad] call BIS_fnc_DirTo;
        _objVehicle setDir (_direction);
    };
    _sTaskDescription = selectRandom["steal research data from bob","John has data, steal it!"];
};

[_MISSION_LOCAL_fnc_CustomRequired, _MISSION_LOCAL_fnc_CustomVars, _MISSION_LOCAL_fnc_CustomMission];
