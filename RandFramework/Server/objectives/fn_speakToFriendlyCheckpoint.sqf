// private _fnc_scriptName = "TRGM_SERVER_fnc_speakToFriendlyCheckpoint";
params ["_thisCheckpointUnit", "_caller", "_id", "_thisArrayParams"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (side _caller isEqualTo TRGM_VAR_FriendlySide) then {
    private _CheckpointPos = _thisArrayParams select 0;
    private _CheckpointName = _thisArrayParams select 1;

    [_thisCheckpointUnit] remoteExec ["removeAllActions", 0, true];
    if (alive _thisCheckpointUnit) then {
        private _iTaskIndex = 0;
        {
            private _indexPos = TRGM_VAR_ObjectivePositions select _iTaskIndex;
            private _indexDistance = _CheckpointPos distance2D _indexPos;
            private _currDistance = _CheckpointPos distance2D _x;
            if (_currDistance < _indexDistance) then {
                _iTaskIndex = _foreachindex;
            };
        } forEach TRGM_VAR_ObjectivePositions;
        ["TalkFriendCheckPoint", _iTaskIndex] spawn TRGM_GLOBAL_fnc_showIntel;
        if (call TRGM_GETTER_fnc_bCheckpointRespawnAfterVisitOnly) then {
            private _markerName = format ["respawn_west_%1", _checkPointName];
            private _checkpointRespawnMarker = createMarker [_markerName, _CheckpointPos];
            _checkpointRespawnMarker setMarkerShape "ICON";
            _checkpointRespawnMarker setMarkerType "Empty";
        };
    } else {
        [localize "STR_TRGM2_SpeakToFriendlyCheckpoint_DontTell"] call TRGM_GLOBAL_fnc_notify;
    };
};

true;