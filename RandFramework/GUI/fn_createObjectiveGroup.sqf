#define UI_GRID_X       (safezoneX)
#define UI_GRID_Y       (safezoneY)
#define UI_GRID_W       (safezoneW / 40)
#define UI_GRID_H       (safezoneH / 25)
#define UI_GRID_WABS    (safezoneW)
#define UI_GRID_HABS    (safezoneH)

#define MISSION_TYPE_X (11.5 * UI_GRID_W + UI_GRID_X)
#define MISSION_TYPE_Y (7.28 * UI_GRID_H + UI_GRID_Y)
#define MISSION_TYPE_W (5 * UI_GRID_W)
#define MISSION_TYPE_H (1 * UI_GRID_H)

#define PADDING_W (UI_GRID_W * (2 / 3))
#define PADDING_H (1.5 * UI_GRID_H)

#define TRGM_ORANGE [0.85,0.45,0,1]
#define TRGM_BLUE   [0,0.45,0.85,1]

#define OBJECTIVE_Y (MISSION_TYPE_Y + PADDING_H)
#define OBJECTIVE_W (3 * UI_GRID_W)
#define OBJECTIVE_H (0.6 * UI_GRID_H)

format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
_this params ["_index"];

disableSerialization;

if (isNil "TRGM_VAR_iMissionIsCampaign") then { TRGM_VAR_iMissionIsCampaign = false; publicVariable "TRGM_VAR_iMissionIsCampaign"; };

if (TRGM_VAR_iMissionIsCampaign) exitWith {};

if (isNil "TRGM_VAR_iMissionParamObjectives") exitWith {};

private _display = findDisplay 5000;

private _startIdc = 5200 + (10 * _index);
private _objectiveControls = [
    [_startIdc + 0, "RscText"        , format [localize "STR_TRGM2_dialogs_ObjectiveIndex", _index + 1], [(11.10 * UI_GRID_W + UI_GRID_X), OBJECTIVE_Y, OBJECTIVE_W, OBJECTIVE_H]],
    [_startIdc + 1, "RscCombo"       , localize "STR_TRGM2_dialogs_Objective", [(13 * UI_GRID_W + UI_GRID_X), OBJECTIVE_Y, (2 * OBJECTIVE_W), OBJECTIVE_H]],
    [_startIdc + 2, "RscTextCheckBox", ["Not heavy objective", "Heavy objective", "Set the objective as heavy.", 1], [(19.25 * UI_GRID_W + UI_GRID_X), OBJECTIVE_Y, OBJECTIVE_W, OBJECTIVE_H]],
    [_startIdc + 3, "RscTextCheckBox", ["Not hidden objective", "Hidden objective", "Set the objective as hidden.", 1], [(22.5 * UI_GRID_W + UI_GRID_X), OBJECTIVE_Y, OBJECTIVE_W, OBJECTIVE_H]],
    [_startIdc + 4, "RscTextCheckBox", ["Not in same AO", "In same AO", "Set the objective to be in the same AO as the objective above this.", 1], [(25.75 * UI_GRID_W + UI_GRID_X), OBJECTIVE_Y, OBJECTIVE_W, OBJECTIVE_H]]
];

{
    _x params ["_idc", "_controlType", "_textArgs", "_positionArgs"];
    _positionArgs params ["_xPos", "_yPos", "_width", "_height"];
    private _control = _display ctrlCreate [_controlType, _idc];
    _control ctrlSetPosition [_xPos, (_yPos + (_index * OBJECTIVE_H)), _width, _height];
    switch (_controlType) do {
        case "RscText": {
            _control ctrlSetText _textArgs;
            _control ctrlSetTextColor TRGM_ORANGE;
        };
        case "RscCombo": {
            _control ctrlSetText _textArgs;
            {
                _control lbAdd _x;
            } forEach TRGM_VAR_MissionParamObjectives;
            _control lbSetCurSel 0;
        };
        case "RscTextCheckBox": {
            _textArgs params ["_string", "_checked_string", "_tooltip", "_value"];
            _control lbSetText      [0, _string];
            _control lbSetTextRight [0, _checked_string];
            _control lbSetTooltip   [0, _tooltip];
            _control lbSetValue     [0, _value];
            _control ctrlSetTextColor TRGM_ORANGE;
            _control lbSetSelectColorRight TRGM_BLUE;
            _control ctrlSetBackgroundColor [0, 0, 0, 1];
            _control lbSetSelectColor [0, 0, 0, 1];
        };
        default {};
    };
    _control ctrlCommit 0;
} forEach _objectiveControls;

true;