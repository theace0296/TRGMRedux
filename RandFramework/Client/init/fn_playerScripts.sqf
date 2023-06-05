// private _fnc_scriptName = "TRGM_CLIENT_fnc_playerScripts";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (side player isEqualTo civilian) then {

    0 enableChannel false;
    1 enableChannel false;
    2 enableChannel false;
    3 enableChannel false;
    4 enableChannel false;
    5 enableChannel false;

    //["CC"] call TRGM_GLOBAL_fnc_notify;

    //player removeAllActions;

    player setVariable ["tf_unable_to_use_radio", true];
    player setVariable ["tf_globalVolume", 0];

    player addEventHandler ["GetInMan",{player action ["Eject",vehicle player];}];

    [player, true] remoteExec ["hideObjectGlobal", 2];

    player addaction ["Teleport",{titleText[localize "STR_TRGM2_tele_SelectPosition", "PLAIN"]; onMapSingleClick "vehicle player setPos _pos; onMapSingleClick '';true;";}];
    player addaction [localize "STR_TRGM2_Toggle_Fast_Run",{
        private _bCurrentFastRun = player getVariable ["fastRun",false];
        player setVariable ["fastRun",!_bCurrentFastRun];
    }];

    [player, true] remoteExec ["hideObjectGlobal", 2];
    while {(alive(player))} do
    {
        //[format["speed:%1",speed player]] call TRGM_GLOBAL_fnc_notify;
        player enableFatigue false;
        player enableStamina false;
        removeAllWeapons player;

        if (speed player > 16) then {
            //["test2"] call TRGM_GLOBAL_fnc_notify;
            if (player getVariable ["fastRun",false]) then {
                player setAnimSpeedCoef 6;
                player allowDamage false;
                sleep 0.4;
            };
        }
        else {
            player setAnimSpeedCoef 1;
            player allowDamage false;
            sleep 0.4;
        };

        sleep 10;
    };

};

if (TRGM_VAR_iAllowNVG isEqualTo 2) then {
    call TRGM_GLOBAL_fnc_nvScript;
};

private _trg = createTrigger["EmptyDetector", [player] call TRGM_GLOBAL_fnc_getRealPos];
_trg setTriggerActivation["ALPHA", "PRESENT", true];
_trg setTriggerText (localize "STR_TRGM2_IlluminatePosition_Text");
_trg setTriggerStatements["this", "[player] spawn TRGM_GLOBAL_fnc_fireIllumFlares;", ""];

if ([player] call TRGM_CLIENT_fnc_isAdmin) then {
    private _trg2 = createTrigger["EmptyDetector", [player] call TRGM_GLOBAL_fnc_getRealPos];
    _trg2 setTriggerActivation["BRAVO", "PRESENT", true];
    _trg2 setTriggerText (localize "STR_TRGM2_adminOption_openObjectiveStatusManager");
    _trg2 setTriggerStatements["this", "[player] spawn TRGM_GUI_fnc_openDialogObjectiveManager;", ""];
};