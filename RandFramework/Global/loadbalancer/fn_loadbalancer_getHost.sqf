// private _fnc_scriptName = "TRGM_GLOBAL_fnc_loadbalancer_getHost";
private _target = selectRandomWeighted (missionNamespace getVariable ["TRGM_VAR_HC_FpsWeighted", []]);
if (!isNil "_target") exitWith { _target };

_target = selectRandomWeighted (missionNamespace getVariable ["TRGM_VAR_Players_FpsWeighted", []]);
if (!isNil "_target") exitWith { _target };

2