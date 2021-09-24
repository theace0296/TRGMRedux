//Not used... may consider settings this for militia units???
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};

private _Unit = _this select 0;
_Unit setSkill ["aimingaccuracy", 0.1];
_Unit setSkill ["aimingshake", 0.1];

true;