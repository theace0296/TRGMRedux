params ["_action"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if !(hasInterface) exitWith {};

private _existingActions = player getVariable ["TRGM_addedAceActions",[]];

if(!(_action in _existingActions)) then {
    [player, 1, ["ACE_SelfActions"], _action] call ACE_interact_menu_fnc_addActionToObject;
    player addEventHandler ["Respawn", {
        params ["_unit", "_corpse"];
        removeAllActions _corpse;
        private _existingActions = _unit getVariable ["TRGM_addedAceActions",[]];
        {[_x] call TRGM_GLOBAL_fnc_addAceActionToPlayer;} forEach _existingActions;
    }];
};

_existingActions pushBackUnique _action;
player setVariable ["TRGM_addedAceActions", _existingActions];

true;