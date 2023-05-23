// private _fnc_scriptName = "MISSIONS_fnc_bugRadioMission";
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
    _roadSearchRange = 100; //this is how far out the engine will check to make sure a road is within range (if your objective requires a nearby road)
    _MissionTitle = localize "STR_TRGM2_startInfMission_MissionTitle6";
    _allowFriendlyIns = false;
};

private _MISSION_LOCAL_fnc_CustomMission = { //This function is the main script for your mission, some if the parameters passed in must not be changed!!!
    /*
     * Parameter Descriptions
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     * _markerType                 : The marker type to be used, you can set the type of marker below, but if the player has selected to hide mission locations, then your marker will not show.
     * _objectiveMainBuilding      : DO NOT EDIT THIS VALUE (this is the main building location selected within your AO)
     * _centralAO_x                : DO NOT EDIT THIS VALUE (this is the X coord of the AO)
     * _centralAO_y                : DO NOT EDIT THIS VALUE (this is the Y coord of the AO)
     * _roadSearchRange            : DO NOT EDIT THIS VALUE (this is the search range for a valid road, set previously in _MISSION_LOCAL_fnc_CustomVars)
     * _bCreateTask                : DO NOT EDIT THIS VALUE (this is determined by the player, if the player selected to play a hidden mission, the task is not created!)
     * _iTaskIndex                 : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the index of the task used to determine mission/task completion!)
     * _bIsMainObjective           : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the boolean if the mission is a Heavy or Standard mission!)
     * _args                       : These are additional arguments that might be required for the mission, for an example, see the Destroy Vehicles Mission.
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    params ["_markerType","_objectiveMainBuilding","_centralAO_x","_centralAO_y","_roadSearchRange", "_bCreateTask", "_iTaskIndex", "_bIsMainObjective", ["_args", []]];
    if (_markerType != "empty") then { _markerType = "hd_unknown"; }; // Set marker type here...

    //###################################### BUG RADIO ######################################
    ["Mission Setup: 8-3", true] call TRGM_GLOBAL_fnc_log;
    _allpositionsRadio1 = _objectiveMainBuilding buildingPos -1;
    _sRadio1Name = format["objRadio%1",_iTaskIndex];
    _objRadio1 = selectRandom SideRadioClassNames createVehicle [0,0,500];
    _objRadio1 setVariable [_sRadio1Name, _objRadio1, true];
    missionNamespace setVariable [_sRadio1Name, _objRadio1];
    _objRadio1 setPosATL (selectRandom _allpositionsRadio1);

    _objRadio1 setVariable ["taskIndex", _iTaskIndex, true];
    _objRadio1 setVariable ["createTask", _bCreateTask, true];
    _objRadio1 setVariable ["ObjectiveParams", [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
    missionNamespace setVariable [format ["missionObjectiveParams%1", _iTaskIndex], [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];

    [_objRadio1, [localize "STR_TRGM2_startInfMission_MissionTitle6_Button", {_this spawn TRGM_GUI_fnc_downloadData;}, [localize "STR_TRGM2_downloadData_title", true, "TRGM_SERVER_fnc_bugRadio", []], 0, true, true, "", "_this isEqualTo player"]] remoteExec ["addAction", 0, true];

    TRGM_LOCAL_fnc_radioLoop = {
        _radio = _this select 0;
        _bPlay = true;
        waitUntil {
            if (!alive _radio) then {_bPlay = false};
            playSound3D ["A3\Sounds_F\sfx\radio\" + selectRandom TRGM_VAR_EnemyRadioSounds + ".wss",_radio,false,getPosASL _radio,0.5,1,0];
            sleep selectRandom [10,15,20,30];
            !_bPlay || isNil "_radio";
        };
    };
    [_objRadio1] spawn TRGM_LOCAL_fnc_radioLoop;
    _sTaskDescription = selectRandom[(localize "STR_TRGM2_startInfMission_MissionTitle6_Desc")];
};

[_MISSION_LOCAL_fnc_CustomRequired, _MISSION_LOCAL_fnc_CustomVars, _MISSION_LOCAL_fnc_CustomMission];
