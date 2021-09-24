// private _fnc_scriptName = "AIS_Core_fnc_resetOnTeamSwitch";
/*
 * Author: Psycho

 * Handle unit state after a teamswtich was performed.

 * Arguments:
    0: Player New (Object)
    1: Unit Old (Object)

 * Return value:
    -
*/

params ["_new_player", "_old_player"];


removeAllActions _old_player;
_old_player enableAI "TEAMSWITCH";
_existingActions = _new_player getVariable ["TRGM_addedActions",[]];
if (!(_existingActions isEqualTo []) && {call TRGM_GETTER_fnc_bTransportEnabled && {!(isNil "TRGM_VAR_transportHelosToGetActions")}}) then {
    [TRGM_VAR_transportHelosToGetActions] call TRGM_GLOBAL_fnc_addTransportActions;
};
AIS_Core_realSide = getNumber (configfile >> "CfgVehicles" >> (typeOf _new_player) >> "side");

if (_old_player getVariable ["ais_unconscious", false]) then {
    ais_character_changed = true;    // reset blood splatter screen
};

if (_new_player getVariable ["ais_unconscious", false]) then {
    [_new_player] call AIS_System_fnc_bloodloss;
};


true