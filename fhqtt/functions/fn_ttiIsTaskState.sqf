// private _fnc_scriptName = "FHQ_fnc_ttiIsTaskState";
/* Internal Function */
private _state = toLower _this;
private _res = false;

if (_state in ["succeeded", "failed", "canceled", "created", "assigned"]) then {
    _res = true;
};

_res;