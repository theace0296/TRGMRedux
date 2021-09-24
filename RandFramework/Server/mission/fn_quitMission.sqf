
//'if mission is successs... then do nothing with it
//'otherwise fail the mission'

//{removeAllActions endMissionBoard;} remoteExec ["call", 0];

//run this as a string?? use CALL command???

// This seems to be not called by anything, should it be removed? - TheAce
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};

// [InfSide%1, "failed"] remoteExec [FHQ_fnc_ttSetTaskState, 0], TRGM_VAR_iCampaignDay