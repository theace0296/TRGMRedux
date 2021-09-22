
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
private _artiVeh = _this select 0;
if !(isNil "_artiVeh") then {
    _artiVeh addEventHandler [
        "fired",
        "[0.1,localize 'STR_TRGM2_SupportArtiRequested_Hint'] spawn TRGM_GLOBAL_fnc_adjustBadPoints; [(localize ""STR_TRGM2_SupportArtiRequested_Hint"")] call TRGM_GLOBAL_fnc_notify;"
    ];
};
