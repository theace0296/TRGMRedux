params ["_thisCiv"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


if (isServer) then { // only do once -> on the serer

    // Set Armament of this Civ
    _possibleArmaments = [
        [
            "hgun_Pistol_heavy_02_F",     // gun
            "6Rnd_45ACP_Cylinder",         // magazine
            2                             // amount of magazines
        ],
        [
            "hgun_P07_F",
            "16Rnd_9x21_Mag",
            2
        ],
        [
            "hgun_ACPC2_F",
            "9Rnd_45ACP_Mag",
            3
        ]
    ];

    _thisCiv setVariable ["armament", (selectRandom _possibleArmaments), true];
    // to retrieve the armament use: (_civ getVariable "armament") params ["_gun","_magazine","_amount"];


    [_thisCiv] spawn {
        params ["_thisCiv"];
        (_thisCiv getVariable "armament") params ["_gun","_magazine","_amount"];

        private _bFired = false;
        private _bActivated = false;

        // continiously watch for players and decide to engage or not
        while {alive _thisCiv && !_bFired} do {
            {
                if ((_x in playableUnits) || _x in switchableUnits) then {
                    if (random 1 < .33) then {
                        //load armament
                        if (!_bActivated) then {
                            _bActivated = true;
                            private _grpName = createGroup TRGM_VAR_EnemySide;
                            [_thisCiv] joinSilent _grpName;

                            _thisCiv addMagazines [_magazine,_amount];
                            _thisCiv addWeapon _gun;
                            _thisCiv allowFleeing 0;
                        };
                        private _cansee = [objNull, "VIEW"] checkVisibility [eyePos _thisCiv, eyePos _x];
                        if (_cansee > 0.2) then {
                            _thisCiv doTarget _x;
                            _thisCiv commandFire _x; //LOCAL - ?

                            sleep 3;
                            _thisCiv fire _gun;
                            sleep 1;
                            _thisCiv fire _gun;
                            sleep 1;
                            _thisCiv fire _gun;
                            _bFired = true;
                        };

                    };
                };

            } forEach (nearestObjects [([_thisCiv] call TRGM_GLOBAL_fnc_getRealPos),["Man"],10]);

            sleep 5;
        };
    };

};


true;