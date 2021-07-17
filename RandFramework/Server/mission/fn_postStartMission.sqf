
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

waituntil {sleep 2; TRGM_VAR_CoreCompleted};

sleep 2;



_bMoveToAO = false;
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

_isHiddenObj = false;
_mainAOPos = TRGM_VAR_ObjectivePossitions select 0;
if (! isNil "_mainAOPos") then {
    if (_mainAOPos in TRGM_VAR_HiddenPossitions ) then {
        _isHiddenObj = true;
    };
};

{ _x setVariable ["TRGM_postStartMissionCamRunning", "NOTRUN", true]; } forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
[_isHiddenObj, _bMoveToAO] remoteExec ["TRGM_CLIENT_fnc_postStartMissionCamera", 0, true];

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

[] remoteExec ["TRGM_CLIENT_fnc_postStartMissionEndCamera", 0, true];

sleep 3;
saveGame;
sleep 1;

if (call TRGM_GETTER_fnc_bIsCampaign && TRGM_VAR_AllInitScriptsFinished) then {
    "Mission setup finished!" call TRGM_GLOBAL_fnc_notifyGlobal;
};

TRGM_VAR_AllInitScriptsFinished = true; publicVariable "TRGM_VAR_AllInitScriptsFinished";

true;