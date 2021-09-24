// private _fnc_scriptName = "TRGM_GLOBAL_fnc_commsPilotToVehicle";
params ["_vehicle","_text"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



private _playersInVehicle = [];
{
    if (isPlayer _x) then {
        _playersInVehicle pushBack _x;
    }
} forEach crew _vehicle;

[_vehicle,_text] remoteExecCall ["vehicleChat",_playersInVehicle ,false];

true;