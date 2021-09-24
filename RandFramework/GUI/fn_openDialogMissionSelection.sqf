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

format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



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

    if (count TRGM_VAR_AdvancedSettings < 6) then {
        TRGM_VAR_AdvancedSettings pushBack 10;
    };

    if (count TRGM_VAR_AdvancedSettings < 7) then {
        TRGM_VAR_AdvancedSettings pushBack (TRGM_VAR_DefaultEnemyFactionValue select 0);
    };

    if (TRGM_VAR_AdvancedSettings select 6 isEqualTo 0) then { //we had an issue with some being set to zero (due to a bad published version, this makes sure any zeros are adjusted to correct id)
        TRGM_VAR_AdvancedSettings set [6,TRGM_VAR_DefaultEnemyFactionValue select 0];
    };

    if (count TRGM_VAR_AdvancedSettings < 8) then {
        TRGM_VAR_AdvancedSettings pushBack (TRGM_VAR_DefaultMilitiaFactionValue select 0);
    };

    if (count TRGM_VAR_AdvancedSettings < 9) then {
        TRGM_VAR_AdvancedSettings pushBack (TRGM_VAR_DefaultFriendlyFactionValue select 0);
    };

    if !(TRGM_VAR_AdvancedSettings select 6 in TRGM_VAR_DefaultEnemyFactionArray) then {
        private _bFound = false;
        {
            if (!_bFound && _x in TRGM_VAR_DefaultEnemyFactionArray) then {
                _bFound = true;
                TRGM_VAR_AdvancedSettings set [6,_x];
            };
        } forEach TRGM_VAR_DefaultEnemyFactionValue;
    };

    if !(TRGM_VAR_AdvancedSettings select 7 in TRGM_VAR_DefaultMilitiaFactionArray) then {
        private _bFound = false;
        {
            if (!_bFound && _x in TRGM_VAR_DefaultMilitiaFactionArray) then {
                _bFound = true;
                TRGM_VAR_AdvancedSettings set [7,_x];
            };
        } forEach TRGM_VAR_DefaultMilitiaFactionValue;
    };

    if !(TRGM_VAR_AdvancedSettings select 8 in TRGM_VAR_DefaultFriendlyFactionArray) then {
        private _bFound = false;
        {
            if (!_bFound && _x in TRGM_VAR_DefaultFriendlyFactionArray) then {
                _bFound = true;
                TRGM_VAR_AdvancedSettings set [8,_x];
            };
        } forEach TRGM_VAR_DefaultFriendlyFactionValue;
    };

    for [{private _i = 9}, {_i < count TRGM_VAR_DefaultAdvancedSettings}, {_i = _i + 1}] do {
        if (count TRGM_VAR_AdvancedSettings < (_i + 1)) then {
            TRGM_VAR_AdvancedSettings pushBack (TRGM_VAR_DefaultAdvancedSettings select _i);
        };
    };

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
        private _CurrentControl = _x;
        private _lnpCtrlType = _x select 2;
        private _ThisControlOptions = (_x select 4);
        private _ThisControlIDX = (_x select 0) + 1;
        private _ctrlItem = (findDisplay 6000) displayCtrl _ThisControlIDX;
        TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + "\n\n" + str(lbCurSel _ctrlItem);
        publicVariable "TRGM_VAR_debugMessages";
        private _value = nil;
        if (_lnpCtrlType isEqualTo "RscCombo") then {
            TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + "\n\nHERE80:" + str(lbCurSel _ctrlItem);
            _value = _ThisControlOptions select ([lbCurSel _ctrlItem, 0] select (lbCurSel _ctrlItem isEqualTo -1));
        };
        if (_lnpCtrlType isEqualTo "RscEdit") then {
            _value = ctrlText _ThisControlIDX;
        };
        if (_lnpCtrlType isEqualTo "RscXSliderH") then {
            _value = sliderPosition _ThisControlIDX;
        };
        TRGM_VAR_AdvancedSettings pushBack _value;
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

