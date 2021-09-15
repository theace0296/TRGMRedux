params [["_vehicle", objNull, [objNull]]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (isNil "_vehicle" || isNull _vehicle) exitWith {};

if !(_vehicle isKindOf "Helicopter") exitWith {};

[_vehicle, [format [localize "STR_TRGM2_spawnCrew", gettext (configFile >> "Cfgvehicles" >> (typeOf _vehicle) >> "displayname")], {
    params [["_target", objNull, [objNull]], ["_caller", objNull, [objNull]], ["_id", -1, [1]], ["_args", [], [[]]]];
    private _group = createGroup TRGM_VAR_FriendlySide;
    [_group, _target, true] call TRGM_GLOBAL_fnc_createVehicleCrew;
    private _totalTurrets = [typeof _target, true] call BIS_fnc_allTurrets;
    {_target lockTurret [_x, true]} forEach _totalTurrets;
    { _x disableAI "MOVE"; _x allowDamage false; } forEach crew _target;
    [_target] spawn {
        params ["_vehicle"];
        waitUntil { !([_vehicle] call TRGM_GLOBAL_fnc_helicopterIsFlying); };
        { _x enableAI "MOVE"; } forEach crew _vehicle;
        [_vehicle] call TRGM_GLOBAL_fnc_setVehicleUpright;
        {_x setDamage 0;} forEach (crew _vehicle + [_vehicle]);
        if (call TRGM_GETTER_fnc_bTransportEnabled) then {
            [[_vehicle]] remoteExec ["TRGM_GLOBAL_fnc_addTransportActions", 0, true];
            if !(isNil "TRGM_VAR_transportHelosToGetActions") then {
                TRGM_VAR_transportHelosToGetActions pushBack _vehicle;
                publicVariable "TRGM_VAR_transportHelosToGetActions";
            };
        };
    };
}, [], -99, false, false, "", "_this isEqualTo player && leader group player isEqualTo player && count crew _target isEqualto 0 && alive _target && ((_target distance (getMarkerPos 'mrkHQ')) < 500)"]] remoteExec ["addAction", 0];