/*
 * Author: TheAce0296
 * Sets the value of the time setting slider/edit boxes.
 *
 * Arguments:
 * 0 - Control that called this function. <CONTROL> (Can be NIL)
 * 1 - Base value to set other values from <NUMBER/ARRAY> (Can be NIL)
 * 2 - String identifier of where the value is coming from. <STRING>
 *     "Slider" - Value is coming from the time slider,    Arg 2 should be a number.
 *     "Edit"     - Value is coming from the edit boxes,     Arg 2 does not apply.
 *     "Init"     - Value is coming from an internal script, Arg 2 should be an array of [hour, minute].
 *
 * Return Value:
 * true <BOOL>
 *
 * Example:
 * [nil, [8, 15], "Init"] call TRGM_GUI_fnc_timeSliderOnChange;
 */

disableSerialization;
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



params ["_ctrl", "_newvalue", "_ctrlStr"];

private _display     = findDisplay 5000;
private _ctrlSlider = _display displayCtrl 5115;
private _ctrlHour     = _display displayCtrl 5116;
private _ctrlMinute = _display displayCtrl 5117;
private _ctrlSecond = _display displayCtrl 5118;

switch (_ctrlStr) do {
    case "Slider": {
        private _value = _newvalue * 3600;
        private _valueHour = floor (_value / 3600);
        private _valueMinute = floor ((_value / 60) mod 60);
        private _valueSecond = floor (_value mod 60);
        private _textHour = if (_valueHour < 10) then {'0' + str _valueHour} else {str _valueHour};
        private _textMinute = if (_valueMinute < 10) then {'0' + str _valueMinute} else {str _valueMinute};
        private _textSecond = if (_valueSecond < 10) then {'0' + str _valueSecond} else {str _valueSecond};
        _ctrlHour ctrlSetText _textHour;
        _ctrlMinute ctrlSetText _textMinute;
        _ctrlSecond ctrlSetText _textSecond;
    };
    case "Edit": {
        private _value = (round (parseNumber ctrlText _ctrlHour) + round (parseNumber ctrlText _ctrlMinute) / 60 + round (parseNumber ctrlText _ctrlSecond) / 3600) * 3600;
        _ctrlSlider sliderSetPosition (_value / 3600);
    };
    case "Init": {
        private _valueHour = _newvalue select 0;
        private _valueMinute = _newvalue select 1;
        private _valueSecond = 0;
        private _textHour = if (_valueHour < 10) then {'0' + str _valueHour} else {str _valueHour};
        private _textMinute = if (_valueMinute < 10) then {'0' + str _valueMinute} else {str _valueMinute};
        private _textSecond = if (_valueSecond < 10) then {'0' + str _valueSecond} else {str _valueSecond};
        _ctrlHour ctrlSetText _textHour;
        _ctrlMinute ctrlSetText _textMinute;
        _ctrlSecond ctrlSetText _textSecond;
        private _value = (round (_valueHour) + round (_valueMinute) / 60 + round (_valueSecond) / 3600) * 3600;
        _ctrlSlider sliderSetPosition (_value / 3600);
        TRGM_VAR_arrayTime = [_valueHour, _valueMinute]; publicVariable "TRGM_VAR_arrayTime";
    };
    default {};
};