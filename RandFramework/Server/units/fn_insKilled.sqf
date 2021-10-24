// private _fnc_scriptName = "TRGM_SERVER_fnc_insKilled";
params  ["_killed","_killer"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + "\n" + format ["InsKilledTest: KilledSide: %1 - KillerSide: %2 - KilledString: %3 - KillerString: %4",side _killed,side _killer,str(_killed),str(_killer)];
publicVariable "TRGM_VAR_debugMessages";

sleep 3;

if (side _killer isEqualTo TRGM_VAR_FriendlySide && str(_killed) != str(_killer)) then {
    [0.2,format[localize "STR_TRGM2_InsKilled_RebelKilled", name _killer]] spawn TRGM_GLOBAL_fnc_adjustBadPoints;

    private _nearestunits = nearestObjects [getPos _killed,["Man","Car","Tank"],2000];
    private _grpName = createGroup TRGM_VAR_EnemySide;
    {
        private _isRebel = _x getVariable ["IsRebel", false];
        if (_isRebel) then {
            [_x] joinSilent _grpName;
        };
    } forEach _nearestunits;
};

true;