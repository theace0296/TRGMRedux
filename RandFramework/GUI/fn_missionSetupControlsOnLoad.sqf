// private _fnc_scriptName = "TRGM_GUI_fnc_missionSetupControlsOnLoad";
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


_this params ["_control"];
disableSerialization;

private _idc = ctrlIDC _control;

switch (_idc) do {
    case 5500: {
        _control ctrlShow false;
    };
    case 5510;
    case 5511;
    case 5512;
    case 5513;
    case 5514;
    case 5515;
    case 5516;
    case 5517: {
        waitUntil { !(isNil "TRGM_VAR_iMissionParamObjectives"); };
        private _index = ((ctrlIDC _control) - 5510);
        if ((_index + 1) > count TRGM_VAR_iMissionParamObjectives) then {
            _control ctrlEnable false;
            _control ctrlShow false;
        };
    };
    case 5201: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamObjectives") && {!(isNil "TRGM_VAR_iMissionParamObjectives") && {count TRGM_VAR_MissionParamObjectives > 0}}; };
        lbClear _control;
        {
            _control lbAdd _x;
        } forEach TRGM_VAR_MissionParamObjectives;
        private _index = ((ctrlIDC (ctrlParentControlsGroup _control)) - 5510);
        if ((_index + 1) > count TRGM_VAR_iMissionParamObjectives) then {
            _control ctrlEnable false;
            _control ctrlShow false;
        } else {
            private _objectiveParams = TRGM_VAR_iMissionParamObjectives select _index;
            if (isNil "_objectiveParams" || {count _objectiveParams < 4}) then {
                _objectiveParams = [0, false, false, false];
            };
            _control lbSetCurSel (_objectiveParams select 0);
        };
    };
    case 5202: {
        waitUntil { !(isNil "TRGM_VAR_iMissionParamObjectives"); };
        private _index = ((ctrlIDC (ctrlParentControlsGroup _control)) - 5510);
        if ((_index + 1) > count TRGM_VAR_iMissionParamObjectives) then {
            _control ctrlEnable false;
            _control ctrlShow false;
        } else {
            private _objectiveParams = TRGM_VAR_iMissionParamObjectives select _index;
            if (isNil "_objectiveParams" || {count _objectiveParams < 4}) then {
                _objectiveParams = [0, false, false, false];
            };
            _control ctrlSetChecked (_objectiveParams select 1);
        };
    };
    case 5203: {
        waitUntil { !(isNil "TRGM_VAR_iMissionParamObjectives"); };
        private _index = ((ctrlIDC (ctrlParentControlsGroup _control)) - 5510);
        if ((_index + 1) > count TRGM_VAR_iMissionParamObjectives) then {
            _control ctrlEnable false;
            _control ctrlShow false;
        } else {
            private _objectiveParams = TRGM_VAR_iMissionParamObjectives select _index;
            if (isNil "_objectiveParams" || {count _objectiveParams < 4}) then {
                _objectiveParams = [0, false, false, false];
            };
            _control ctrlSetChecked (_objectiveParams select 2);
        };
    };
    case 5204: {
        waitUntil { !(isNil "TRGM_VAR_iMissionParamObjectives"); };
        private _index = ((ctrlIDC (ctrlParentControlsGroup _control)) - 5510);
        if ((_index + 1) > count TRGM_VAR_iMissionParamObjectives) then {
            _control ctrlEnable false;
            _control ctrlShow false;
        } else {
            private _objectiveParams = TRGM_VAR_iMissionParamObjectives select _index;
            if (isNil "_objectiveParams" || {count _objectiveParams < 4}) then {
                _objectiveParams = [0, false, false, false];
            };
            _control ctrlSetChecked (_objectiveParams select 3);
        };
        if (_index isEqualTo 0) then {
            _control ctrlEnable false;
            _control ctrlSetChecked false;
            _control ctrlSetBackgroundColor [1, 1, 1, 0.25];
            _control ctrlSetActiveColor [1, 1, 1, 0.25];
            _control ctrlSetTextColor [1, 1, 1, 0.25];
        };
    };
    case 5501: {
        waitUntil { !(isNil "TRGM_VAR_iMissionIsCampaign"); };
        _control ctrlSetChecked TRGM_VAR_iMissionIsCampaign;
    };
    case 5504: {
        waitUntil { !(isNil "TRGM_VAR_IsFullMap"); };
        _control ctrlSetChecked TRGM_VAR_IsFullMap;
    };
    case 5100: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamRepOptions") && {count TRGM_VAR_MissionParamRepOptions > 0}; };
        lbClear _control;
        {
            _control lbAdd _x;
        } forEach TRGM_VAR_MissionParamRepOptions;
        _control lbSetCurSel (TRGM_VAR_MissionParamRepOptionsValues find TRGM_VAR_iMissionParamRepOption);
    };
    case 5101: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamWeatherOptions") && {count TRGM_VAR_MissionParamWeatherOptions > 0}; };
        lbClear _control;
        {
            _control lbAdd _x;
        } forEach TRGM_VAR_MissionParamWeatherOptions;
        _control lbSetCurSel (TRGM_VAR_MissionParamWeatherOptionsValues find TRGM_VAR_iWeather);
    };
    case 5102: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamNVGOptions") && {count TRGM_VAR_MissionParamNVGOptions > 0}; };
        lbClear _control;
        {
            _control lbAdd _x;
        } forEach TRGM_VAR_MissionParamNVGOptions;
        _control lbSetCurSel (TRGM_VAR_MissionParamNVGOptionsValues find TRGM_VAR_iAllowNVG);
    };
    case 5103: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamReviveOptions") && {count TRGM_VAR_MissionParamReviveOptions > 0}; };
        lbClear _control;
        {
            _control lbAdd _x;
        } forEach TRGM_VAR_MissionParamReviveOptions;
        _control lbSetCurSel (TRGM_VAR_MissionParamReviveOptionsValues find TRGM_VAR_iUseRevive);
        if (isClass(configFile >> "CfgPatches" >> "ace_medical")) then {
            _control ctrlEnable false;
        };
    };
    case 5104: {
        waitUntil { !(isNil "TRGM_VAR_MissionParamLocationOptions") && {count TRGM_VAR_MissionParamLocationOptions > 0}; };
        lbClear _control;
        {
            _control lbAdd _x;
        } forEach TRGM_VAR_MissionParamLocationOptions;
        _control lbSetCurSel (TRGM_VAR_MissionParamLocationOptionsValues find TRGM_VAR_iStartLocation);
    };
    case 5115: {
        waitUntil { !(isNil "TRGM_VAR_arrayTime"); };
        if ([8, 15] isEqualTo TRGM_VAR_arrayTime) then {
            [nil, [date select 3, date select 4], "Init"] call TRGM_GUI_fnc_timeSliderOnChange;
        } else {
            [nil, TRGM_VAR_arrayTime, "Init"] call TRGM_GUI_fnc_timeSliderOnChange;
        };
    };
    default { };
};

true;
