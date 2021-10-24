// private _fnc_scriptName = "TRGM_GUI_fnc_missionSetupControlsOnChange";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


_this params ["_control"];
disableSerialization;

private _idc = ctrlIDC _control;

switch (_idc) do {
    case 5201: {
        waitUntil { !(isNil "TRGM_VAR_iMissionParamObjectives"); };
        private _index = ((ctrlIDC (ctrlParentControlsGroup _control)) - 5510);
        if (_index < count TRGM_VAR_iMissionParamObjectives) then {
            private _objectiveParams = TRGM_VAR_iMissionParamObjectives select _index;
            if (isNil "_objectiveParams" || {count _objectiveParams < 4}) then {
                _objectiveParams = [0, false, false, false];
            };
            private _selection = lbCurSel _control;
            _objectiveParams set [0, _selection];
            TRGM_VAR_iMissionParamObjectives set [_index, _objectiveParams];
        };
    };
    case 5202: {
        waitUntil { !(isNil "TRGM_VAR_iMissionParamObjectives"); };
        private _index = ((ctrlIDC (ctrlParentControlsGroup _control)) - 5510);
        if (_index < count TRGM_VAR_iMissionParamObjectives) then {
            private _objectiveParams = TRGM_VAR_iMissionParamObjectives select _index;
            if (isNil "_objectiveParams" || {count _objectiveParams < 4}) then {
                _objectiveParams = [0, false, false, false];
            };
            private _isChecked = ctrlChecked _control;
            _objectiveParams set [1, _isChecked];
            TRGM_VAR_iMissionParamObjectives set [_index, _objectiveParams];
        };
    };
    case 5203: {
        waitUntil { !(isNil "TRGM_VAR_iMissionParamObjectives"); };
        private _index = ((ctrlIDC (ctrlParentControlsGroup _control)) - 5510);
        if (_index < count TRGM_VAR_iMissionParamObjectives) then {
            private _objectiveParams = TRGM_VAR_iMissionParamObjectives select _index;
            if (isNil "_objectiveParams" || {count _objectiveParams < 4}) then {
                _objectiveParams = [0, false, false, false];
            };
            private _isChecked = ctrlChecked _control;
            _objectiveParams set [2, _isChecked];
            TRGM_VAR_iMissionParamObjectives set [_index, _objectiveParams];
        };
    };
    case 5204: {
        waitUntil { !(isNil "TRGM_VAR_iMissionParamObjectives"); };
        private _index = ((ctrlIDC (ctrlParentControlsGroup _control)) - 5510);
        if (_index < count TRGM_VAR_iMissionParamObjectives) then {
            private _objectiveParams = TRGM_VAR_iMissionParamObjectives select _index;
            if (isNil "_objectiveParams" || {count _objectiveParams < 4}) then {
                _objectiveParams = [0, false, false, false];
            };
            private _isChecked = (ctrlChecked _control) && !(_index isEqualTo 0);
            _objectiveParams set [3, _isChecked];
            TRGM_VAR_iMissionParamObjectives set [_index, _objectiveParams];
        };
    };
    case 5504: {
        TRGM_VAR_IsFullMap = ctrlChecked _control;
        publicVariable "TRGM_VAR_IsFullMap";
    };
    case 5100: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamRepOptionsValues") && {count TRGM_VAR_MissionParamRepOptionsValues > 0}; };
        TRGM_VAR_iMissionParamRepOption = TRGM_VAR_MissionParamRepOptionsValues select (lbCurSel _control);
        publicVariable "TRGM_VAR_iMissionParamRepOption";
    };
    case 5101: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamWeatherOptionsValues") && {count TRGM_VAR_MissionParamWeatherOptionsValues > 0}; };
        TRGM_VAR_iWeather = TRGM_VAR_MissionParamWeatherOptionsValues select (lbCurSel _control);
        publicVariable "TRGM_VAR_iWeather";
    };
    case 5115: {
        private _ctrlTimeValue = (sliderPosition _control) * 3600;
        TRGM_VAR_arrayTime = [floor (_ctrlTimeValue / 3600), floor ((_ctrlTimeValue / 60) mod 60)];
        publicVariable "TRGM_VAR_arrayTime";
    };
    case 5102: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamNVGOptionsValues") && {count TRGM_VAR_MissionParamNVGOptionsValues > 0}; };
        TRGM_VAR_iAllowNVG = TRGM_VAR_MissionParamNVGOptionsValues select (lbCurSel _control);
        publicVariable "TRGM_VAR_iAllowNVG";
    };
    case 5103: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamReviveOptionsValues") && {count TRGM_VAR_MissionParamReviveOptionsValues > 0}; };
        TRGM_VAR_iUseRevive = TRGM_VAR_MissionParamReviveOptionsValues select (lbCurSel _control);
        publicVariable "TRGM_VAR_iUseRevive";
    };
    case 5104: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamLocationOptionsValues") && {count TRGM_VAR_MissionParamLocationOptionsValues > 0}; };
        TRGM_VAR_iStartLocation = TRGM_VAR_MissionParamLocationOptionsValues select (lbCurSel _control);
        publicVariable "TRGM_VAR_iStartLocation";
    };
    default { };
};

true;
