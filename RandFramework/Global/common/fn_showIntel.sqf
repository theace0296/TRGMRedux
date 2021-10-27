// private _fnc_scriptName = "TRGM_GLOBAL_fnc_showIntel";
params ["_FoundViaType", "_iTaskIndex"];

if !(side player isEqualTo TRGM_VAR_FriendlySide) exitWith {};

if (isNil _iTaskIndex) then {
    _iTaskIndex = TRGM_VAR_ObjectivePositions findIf {!(_x in TRGM_VAR_ClearedPositions);};
    if (_iTaskIndex < 0) then {
        _iTaskIndex = 0;
    };
};

if ((TRGM_VAR_iMissionParamObjectives # _iTaskIndex # 0) in TRGM_VAR_MissionsThatHaveIntel) exitWith {
    {
        _x params ["_taskType", "_isHeavy", "_isHidden", "_sameAOAsPrev"];
        if (_isHidden) then {
            format["mrkMainObjective%1", _forEachIndex] setMarkerType "mil_unknown";
        } else {
            private _showIntelHandle = [_FoundViaType, _forEachIndex] spawn TRGM_GLOBAL_fnc_showIntel;
            waitUntil {sleep 1; scriptDone _showIntelHandle;};
        };
    } forEach TRGM_VAR_iMissionParamObjectives;
    [localize "STR_TRGM2_interrogateOfficer_MapIntel"] call TRGM_GLOBAL_fnc_notifyGlobal;
    true;
};

private _AllowedIntelToShow = TRGM_VAR_IntelShownType;
private _IntelFound = missionNamespace getVariable [format ["TRGM_VAR_IntelFound_%1", _iTaskIndex], []];

private _IntelToShow = 0;
private _iAttemptCount = 0;
while {_IntelToShow isEqualTo 0 && _iAttemptCount < 100} do {
    _iAttemptCount = _iAttemptCount + 1;
    _IntelToShow = selectRandom _AllowedIntelToShow;
    if (_IntelToShow in _IntelFound) then {_IntelToShow = 0};
};

private _showIntel = true;

if (_FoundViaType isEqualTo "CommsTower") then {
    [(localize "STR_TRGM2_PickingUpComms")] call TRGM_GLOBAL_fnc_notify;
    private _TowerBuild = missionNamespace getVariable [format ["TRGM_VAR_CommsTower%1", _iTaskIndex], objNull];
    if (!(isNil "_TowerBuild") && {!(isNull _TowerBuild)}) then {
        private _towerShowIntel = _TowerBuild getVariable "TRGM_VAR_ShowIntel";
        if !(isNil "_towerShowIntel") then {
            _showIntel = _towerShowIntel;
        };
        if (_showIntel) then {
            _TowerBuild setVariable ["TRGM_VAR_ShowIntel", selectRandom [true, false, false], true];
        };
    };
    sleep 4;
};



if (_IntelToShow isEqualTo 0 || !_showIntel) then { //Nothing found
    [(localize "STR_TRGM2_showIntel_NoIntel")] call TRGM_GLOBAL_fnc_notify;
} else {
    missionNamespace setVariable [format ["TRGM_VAR_IntelFound_%1", _iTaskIndex], _IntelFound + [_IntelToShow], true];
};

if (_IntelToShow isEqualTo 1) then { //Mortor team location
    private _IntelShowPos = nearestObjects [TRGM_VAR_ObjectivePositions select _iTaskIndex,(call sMortar) + (call sMortarMilitia),3000];
    private _iCount = count _IntelShowPos;
    if (_iCount > 0) then {
        {
            private _test = createMarker [format["MrkIntelMortor%1",_forEachIndex], getPos _x];
            _test setMarkerShape "ICON";
            _test setMarkerType "o_art";
            _test setMarkerText "Mortar";
        } forEach _IntelShowPos;
        [(localize "STR_TRGM2_showIntel_MortarMapUpdated")] call TRGM_GLOBAL_fnc_notify;
    } else {
        [(localize "STR_TRGM2_showIntel_MortarMapNoUpdate")] call TRGM_GLOBAL_fnc_notify;
    };
};
if (_IntelToShow isEqualTo 2) then { //AAA team location
    private _IntelShowPos = nearestObjects [TRGM_VAR_ObjectivePositions select _iTaskIndex,[(call sAAAVeh)] + [(call sAAAVehMilitia)] + (call DestroyAAAVeh),3000];
    private _iCount = count _IntelShowPos;
    private _iStep = 0;
    if (_iCount > 0) then {
        {
            private _test = createMarker [format["MrkIntelAAA%1",_forEachIndex], getPos _x];
            _test setMarkerShape "ICON";
            _test setMarkerType "o_art";
            _test setMarkerText (localize "STR_TRGM2_showIntel_AAAMarker");
            _iStep = _iStep + 1;
        } forEach _IntelShowPos;
        [(localize "STR_TRGM2_showIntel_AAAMapUpdated")] call TRGM_GLOBAL_fnc_notify;
    } else {
        [(localize "STR_TRGM2_showIntel_AAAMapNoUpdate")] call TRGM_GLOBAL_fnc_notify;
    };
};
if (_IntelToShow isEqualTo 3) then { //Comms tower location
    private _TowerBuild = missionNamespace getVariable [format ["TRGM_VAR_CommsTower%1", _iTaskIndex], objNull];
    if (!(isNil "_TowerBuild") && {!(isNull _TowerBuild)}) then {
        private _test = createMarker ["CommsIntelAAA1", getPos _TowerBuild];
        _test setMarkerShape "ICON";
        _test setMarkerType "mil_destroy";
        _test setMarkerText (localize "STR_TRGM2_showIntel_CommsTowerMarker");
        [(localize "STR_TRGM2_showIntel_CommsTowerMapUpdated")] call TRGM_GLOBAL_fnc_notify;
    } else {
        [(localize "STR_TRGM2_showIntel_CommsTowerMapNoUpdate")] call TRGM_GLOBAL_fnc_notify;
    };
};
if (_IntelToShow isEqualTo 4) then { //All checkpoints
    private _bFoundcheckpoints = false;
    {
        private _distanceToCheckPoint = (_x select 0) distance (TRGM_VAR_ObjectivePositions select _iTaskIndex);
        private _checkpointPos = _x select 0;
        if (_distanceToCheckPoint < 1000) then {
            _bFoundcheckpoints = true;
            private _test = createMarker [format["MrkIntelCheckpoint%1%2",_checkpointPos select 0, _checkpointPos select 1], _checkpointPos];
            _test setMarkerShape "ICON";
            _test setMarkerType "o_inf";
            _test setMarkerText (localize "STR_TRGM2_setCheckpoint_MarkerText");
        };
    } forEach TRGM_VAR_CheckPointAreas;
    if (_bFoundcheckpoints) then {
        [(localize "STR_TRGM2_showIntel_CheckpointMapUpdated")] call TRGM_GLOBAL_fnc_notify;
    } else {
        [(localize "STR_TRGM2_showIntel_CheckpointMapNoUpdate")] call TRGM_GLOBAL_fnc_notify;
    };

};
if (_IntelToShow isEqualTo 5) then { //AT Mine field
    if (count TRGM_VAR_ATFieldPos isEqualTo 0) then {
        [(localize "STR_TRGM2_showIntel_NoATArea")] call TRGM_GLOBAL_fnc_notify;
    } else {
        {
            private _test = createMarker [format["ATIntel%1%2",_x select 0,_x select 1], _x];
            _test setMarkerShape "ICON";
            _test setMarkerType "mil_warning";
            _test setMarkerText (localize "STR_TRGM2_showIntel_ATAreaMarker");
            [(localize "STR_TRGM2_showIntel_ATArea")] call TRGM_GLOBAL_fnc_notify;
        } forEach TRGM_VAR_ATFieldPos;
    };
};


true;