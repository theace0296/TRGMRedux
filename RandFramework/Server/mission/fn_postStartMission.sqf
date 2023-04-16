// private _fnc_scriptName = "TRGM_SERVER_fnc_postStartMission";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

waituntil {sleep 2; TRGM_VAR_CoreCompleted};

sleep 2;

private _bMoveToAO = false;
if (TRGM_VAR_iStartLocation isEqualTo 2) then {
    _bMoveToAO = random 1 < .50;
};
if (TRGM_VAR_iStartLocation isEqualTo 1) then {
    _bMoveToAO = true;
};
if (_bMoveToAO) then {
    call TRGM_SERVER_fnc_aoCampCreator;
};

TRGM_VAR_MissionLoaded = true; publicVariable "TRGM_VAR_MissionLoaded";

private _isHiddenObj = false;
private _mainAOPos = TRGM_VAR_ObjectivePositions select 0;
if (! isNil "_mainAOPos") then {
    if (_mainAOPos in TRGM_VAR_HiddenPositions) then {
        _isHiddenObj = true;
    };
};

{ _x setVariable ["TRGM_postStartMissionCamRunning", "NOTRUN", true]; } forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
[_isHiddenObj, _bMoveToAO] remoteExec ["TRGM_CLIENT_fnc_postStartMissionCamera", [0, -2] select isMultiplayer, true];

"FinalCleanup" call TRGM_GLOBAL_fnc_log;
call TRGM_SERVER_fnc_finalSetupCleaner;

sleep 2;

if (_bMoveToAO) then {
    //AOCampPos
    {
        if (isPlayer _x) then {
            [[_x], {
                (_this select 0) setpos [(TRGM_VAR_foundHQPos select 0) - 10, (TRGM_VAR_foundHQPos select 1)];
                {_x setpos [(TRGM_VAR_foundHQPos select 0) - 10, (TRGM_VAR_foundHQPos select 1)];} forEach units group (_this select 0);
                (_this select 0) setdamage 0;
            }] remoteExec ["call", _x];
        };
    } forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
};

[] remoteExec ["TRGM_CLIENT_fnc_postStartMissionEndCamera", [0, -2] select isMultiplayer, true];

sleep 3;
saveGame;
sleep 1;

TRGM_VAR_AllInitScriptsFinished = true; publicVariable "TRGM_VAR_AllInitScriptsFinished";
if (TRGM_VAR_iMissionIsCampaign) then {
    [(localize "STR_TRGM2_startInfMission_SoItBegin")] call TRGM_GLOBAL_fnc_notifyGlobal;
};

true;