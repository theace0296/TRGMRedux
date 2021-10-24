// private _fnc_scriptName = "TRGM_SERVER_fnc_paramedicKilled";
params ["_killed","_killer"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (side _killer isEqualTo TRGM_VAR_FriendlySide && str(_killed) != str(_killer)) then {
    //bCivKilled = true;
    //publicVariable "bCivKilled";

    //CivDeathCount = CivDeathCount + 1;
    //publicVariable "CivDeathCount";

    [0.2,format[localize "STR_TRGM2_ParamedicKilledBy", name _killer]] spawn TRGM_GLOBAL_fnc_adjustBadPoints;
};

true;