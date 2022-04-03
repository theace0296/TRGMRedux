// private _fnc_scriptName = "TRGM_GLOBAL_fnc_loadbalancer_setFps";
params [["_player", objNull, [objNull]], ["_fps",0,[0]]];
if (isNull _player) exitWith {};
_player setVariable ["TRGM_VAR_ClientFps", _fps];