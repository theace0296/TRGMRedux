// private _fnc_scriptName = "TRGM_CLIENT_fnc_supportArtiRequested";

format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


private _artiVeh = _this select 0;
if !(isNil "_artiVeh") then {
    _artiVeh addEventHandler [
        "fired",
        "[0.1,localize 'STR_TRGM2_SupportArtiRequested_Hint'] spawn TRGM_GLOBAL_fnc_adjustBadPoints; [(localize ""STR_TRGM2_SupportArtiRequested_Hint"")] call TRGM_GLOBAL_fnc_notify;"
    ];
};
