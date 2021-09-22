params ["_vehicles"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

/********************* Add Player Actions ****************/
private _useAceInteractionForTransport = [false, true] select ((["EnableAceActions", 0] call BIS_fnc_getParamValue) isEqualTo 1);
if (_useAceInteractionForTransport && call TRGM_GLOBAL_fnc_isAceLoaded) then {
    //Ace action

    private _generateChildActions = {
        params ["_target", "_player", "_actionParams"];
        _actionParams params ["_vehicles"];

        private _actionAdapterPickupAce = {
            params ["_target", "_player", "_actionParams"];
            _actionParams params ["_selectedVehicle"];
            [_selectedVehicle, true] spawn TRGM_GLOBAL_fnc_selectLz;
        };

        private _childCondition = {
            params ["_target", "_player", "_actionParams"];
            _actionParams params ["_selectedVehicle"];
            alive _selectedVehicle && !(_player in (crew _selectedVehicle));
        };


        // Add children to this action
        private _actions = [];
        {
            private _vehicle = _x;
            private _name = [_vehicle] call TRGM_GLOBAL_fnc_getTransportName;
            private _action = [format ["vehicle:%1", _vehicle], _name, "", _actionAdapterPickupAce, _childCondition, {}, _vehicle] call ACE_interact_menu_fnc_createAction;
            _actions pushBack [_action, [], _vehicle]; // New action, it's children, and the action's target
        } forEach _vehicles;

        _actions;
    };

    private _selfActionCondition = {
        params ["_target", "_player", "_actionParams"];
        if (call TRGM_GETTER_fnc_bTransportLeaderOnly) exitWith {
            [_player] call TRGM_GLOBAL_fnc_isLeaderOrAdmin;
        };
        true;
    };

    private _selfAction = [
        'CallTransportChopper',
        localize 'STR_TRGM2_transport_fnaddTransportActionsPlayer_CallTransport',
        '',
        {},
        _selfActionCondition,
        _generateChildActions,
        [_vehicles]
    ] call ACE_interact_menu_fnc_createAction;

    [_selfAction] remoteExec ["TRGM_GLOBAL_fnc_addAceActionToPlayer", [0, -2] select isDedicated, true];

} else {
    // Fallback vanilla action

    private _actionAdapterPickup = {
        params ["_target", "_caller", "_id", "_arguments"];
        _arguments params ["_targetVehicle"];
        [_targetVehicle, true] spawn TRGM_GLOBAL_fnc_selectLz;
    };

    private _playerActions = [];
    {
        // since you can not access arguments within the condition, use a global unique identifier for the argument variable
        // create a unique variableName with prefix
        private _uniqueVarName = [_x,"TRGM_transport_vehicle_"] call BIS_fnc_objectVar;
        publicVariable _uniqueVarName;
        private _condition = format ["alive %1 && !(_this in (crew %1))", _uniqueVarName];
        if (call TRGM_GETTER_fnc_bTransportLeaderOnly) then {
            _condition = format ["[_this] call TRGM_GLOBAL_fnc_isLeaderOrAdmin && alive %1 && !(_this in (crew %1))", _uniqueVarName];
        };

        private _name = [_x] call TRGM_GLOBAL_fnc_getTransportName;
        private _actionName = format [localize "STR_TRGM2_TRGMInitPlayerLocal_CallHeliTransport",_name];

        _playerActions pushBack [
            _actionName,
            _actionAdapterPickup,
            [_x],
            -20, //priority
            false,
            true,
            "",
            _condition,
            -1,
            false,
            ""
        ];

    } forEach _vehicles;

    {
        if (isServer) then {
            [_x] remoteExec ["TRGM_GLOBAL_fnc_addPlayerActionPersistent",0,true];
        } else {
            if (hasInterface) then {
                [_x] call TRGM_GLOBAL_fnc_addPlayerActionPersistent;
            }
        };
    } foreach _playerActions;
};

true;