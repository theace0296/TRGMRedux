// private _fnc_scriptName = "TRGM_GUI_fnc_openDialogObjectiveManager";
/*
* Author: TheAce0296
* Creates the admin objectives manager dialog.
*
* Arguments:
* 0: The unit opened the dialog (should be player) <OBJECT>
*
* Return Value:
* true <BOOL>
*
* Example:
* player call TRGM_GUI_fnc_openDialogObjectiveManager
*/

disableSerialization;

format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

params [["_player", objNull, [objNull]]];

if (player != _player) exitwith {};

private _UI_GRID_X = safezoneX;
private _UI_GRID_Y = safezoneY;
private _UI_GRID_W = safezoneW / 40;
private _UI_GRID_H = safezoneH / 25;
private _UI_GRID_WABS = safezoneW;
private _UI_GRID_HABS = safezoneH;

private _TRGM_ORANGE = [0.85,0.45,0,1];
private _TRGM_BLUE = [0,0.45,0.85,1];
private _TRGM_BLACK = [0,0,0,1];
private _TRGM_WHITE = [1,1,1,1];
private _TRGM_GREY = [0,0,0,0.5];
private _TRGM_INVISIBLE = [0,0,0,0];

private _OBJECTIVE_Y = (7.28 * _UI_GRID_H + _UI_GRID_Y) + (1.5 * _UI_GRID_H);
private _OBJECTIVE_W = 3 * _UI_GRID_W;
private _OBJECTIVE_H = (0.75 * _UI_GRID_H);

createDialog "TRGM_VAR_DialogObjectiveManager";
waitUntil {
    !isNull (findDisplay 9000);
};

private _display = findDisplay 9000;
private _objectives = missionNamespace getVariable ["TRGM_VAR_Objectives", []];
private _backgroundPosition = [
    0.3 * _UI_GRID_X,
    _OBJECTIVE_Y - (0.5 * _OBJECTIVE_H),
    (2 * _UI_GRID_W) + (6.5 * _OBJECTIVE_W),
    (2 * _UI_GRID_H) + (_OBJECTIVE_H * count _objectives) + _UI_GRID_H
];

