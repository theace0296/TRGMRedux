// private _fnc_scriptName = "TRGM_GLOBAL_fnc_removeAceActionFromPlayer";
params ["_action"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if !(hasInterface) exitWith {};

private _existingActions = player getVariable ["TRGM_addedAceActions",[]];

if(_action in _existingActions) then {
    [player, 1, ["ACE_SelfActions", (_action select 0)]] call ACE_interact_menu_fnc_removeActionFromObject;
    _existingActions deleteAt (_existingActions find _action);
    player setVariable ["TRGM_addedAceActions", _existingActions];
};

true;