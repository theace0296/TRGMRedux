// private _fnc_scriptName = "TRGM_SERVER_fnc_speakInformant";
params ["_thisCiv", "_caller", "_id", "_args"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _iTaskIndex = _thisCiv getVariable "taskIndex";
private _bCreateTask = _thisCiv getVariable "createTask";

if (alive _thisCiv) then {
    [_thisCiv] spawn TRGM_SERVER_fnc_updateTask;
} else {
    [localize "STR_TRGM2_interrogateOfficer_Muppet"] call TRGM_GLOBAL_fnc_notify;
    [_thisCiv, "failed"] spawn TRGM_SERVER_fnc_updateTask;
};

if (side _caller isEqualTo TRGM_VAR_FriendlySide && !_bCreateTask) then {
    private _ballowSearch = true;

    [localize "STR_TRGM2_SpeakInformant_StartSpeak"] call TRGM_GLOBAL_fnc_notify;
    _thisCiv disableAI "move";
    sleep 3;
    _thisCiv enableAI "move";
    if (alive _thisCiv) then {
        _ballowSearch = true;
    } else {
        _ballowSearch = false;
    };

    if (_ballowSearch) then {
        if (getMarkerType format["mrkMainObjective%1", _iTaskIndex] isEqualTo "empty") then {
            format["mrkMainObjective%1", _iTaskIndex] setMarkerType "mil_unknown";
            [localize "STR_TRGM2_bugRadio_MapUpdated"] call TRGM_GLOBAL_fnc_notifyGlobal;
        } else {
            private _firstHandle = ["SpeakInform", _iTaskIndex] spawn TRGM_GLOBAL_fnc_showIntel;
            sleep 5;
            waitUntil {scriptDone _firstHandle;};
            ["SpeakInform", _iTaskIndex] spawn TRGM_GLOBAL_fnc_showIntel;
        };
    };
};