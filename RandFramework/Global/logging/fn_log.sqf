params [["_message", ""], ["_systemChat", false]];

if (isNil "TRGM_VAR_bDebugMode") then {TRGM_VAR_bDebugMode = false; publicVariable "TRGM_VAR_bDebugMode";};

if (TRGM_VAR_bDebugMode) then {
    [format ["[[TRGM - DEBUG]] %1", _message]] remoteExec ["diag_log", 0];
};

if (_systemChat) then {
    [format ["[[TRGM - DEBUG]] %1", _message]] remoteExec ["diag_log", 0];
    [format ["[TRGM] %1", _message]] remoteExec ["systemChat", 0];
};