private _fnc_createObjectiveRow = {
    private _index = _this # 0;
    private _baseIdc = 9011 + (10 * _index);
    private _objectives = missionNamespace getVariable ["TRGM_VAR_Objectives", []];
    private _objective = _objectives # _index;
    _objective params ["_markerType","_objectiveMainBuilding","_centralAO_x","_centralAO_y","_roadSearchRange", "_bCreateTask", "_iTaskIndex", "_bIsMainObjective", ["_args", []]];
    _args params ["_hintStrOnComplete", ["_repAmountOnComplete", 0], ["_repReasonOnComplete", ""]];

    private _objectivePositionX = (_backgroundPosition # 0) - _OBJECTIVE_W;
    private _objectivePositionY = _OBJECTIVE_Y + (_index * _OBJECTIVE_H);
    private _statuses = ["succeeded", "failed", "canceled", "in_progress"];

    private _label = format [localize "STR_TRGM2_dialogs_ObjectiveIndex", _index + 1];
    private _ctrlLabel = _display ctrlCreate ["RscText", _baseIdc + 1];
    _ctrlLabel ctrlSetPosition [
        _objectivePositionX + (_OBJECTIVE_W),
        _objectivePositionY,
        _OBJECTIVE_W,
        _OBJECTIVE_H
    ];
    _ctrlLabel ctrlSetText _label;
    _ctrlLabel ctrlSetTextColor _TRGM_ORANGE;
    _ctrlLabel ctrlCommit 0;

    private _ctrlStatus = _display ctrlCreate ["RscCombo", _baseIdc + 2];
    _ctrlStatus ctrlSetPosition [
        _objectivePositionX + (2 * _OBJECTIVE_W),
        _objectivePositionY,
        2 * _OBJECTIVE_W,
        _OBJECTIVE_H
    ];
    lbClear _ctrlStatus;
    { _ctrlStatus lbAdd (localize (format ["STR_TRGM2_%1", _x])); } forEach _statuses;
    private _status = toLower([format["InfSide%1", _index]] call FHQ_fnc_ttGetTaskState);
    if !(_status in _statuses) then { _status = "in_progress"; };
    _ctrlStatus lbSetCurSel (_statuses find _status);
    _ctrlStatus ctrlAddEventHandler ["LBSelChanged", {
        params ["_control", "_selectedIndex"];
        private _display = ctrlParent _control;
        private _baseIdc = (ctrlIDC _control) - 2;
        private _statuses = ["succeeded", "failed", "canceled", "in_progress"];
        private _status = _statuses select _selectedIndex;
        {
            private _inputCtrl = _display displayCtrl (_baseIdc + _x);
            _inputCtrl ctrlEnable (_status isNotEqualTo "in_progress");
            switch (str _x) do {
                case "3": {
                    private _reason = "";
                    switch (_status) do {
                        case "succeeded": { _reason = localize "STR_TRGM2_ObjectiveComplete"; };
                        case "failed": { _reason = localize "STR_TRGM2_ObjectiveFailed"; };
                        case "canceled": { _reason = localize "STR_TRGM2_ObjectiveCanceled"; };
                        default { _reason = ""; };
                    };
                    _inputCtrl ctrlSetText _reason;
                };
                case "4": {
                    private _reputation = 1;
                    switch (_status) do {
                        case "succeeded": { _reputation = 1; };
                        case "failed": { _reputation = 1; };
                        case "canceled": { _reputation = 0; };
                        default { _reputation = 0; };
                    };
                    _inputCtrl ctrlSetText (str _reputation);
                };
                case "5": {};
                default {};
            };
            _inputCtrl ctrlCommit 0;
        } forEach [3,4,5];
    }];
    _ctrlStatus ctrlCommit 0;

    private _ctrlReason = _display ctrlCreate ["RscEdit", _baseIdc + 3];
    _ctrlReason ctrlSetPosition [
        _objectivePositionX + (4 * _OBJECTIVE_W),
        _objectivePositionY,
        2 * _OBJECTIVE_W,
        _OBJECTIVE_H
    ];
    private _reason = "";
    switch (_status) do {
        case "succeeded": { _reason = [_repReasonOnComplete, localize "STR_TRGM2_ObjectiveComplete"] select (_repReasonOnComplete isEqualTo ""); };
        case "failed": { _reason = localize "STR_TRGM2_ObjectiveFailed"; };
        case "canceled": { _reason = localize "STR_TRGM2_ObjectiveCanceled"; };
        default { _reason = ""; };
    };
    _ctrlReason ctrlSetText _reason;
    _ctrlReason ctrlSetBackgroundColor _TRGM_BLACK;
    _ctrlReason ctrlSetTextColor _TRGM_WHITE;
    _ctrlReason ctrlSetTooltip (localize "STR_TRGM2_objectiveStatusReason");
    _ctrlReason ctrlCommit 0;

    private _ctrlReputation = _display ctrlCreate ["RscEdit", _baseIdc + 4];
    _ctrlReputation ctrlSetPosition [
        _objectivePositionX + (6 * _OBJECTIVE_W),
        _objectivePositionY,
        _OBJECTIVE_W,
        _OBJECTIVE_H
    ];
    private _reputation = 1;
    switch (_status) do {
        case "succeeded": { _reputation = [1, _repAmountOnComplete] select (_repAmountOnComplete > 0); };
        case "failed": { _reputation = 1; };
        case "canceled": { _reputation = 0; };
        default { _reputation = 0; };
    };
    _ctrlReputation ctrlSetText (str _reputation);
    _ctrlReputation ctrlSetBackgroundColor _TRGM_BLACK;
    _ctrlReputation ctrlSetTextColor _TRGM_WHITE;
    _ctrlReputation ctrlSetTooltip (localize "STR_TRGM2_objectiveReputationAmount");
    _ctrlReputation ctrlCommit 0;

    private _ctrlUpdateButton = _display ctrlCreate ["RscButton", _baseIdc + 5];
    _ctrlUpdateButton ctrlSetPosition [
        _objectivePositionX + (7 * _OBJECTIVE_W),
        _objectivePositionY,
        _OBJECTIVE_W,
        _OBJECTIVE_H
    ];
    _ctrlUpdateButton ctrlSetText (localize "STR_TRGM2_update");
    _ctrlUpdateButton ctrlSetBackgroundColor _TRGM_ORANGE;
    _ctrlUpdateButton ctrlSetActiveColor _TRGM_ORANGE;
    _ctrlUpdateButton ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        private _baseIdc = (ctrlIDC _control) - 5;
        private _index = ((_baseIdc - 9011) / 10);
        private _statuses = ["succeeded", "failed", "canceled", "in_progress"];
        private _status = _statuses select (lbCurSel (_baseIdc + 2));
        private _reason = ctrlText (_baseIdc + 3);
        private _reputation = parseNumber ctrlText (_baseIdc + 4);

        if (_status isEqualTo "in_progress" || !(_status in _statuses)) exitWith {};
        _reputation = [1, _reputation] select (_reputation > 0);
        switch (_status) do {
            case "succeeded": {
                _reason = [_reason, localize "STR_TRGM2_ObjectiveComplete"] select (_reason isEqualTo "");
                [_reputation, _reason] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints;
            };
            case "failed": {
                _reason = [_reason, localize "STR_TRGM2_ObjectiveFailed"] select (_reason isEqualTo "");
                [_reputation, _reason] spawn TRGM_GLOBAL_fnc_adjustBadPoints;
            };
            case "canceled": {
                _reason = [_reason, localize "STR_TRGM2_ObjectiveCanceled"] select (_reason isEqualTo "");
            };
            default {};
        };
        [format [localize "STR_TRGM2_Objective_X_UpdatedTo_Y", _index + 1, localize (format ["STR_TRGM2_%1", _status])]] call TRGM_GLOBAL_fnc_notifyGlobal;
        [format ["InfSide%1", _index], _status] remoteExec ["FHQ_fnc_ttSetTaskState", 0];
    }];
    _ctrlUpdateButton ctrlCommit 0;


    _ctrlReason ctrlEnable (_status isNotEqualTo "in_progress");
    _ctrlReason ctrlSetDisabledColor _TRGM_GREY;
    _ctrlReason ctrlCommit 0;
    _ctrlReputation ctrlEnable (_status isNotEqualTo "in_progress");
    _ctrlReputation ctrlSetDisabledColor _TRGM_GREY;
    _ctrlReputation ctrlCommit 0;
    _ctrlUpdateButton ctrlEnable (_status isNotEqualTo "in_progress");
    _ctrlUpdateButton ctrlSetDisabledColor _TRGM_GREY;
    _ctrlUpdateButton ctrlCommit 0;
};

