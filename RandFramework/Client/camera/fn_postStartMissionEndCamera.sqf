format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (hasInterface) then {
    titleCut ["", "BLACK in", 5];
    private _camera = player getVariable "TRGM_postStartMissionCam";
    if !(isNil "_camera") then {
        _camera cameraEffect ["Terminate","back"];
        player setVariable ["TRGM_postStartMissionCam", nil, true];
    };
    sleep 10;
    player allowdamage true;
    player doFollow player;
};