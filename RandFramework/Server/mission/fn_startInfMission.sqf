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

TRGM_VAR_usedLocations = [];

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

if ((_MarkerTypes select 0) isEqualTo "empty") then {
    TRGM_VAR_MainIsHidden =  true; publicVariable "TRGM_VAR_MainIsHidden";
} else {
    TRGM_VAR_MainIsHidden =  false; publicVariable "TRGM_VAR_MainIsHidden";
};

TRGM_VAR_GenerateMissionPercentCompletions = [];
private _populateObjectiveArgs = [];
for [{private _i = 0}, {_i < count _ThisTaskTypes}, {_i = _i + 1}] do {
    private _iTaskIndex = [_i, (TRGM_VAR_iCampaignDay - 1) + _i] select (_bIsCampaign);
    TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 0];
    if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 0]; };
    _populateObjectiveArgs pushBack [
        _iTaskIndex,
        _bIsCampaign,
        _ThisTaskTypes # _iTaskIndex,
        [false, _IsMainObjs # _iTaskIndex] select (count _IsMainObjs > _iTaskIndex),
        ["hd_dot", _MarkerTypes # _iTaskIndex] select (count _MarkerTypes > _iTaskIndex),
        [true, _CreateTasks # _iTaskIndex] select (count _CreateTasks > _iTaskIndex),
        [false, _SamePrevAOStats # _iTaskIndex] select (count _SamePrevAOStats > _iTaskIndex),
        [false, _bSideMissionsCivOnly # _iTaskIndex] select (count _bSideMissionsCivOnly > _iTaskIndex),
        _HasNonHiddenObjective,
        _HasHiddenObjective
    ];
};
publicVariable "TRGM_VAR_GenerateMissionPercentCompletions";

private _totalObjectives = count _populateObjectiveArgs;
private _completedObjectives = 0;
private _activeObjectiveHandles = [];
while {count _populateObjectiveArgs > 0 || count _activeObjectiveHandles > 0} do {
    private _handlesToRemove = [];
    {
        if (scriptDone (_x # 1)) then {
            _handlesToRemove pushBack _x;
            _completedObjectives = _completedObjectives + 1;
        };
    } forEach _activeObjectiveHandles;

    _activeObjectiveHandles = _activeObjectiveHandles - _handlesToRemove;

    if (count _activeObjectiveHandles <= 3) then {
        private _args = _populateObjectiveArgs # 0;
        _populateObjectiveArgs = _populateObjectiveArgs - [_args];
        _activeObjectiveHandles pushBack [_args # 0, (_args spawn TRGM_SERVER_fnc_generateObjective)];
    };

    private _lines = flatten (_activeObjectiveHandles apply { [lineBreak, format["  Objective: %1 | %2 percent", _x # 0, TRGM_VAR_GenerateMissionPercentCompletions # (_x # 0)]] });
    private _content = ["Populating Objectives: "] + _lines + [lineBreak];
    [ceil(45 + ((_completedObjectives / _totalObjectives) * 25)), TRGM_VAR_iMissionIsCampaign, composeText _content] spawn TRGM_GLOBAL_fnc_populateLoadingWait;
    sleep 1;
};

[70, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

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

[75, TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

//now we have all our location positinos, we can set other area stuff
{
    [80 + (_forEachIndex * 2), TRGM_VAR_iMissionIsCampaign] spawn TRGM_GLOBAL_fnc_populateLoadingWait;
    if !(_x in TRGM_VAR_HiddenPositions) then {
        private _setAreaEventsHandle = [_x, _forEachIndex] spawn TRGM_SERVER_fnc_setOtherAreaStuff;
        waitUntil { sleep 5; scriptDone _setAreaEventsHandle; };
    };
} forEach TRGM_VAR_ObjectivePositions;

if (TRGM_VAR_IsFullMap) then {
    ["Loading Full Map Events : BEGIN", true] call TRGM_GLOBAL_fnc_log;
    private _mapSizeTxt = "LARGE";
    private _mapSize = worldName call BIS_fnc_mapSize;
    if (_mapSize < 13000) then {
        _mapSizeTxt = "MEDIUM"
    };
    if (_mapSize < 10000) then {
        _mapSizeTxt = "SMALL"
    };
    private _mainObjPos = TRGM_VAR_ObjectivePositions select 0;

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

    waitUntil { sleep 1; ({ scriptDone _x; } count _fullMapEventsHandles) isEqualTo (count _fullMapEventsHandles)};

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