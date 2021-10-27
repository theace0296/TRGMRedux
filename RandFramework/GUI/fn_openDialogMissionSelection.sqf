// private _fnc_scriptName = "TRGM_GUI_fnc_openDialogMissionSelection";
/*
 * Author: Trendy (Modified by TheAce0296)
 * Opens the main mission set up dialog.
 * Loads the previous settings if they exist.
 *
 * Arguments: None
 *
 * Return Value:
 * true <BOOL>
 *
 * Example:
 * [] spawn TRGM_GUI_fnc_openDialogMissionSelection
 */

disableSerialization;

format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (isNil "TRGM_VAR_InitialLoadedPreviousSettings" && !TRGM_VAR_ForceMissionSetup) then {
    TRGM_VAR_InitialLoadedPreviousSettings = profileNamespace getVariable [format ["%1:PreviousSettings:%2", worldname, TRGM_VAR_SaveDataVersion],Nil]; //Get this from server only, but use player ID!!!
    if (!isNil "TRGM_VAR_InitialLoadedPreviousSettings" && {count TRGM_VAR_InitialLoadedPreviousSettings > 0 && {((["ResetMissionSettings", 0] call BIS_fnc_getParamValue) isEqualTo 0)}}) then {
        TRGM_VAR_InitialLoadedPreviousSettings params [
            ["_iMissionIsCampaign", false],
            ["_iMissionParamObjectives", [[0, false, false, false]]],
            ["_iAllowNVG", 2],
            ["_iMissionParamRepOption", 0],
            ["_iWeather", 1],
            ["_iUseRevive", 0],
            ["_iStartLocation", 2],
            ["_AdvancedSettings", TRGM_VAR_DefaultAdvancedSettings],
            ["_arrayTime", [8, 15]],
            ["_IsFullMap", false]
        ];
        TRGM_VAR_iMissionIsCampaign      = _iMissionIsCampaign; publicVariable "TRGM_VAR_iMissionIsCampaign";
        TRGM_VAR_iMissionParamObjectives = _iMissionParamObjectives; publicVariable "TRGM_VAR_iMissionParamObjectives";
        TRGM_VAR_iAllowNVG               = _iAllowNVG; publicVariable "TRGM_VAR_iAllowNVG";
        TRGM_VAR_iMissionParamRepOption  = _iMissionParamRepOption; publicVariable "TRGM_VAR_iMissionParamRepOption";
        TRGM_VAR_iWeather                = _iWeather; publicVariable "TRGM_VAR_iWeather";
        TRGM_VAR_iUseRevive              = _iUseRevive; publicVariable "TRGM_VAR_iUseRevive";
        TRGM_VAR_iStartLocation          = _iStartLocation; publicVariable "TRGM_VAR_iStartLocation";
        TRGM_VAR_AdvancedSettings        = _AdvancedSettings; publicVariable "TRGM_VAR_AdvancedSettings";
        TRGM_VAR_arrayTime               = _arrayTime; publicVariable "TRGM_VAR_arrayTime";
        TRGM_VAR_IsFullMap               = _IsFullMap; publicVariable "TRGM_VAR_IsFullMap";
    };

    {
        private _index = _x select 0;
        private _defaultValue = _x select 5;
        if (count TRGM_VAR_AdvancedSettings <= _index) then {
            TRGM_VAR_AdvancedSettings set [_index, _defaultValue];
        };
    } forEach TRGM_VAR_AdvControls;

    if (isClass(configFile >> "CfgPatches" >> "ace_medical")) then {
        if (TRGM_VAR_iUseRevive != 0) then { //Ace is active, so need to make sure "no revive" is selected
            TRGM_VAR_iUseRevive =  0; publicVariable "TRGM_VAR_iUseRevive";
        };
    };
    TRGM_VAR_InitialLoadedPreviousSettings = []; // no longer Nil, so will not reload our previously saved data and change any current changes
};

if (!isNull (findDisplay 6000)) then {
    TRGM_VAR_AdvancedSettings = [];
    {
        _x params ["_index", "_lblText", "_lnpCtrlType", "_Options", "_Values", "_DefaultValue", "_toolTip", "_appendText"];
        #define ADVCTRLIDC(IDX) 6001 + (2 * IDX)
        private _lblCtrlID = ADVCTRLIDC(_index);
        private _InpCtrlID = _lblCtrlID + 1;
        private _ctrlItem = (findDisplay 6000) displayCtrl _InpCtrlID;
        TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + "\n\n" + str(lbCurSel _ctrlItem);
        publicVariable "TRGM_VAR_debugMessages";
        private _value = nil;
        if (_lnpCtrlType isEqualTo "RscCombo") then {
            TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + "\n\nHERE80:" + str(lbCurSel _ctrlItem);
            _value = _Options select ([lbCurSel _ctrlItem, 0] select (lbCurSel _ctrlItem isEqualTo -1));
        };
        if (_lnpCtrlType isEqualTo "RscEdit") then {
            _value = ctrlText _InpCtrlID;
        };
        if (_lnpCtrlType isEqualTo "RscXSliderH") then {
            _value = sliderPosition _InpCtrlID;
        };
        TRGM_VAR_AdvancedSettings set [_index, _value];
    } forEach TRGM_VAR_AdvControls;
    publicVariable "TRGM_VAR_AdvancedSettings";
};

closedialog 0;

sleep 0.1;

if (isNil "TRGM_VAR_ForceMissionSetup") then { TRGM_VAR_ForceMissionSetup =   false; publicVariable "TRGM_VAR_ForceMissionSetup"; };
if (TRGM_VAR_ForceMissionSetup) then {
    [_this] spawn TRGM_GUI_fnc_setParamsAndBegin;
}
else {
    createDialog "TRGM_VAR_DialogSetupParams";
    waitUntil {!isNull (findDisplay 5000);};
};

