params ["_thisCheckpointUnit", "_caller", "_id", "_thisArrayParams"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (side _caller isEqualTo TRGM_VAR_FriendlySide) then {
    private _CheckpointPos = _thisArrayParams select 0;
    private _CheckpointName = _thisArrayParams select 1;

    [_thisCheckpointUnit] remoteExec ["removeAllActions", 0, true];
    if (alive _thisCheckpointUnit) then {
        [TRGM_VAR_IntelShownType,"TalkFriendCheckPoint"] spawn TRGM_GLOBAL_fnc_showIntel;
        if (call TRGM_GETTER_fnc_bCheckpointRespawnAfterVisitOnly) then {
            private _markerName = format ["respawn_west_%1", _checkPointName];
            private _checkpointRespawnMarker = createMarker [_markerName, _CheckpointPos];
            _checkpointRespawnMarker setMarkerShape "ICON";
            _checkpointRespawnMarker setMarkerType "Empty";
        };
    } else {
        ["He doesnt seem to be saying much at this time"] call TRGM_GLOBAL_fnc_notify;
    };
};

true;