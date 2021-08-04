
_option = _this select 0;
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


//all players will have this run, need to make sure only show for commander
_dCurrentRep = [TRGM_VAR_MaxBadPoints - TRGM_VAR_BadPoints,1] call BIS_fnc_cutDecimals;

{
    // Current missionboard is saved in variable _x
    //These two lines do the same... just here for my reference
    //{removeAllActions endMissionBoard;} remoteExec ["call", 0];
    _x remoteExec ["removeAllActions", 0];
    [_x, [localize "STR_TRGM2_SetMissionBoardOptions_ShowRep",{[false] spawn TRGM_GLOBAL_fnc_showRepReport;}]] remoteExec ["addAction", 0];
    if (!isMultiplayer) then {
        [_x, [localize "STR_TRGM2_SetMissionBoardOptions_Save", {saveGame}]] remoteExec ["addAction", 0];
    };
} forEach [endMissionBoard, endMissionBoard2];

switch (_option) do {
    case "INIT": {
        {
            [_x, [localize "STR_TRGM2_SetMissionBoardOptions_StartMission",{[false] spawn TRGM_SERVER_fnc_startMissionPreCheck;}]] remoteExec ["addAction", 0];
        } forEach [endMissionBoard, endMissionBoard2];
        if (call TRGM_GETTER_fnc_bIsCampaign) then {
            [endMissionBoard, [localize "STR_TRGM2_SetMissionBoardOptions_ExitCampaign",{[false] spawn TRGM_SERVER_fnc_exitCampaign;}]] remoteExec ["addAction", 0];
        };
    };
    case "NEW_MISSION": {
        {
            [_x, [localize "STR_TRGM2_SetMissionBoardOptions_TurnInMission",{[] spawn TRGM_SERVER_fnc_turnInMission;}]] remoteExec ["addAction", 0];
        } forEach [endMissionBoard, endMissionBoard2];
    };
    case "MISSION_COMPLETE": {
        {
            if (_dCurrentRep >= 10) then {
                [_x, [localize "STR_TRGM2_SetMissionBoardOptions_RequestFinal",{[true] spawn TRGM_SERVER_fnc_startMissionPreCheck;}]] remoteExec ["addAction", 0];
            } else {
                [_x, [localize "STR_TRGM2_SetMissionBoardOptions_RequestNext",{[false] spawn TRGM_SERVER_fnc_startMissionPreCheck;}]] remoteExec ["addAction", 0];
            };
        } forEach [endMissionBoard, endMissionBoard2];
        if (isMultiplayer) then {
            [endMissionBoard, [localize "STR_TRGM2_SetMissionBoardOptions_EndMission",{_this spawn TRGM_SERVER_fnc_attemptEndMission;}]] remoteExec ["addAction", 0];
        };
        if (call TRGM_GETTER_fnc_bIsCampaign) then {
            [endMissionBoard, [localize "STR_TRGM2_SetMissionBoardOptions_ExitCampaign",{[false] spawn TRGM_SERVER_fnc_exitCampaign;}]] remoteExec ["addAction", 0];
        };
    };
    case "CAMPAIGN_END": {
        [endMissionBoard, [localize "STR_TRGM2_SetMissionBoardOptions_EndMission",{_this spawn TRGM_SERVER_fnc_attemptEndMission;}]] remoteExec ["addAction", 0];
    };
};

true;