private _ctrlBackground = _display ctrlCreate ["RscText", 9002];
_ctrlBackground ctrlSetPosition _backgroundPosition;
_ctrlBackground ctrlSetBackgroundColor [0.35,0.31,0.30,1];
_ctrlBackground ctrlSetText "";
_ctrlBackground ctrlCommit 0;

private _ctrlButtonClose = _display ctrlCreate ["RscButton", 9003];
_ctrlButtonClose ctrlSetPosition [
    (_backgroundPosition # 0) + (0.5 * (_backgroundPosition # 2)) - (2.5 * _UI_GRID_W),
    (_backgroundPosition # 1) + (_backgroundPosition # 3) - (1.5 * _UI_GRID_H),
    5 * _UI_GRID_W,
    _UI_GRID_H
];
_ctrlButtonClose ctrlSetBackgroundColor _TRGM_ORANGE;
_ctrlButtonClose ctrlSetActiveColor _TRGM_ORANGE;
_ctrlButtonClose ctrlSetText (localize "STR_TRGM2_close");
_ctrlButtonClose ctrlAddEventHandler ["ButtonClick", {
    closedialog 0;
    false;
}];
_ctrlButtonClose ctrlCommit 0;

{
    [_forEachIndex] call _fnc_createObjectiveRow;
} forEach _objectives;

true;