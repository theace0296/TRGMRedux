params ["_action", "_object"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

private _existingActions = _object getVariable ["TRGM_addedAceActions",[]];

if(!(_action in _existingActions)) then {
    [_object, 1, ["ACE_SelfActions"], _action] remoteExec ["ACE_interact_menu_fnc_addActionToObject", [0, -2] select isDedicated, true];
};

_existingActions pushBackUnique _action;
_object setVariable ["TRGM_addedAceActions", _existingActions];

true;