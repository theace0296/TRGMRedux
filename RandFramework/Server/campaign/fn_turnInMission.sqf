
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


private _bAllow = true;

if (isMultiplayer) then {

    private _bSLAlive = false;
    private _bK1_1Alive = false;
    if (!isnil "sl") then { //sl is leader of K1 - k2_1 is leader of K2
        _bSLAlive = alive sl;
    };
    if (!isnil "k2_1") then {
        _bK1_1Alive = alive k2_1;
    };

    if (_bSLAlive && str(player) != "sl") then {
        [(localize "STR_TRGM2_attemptendmission_Kilo1")] call TRGM_GLOBAL_fnc_notify;
        _bAllow = false;
    };

    if (!_bSLAlive && _bK1_1Alive && str(player) != "k2_1") then {
        [(localize "STR_TRGM2_attemptendmission_Kilo2")] call TRGM_GLOBAL_fnc_notify;
        _bAllow = false;
    };
    if (!_bSLAlive && !_bK1_1Alive && (leader (group player))!=player) then {
            [(localize "STR_TRGM2_attemptendmission_Kilo1")] call TRGM_GLOBAL_fnc_notify;
            _bAllow = false;
    };


};


if (_bAllow) then {
    //Fail current mission
    private _iCurrentTaskCount = 0;
    while {_iCurrentTaskCount < count TRGM_VAR_ActiveTasks} do {
        if (!(TRGM_VAR_ActiveTasks call FHQ_fnc_ttAreTasksCompleted)) then {
            [TRGM_VAR_ActiveTasks select _iCurrentTaskCount, "canceled"] call FHQ_fnc_ttSetTaskState;
            _iCurrentTaskCount = _iCurrentTaskCount + 1;
        };
    };
    //lower rep
    [0.3, format[localize "STR_TRGM2_startInfMission_DayTurnedIn",str(TRGM_VAR_iCampaignDay)]] spawn TRGM_GLOBAL_fnc_adjustBadPoints;

    sleep 3;

    private _escortPilot1 = driver chopper1;
    {
        deleteWaypoint _x
    } foreach waypoints group _escortPilot1;
    chopper1 setVariable ["baseLZ", ([heliPad1] call TRGM_GLOBAL_fnc_getRealPos), true];
    [chopper1] spawn TRGM_GLOBAL_fnc_flyToBase;
    chopper1 setPos ([heliPad1] call TRGM_GLOBAL_fnc_getRealPos);
    chopper2 setPos ([airSupportHeliPad] call TRGM_GLOBAL_fnc_getRealPos);
    "transportChopper" setMarkerPos ([chopper1] call TRGM_GLOBAL_fnc_getRealPos);
    chopper1 engineOn false;
    chopper2 engineOn false;
    private _escortPilot = driver chopper2;
    {
        deleteWaypoint _x
    } foreach waypoints group _escortPilot;

    sleep 0.2;
};

true;