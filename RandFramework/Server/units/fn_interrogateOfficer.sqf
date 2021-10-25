// private _fnc_scriptName = "TRGM_SERVER_fnc_interrogateOfficer";
params ["_thisCiv","_caller","_id","_args"];
_args params ["_iTaskIndex","_bCreateTask"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (isNil "_iTaskIndex") then {
    _iTaskIndex = _thisCiv getVariable "taskIndex";
};
if (isNil "_bCreateTask") then {
    _bCreateTask = _thisCiv getVariable "createTask";
};

if (side _caller isEqualTo TRGM_VAR_FriendlySide) then {

    //TRGM_VAR_ClearedPositions pushBack (TRGM_VAR_ObjectivePositions select _iTaskIndex);
    TRGM_VAR_ClearedPositions pushBack ([TRGM_VAR_ObjectivePositions, _caller] call BIS_fnc_nearestPosition);
    publicVariable "TRGM_VAR_ClearedPositions";

    //removeAllActions _thisCiv;
    [_thisCiv] remoteExec ["removeAllActions", 0, true];

    if (_bCreateTask) then {
        if (alive _thisCiv) then {
            sName = format["InfSide%1",_iTaskIndex];
            [sName, "succeeded"] remoteExec ["FHQ_fnc_ttsetTaskState", 0];
            _thisCiv switchMove "Acts_ExecutionVictim_Loop";
            //_thisCiv disableAI "anim";
        }
        else {
            //fail task
            [localize "STR_TRGM2_interrogateOfficer_Muppet"] call TRGM_GLOBAL_fnc_notify;
            //TRGM_VAR_badPoints = TRGM_VAR_badPoints + 10;
            //publicVariable "TRGM_VAR_badPoints";
            //[format["InfSide%1",_iTaskIndex], "failed"] call FHQ_fnc_ttsetTaskState;
            sName = format["InfSide%1",_iTaskIndex];
            [sName, "failed"] remoteExec ["FHQ_fnc_ttsetTaskState", 0];
        };
    }
    else {
        _searchChance = [true,false,false,false];

        [localize "STR_TRGM2_interrogateOfficer_MapIntel"] call TRGM_GLOBAL_fnc_notify;


        if (alive _thisCiv) then {
            //increased chance of results
            _searchChance = [true,false];
        }
        else {
            //normal search
            _searchChance = [true,false,false,false,false];
        };

        removeAllActions _thisCiv;

        if (getMarkerType format["mrkMainObjective%1", _iTaskIndex] isEqualTo "empty") then {
            format["mrkMainObjective%1", _iTaskIndex] setMarkerType "mil_unknown";
            [localize "STR_TRGM2_bugRadio_MapUpdated"] call TRGM_GLOBAL_fnc_notifyGlobal;
        } else {
            if (alive _thisCiv) then {
                private _firstHandle = ["IntOfficer", _iTaskIndex] spawn TRGM_GLOBAL_fnc_showIntel;
                sleep 2;
                waitUntil {scriptDone _firstHandle;};
                ["IntOfficer", _iTaskIndex] spawn TRGM_GLOBAL_fnc_showIntel;
            } else {
                [(localize "STR_TRGM2_interrogateOfficer_DeadGuy")] call TRGM_GLOBAL_fnc_notify;
            };
        };
    };


};
