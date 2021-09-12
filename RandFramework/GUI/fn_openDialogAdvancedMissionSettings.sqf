/*
 * Author: Trendy (Modified by TheAce0296)
 * Opens the advanced mission settings dialog,
 * also saves the settings in the main dialog so
 * they don't get overwritten when moving from the
 * advanced settings dialog to the main dialog.
 *
 * Arguments: None
 *
 * Return Value:
 * true <BOOL>
 *
 * Example:
 * [] spawn TRGM_GUI_fnc_openDialogAdvancedMissionSettings
 */

disableSerialization;

format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

closedialog 0;

sleep 0.1;

createDialog "TRGM_VAR_DialogSetupParamsAdvanced";
waitUntil {!isNull (findDisplay 6000);};

_display = findDisplay 6000;
_lineHeight = 0.03;

_display ctrlCreate ["RscText", 6999];
_lblctrlTitle = _display displayCtrl 6999;
_lblctrlTitle ctrlSetPosition [0.3 * safezoneW + safezoneX, (0.25 + 0) * safezoneH + safezoneY,1 * safezoneW,0.02 * safezoneH];
ctrlSetText [6999,  localize "STR_TRGM2_openDialogAdvancedMissionSettings_AdvOpt"];

_lblctrlTitle ctrlCommit 0;

{
    // _lblCtrlID , _lblText                                                ,_lnpCtrlType ,_Options                          ,_Values                       ,_DefaultSelIndex                       ,tooltip
    //[6013       , localize "STR_TRGM2_TRGMSetUnitGlobalVars_EnemyFactions","RscCombo"   ,TRGM_VAR_DefaultEnemyFactionArrayText,TRGM_VAR_DefaultEnemyFactionArray,TRGM_VAR_DefaultEnemyFactionValue select 0,""     ],
    _currentLinePos = _lineHeight * (_forEachIndex + 1 - ([0, 13] select (_forEachIndex > 12)));
    _ctrlWidth = 0.08 * safezoneW;
    _ctrlHeight = 0.02 * safezoneH;
    _lblXPos = ([0, ((2 * _ctrlWidth) + 0.1)] select (_forEachIndex > 12)) + (0.3 * safezoneW + safezoneX);
    _inpXPos = ([0, ((2 * _ctrlWidth) + 0.1)] select (_forEachIndex > 12)) + (0.4 * safezoneW + safezoneX);
    _ctrlYPos = ((0.27 + _currentLinePos) * safezoneH + safezoneY);

    _x params ["_lblCtrlID", "_lblText", "_lnpCtrlType", "_Options", "_Values", "_DefaultValue", "_toolTip", "_appendText"];
    _InpCtrlID = _lblCtrlID + 1;

    _display ctrlCreate ["RscText", _lblCtrlID];
    _lblctrl = _display displayCtrl _lblCtrlID;
    _lblctrl ctrlSetPosition [_lblXPos, _ctrlYPos,_ctrlWidth,_ctrlHeight];
    ctrlSetText [_lblCtrlID,  _x select 1];
    _lblctrl ctrlCommit 0;

    _display ctrlCreate [_lnpCtrlType, _InpCtrlID];
    _inpctrl = _display displayCtrl _InpCtrlID;
    _inpctrl ctrlSetPosition [_inpXPos, _ctrlYPos,[_ctrlWidth, .75*_ctrlWidth] select (_lnpCtrlType isEqualTo "RscXSliderH"),_ctrlHeight];

    if (_lnpCtrlType isEqualTo "RscCombo") then {
        {
            _inpctrl lbAdd _x;
        } forEach _Options;
        _savedValue = _Values find (TRGM_VAR_AdvancedSettings select _forEachIndex);
        _inpctrl lbSetCurSel ([_savedValue, _DefaultValue] select (isNil "_savedValue"));
    };
    if (_lnpCtrlType isEqualTo "RscEdit") then {
        _savedValue = (TRGM_VAR_AdvancedSettings select _forEachIndex);
        _inpctrl ctrlSetText ([_savedValue, _DefaultValue] select (isNil "_savedValue"));
    };
    if (_lnpCtrlType isEqualTo "RscXSliderH") then {
        _inpctrl sliderSetRange [_Options, _Values];
        _inpctrl sliderSetSpeed [(_Values / _Options), 1];
        _savedValue = (TRGM_VAR_AdvancedSettings select _forEachIndex);
        _inpctrl sliderSetPosition ([_savedValue, _DefaultValue] select (isNil "_savedValue"));

        _display ctrlCreate ["ctrlEdit", (_InpCtrlID+500)];
        _valctrl = _display displayCtrl (_InpCtrlID+500);
        _valctrl ctrlSetPosition [_inpXPos+(.75*_ctrlWidth), _ctrlYPos,.25*_ctrlWidth,_ctrlHeight];
        _valctrl ctrlSetText (str(round ([_savedValue, _DefaultValue] select (isNil "_savedValue"))) + "s");
        _valctrl ctrlCommit 0;

        _inpctrl ctrlAddEventHandler ["SliderPosChanged", {
            params ["_control", "_newValue"];
            _display     = findDisplay 6000;
            _ctrlIDC     = ctrlIDC _control;
            _ctrlSlider    = _display displayCtrl _ctrlIDC;
            _ctrlVal     = _display displayCtrl (_ctrlIDC+500);
            _ctrlText = str(round _newValue);
            if !(isNil "_appendText") then {
                _ctrlText = format ["%1%2", _ctrlText, _appendText];
            };
            _ctrlVal ctrlSetText _ctrlText;
        }];
    };
    _inpctrl ctrlCommit 0;
    _inpctrl ctrlSetTooltip _toolTip;

} forEach TRGM_VAR_AdvControls;
