params ["_killed","_killer"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


if (side _killer isEqualTo TRGM_VAR_FriendlySide && str(_killed) != str(_killer)) then {
    //bCivKilled = true;
    //publicVariable "bCivKilled";

    //CivDeathCount = CivDeathCount + 1;
    //publicVariable "CivDeathCount";

    [0.2,format["Paramedic Killed by %1", name _killer]] spawn TRGM_GLOBAL_fnc_adjustBadPoints;
};

true;