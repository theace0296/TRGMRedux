//if some condition is true, we give this guy a gun and change side

params["_thisCiv"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};

private _bFired = false;

while {alive _thisCiv && !_bFired} do {
    private _nearestunits = nearestObjects [([_thisCiv] call TRGM_GLOBAL_fnc_getRealPos),["Man"],10];
    {
        if ((_x in playableunits)) then {
            if (random 1 < .33) then {
                private _grpName = createGroup TRGM_VAR_EnemySide;
                [_thisCiv] joinSilent _grpName;

                _thisCiv dotarget _x;
                _thisCiv commandFire _x;
                _bFired = true;
            };
        };

    } forEach _nearestunits;
    sleep 5;
};


true;