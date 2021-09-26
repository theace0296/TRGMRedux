// private _fnc_scriptName = "TRGM_GLOBAL_fnc_addPlayerActionPersistent";
params ["_action"];



if !(hasInterface) exitWith {};

private _existingActions = player getVariable ["TRGM_addedActions",[]];

if(!(_action in _existingActions)) then {
    player addAction _action;
    player addEventHandler ["Respawn", {
        params ["_unit", "_corpse"];
        removeAllActions _corpse;
        private _existingActions = _unit getVariable ["TRGM_addedActions",[]];
        {[_x] call TRGM_GLOBAL_fnc_addPlayerActionPersistent;} forEach _existingActions;
    }];
};

_existingActions pushBackUnique _action;
player setVariable ["TRGM_addedActions",_existingActions];

true;