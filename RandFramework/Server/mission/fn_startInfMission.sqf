// private _fnc_scriptName = "TRGM_SERVER_fnc_startInfMission";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer) exitWith {};

[35, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

["Mission Setup: 16", true] call TRGM_GLOBAL_fnc_log;

call TRGM_SERVER_fnc_initMissionVars;

//This is only ever called on server!!!!
["Mission Setup: 15", true] call TRGM_GLOBAL_fnc_log;

TRGM_Logic setVariable ["DeathRunning", false, true];
TRGM_Logic setVariable ["PointsUpdating", false, true];


["Mission Setup: 14.5", true] call TRGM_GLOBAL_fnc_log;

private _ThisTaskTypes = nil;
private _IsMainObjs = nil;
private _MarkerTypes = nil;
private _CreateTasks = nil;
private _HasHiddenObjective = false;
private _HasNonHiddenObjective = true;
private _SamePrevAOStats = nil;
private _bIsCampaign = false;
private _bIsCampaignFinalMission = false;
private _bSideMissionsCivOnly = nil;

private _MainMissionTasksToUse = TRGM_VAR_MainMissionTasks;
private _SideMissionTasksToUse = TRGM_VAR_SideMissionTasks;
private _MissionsThatHaveIntel = TRGM_VAR_MissionsThatHaveIntel;

["Mission Setup: 14", true] call TRGM_GLOBAL_fnc_log;

if (TRGM_VAR_iMissionIsCampaign) then {
    private _totalRep = [TRGM_VAR_MaxBadPoints - TRGM_VAR_BadPoints,1] call BIS_fnc_cutDecimals;
    if (_totalRep >= 10) then {
        if !(isNil "TRGM_VAR_MainObjectivesToExcludeFromCampaign") then {
            _MainMissionTasksToUse = TRGM_VAR_MainMissionTasks - TRGM_VAR_MainObjectivesToExcludeFromCampaign;
        };
        if !(isNil "TRGM_VAR_SideObjectivesToExcludeFromCampaign") then {
            _SideMissionTasksToUse = TRGM_VAR_SideMissionTasks - TRGM_VAR_SideObjectivesToExcludeFromCampaign;
        };
        _ThisTaskTypes = [selectRandom _MainMissionTasksToUse, selectRandom _MissionsThatHaveIntel, selectRandom _SideMissionTasksToUse];
        _IsMainObjs = [true,false,false]; //if false, then chacne of no enemu, or civs only etc.... if true, then more chacne of bad shit happening
        _MarkerTypes = ["mil_objective","hd_dot","hd_dot"];
        _CreateTasks = [true,false,false];
        _SamePrevAOStats = [false,false,false];
        _bSideMissionsCivOnly = [false,false,false];
        _bIsCampaignFinalMission = true;
    } else {
        if (random 1 < .33) then {
            _ThisTaskTypes = [selectRandom _SideMissionTasksToUse, 4];
            _IsMainObjs = [false,false]; //if false, then chacne of no enemu, or civs only etc.... if true, then more chacne of bad shit happening
            _MarkerTypes = ["mil_objective","hd_dot"];
            _CreateTasks = [true,false];
            _SamePrevAOStats = [false,false];
            _bSideMissionsCivOnly = [false,true];
        } else {
            _ThisTaskTypes = [selectRandom _SideMissionTasksToUse];
            _IsMainObjs = [false]; //if false, then chacne of no enemu, or civs only etc.... if true, then more chacne of bad shit happening
            _MarkerTypes = ["mil_objective"];
            _CreateTasks = [true];
            _SamePrevAOStats = [false];
            _bSideMissionsCivOnly = [false];
        };
    };
    _bIsCampaign = true;
} else {
    _ThisTaskTypes = [];
    _IsMainObjs = [];
    _MarkerTypes = [];
    _CreateTasks = [];
    _SamePrevAOStats = [];
    _bSideMissionsCivOnly = [];
    _HasHiddenObjective = false;
    _HasNonHiddenObjective = false;
    {
        _x params ["_taskType", "_isHeavy", "_isHidden", "_sameAOAsPrev"];
        if (_taskType isEqualTo 0) then {
            if (_isHeavy) then {
                _ThisTaskTypes = _ThisTaskTypes + [selectRandom _MainMissionTasksToUse];
            } else {
                _ThisTaskTypes = _ThisTaskTypes + [selectRandom _SideMissionTasksToUse];
            };
        } else {
            _ThisTaskTypes = _ThisTaskTypes + [_taskType];
        };
        _IsMainObjs = _IsMainObjs + [_isHeavy];
        private _markerType = ["hd_dot", "mil_objective"] select (_isHeavy);
        if (_isHidden) then {
            _markerType = "empty";
            _HasHiddenObjective = true;
        } else {
            _HasNonHiddenObjective = true;
        };
        _MarkerTypes = _MarkerTypes + [_markerType];
        _CreateTasks = _CreateTasks + [_isHidden];
        _SamePrevAOStats = _SamePrevAOStats + [_sameAOAsPrev];
        private _civOnly = [false, !_isHeavy] select (_taskType isEqualTo 4 && random 1 < .33);
        _bSideMissionsCivOnly = _bSideMissionsCivOnly + [_civOnly];
    } forEach TRGM_VAR_iMissionParamObjectives;

    if (_HasHiddenObjective || {({ _x in TRGM_VAR_MissionsThatHaveIntel; } count _ThisTaskTypes) < 1}) then {
        _ThisTaskTypes = _ThisTaskTypes + [4];
        _IsMainObjs = _IsMainObjs + [false];
        _MarkerTypes = _MarkerTypes + ["hd_dot"];
        _CreateTasks = _CreateTasks + [false];
        _SamePrevAOStats = _SamePrevAOStats + [false];
        _bSideMissionsCivOnly = _bSideMissionsCivOnly + [true];
    };

    TRGM_VAR_MaxBadPoints = 1;
};

TRGM_VAR_MissionParamsSet =  true; publicVariable "TRGM_VAR_MissionParamsSet";

["Mission Setup: 13", true] call TRGM_GLOBAL_fnc_log;

publicVariable "TRGM_VAR_MaxBadPoints";

private _usedLocations = [];
private _randInfor1X = nil;
private _randInfor1Y = nil;
private _buildings = nil;

["Mission Setup: Gatherthing map info", true] call TRGM_GLOBAL_fnc_log;

if (isNil "TRGM_VAR_allLocationPositions") then {
    private _worldName = worldName;
    TRGM_VAR_allLocationPositionsMap = profileNamespace getVariable "TRGM_VAR_allLocationPositionsMap";
    if !(TRGM_VAR_allLocationPositionsMap isEqualType createHashMap) then {
        TRGM_VAR_allLocationPositionsMap = createHashMap;
    };
    TRGM_VAR_allLocationPositions = TRGM_VAR_allLocationPositionsMap get _worldName;
    private _LocationVersion = profileNamespace getVariable ["TRGM_VAR_LocationVersion", 0];

    TRGM_VAR_bRecalculateLocationData = [false, true] select ((["RecalculateLocationData", 0] call BIS_fnc_getParamValue) isEqualTo 1);
    TRGM_VAR_bRecalculateLocationData = [TRGM_VAR_bRecalculateLocationData, true] select !(TRGM_VAR_LocationVersion isEqualTo _LocationVersion);

    if (TRGM_VAR_bRecalculateLocationData) then {
        TRGM_VAR_allLocationPositionsMap = createHashMap;
    };

    if (isNil "TRGM_VAR_allLocationPositions" || TRGM_VAR_bRecalculateLocationData) then {
        private _allLocationTypes = ("true" configClasses (configFile >> "CfgLocationTypes")) apply {configName _x;};
        private _allLocations = nearestLocations [(getMarkerPos "mrkHQ"), _allLocationTypes, worldSize];

        TRGM_VAR_allLocationPositions = [];
        {
            private _position = [(locationPosition _x) select 0, (locationPosition _x) select 1];
            if (_position in TRGM_VAR_allLocationPositions) then {continue;};
            if ({(_position distance _x) < 1000;} count TRGM_VAR_allLocationPositions > 0) then {continue;};
            if (count nearestObjects [_position, TRGM_VAR_BasicBuildings, 200] <= 0) then {continue;};
            TRGM_VAR_allLocationPositions pushBack _position;
        } forEach (_allLocations call TRGM_GLOBAL_fnc_fisherYatesShuffleArray);

        TRGM_VAR_allLocationPositionsMap set [_worldName, +TRGM_VAR_allLocationPositions];
        profileNamespace setVariable ["TRGM_VAR_LocationVersion", TRGM_VAR_LocationVersion];
        profileNamespace setVariable ["TRGM_VAR_allLocationPositionsMap", TRGM_VAR_allLocationPositionsMap];
        profileNamespace setVariable ["TRGM_VAR_allLocationPositions", nil];
        saveProfileNamespace;
    };
    TRGM_VAR_allLocationPositions = TRGM_VAR_allLocationPositions select {((getMarkerPos "mrkHQ") distance _x) > TRGM_VAR_SideMissionMinDistFromBase};
    publicVariable "TRGM_VAR_allLocationPositions";
};

["Mission Setup: Map info collected", true] call TRGM_GLOBAL_fnc_log;

["Mission Setup: 12.5", true] call TRGM_GLOBAL_fnc_log;

[45, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

private _populateAOHandles = [];

waitUntil {
    private _iTaskIndex = TRGM_VAR_InfTaskCount;
    if (_bIsCampaign) then {
        _iTaskIndex = (TRGM_VAR_iCampaignDay - 1) + TRGM_VAR_InfTaskCount;
    }
    else {
        _iTaskIndex = TRGM_VAR_InfTaskCount;
    };

    TRGM_VAR_bCommsBlocked set [_iTaskIndex, false];
    publicVariable "TRGM_VAR_bCommsBlocked";

    private _iThisTaskType = _ThisTaskTypes select TRGM_VAR_InfTaskCount;

    private _bIsMainObjective = _IsMainObjs select TRGM_VAR_InfTaskCount; if (isNil "_bIsMainObjective") then { _bIsMainObjective = false; }; //more chance of bad things, and set middle area stuff around (comms, base etc...)
    private _MarkerType = _MarkerTypes select TRGM_VAR_InfTaskCount; if (isNil "_MarkerType") then { _MarkerType = "hd_dot"; };//"Empty" or other
    private _bCreateTask = _CreateTasks select TRGM_VAR_InfTaskCount; if (isNil "_bCreateTask") then { _bCreateTask = true; };
    private _bIsHidden = _MarkerType isEqualTo "empty"; if (isNil "_bIsHidden") then { _bIsHidden = false; };
    private _SamePrevAO = _SamePrevAOStats select TRGM_VAR_InfTaskCount; if (isNil "_SamePrevAO") then { _SamePrevAO = false; };
    private _allowFriendlyIns = true;
    private _bSideMissionsCivOnlyToUse = _bSideMissionsCivOnly select TRGM_VAR_InfTaskCount;

    if ((_MarkerTypes select 0) isEqualTo "empty") then {
        TRGM_VAR_MainIsHidden =  true; publicVariable "TRGM_VAR_MainIsHidden";
    } else {
        TRGM_VAR_MainIsHidden =  false; publicVariable "TRGM_VAR_MainIsHidden";
    };

    //["c"] call TRGM_GLOBAL_fnc_notify;
    ["Mission Setup: 12", true] call TRGM_GLOBAL_fnc_log;

    TRGM_VAR_InfTaskStarted =  true; publicVariable "TRGM_VAR_InfTaskStarted";

    //TRGM_VAR_InfTaskCount = TRGM_VAR_InfTaskCount + 1;
    //publicVariable "TRGM_VAR_InfTaskCount";

    //InformantStuff
    TRGM_VAR_SideCompleted =  []; publicVariable "TRGM_VAR_SideCompleted";

    TRGM_VAR_SideCompleted pushBack false;
    publicVariable "TRGM_VAR_SideCompleted";
    private _bInfor1Found = false;

    private _MissionTitle = "";
    private _RequiresNearbyRoad = false;
    private _roadSearchRange = 20;

    private _bNewTaskSetup = false;
    private _args = [];
    ["Mission Setup: 11", true] call TRGM_GLOBAL_fnc_log;

    switch (_iThisTaskType) do {
        case 1: {
            ["Mission Setup: Init Hack Data", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_hackDataMission; //Hack Data
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_Hacked_data_rep_increased", 1, localize "STR_TRGM2_Hacked_data"];
            ["Mission Setup: Generating Hack Data", true] call TRGM_GLOBAL_fnc_log;
        };
        case 2: {
            ["Mission Setup: Init Steal data from research vehicle", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_stealDataFromResearchVehMission; //Steal data from research vehicle
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_Downloaded_data_rep_increased", 1, localize "STR_TRGM2_Downloaded_data"];
            ["Mission Setup: Generating Steal data from research vehicle", true] call TRGM_GLOBAL_fnc_log;
        };
        case 3: {
            ["Mission Setup: Init Destroy ammo trucks", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_destroyVehiclesMission; //Destroy ammo trucks
            [localize "STR_TRGM2_startInfMission_MissionTitle3"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_startInfMission_MissionTitle3_Destory", 1, localize "STR_TRGM2_startInfMission_MissionTitle3_Destory_Board", selectRandom (call sideAmmoTruck), [localize "STR_TRGM2_startInfMission_MissionTitle3_Desc"]];
            ["Mission Setup: Generating Destroy ammo trucks", true] call TRGM_GLOBAL_fnc_log;
        };
        case 4: {
            ["Mission Setup: Init Speak with informant", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_hvtMission; //Speak with informant
            [localize "STR_TRGM2_startInfMission_MissionTitle4"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = ["", 0, "", selectRandom InformantClasses, Civilian, "SPEAK", "", localize "STR_TRGM2_startInfMission_MissionTitle8_Button2", [(localize "STR_TRGM2_startInfMission_MissionTitle4_Desc") + TRGM_VAR_InformantImage]];
            ["Mission Setup: Generating Speak with informant", true] call TRGM_GLOBAL_fnc_log;
        };
        case 5: {
            ["Mission Setup: Init Interrogate officer", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_hvtMission; //Interrogate officer
            [localize "STR_TRGM2_startInfMission_MissionTitle5"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = ["", 0, "", selectRandom InterogateOfficerClasses, TRGM_VAR_EnemySide, "INTERROGATE", localize "STR_TRGM2_startInfMission_MissionTitle8_Button", localize "STR_TRGM2_startInfMission_MissionTitle8_Button2", [(localize "STR_TRGM2_startInfMission_MissionTitle5_Desc") + TRGM_VAR_OfficerImage]];
            ["Mission Setup: Generating Interrogate officer", true] call TRGM_GLOBAL_fnc_log;
        };
        case 6: {
            ["Mission Setup: Init Transmit Enemy Comms to HQ", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_bugRadioMission; //Transmit Enemy Comms to HQ
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_startInfMission_MissionTitle6_Hint", 0.5, localize "STR_TRGM2_startInfMission_MissionTitle6_Board"];
            ["Mission Setup: Generating Transmit Enemy Comms to HQ", true] call TRGM_GLOBAL_fnc_log;
        };
        case 7: {
            ["Mission Setup: Init Eliminate Officer", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_hvtMission; //Eliminate Officer   -   gain 1 point if side, if main, need to id him before complete
            [localize "STR_TRGM2_startInfMission_MissionTitle7"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_startInfMission_MissionTitle8_Eliminated", 1, localize "STR_TRGM2_startInfMission_MissionTitle8_Eliminated_Board", selectRandom InterogateOfficerClasses, TRGM_VAR_EnemySide, "KILL", localize "STR_TRGM2_startInfMission_MissionTitle8_Button", "", [(localize "STR_TRGM2_startInfMission_MissionTitle7_Desc") + (["", localize "STR_TRGM2_startInfMission_MissionTitle8_MustSearch"] select (_bIsMainObjective)) + TRGM_VAR_OfficerImage]];
            ["Mission Setup: Generating Eliminate Officer", true] call TRGM_GLOBAL_fnc_log;
        };
        case 8: {
            ["Mission Setup: Init Assasinate weapon dealer", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_hvtMission; //Assasinate weapon dealer   -   gain 1 point if side, no intel from him... if main need to id him before complete
            [localize "STR_TRGM2_startInfMission_MissionTitle8"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_startInfMission_MissionTitle8_Eliminated", 1, localize "STR_TRGM2_startInfMission_MissionTitle8_Eliminated_Board", selectRandom WeaponDealerClasses, Civilian, "KILL", localize "STR_TRGM2_startInfMission_MissionTitle8_Button", "", [(localize "STR_TRGM2_startInfMission_MissionTitle8_Desc") + (["", localize "STR_TRGM2_startInfMission_MissionTitle8_MustSearch"] select (_bIsMainObjective)) + TRGM_VAR_WeaponDealerImage]];
            ["Mission Setup: Generating Assasinate weapon dealer", true] call TRGM_GLOBAL_fnc_log;
        };
        case 9: {
            ["Mission Setup: Init Destroy AAA vehicles", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_destroyVehiclesMission; //Destroy AAA vehicles
            [localize "STR_TRGM2_startInfMission_MissionTitle9"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_startInfMission_MissionTitle9_Destory", 1, localize "STR_TRGM2_startInfMission_MissionTitle9_Destory_Board", selectRandom (call DestroyAAAVeh), [localize "STR_TRGM2_startInfMission_MissionTitle9_Desc"]];
            ["Mission Setup: Generating Destroy AAA vehicles", true] call TRGM_GLOBAL_fnc_log;
        };
        case 10: {
            ["Mission Setup: Init Destroy Artillery vehicles", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_destroyVehiclesMission; //Destroy Artillery vehicles
            [localize "STR_TRGM2_startInfMission_MissionTitle10"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_startInfMission_MissionTitle10_Destory", 1, localize "STR_TRGM2_startInfMission_MissionTitle10_Destory_Board", selectRandom (call sArtilleryVeh), [localize "STR_TRGM2_startInfMission_MissionTitle10_Desc"]];
            ["Mission Setup: Generating Destroy Artillery vehicles", true] call TRGM_GLOBAL_fnc_log;
        };
        case 11: {
            ["Mission Setup: Init Rescue POW", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_hvtMission; //Rescue POW
            [localize "STR_TRGM2_Rescue_POW"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_Rescue_POW_Hint", 1, localize "STR_TRGM2_Rescue_POW_Board", selectRandom FriendlyVictims, TRGM_VAR_FriendlySide, "RESCUE", "", "", [localize "STR_TRGM2_Rescue_POW_Desc"]];
            ["Mission Setup: Generating Rescue POW", true] call TRGM_GLOBAL_fnc_log;
        };
        case 12: {
            ["Mission Setup: Init Rescue Reporter", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_hvtMission; //Rescue Reporter
            [localize "STR_TRGM2_Rescue_Reporter"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_Rescue_Reporter_Hint", 1, localize "STR_TRGM2_Rescue_Reporter_Board", selectRandom Reporters, Civilian, "RESCUE", "", "", [localize "STR_TRGM2_Rescue_Reporter_Desc"]];
            ["Mission Setup: Generating Rescue Reporter", true] call TRGM_GLOBAL_fnc_log;
        };
        case 13: {
            ["Mission Setup: Init Defuse 3 IEDs", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_defuseIEDsMission; //Defuse 3 IEDs
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_IEDMissionHint", 1, localize "STR_TRGM2_IEDMissionBoard"];
            ["Mission Setup: Generating Defuse 3 IEDs", true] call TRGM_GLOBAL_fnc_log;
        };
        case 14: {
            ["Mission Setup: Init Defuse Bomb", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_bombDisposalMission; //Defuse Bomb
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_BombMissionHint", 1, localize "STR_TRGM2_BombMissionBoard"];
            ["Mission Setup: Generating Defuse Bomb", true] call TRGM_GLOBAL_fnc_log;
        };
        case 15: {
            ["Mission Setup: Init Search and Destroy", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_searchAndDestroyMission; //Search and Destroy
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_TargetMissionHint", 1, localize "STR_TRGM2_TargetMissionBoard"];
            ["Mission Setup: Generating Search and Destroy", true] call TRGM_GLOBAL_fnc_log;
        };
        case 16: {
            ["Mission Setup: Init Destroy Cache", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_destroyCacheMission; //Destroy Cache
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_CacheMissionHint", 1, localize "STR_TRGM2_CacheMissionBoard"];
            ["Mission Setup: Generating Destroy Cache", true] call TRGM_GLOBAL_fnc_log;
        };
        case 17:  {
            ["Mission Setup: Init Secure and Resupply", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_secureAndResupplyMission; //Secure and Resupply
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_ClearAreaMissionHint", 1, localize "STR_TRGM2_ClearAreaMissionBoard"];
            ["Mission Setup: Generating Secure and Resupply", true] call TRGM_GLOBAL_fnc_log;
        };
        case 18:  {
            ["Mission Setup: Init Meeting Assassination", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_meetingAssassinationMission; //Meeting Assassination
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_MeetingAssassinationMissionHint", 1, localize "STR_TRGM2_MeetingAssassinationMissionBoard"];
            ["Mission Setup: Generating Meeting Assassination", true] call TRGM_GLOBAL_fnc_log;
        };
        case 19:  {
            ["Mission Setup: Init Ambush Convoy", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_ambushConvoyMission //Ambush Convoy
            call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_AmbushConvoyMissionHint", 1, localize "STR_TRGM2_AmbushConvoyMissionBoard"];
            ["Mission Setup: Generating Ambush Convoy", true] call TRGM_GLOBAL_fnc_log;
        };
        case 20: {
            ["Mission Setup: Init Destroy Armored vehicles", true] call TRGM_GLOBAL_fnc_log;
            call MISSIONS_fnc_destroyVehiclesMission; //Destroy Armored vehicles
            [localize "STR_TRGM2_DestroyArmoredVehiclesTitle"] call MISSION_fnc_CustomVars;
            _bNewTaskSetup = true;
            _args = [localize "STR_TRGM2_DestroyArmoredVehiclesTask", 1, localize "STR_TRGM2_DestroyArmoredVehiclesBoard", selectRandom (call DestroyArmoredVeh), [localize "STR_TRGM2_DestroyArmoredVehiclesDesc"]];
            ["Mission Setup: Generating Destroy Armored vehicles", true] call TRGM_GLOBAL_fnc_log;
        };
        case 99999: {
            ["Mission Setup: Init Custom Mission", true] call TRGM_GLOBAL_fnc_log;
            call CUSTOM_MISSION_fnc_CustomMission; //Custom Mission
            call MISSION_fnc_CustomVars;
            _args = [localize "STR_TRGM2_ObjectiveCompleteRepIncreased", 1, localize "STR_TRGM2_ObjectiveComplete"];
            ["Mission Setup: Generating Custom Mission", true] call TRGM_GLOBAL_fnc_log;
        };
        default { };
    };

    private _bUserDefinedAO = false;
    if (!(isNil "TRGM_VAR_iMissionParamLocations") && {_iTaskIndex < count TRGM_VAR_iMissionParamLocations}) then {
        private _manualLocation = (TRGM_VAR_iMissionParamLocations select _iTaskIndex);
        if (!((_manualLocation select 0) isEqualTo 0) && !((_manualLocation select 1) isEqualTo 0)) then {
            _bUserDefinedAO = true;
        };
    };
    [format ["Mission Setup: Task: %1", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;

    //kill leader (he will run away in car to AO)    ::   save stranded guys    ::

    ["Mission Setup: Getting potential locations", true] call TRGM_GLOBAL_fnc_log;

    TRGM_VAR_allLocationPositions = TRGM_VAR_allLocationPositions select {!(_x in _usedLocations)};

    ["Mission Setup: Locations found", true] call TRGM_GLOBAL_fnc_log;

    ["Mission Setup: 10", true] call TRGM_GLOBAL_fnc_log;
    private _attempts = 0;
    waitUntil {
        _attempts = _attempts + 1;
        ["Mission Setup: 9", true] call TRGM_GLOBAL_fnc_log;
        private _markerInformant1 = nil;
        private _randLocation = nil;

        if (!_SamePrevAO || {_bUserDefinedAO || {_attempts > 100}}) then {
            _randLocation = if (!(isNil "TRGM_VAR_allLocationPositions") && {count TRGM_VAR_allLocationPositions > 0 && {_attempts < 10}}) then {selectRandom TRGM_VAR_allLocationPositions} else {[0 + (floor random 25000), 0 + (floor random 25000)]};
            if (_attempts < 100 && {!_bIsCampaign && {!(isNil "TRGM_VAR_iMissionParamLocations") && {_iTaskIndex < count TRGM_VAR_iMissionParamLocations}}}) then {
                private _manualLocation = (TRGM_VAR_iMissionParamLocations select _iTaskIndex);
                if (!((_manualLocation select 0) isEqualTo 0) && !((_manualLocation select 1) isEqualTo 0)) then {
                    _randLocation = _manualLocation;
                };
            };
            _randInfor1X = _randLocation select 0;
            _randInfor1Y = _randLocation select 1;
            _buildings = nearestObjects [[_randInfor1X,_randInfor1Y], TRGM_VAR_BasicBuildings, 100*_attempts] select {!((_x buildingPos -1) isEqualTo [])};
        };

        private _isPosFarEnoughFromHq = (getMarkerPos "mrkHQ" distance [_randInfor1X, _randInfor1Y]) > TRGM_VAR_SideMissionMinDistFromBase;
        private _playerSelectedAo = call TRGM_GETTER_fnc_bManualAOPlacement;

        if ((_isPosFarEnoughFromHq || _playerSelectedAo) && {(count _buildings) > 0}) then {
            ["Mission Setup: Task location found", true] call TRGM_GLOBAL_fnc_log;
            _bInfor1Found = true;
            private _infBuilding = selectRandom _buildings;
            _infBuilding setDamage 0;
            private _allBuildingPos = _infBuilding buildingPos -1;
            private _inf1X = position _infBuilding select 0;
            private _inf1Y = position _infBuilding select 1;
            if !(isNil "_randLocation") then {
                _usedLocations pushBack _randLocation;
            };

            if (count _allBuildingPos > 2) then {
                private _TasksToValidate = [_iThisTaskType];
                if (count _SamePrevAOStats > TRGM_VAR_InfTaskCount) then {
                    if (_SamePrevAOStats select (TRGM_VAR_InfTaskCount + 1)) then {
                        _TasksToValidate = _TasksToValidate + [_ThisTaskTypes select (TRGM_VAR_InfTaskCount + 1)];
                        if (count _SamePrevAOStats > TRGM_VAR_InfTaskCount + 1) then {
                            if (_SamePrevAOStats select (TRGM_VAR_InfTaskCount + 2)) then {
                                _TasksToValidate = _TasksToValidate + [_ThisTaskTypes select (TRGM_VAR_InfTaskCount + 2)];
                            };
                        };
                    };
                };

                private _nearestRoads = nil;
                {
                    if (_x isEqualTo 99999 || _bNewTaskSetup) then {
                        private _bCustomRequiredPass = true;
                        if (_bNewTaskSetup) then {
                            _bCustomRequiredPass = [_infBuilding,_inf1X,_inf1Y] call MISSION_fnc_CustomRequired;
                        };
                        if (!_bCustomRequiredPass) then {
                            _bInfor1Found = false
                        };
                    };

                    _nearestRoads = [_inf1X,_inf1Y] nearRoads _roadSearchRange;
                    if (_RequiresNearbyRoad) then {
                        if (count _nearestRoads isEqualTo 0) then {
                            _bInfor1Found = false;
                        };
                    };
                } forEach _TasksToValidate;


                if (_bInfor1Found) then {
                    TRGM_VAR_ObjectivePositions pushBack [_inf1X,_inf1Y];
                    publicVariable "TRGM_VAR_ObjectivePositions";
                    if (_bIsHidden) then {
                        TRGM_VAR_HiddenPossitions pushBack [_inf1X,_inf1Y];
                        publicVariable "TRGM_VAR_HiddenPossitions";
                    };
                    private _sTaskDescription = "";
                    if (TRGM_VAR_ISUNSUNG) then {
                        if (_iThisTaskType isEqualTo 6) then {
                            private _radio = selectRandom ["uns_radio2_transitor_NVA","uns_radio2_transitor_NVA"] createVehicle (selectRandom (_infBuilding buildingPos -1));
                        }
                        else {
                            private _radio = selectRandom ["uns_radio2_nva_radio","uns_radio2_transitor_NVA","uns_radio2_transitor_NVA"] createVehicle (selectRandom (_infBuilding buildingPos -1));
                        };

                    };
                    //###################################### CUSTOM MISSION ######################################
                    ["Mission Setup: 8-0-10", true] call TRGM_GLOBAL_fnc_log;
                    if (_iThisTaskType isEqualTo 99999 || _bNewTaskSetup) then {
                        ["Mission Setup: Generating mission", true] call TRGM_GLOBAL_fnc_log;
                        [_MarkerType, _infBuilding, _inf1X, _inf1Y, _roadSearchRange, _bCreateTask, _iTaskIndex, _bIsMainObjective, _args] call MISSION_fnc_CustomMission;
                    };
                    //############################################################################################
                    ["Mission Setup: 8-2", true] call TRGM_GLOBAL_fnc_log;

                    if (!isNil "TRGM_VAR_Mission1Title") then {_MissionTitle = TRGM_VAR_Mission1Title};
                    if (!isNil "TRGM_VAR_Mission1Desc") then {_sTaskDescription = TRGM_VAR_Mission1Desc};

                    TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n_bIsMainObjective: %1",_bIsMainObjective];
                    TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n_iTaskIndex: %1",_iTaskIndex];
                    TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n_MissionTitle: %1",_MissionTitle];

                    private _mrkPrefix = "";
                    if (_bIsMainObjective) then {
                        _markerInformant1 = createMarker [format["mrkMainObjective%1",_iTaskIndex], [_inf1X,_inf1Y]];
                        _mrkPrefix = "mrkMainObjective";
                    }
                    else {
                        _markerInformant1 = createMarker [format["Informant%1",_iTaskIndex], [_inf1X,_inf1Y]];
                        _mrkPrefix = "Informant";
                    };

                    _markerInformant1 setMarkerShape "ICON";

                    private _hideAoMarker = _bIsHidden;
                    if (!isNil "TRGM_VAR_HideAoMarker") then {
                        _hideAoMarker = TRGM_VAR_HideAoMarker;
                    };
                    if (_hideAoMarker) then {
                        _markerInformant1 setMarkerType "empty";
                    }
                    else {
                        _markerInformant1 setMarkerType _MarkerType;
                    };

                    private _bIsSameMrkPos = false;
                    if (_iTaskIndex > 0) then {
                        private _sPrevMrkName = format["%1%2",_mrkPrefix,_iTaskIndex-1];
                        private _sCurrMrkName = format["%1%2",_mrkPrefix,_iTaskIndex];
                        if (str(getMarkerPos _sCurrMrkName) isEqualTo str(getMarkerPos _sPrevMrkName)) then {
                            _bIsSameMrkPos = true;
                            _sPrevMrkName setMarkerText format["%1 / %2",MarkerText _sPrevMrkName,_MissionTitle];
                        };
                    };

                    if (!_bIsSameMrkPos) then {
                        _markerInformant1 setMarkerText format["%1 ",_MissionTitle];
                    };

                    if (_iTaskIndex isEqualTo 0 && TRGM_VAR_iMissionIsCampaign) then {_allowFriendlyIns = false};

                    if (_bSideMissionsCivOnlyToUse && !_bIsHidden) then {
                        TRGM_VAR_ClearedPositions pushBack [_inf1X,_inf1Y];
                        publicVariable "TRGM_VAR_ClearedPositions";
                        _markerInformant1 setMarkerText (localize "STR_TRGM2_startInfMission_markerInformant");
                        if (!_SamePrevAO) then {
                            _populateAOHandles pushBack ([[_inf1X,_inf1Y],_iThisTaskType,_infBuilding,_bIsMainObjective, _iTaskIndex, _allowFriendlyIns, true] spawn TRGM_SERVER_fnc_populateSideMission);
                        };
                    } else {
                        if (!_SamePrevAO) then {
                            _populateAOHandles pushBack ([[_inf1X,_inf1Y],_iThisTaskType,_infBuilding,_bIsMainObjective, _iTaskIndex, _allowFriendlyIns] spawn TRGM_SERVER_fnc_populateSideMission);
                        };
                    };

                    //[_sTaskDescription] call TRGM_GLOBAL_fnc_notify;

                    if (_bIsCampaign) then {
                        [TRGM_VAR_FriendlySide,[format["InfSide%1",_iTaskIndex], _sTaskDescription, format[localize "STR_TRGM2_startInfMission_MissionDayTitle",_iTaskIndex+1,_MissionTitle],""]] call FHQ_fnc_ttAddTasks;
                        TRGM_VAR_ActiveTasks pushBack format["InfSide%1",_iTaskIndex];
                        publicVariable "TRGM_VAR_ActiveTasks";
                    } else {
                        if (_bIsHidden) then {
                            [TRGM_VAR_FriendlySide,[format["InfSide%1",_iTaskIndex], localize "STR_TRGM2_startInfMission_UnknownMissionTitle", format["%1 : %2",_iTaskIndex+1,localize "STR_TRGM2_startInfMission_UnknownMission"],""]] call FHQ_fnc_ttAddTasks;
                        } else {
                            [TRGM_VAR_FriendlySide,[format["InfSide%1",_iTaskIndex], _sTaskDescription, format["%1 : %2",_iTaskIndex+1,_MissionTitle],""]] call FHQ_fnc_ttAddTasks;
                        };
                        TRGM_VAR_ActiveTasks pushBack format["InfSide%1",_iTaskIndex];
                        publicVariable "TRGM_VAR_ActiveTasks";
                    };
                };
            } else {
                _bInfor1Found = false;
            };
        };
        ["Mission Setup: 8-1", true] call TRGM_GLOBAL_fnc_log;
        sleep 1;
        _bInfor1Found;
    };

    if (TRGM_VAR_InfTaskCount isEqualTo 0) then {
        TRGM_VAR_CurrentZeroMissionTitle = _MissionTitle; //curently only used for campaign
        if (TRGM_VAR_MainMissionTitle != "") then {TRGM_VAR_CurrentZeroMissionTitle = TRGM_VAR_MainMissionTitle};
        publicVariable "TRGM_VAR_CurrentZeroMissionTitle";
        if (!_HasNonHiddenObjective && _HasHiddenObjective) then {
            TRGM_VAR_MainMissionTitle = localize "STR_TRGM2_startInfMission_UnknownMission";
        };
    };
    ["Mission Setup: 8-0", true] call TRGM_GLOBAL_fnc_log;
    TRGM_VAR_InfTaskCount = TRGM_VAR_InfTaskCount + 1;
    sleep 1;
    TRGM_VAR_InfTaskCount >= count _ThisTaskTypes;
};

[50, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

["Mission Setup: 7", true] call TRGM_GLOBAL_fnc_log;

private _trgComplete = createTrigger ["EmptyDetector", [0,0]];
_trgComplete setVariable ["DelMeOnNewCampaignDay",true];
_trgComplete setTriggerArea [0, 0, 0, false];
if (TRGM_VAR_iMissionIsCampaign) then {
    private _totalRep = [TRGM_VAR_MaxBadPoints - TRGM_VAR_BadPoints,1] call BIS_fnc_cutDecimals;

    if (_totalRep >= 10 && TRGM_VAR_FinalMissionStarted) then {
        _trgComplete setTriggerStatements ["TRGM_VAR_ActiveTasks call FHQ_fnc_ttAreTasksCompleted;", "[TRGM_VAR_FriendlySide, [""DeBrief"", localize ""STR_TRGM2_mainInit_Debrief"", ""Debrief"", """"]] call FHQ_fnc_ttAddTasks;  [""CAMPAIGN_END""] remoteExec [""TRGM_SERVER_fnc_setMissionBoardOptions"",0,true];}; deletevehicle thisTrigger", ""];

    }
    else {
        _trgComplete setTriggerStatements ["TRGM_VAR_ActiveTasks call FHQ_fnc_ttAreTasksCompleted;", "[(localize ""STR_TRGM2_startInfMission_RTBNextMission"")] call TRGM_GLOBAL_fnc_notify; [""MISSION_COMPLETE""] remoteExec [""TRGM_SERVER_fnc_setMissionBoardOptions"",0,true]; if (TRGM_VAR_ActiveTasks call FHQ_fnc_ttAreTasksSuccessful) then {[1, format[localize ""STR_TRGM2_startInfMission_DayComplete"",str(TRGM_VAR_iCampaignDay)]] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints}; deletevehicle thisTrigger", ""];
    };
}
else {
    //If not campaign and rep is disabled, then we will not fail the mission if rep low, but will be a task to keep rep above average
    if (TRGM_VAR_iMissionParamRepOption isEqualTo 0) then {
        //CREATE TASK HERE... we fail it in mainInit.sqf when checking rep points
        [TRGM_VAR_FriendlySide, ["tskKeepAboveAverage",localize "STR_TRGM2_startInfMission_HoldReputation_Desc",localize "STR_TRGM2_startInfMission_HoldReputation_Title",""]] call FHQ_fnc_ttAddTasks;
        ["tskKeepAboveAverage", "created"] call FHQ_fnc_ttSetTaskState;
    };
    if (TRGM_VAR_iMissionParamRepOption isEqualTo 1) then {
        //CREATE TASK HERE... we fail it in mainInit.sqf when checking rep points
        [TRGM_VAR_FriendlySide, ["tskKeepAboveAverage",localize "STR_TRGM2_startInfMission_HoldReputation_Desc",localize "STR_TRGM2_startInfMission_HoldReputation_Title2",""]] call FHQ_fnc_ttAddTasks;
        ["tskKeepAboveAverage", "created"] call FHQ_fnc_ttSetTaskState;
    };

};

["Mission Setup: 6", true] call TRGM_GLOBAL_fnc_log;

[55, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

// waitUntil { sleep 5; ({scriptDone _x;} count _populateAOHandles) isEqualTo (count _populateAOHandles); };

[75, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

//now we have all our location positinos, we can set other area stuff
{
    [80 + (_forEachIndex * 2), TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;
    if !(_x in TRGM_VAR_HiddenPossitions) then {
        private _setAreaEventsHandle = [_x, _forEachIndex] spawn TRGM_SERVER_fnc_setOtherAreaStuff;
        waitUntil { sleep 5; scriptDone _setAreaEventsHandle; };
    };
} forEach TRGM_VAR_ObjectivePositions;

if (TRGM_VAR_IsFullMap) then {
    ["Loading Full Map Events : BEGIN", true] call TRGM_GLOBAL_fnc_log;
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
    private _mainObjPos = TRGM_VAR_ObjectivePositions select 0;

    private _setDownCivCarEventHandle = [_mainObjPos,true] spawn TRGM_SERVER_fnc_setDownCivCarEvent;
    waitUntil { sleep 5; scriptDone _setDownCivCarEventHandle; };
    private _setDownedChopperEventHandle = [_mainObjPos,true] spawn TRGM_SERVER_fnc_setDownedChopperEvent;
    waitUntil { sleep 5; scriptDone _setDownedChopperEventHandle; };
    private _setATMineEventHandle = [_mainObjPos,true] spawn TRGM_SERVER_fnc_setATMineEvent;
    waitUntil { sleep 5; scriptDone _setATMineEventHandle; };
    private _setIEDEventHandle = [_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent;
    waitUntil { sleep 5; scriptDone _setIEDEventHandle; };
    private _setIEDEvent2Handle = [_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent;
    waitUntil { sleep 5; scriptDone _setIEDEvent2Handle; };

    if (_mapSizeTxt isEqualTo "MEDIUM" || _mapSizeTxt isEqualTo "LARGE") then {
        private _setIEDEvent3Handle = [_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent;
        waitUntil { sleep 5; scriptDone _setIEDEvent3Handle; };
        private _setIEDEvent4Handle = [_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent;
        waitUntil { sleep 5; scriptDone _setIEDEvent4Handle; };
        private _setATMineEvent2Handle = [_mainObjPos,true] spawn TRGM_SERVER_fnc_setATMineEvent;
        waitUntil { sleep 5; scriptDone _setATMineEvent2Handle; };
    };
    if (_mapSizeTxt isEqualTo "LARGE") then {
        private _setDownCivCarEvent2Handle = [_mainObjPos,true] spawn TRGM_SERVER_fnc_setDownCivCarEvent;
        waitUntil { sleep 5; scriptDone _setDownCivCarEvent2Handle; };
        private _setDownedChopperEvent2Handle = [_mainObjPos,true] spawn TRGM_SERVER_fnc_setDownedChopperEvent;
        waitUntil { sleep 5; scriptDone _setDownedChopperEvent2Handle; };
        private _setIEDEvent5Handle = [_mainObjPos,2000,false,false,nil,nil,true] spawn TRGM_SERVER_fnc_setIEDEvent;
        waitUntil { sleep 5; scriptDone _setIEDEvent5Handle; };
    };

    ["Loading Full Map Events : END", true] call TRGM_GLOBAL_fnc_log;
    [95, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;
};

[98, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

["Mission Setup: 2", true] call TRGM_GLOBAL_fnc_log;


["Mission Setup: 1", true] call TRGM_GLOBAL_fnc_log;


publicVariable "TRGM_VAR_debugMessages";
[TRGM_VAR_debugMessages, true] call TRGM_GLOBAL_fnc_log;

[] remoteExec ["TRGM_GLOBAL_fnc_animateAnimals",0,true];

TRGM_VAR_MissionLoaded = true; publicVariable "TRGM_VAR_MissionLoaded";

["Mission Setup: 0", true] call TRGM_GLOBAL_fnc_log;
true;