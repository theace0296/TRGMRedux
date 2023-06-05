// private _fnc_scriptName = "MISSIONS_fnc_defuseIEDsMission";
// These are only ever called by the server!

// MISSION 13: Defuse IEDs

private _MISSION_local_fnc_CustomRequired = {
    // used to set any required details for the AO (example, a wide open space or factory nearby)... if this is not found in AO, the engine will scrap the area and loop around again with a different location
    // be careful about using this, some maps may not have what you require, so the engine will never satisfy the requirements here (example, if no airports are on a map and that is what you require)
    private ["_objectiveMainBuilding", "_centralAO_x", "_centralAO_y", "_result", "_flatPos"];
    _objectiveMainBuilding = _this select 0;
    _centralAO_x = _this select 1;
    _centralAO_y = _this select 2;

    _result = true;
    // always returing true, because we have in custom vars "_RequiresNearbyRoad" which will take care of our checks
    _result;
    // return value
};

private _MISSION_LOCAL_fnc_CustomVars = {
    // This is called before the mission function is called below, and the variables below can be adjusted for your mission
    _RequiresNearbyRoad = true;
    _roadSearchRange = 100;
    // this is how far out the engine will check to make sure a road is within range (if your objective requires a nearby road)
    _allowFriendlyins = false;
    _MissionTitle = localize "str_TRGM2_IEDMissionTitle";
    // this is what shows in dialog mission selection
};

private _MISSION_LOCAL_fnc_CustomMission = {
    // This function is the main script for your mission, some if the parameters passed in must not be changed!!!
    /*
    * parameter Descriptions
    * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    * _markertype : The marker type to be used, you can set the type of marker below, but if the player has selected to hide mission locations, then your marker will not show.
    * _objectiveMainBuilding : do not EDIT THIS VALUE (this is the main building location selected within your AO)
    * _centralAO_x : do not EDIT THIS VALUE (this is the X coord of the AO)
    * _centralAO_y : do not EDIT THIS VALUE (this is the Y coord of the AO)
    * _roadSearchRange : do not EDIT THIS VALUE (this is the search range for a valid road, set previously in _MISSION_LOCAL_fnc_CustomVars)
    * _bcreateTask : do not EDIT THIS VALUE (this is determined by the player, if the player selected to play a hidden mission, the task is not created!)
    * _iTaskindex : do not EDIT THIS VALUE (this is determined by the engine, and is the index of the task used to determine mission/task completion!)
    * _bIsMainObjective : do not EDIT THIS VALUE (this is determined by the engine, and is the boolean if the mission is a Heavy or Standard mission!)
    * _args : These are additional arguments that might be required for the mission, for an example, see the Destroy vehicles Mission.
    * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    params ["_markertype", "_objectiveMainBuilding", "_centralAO_x", "_centralAO_y", "_roadSearchRange", "_bcreateTask", "_iTaskindex", "_bIsMainObjective", ["_args", []]];
    if (_markertype != "empty") then {
        _markertype = "hd_unknown";
    };
    // set marker type here...

    _compactIedtargets = call TRGM_GETTER_fnc_bCompactTargetMissions;

    _spacingBetweentargets = 1500;
    if (_compactIedtargets) then {
        _spacingBetweentargets = 150
    };

    // _MissionTitle = format["Meeting Assassination: %1", name(_mainHVT)];
    //you can adjust this here to change what shows as marker and task text
    _staskDescription = selectRandom[localize "str_TRGM2_IEDMissionDescription"];
    // adjust this based on veh? and man? if van then if car then?

    _mainObjPos = getPos _objectiveMainBuilding;

    _IEDtype = selectRandom ["CAR", "RUBBLE"];
    _ieds = nil;
    if (_IEDtype isEqualto "CAR") then {
        _ieds = CivCars;
    };
    if (_IEDtype isEqualto "RUBBLE") then {
        _ieds = TRGM_VAR_IEDFakeclassnames;
    };

    _IED1 = createvehicle [selectRandom _ieds, [0, 0, 0], [], 0, "NONE"];
    _sTargetname1 = format["objinformant%1", _iTaskindex];
    _IED1 setVariable [_sTargetname1, _IED1, true];
    missionnamespace setVariable [_sTargetname1, _IED1];
    _IED1 setVariable ["Objectiveparams", [_markertype, _objectiveMainBuilding, _centralAO_x, _centralAO_y, _roadSearchRange, _bcreateTask, _iTaskindex, _bIsMainObjective, _args]];
    missionnamespace setVariable [format ["missionObjectiveparams%1", _iTaskindex], [_markertype, _objectiveMainBuilding, _centralAO_x, _centralAO_y, _roadSearchRange, _bcreateTask, _iTaskindex, _bIsMainObjective, _args]];
    [_mainObjPos, 100, true, true, _IED1, _IEDtype] spawn TRGM_SERVER_fnc_setIEDEvent;

    _IED2 = createvehicle [selectRandom _ieds, [-25, -25, 0], [], 0, "NONE"];
    _sTargetname2 = format["objinformant2_%1", _iTaskindex];
    _IED2 setVariable [_sTargetname2, _IED2, true];
    missionnamespace setVariable [_sTargetname2, _IED2];
    [_mainObjPos, _spacingBetweentargets, true, true, _IED2, _IEDtype] spawn TRGM_SERVER_fnc_setIEDEvent;

    _IED3 = createvehicle [selectRandom _ieds, [-50, -50, 0], [], 0, "NONE"];
    _sTargetname3 = format["objinformant3_%1", _iTaskindex];
    _IED3 setVariable [_sTargetname3, _IED3, true];
    missionnamespace setVariable [_sTargetname3, _IED3];
    [_mainObjPos, _spacingBetweentargets, true, true, _IED3, _IEDtype] spawn TRGM_SERVER_fnc_setIEDEvent;

    _allIEDs = [_IED1, _IED2, _IED3];
    [_allIEDs] spawn {
        private _allIEDs = _this select 0;
        waitUntil {
            ({
                _x getVariable ["isDefused", false]
            } count _allIEDs) isEqualto (count _allIEDs);
        };
        [_allIEDs select 0] spawn TRGM_SERVER_fnc_updateTask;
    };
};

[_MISSION_local_fnc_CustomRequired, _MISSION_LOCAL_fnc_CustomVars, _MISSION_LOCAL_fnc_CustomMission];