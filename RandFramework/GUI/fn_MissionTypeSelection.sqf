// private _fnc_scriptName = "TRGM_GUI_fnc_missionTypeSelection";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


_this params ["_control", "_selectedIndex", "_currentState"];

disableSerialization;

if !(_selectedIndex isEqualTo 0) exitWith {};

private _setTextCheckboxDisabled = {
    params ["_ctrl"];
    _ctrl ctrlEnable false;
    _ctrl ctrlSetBackgroundColor [1, 1, 1, 0.25];
    _ctrl ctrlSetActiveColor [1, 1, 1, 0.25];
    _ctrl ctrlSetTextColor [1, 1, 1, 0.25];
};

private _setTextCheckboxEnabled = {
    params ["_ctrl"];
    _ctrl ctrlEnable true;
    _ctrl ctrlSetBackgroundColor [0,0,0,1];
    _ctrl ctrlSetActiveColor [0, 0.45, 0.85, 1];
    _ctrl ctrlSetTextColor [0.85, 0.45 ,0, 1];
};

private _display = findDisplay 5000;

if (isNil "TRGM_VAR_AllowMissionTypeCampaign") then { TRGM_VAR_AllowMissionTypeCampaign = false; publicVariable "TRGM_VAR_AllowMissionTypeCampaign"; };
TRGM_VAR_iMissionIsCampaign = _currentState isEqualTo 1; publicVariable "TRGM_VAR_iMissionIsCampaign";

if (TRGM_VAR_iMissionIsCampaign) then {
    if (!TRGM_VAR_AllowMissionTypeCampaign) then {
        for [{private _groupIdx = 0}, {_groupIdx < count TRGM_VAR_iMissionParamObjectives}, {_groupIdx = _groupIdx + 1}] do {
            private _objectiveControlsGroup = _display displayCtrl (5510 + _groupIdx);
            for [{private _idx = 1}, {_idx <= 4}, {_idx = _idx + 1}] do {
                private _idc = 5200 + _idx;
                private _ctrl = _objectiveControlsGroup controlsGroupCtrl _idc;
                _ctrl ctrlEnable false;
                if !(_idx isEqualTo 1) then {
                    [_ctrl] call _setTextCheckboxDisabled;
                };
            };
        };
    };
    private _ctrlRep = _display displayCtrl 5100;
    _ctrlRep ctrlEnable false;
    _ctrlRep lbSetCurSel 1;
    private _ctrlWeather = _display displayCtrl 5101;
    _ctrlWeather ctrlEnable false;
    _ctrlWeather lbSetCurSel 0;

    private _ctrlAddObjective = _display displayCtrl 5502;
    _ctrlAddObjective ctrlEnable false;
    private _ctrlRemoveObjective = _display displayCtrl 5503;
    _ctrlRemoveObjective ctrlEnable false;
    private _ctrlFullMap = _display displayCtrl 5504;
    [_ctrlFullMap] call _setTextCheckboxDisabled;
}
else {

    for [{private _groupIdx = 0}, {_groupIdx < count TRGM_VAR_iMissionParamObjectives}, {_groupIdx = _groupIdx + 1}] do {
        private _objectiveControlsGroup = _display displayCtrl (5510 + _groupIdx);
        for [{private _idx = 1}, {_idx <= 4}, {_idx = _idx + 1}] do {
            private _idc = 5200 + _idx;
            private _ctrl = _objectiveControlsGroup controlsGroupCtrl _idc;
            _ctrl ctrlEnable true;
            if !(_idx isEqualTo 1) then {
                [_ctrl] call _setTextCheckboxEnabled;
            };
        };
        if (_groupIdx isEqualTo 0) then {
            private _ctrl = _objectiveControlsGroup controlsGroupCtrl 5204;
            [_ctrl] call _setTextCheckboxDisabled;
            _ctrl ctrlSetChecked false;
        };
    };

    private _ctrlRep = _display displayCtrl 5100;
    _ctrlRep ctrlEnable true;
    private _ctrlWeather = _display displayCtrl 5101;
    _ctrlWeather ctrlEnable true;

    private _ctrlAddObjective = _display displayCtrl 5502;
    _ctrlAddObjective ctrlEnable true;
    private _ctrlRemoveObjective = _display displayCtrl 5503;
    _ctrlRemoveObjective ctrlEnable true;
    private _ctrlFullMap = _display displayCtrl 5504;
    _ctrlFullMap ctrlEnable true;
    [_ctrlFullMap] call _setTextCheckboxEnabled;
};

if (!isMultiplayer) then {
    private _ctrlLoadLocal = _display displayCtrl 1601;
    private _ctrlLoadGlobal = _display displayCtrl 1602;
    _ctrlLoadLocal  ctrlShow false;
    _ctrlLoadGlobal  ctrlShow false;
};

true;