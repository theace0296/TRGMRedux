// private _fnc_scriptName = "TRGM_SERVER_fnc_commsBlocked";

format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;


TRGM_VAR_WaitTimeCommsDown = (floor random 300) + 60; //any time up to 5 mins plus 60 seconds
publicVariable "TRGM_VAR_WaitTimeCommsDown";
sleep TRGM_VAR_WaitTimeCommsDown;

[HQMan,"EnemyCommsDown"] remoteExec ["sideRadio", 0, true];

true;