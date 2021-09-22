format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

disableSerialization;

if (isNil "TRGM_VAR_iMissionParamObjectives") exitWith {};

private _newIndex = count TRGM_VAR_iMissionParamObjectives;

if (_newIndex > 7) exitWith {
    private _ctrl = (findDisplay 5000) displayCtrl 5500;
    _ctrl ctrlSetText ("Already at maximum number of objectives!");
    _ctrl ctrlShow true;
    [] spawn {
        disableSerialization;
        sleep 10;
        _ctrl = (findDisplay 5000) displayCtrl 5500;
        _ctrl ctrlShow false;
    };
};

private _display = findDisplay 5000;
private _controlsGroup = _display displayCtrl (5510 + _newIndex);
_controlsGroup ctrlEnable true;
_controlsGroup ctrlShow true;
_controlsGroup ctrlCommit 0;
private _startIdc = 5200;
private _objectiveControls = [
    [0, "RscText"        ],
    [1, "RscCombo"       ],
    [2, "RscTextCheckBox"],
    [3, "RscTextCheckBox"],
    [4, "RscTextCheckBox"]
];

{
    _x params ["_idx", "_controlType"];
    private _idc = _startIdc + _idx;
    private _control = _controlsGroup controlsGroupCtrl _idc;
    switch (_controlType) do {
        case "RscText": {};
        case "RscCombo": {
            _control lbSetCurSel 0;
        };
        case "RscTextCheckBox": {
            _control ctrlSetChecked false;
        };
        default {};
    };
    _control ctrlEnable true;
    _control ctrlShow true;
    _control ctrlCommit 0;
} forEach _objectiveControls;

TRGM_VAR_iMissionParamObjectives pushBack [0, false, false, false];
publicVariable "TRGM_VAR_iMissionParamObjectives";

true;
