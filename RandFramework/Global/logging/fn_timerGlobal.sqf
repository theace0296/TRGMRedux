// private _fnc_scriptName = "TRGM_GLOBAL_fnc_timerGlobal";
params ["_duration", "_index", "_label"];
_endTime = _duration + time;
_notificationIndex = ceil(_index + random 100);
while {_endTime - time >= 0 && !TRGM_VAR_OverrideTimer} do {
    _color = "#45f442";//green
    _timeLeft = _endTime - time;
    if (_timeLeft < 16) then {_color = "#eef441";};//yellow
    if (_timeLeft < 6) then {_color = "#ff0000";};//red
    if (_timeLeft < 0) exitWith {};
    _content = parseText format ["%1: <t color='%2'>--- %3 ---</t>", _label, _color, [(_timeLeft/3600),"HH:MM:SS"] call BIS_fnc_timeToString];
    [[_content, _duration + 1, _index, _notificationIndex], {_this spawn TRGM_GUI_fnc_handleNotification}] remoteExec ["call"]; // After the first run, this will only update the text for the notification with index = _taskIndex
};
true;