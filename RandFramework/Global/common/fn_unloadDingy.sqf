// private _fnc_scriptName = "TRGM_GLOBAL_fnc_unloadDingy";
params ["_target", "", "_id", ""];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _dingy = selectRandom TRGM_VAR_FriendlyFastResponseDingy createVehicle [0,0,0];
private _flatPos = [[_target] call TRGM_GLOBAL_fnc_getRealPos, 5, 10, 5, 2, 0.5, 0,[],[[0,0,0],[0,0,0]], _dingy] call TRGM_GLOBAL_fnc_findSafePos;
if (str(_flatPos) isEqualTo "[0,0,0]") then {
    _flatPos = [[_target] call TRGM_GLOBAL_fnc_getRealPos, 5, 8, 5, 0, 0.5, 0,[],[[0,0,0],[0,0,0]], _dingy] call TRGM_GLOBAL_fnc_findSafePos;
    if (str(_flatPos) isEqualTo "[0,0,0]") then {
        [(localize "STR_TRGM2_UnloadDingy_NoArea")] call TRGM_GLOBAL_fnc_notify;
        deleteVehicle _dingy;
    }
    else {
        _dingy setPos _flatPos;
        [_dingy, [format [localize "STR_TRGM2_UnloadDingy_push", getText (configFile >> "CfgVehicles" >> (typeOf _dingy) >> "displayName")],{_this spawn TRGM_GLOBAL_fnc_pushObject;}, [], -99, false, false, "", "_this isEqualTo player && count crew _target isEqualTo 0 && alive _target"]] remoteExec ["addAction", 0];
        [(localize "STR_TRGM2_UnloadDingy_DingyUnloaded")] call TRGM_GLOBAL_fnc_notify;
        _target removeAction _id;
    };

}
else {
    _dingy setPos _flatPos;
    [_dingy, [format [localize "STR_TRGM2_UnloadDingy_push", getText (configFile >> "CfgVehicles" >> (typeOf _dingy) >> "displayName")],{_this spawn TRGM_GLOBAL_fnc_pushObject;}, [], -99, false, false, "", "_this isEqualTo player && count crew _target isEqualTo 0 && alive _target"]] remoteExec ["addAction", 0];
    [(localize "STR_TRGM2_UnloadDingy_DingyUnloadedWater")] call TRGM_GLOBAL_fnc_notify;
    _target removeAction _id;
};
