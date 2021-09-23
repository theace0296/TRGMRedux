format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

private _mrkHQPos = getMarkerPos "mrkHQ";
private _AOCampPos = ([endMissionBoard2] call TRGM_GLOBAL_fnc_getRealPos);
private _bAllAtBase2 = ({(alive _x)&&((_x distance _mrkHQPos < 500)||(_x distance _AOCampPos < 500))} count (call BIS_fnc_listPlayers)) isEqualTo ({ (alive _x) } count (call BIS_fnc_listPlayers));

if !(TRGM_VAR_ActiveTasks call FHQ_fnc_ttAreTasksCompleted) then {
    {
        [_x, "canceled"] call FHQ_fnc_ttSetTaskState;
    } forEach TRGM_VAR_ActiveTasks select {!([_x] call FHQ_fnc_ttAreTasksCompleted)};
};

if (_bAllAtBase2 && TRGM_VAR_ActiveTasks call FHQ_fnc_ttAreTasksCompleted) then {
    ["DeBrief", "succeeded"] call FHQ_fnc_ttsetTaskState;
    sleep 5;
    private _dCurrentRep = [TRGM_VAR_MaxBadPoints - TRGM_VAR_BadPoints,1] call BIS_fnc_cutDecimals;
    if (_dCurrentRep > 0 && {TRGM_VAR_iMissionParamRepOption isEqualTo 1}) then {
        ["tskKeepAboveAverage", "succeeded"] call FHQ_fnc_ttSetTaskState;
    };

    sleep 10;

    if (TRGM_VAR_iMissionIsCampaign) then {
        ["end1", true, 7] remoteExec ["BIS_fnc_endMission"];
    }
    else {

        if (TRGM_VAR_BadPoints >= TRGM_VAR_MaxBadPoints && TRGM_VAR_iMissionParamRepOption isEqualTo 1) then {
            ["end2", true, 7] remoteExec ["BIS_fnc_endMission"]
        }
        else {
            if ((["InfSide0"] call FHQ_fnc_ttareTasksSuccessful)) then {
                ["end1", true, 7] remoteExec ["BIS_fnc_endMission"];
            } else {
                ["end2", true, 7] remoteExec ["BIS_fnc_endMission"];
            };
        };
    };
};

bAttemptedEnd = false; publicVariable "bAttemptedEnd";