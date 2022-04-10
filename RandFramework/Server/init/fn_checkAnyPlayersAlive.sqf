// private _fnc_scriptName = "TRGM_SERVER_fnc_checkAnyPlayersAlive";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



sleep 3;
private  = false;
waitUntil {
    private _bAnyAlive = false;
    {
        if (isPlayer _x) then {
            private _iRespawnTicketsLeft = [_x,nil,true] call BIS_fnc_respawnTickets;
            if (alive _x || _iRespawnTicketsLeft > 0) then {
                _bAnyAlive = true;
            };
        }
        else {
            if (alive _x) then {
                _bAnyAlive = true;
            };
        };
    } forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
    if (!_bAnyAlive) then {
        ["end3", true, 5] remoteExec ["BIS_fnc_endMission"];
        _bEnded = true;
        sleep 5;
    };
    sleep 30;
    _bEnded;
};