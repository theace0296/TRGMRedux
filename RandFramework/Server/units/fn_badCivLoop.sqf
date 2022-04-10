// private _fnc_scriptName = "TRGM_SERVER_fnc_badCivLoop";
params ["_badCiv"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



(_badCiv getVariable "armament") params ["_gun","_magazine","_amount"];

private _bFired = false;
private _bActivated = false;

// continiously watch for players and decide to engage or not
waitUntil {
    {
        if ((_x in playableUnits)) then {
            if (random 1 < .33) then {
                //load armament

                if (!_bActivated) then {
                    _bActivated = true;
                    private _grpName = (createGroup [TRGM_VAR_EnemySide, true]);
                    [_badCiv] joinSilent _grpName;

                    [_badCiv] call TRGM_SERVER_fnc_badCivApplyAssingnedArmament;

                    _badCiv allowFleeing 0;
                };
                private _cansee = [objNull, "VIEW"] checkVisibility [eyePos _badCiv, eyePos _x];
                if (_cansee > 0.2) then {
                    _badCiv doTarget _x;
                    _badCiv commandFire _x; //LOCAL - ?

                    sleep 3;
                    _badCiv fire _gun;
                    sleep 1;
                    _badCiv fire _gun;
                    sleep 1;
                    _badCiv fire _gun;
                    _bFired = true;
                };

            };
        };

    } forEach (nearestObjects [([_badCiv] call TRGM_GLOBAL_fnc_getRealPos),["Man"],10]);
    sleep 2;
    !(alive _badCiv) || _bFired;
};


true;