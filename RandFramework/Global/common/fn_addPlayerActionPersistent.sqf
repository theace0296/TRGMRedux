params ["_action"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

_existingActions = player getVariable ["TRGM_addedActions",[]];

if(!(_action in _existingActions)) then {
    if (call TRGM_GLOBAL_fnc_isCbaLoaded) then {
        [_action] call CBA_fnc_addPlayerAction;
    } else {
        player addAction _action;
        player addEventHandler ["Respawn", {
            params ["_unit", "_corpse"];
            removeAllActions _corpse;
            _existingActions = _unit getVariable ["TRGM_addedActions",[]];
            _unit setVariable ["TRGM_addedActions",_existingActions - [_action]];
            [_action] call TRGM_GLOBAL_fnc_addPlayerActionPersistent;
        }];
    };
};

_existingActions pushBackUnique _action;
player setVariable ["TRGM_addedActions",_existingActions];

true;