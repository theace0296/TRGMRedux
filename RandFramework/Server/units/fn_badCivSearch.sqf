params ["_badCiv","_player"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


_badCiv disableAI "MOVE"; // disable movement during search

private _hintText = selectRandom [localize "STR_TRGM2_civillians_fnbadCivSearch_IsArmed1",localize "STR_TRGM2_civillians_fnbadCivSearch_IsArmed2",localize "STR_TRGM2_civillians_fnbadCivSearch_IsArmed3"];
[_hintText] call TRGM_GLOBAL_fnc_notify;

sleep 3; // wait a few seconds to allow the player to react

_badCiv enableAI "MOVE";

// make hostile - this could trigger a spot & target callout by friendly AI
[_badCiv] call TRGM_SERVER_fnc_badCivTurnHostile;

_badCiv doTarget _player;
_badCiv commandFire _player;

private _gun = primaryWeapon _badCiv;

sleep 3;
_badCiv fire _gun;
sleep 1;
_badCiv fire _gun;
sleep 1;
_badCiv fire _gun;


true;