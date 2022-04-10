// private _fnc_scriptName = "TRGM_SERVER_fnc_playBaseRadioEffect";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

waitUntil {
    playSound3D ["A3\Sounds_F\sfx\radio\" + selectRandom TRGM_VAR_FriendlyRadioSounds + ".wss",baseRadio,false,getPosASL baseRadio,0.5,1,0];
    sleep selectRandom [20,30,40];
    false;
};