// private _fnc_scriptName = "TRGM_SERVER_fnc_generateObjective";
params [
    ["_iTaskIndex", 0, [0]],
    ["_bIsCampaign", false, [false]],
    ["_iThisTaskType", -1, [0]],
    ["_bIsMainObjective", false, [false]],
    ["_sMarkerType", "hd_dot", ["hd_dot"]],
    ["_bCreateTask", true, [true]],
    ["_bSamePrevAO", false, [false]],
    ["_bSideMissionsCivOnlyToUse", false, [false]],
    ["_bHasNonHiddenObjective", false, [false]],
    ["_bHasHiddenObjective", false, [false]]
];

[format ["Mission Setup: Task: %1", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 0]; };

if (_iThisTaskType < 0) exitWith {
    [format ["Mission Setup: Task: %1 - Failed", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
    false;
};

TRGM_VAR_bCommsBlocked set [_iTaskIndex, false];
publicVariable "TRGM_VAR_bCommsBlocked";

private _randInfor1X = nil;
private _randInfor1Y = nil;
private _buildings = nil;

private _bIsHidden = _sMarkerType isEqualTo "empty"; if (isNil "_bIsHidden") then { _bIsHidden = false; };
private _allowFriendlyIns = true;

private _bInfor1Found = false;

private _MissionTitle = "";
private _RequiresNearbyRoad = false;
private _roadSearchRange = 20;

private _bNewTaskSetup = false;
private _args = [];
[format ["Mission Setup: Task: %1 - Vars Set", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 5]; };

private _MISSION_LOCAL_fnc_CustomRequired = {};
private _MISSION_LOCAL_fnc_CustomVars = {};
private _MISSION_LOCAL_fnc_CustomMission = {};

switch (_iThisTaskType) do {
    case 1: {
        ["Mission Setup: Init Hack Data", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_hackDataMission; //Hack Data
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_Hacked_data_rep_increased", 1, localize "STR_TRGM2_Hacked_data"];
        ["Mission Setup: Generating Hack Data", true] call TRGM_GLOBAL_fnc_log;
    };
    case 2: {
        ["Mission Setup: Init Steal data from research vehicle", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_stealDataFromResearchVehMission; //Steal data from research vehicle
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_Downloaded_data_rep_increased", 1, localize "STR_TRGM2_Downloaded_data"];
        ["Mission Setup: Generating Steal data from research vehicle", true] call TRGM_GLOBAL_fnc_log;
    };
    case 3: {
        ["Mission Setup: Init Destroy ammo trucks", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_destroyVehiclesMission; //Destroy ammo trucks
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_startInfMission_MissionTitle3"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_startInfMission_MissionTitle3_Destory", 1, localize "STR_TRGM2_startInfMission_MissionTitle3_Destory_Board", selectRandom (call sideAmmoTruck), [localize "STR_TRGM2_startInfMission_MissionTitle3_Desc"]];
        ["Mission Setup: Generating Destroy ammo trucks", true] call TRGM_GLOBAL_fnc_log;
    };
    case 4: {
        ["Mission Setup: Init Speak with informant", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_hvtMission; //Speak with informant
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_startInfMission_MissionTitle4"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = ["", 0, "", selectRandom InformantClasses, Civilian, "SPEAK", "", localize "STR_TRGM2_startInfMission_MissionTitle8_Button2", [(localize "STR_TRGM2_startInfMission_MissionTitle4_Desc") + TRGM_VAR_InformantImage]];
        ["Mission Setup: Generating Speak with informant", true] call TRGM_GLOBAL_fnc_log;
    };
    case 5: {
        ["Mission Setup: Init Interrogate officer", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_hvtMission; //Interrogate officer
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_startInfMission_MissionTitle5"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = ["", 0, "", selectRandom InterogateOfficerClasses, TRGM_VAR_EnemySide, "INTERROGATE", localize "STR_TRGM2_startInfMission_MissionTitle8_Button", localize "STR_TRGM2_startInfMission_MissionTitle8_Button2", [(localize "STR_TRGM2_startInfMission_MissionTitle5_Desc") + TRGM_VAR_OfficerImage]];
        ["Mission Setup: Generating Interrogate officer", true] call TRGM_GLOBAL_fnc_log;
    };
    case 6: {
        ["Mission Setup: Init Transmit Enemy Comms to HQ", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_bugRadioMission; //Transmit Enemy Comms to HQ
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_startInfMission_MissionTitle6_Hint", 0.5, localize "STR_TRGM2_startInfMission_MissionTitle6_Board"];
        ["Mission Setup: Generating Transmit Enemy Comms to HQ", true] call TRGM_GLOBAL_fnc_log;
    };
    case 7: {
        ["Mission Setup: Init Eliminate Officer", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_hvtMission; //Eliminate Officer   -   gain 1 point if side, if main, need to id him before complete
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_startInfMission_MissionTitle7"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_startInfMission_MissionTitle8_Eliminated", 1, localize "STR_TRGM2_startInfMission_MissionTitle8_Eliminated_Board", selectRandom InterogateOfficerClasses, TRGM_VAR_EnemySide, "KILL", localize "STR_TRGM2_startInfMission_MissionTitle8_Button", "", [(localize "STR_TRGM2_startInfMission_MissionTitle7_Desc") + (["", localize "STR_TRGM2_startInfMission_MissionTitle8_MustSearch"] select (_bIsMainObjective)) + TRGM_VAR_OfficerImage]];
        ["Mission Setup: Generating Eliminate Officer", true] call TRGM_GLOBAL_fnc_log;
    };
    case 8: {
        ["Mission Setup: Init Assasinate weapon dealer", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_hvtMission; //Assasinate weapon dealer   -   gain 1 point if side, no intel from him... if main need to id him before complete
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_startInfMission_MissionTitle8"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_startInfMission_MissionTitle8_Eliminated", 1, localize "STR_TRGM2_startInfMission_MissionTitle8_Eliminated_Board", selectRandom WeaponDealerClasses, Civilian, "KILL", localize "STR_TRGM2_startInfMission_MissionTitle8_Button", "", [(localize "STR_TRGM2_startInfMission_MissionTitle8_Desc") + (["", localize "STR_TRGM2_startInfMission_MissionTitle8_MustSearch"] select (_bIsMainObjective)) + TRGM_VAR_WeaponDealerImage]];
        ["Mission Setup: Generating Assasinate weapon dealer", true] call TRGM_GLOBAL_fnc_log;
    };
    case 9: {
        ["Mission Setup: Init Destroy AAA vehicles", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_destroyVehiclesMission; //Destroy AAA vehicles
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_startInfMission_MissionTitle9"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_startInfMission_MissionTitle9_Destory", 1, localize "STR_TRGM2_startInfMission_MissionTitle9_Destory_Board", selectRandom (call DestroyAAAVeh), [localize "STR_TRGM2_startInfMission_MissionTitle9_Desc"]];
        ["Mission Setup: Generating Destroy AAA vehicles", true] call TRGM_GLOBAL_fnc_log;
    };
    case 10: {
        ["Mission Setup: Init Destroy Artillery vehicles", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_destroyVehiclesMission; //Destroy Artillery vehicles
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_startInfMission_MissionTitle10"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_startInfMission_MissionTitle10_Destory", 1, localize "STR_TRGM2_startInfMission_MissionTitle10_Destory_Board", selectRandom (call sArtilleryVeh), [localize "STR_TRGM2_startInfMission_MissionTitle10_Desc"]];
        ["Mission Setup: Generating Destroy Artillery vehicles", true] call TRGM_GLOBAL_fnc_log;
    };
    case 11: {
        ["Mission Setup: Init Rescue POW", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_hvtMission; //Rescue POW
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_Rescue_POW"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_Rescue_POW_Hint", 1, localize "STR_TRGM2_Rescue_POW_Board", selectRandom FriendlyVictims, TRGM_VAR_FriendlySide, "RESCUE", "", "", [localize "STR_TRGM2_Rescue_POW_Desc"]];
        ["Mission Setup: Generating Rescue POW", true] call TRGM_GLOBAL_fnc_log;
    };
    case 12: {
        ["Mission Setup: Init Rescue Reporter", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_hvtMission; //Rescue Reporter
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_Rescue_Reporter"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_Rescue_Reporter_Hint", 1, localize "STR_TRGM2_Rescue_Reporter_Board", selectRandom Reporters, Civilian, "RESCUE", "", "", [localize "STR_TRGM2_Rescue_Reporter_Desc"]];
        ["Mission Setup: Generating Rescue Reporter", true] call TRGM_GLOBAL_fnc_log;
    };
    case 13: {
        ["Mission Setup: Init Defuse 3 IEDs", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_defuseIEDsMission; //Defuse 3 IEDs
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_IEDMissionHint", 1, localize "STR_TRGM2_IEDMissionBoard"];
        ["Mission Setup: Generating Defuse 3 IEDs", true] call TRGM_GLOBAL_fnc_log;
    };
    case 14: {
        ["Mission Setup: Init Defuse Bomb", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_bombDisposalMission; //Defuse Bomb
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_BombMissionHint", 1, localize "STR_TRGM2_BombMissionBoard"];
        ["Mission Setup: Generating Defuse Bomb", true] call TRGM_GLOBAL_fnc_log;
    };
    case 15: {
        ["Mission Setup: Init Search and Destroy", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_searchAndDestroyMission; //Search and Destroy
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_TargetMissionHint", 1, localize "STR_TRGM2_TargetMissionBoard"];
        ["Mission Setup: Generating Search and Destroy", true] call TRGM_GLOBAL_fnc_log;
    };
    case 16: {
        ["Mission Setup: Init Destroy Cache", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_destroyCacheMission; //Destroy Cache
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_CacheMissionHint", 1, localize "STR_TRGM2_CacheMissionBoard"];
        ["Mission Setup: Generating Destroy Cache", true] call TRGM_GLOBAL_fnc_log;
    };
    case 17:  {
        ["Mission Setup: Init Secure and Resupply", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_secureAndResupplyMission; //Secure and Resupply
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_ClearAreaMissionHint", 1, localize "STR_TRGM2_ClearAreaMissionBoard"];
        ["Mission Setup: Generating Secure and Resupply", true] call TRGM_GLOBAL_fnc_log;
    };
    case 18:  {
        ["Mission Setup: Init Meeting Assassination", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_meetingAssassinationMission; //Meeting Assassination
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_MeetingAssassinationMissionHint", 1, localize "STR_TRGM2_MeetingAssassinationMissionBoard"];
        ["Mission Setup: Generating Meeting Assassination", true] call TRGM_GLOBAL_fnc_log;
    };
    case 19:  {
        ["Mission Setup: Init Ambush Convoy", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_ambushConvoyMission; //Ambush Convoy
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_AmbushConvoyMissionHint", 1, localize "STR_TRGM2_AmbushConvoyMissionBoard"];
        ["Mission Setup: Generating Ambush Convoy", true] call TRGM_GLOBAL_fnc_log;
    };
    case 20: {
        ["Mission Setup: Init Destroy Armored vehicles", true] call TRGM_GLOBAL_fnc_log;
        private _missionFncs = call MISSIONS_fnc_destroyVehiclesMission; //Destroy Armored vehicles
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        [localize "STR_TRGM2_DestroyArmoredVehiclesTitle"] call _MISSION_LOCAL_fnc_CustomVars;
        _bNewTaskSetup = true;
        _args = [localize "STR_TRGM2_DestroyArmoredVehiclesTask", 1, localize "STR_TRGM2_DestroyArmoredVehiclesBoard", selectRandom (call DestroyArmoredVeh), [localize "STR_TRGM2_DestroyArmoredVehiclesDesc"]];
        ["Mission Setup: Generating Destroy Armored vehicles", true] call TRGM_GLOBAL_fnc_log;
    };
    case 99999: {
        ["Mission Setup: Init Custom Mission", true] call TRGM_GLOBAL_fnc_log;
        call CUSTOM_MISSION_fnc_CustomMission; //Custom Mission
        _MISSION_LOCAL_fnc_CustomRequired = _missionFncs # 0;
        _MISSION_LOCAL_fnc_CustomVars = _missionFncs # 1;
        _MISSION_LOCAL_fnc_CustomMission = _missionFncs # 2;
        call _MISSION_LOCAL_fnc_CustomVars;
        _args = [localize "STR_TRGM2_ObjectiveCompleteRepIncreased", 1, localize "STR_TRGM2_ObjectiveComplete"];
        ["Mission Setup: Generating Custom Mission", true] call TRGM_GLOBAL_fnc_log;
    };
    default {
        throw format ["Mission Setup: Task: %1 - Unknown objective type: %2", _iTaskIndex, _iThisTaskType];
    };
};

[format ["Mission Setup: Task: %1 - Objective Set", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 10]; };

private _bUserDefinedAO = false;
if (!(isNil "TRGM_VAR_iMissionParamLocations") && {_iTaskIndex < count TRGM_VAR_iMissionParamLocations}) then {
    private _manualLocation = (TRGM_VAR_iMissionParamLocations select _iTaskIndex);
    if (!((_manualLocation select 0) isEqualTo 0) && !((_manualLocation select 1) isEqualTo 0)) then {
        _bUserDefinedAO = true;
    };
};

[format ["Mission Setup: Task: %1 - Getting potential locations", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 12]; };

private _possibleLocations = TRGM_VAR_allLocationPositions select {!(_x in TRGM_VAR_usedLocations)};

private _attempts = 0;
private _infBuilding = nil;
private _inf1X = nil;
private _inf1Y = nil;
waitUntil {
    _attempts = _attempts + 1;
    private _randLocation = nil;

    if (!_bSamePrevAO || {_bUserDefinedAO || {_attempts > 10}}) then {
        if (!(isNil "_possibleLocations") && {count _possibleLocations > 0}) then {
            _randLocation = selectRandom _possibleLocations;
        } else {
            _randLocation = [0 + (floor random 25000), 0 + (floor random 25000)];
        };
        _possibleLocations = _possibleLocations - [_randLocation];

        if (_attempts < 10 && {!_bIsCampaign && {!(isNil "TRGM_VAR_iMissionParamLocations") && {_iTaskIndex < count TRGM_VAR_iMissionParamLocations}}}) then {
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
        [format ["Mission Setup: Task: %1 - Location found", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
        if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 15]; };
        _bInfor1Found = true;

        if !(isNil "_randLocation") then {
            TRGM_VAR_usedLocations pushBack _randLocation;
            publicVariable "TRGM_VAR_usedLocations";
        };

        _infBuilding = selectRandom _buildings;
        _infBuilding setDamage 0;
        private _allBuildingPos = _infBuilding buildingPos -1;
        _inf1X = position _infBuilding select 0;
        _inf1Y = position _infBuilding select 1;

        if (count _allBuildingPos > 2 && {_iThisTaskType isEqualTo 99999 || _bNewTaskSetup}) then {
            private _bCustomRequiredPass = true;
            if (_bNewTaskSetup) then {
                _bCustomRequiredPass = [_infBuilding,_inf1X,_inf1Y] call _MISSION_LOCAL_fnc_CustomRequired;
                private _nearestRoads = [_inf1X,_inf1Y] nearRoads _roadSearchRange;
                if (_RequiresNearbyRoad && {count _nearestRoads isEqualTo 0}) then {
                    _bCustomRequiredPass = false;
                };
            };
            if (!_bCustomRequiredPass) then {
                _bInfor1Found = false
            };
        } else {
            _bInfor1Found = false;
        };
    };
    sleep 1;
    _bInfor1Found;
};

TRGM_VAR_ObjectivePositions pushBack [_inf1X,_inf1Y];
publicVariable "TRGM_VAR_ObjectivePositions";
if (_bIsHidden) then {
    TRGM_VAR_HiddenPositions pushBack [_inf1X,_inf1Y];
    publicVariable "TRGM_VAR_HiddenPositions";
};
private _sTaskDescription = "";
if (TRGM_VAR_ISUNSUNG) then {
    if (_iThisTaskType isEqualTo 6) then {
        private _radio = selectRandom ["uns_radio2_transitor_NVA","uns_radio2_transitor_NVA"] createVehicle (selectRandom (_infBuilding buildingPos -1));
    } else {
        private _radio = selectRandom ["uns_radio2_nva_radio","uns_radio2_transitor_NVA","uns_radio2_transitor_NVA"] createVehicle (selectRandom (_infBuilding buildingPos -1));
    };
};
//###################################### CUSTOM MISSION ######################################
if (_iThisTaskType isEqualTo 99999 || _bNewTaskSetup) then {
    [format ["Mission Setup: Task: %1 - Generating mission", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
    if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 20]; };
    [_sMarkerType, _infBuilding, _inf1X, _inf1Y, _roadSearchRange, _bCreateTask, _iTaskIndex, _bIsMainObjective, _args] call _MISSION_LOCAL_fnc_CustomMission;
};
//############################################################################################
[format ["Mission Setup: Task: %1 - Finalizing mission", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 45]; };

if (!isNil "TRGM_VAR_Mission1Title") then {_MissionTitle = TRGM_VAR_Mission1Title};
if (!isNil "TRGM_VAR_Mission1Desc") then {_sTaskDescription = TRGM_VAR_Mission1Desc};

TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n_bIsMainObjective: %1",_bIsMainObjective];
TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n_iTaskIndex: %1",_iTaskIndex];
TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n_MissionTitle: %1",_MissionTitle];

private _markerInformant1 = nil;
private _mrkPrefix = "";
if (_bIsMainObjective) then {
    _markerInformant1 = createMarker [format["mrkMainObjective%1",_iTaskIndex], [_inf1X,_inf1Y]];
    _mrkPrefix = "mrkMainObjective";
} else {
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
    _markerInformant1 setMarkerType _sMarkerType;
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
    if (!_bSamePrevAO) then {
        private _handle = [[_inf1X,_inf1Y],_iThisTaskType,_infBuilding,_bIsMainObjective, _iTaskIndex, _allowFriendlyIns, true] spawn TRGM_SERVER_fnc_populateSideMission;
        waitUntil { sleep 1; scriptDone _handle; };
    };
} else {
    if (!_bSamePrevAO) then {
        private _handle = [[_inf1X,_inf1Y],_iThisTaskType,_infBuilding,_bIsMainObjective, _iTaskIndex, _allowFriendlyIns] spawn TRGM_SERVER_fnc_populateSideMission;
        waitUntil { sleep 1; scriptDone _handle; };
    };
};

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

if (_iTaskIndex isEqualTo 0) then {
    TRGM_VAR_CurrentZeroMissionTitle = _MissionTitle; //curently only used for campaign
    if (TRGM_VAR_MainMissionTitle != "") then {TRGM_VAR_CurrentZeroMissionTitle = TRGM_VAR_MainMissionTitle};
    publicVariable "TRGM_VAR_CurrentZeroMissionTitle";
    if (!_bHasNonHiddenObjective && _bHasHiddenObjective) then {
        TRGM_VAR_MainMissionTitle = localize "STR_TRGM2_startInfMission_UnknownMission";
    };
};

[format ["Mission Setup: Task: %1 - Complete", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 100]; };

true;
