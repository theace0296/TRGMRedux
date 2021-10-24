// private _fnc_scriptName = "TRGM_GLOBAL_fnc_addTransportActionsVehicle";
params ["_vehicle"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (!isServer) exitWith {};


/********************* Add Vehicle Actions ****************/
private _useAceInteractionForTransport = [false, true] select ((["EnableAceActions", 0] call BIS_fnc_getParamValue) isEqualTo 1);
if (_useAceInteractionForTransport && call TRGM_GLOBAL_fnc_isAceLoaded) then {
    //Ace action

    private _generateChildActions = {
        params ["_target", "_player"];

        private _actionAdapterPickupAce = {
            params ["_target", "_player"];
            [_target] spawn TRGM_GLOBAL_fnc_selectLz;
        };

        // Add children to this action
        private _actions = [
            [
                format ["vehicle:%1", _target],
                localize "STR_TRGM2_transport_fnaddTransportAction_SelectDest",
                "",
                _actionAdapterPickupAce,
                {
                    params ["_target", "_player"];
                    if !(_player in (crew _target) && alive _target) exitWith { false; };
                    if (call TRGM_GETTER_fnc_bTransportLeaderOnly) exitWith {
                        [_player] call TRGM_GLOBAL_fnc_isLeaderOrAdmin && !([_target] call TRGM_GLOBAL_fnc_helicopterIsFlying);
                    };
                    !([_target] call TRGM_GLOBAL_fnc_helicopterIsFlying);
                }
            ],
            [
                format ["vehicle:%1", _target],
                localize "STR_TRGM2_transport_fnaddTransportAction_DivertLZ",
                "",
                _actionAdapterPickupAce,
                {
                    params ["_target", "_player"];
                    if !(_player in (crew _target) && alive _target) exitWith { false; };
                    if (call TRGM_GETTER_fnc_bTransportLeaderOnly) exitWith {
                        [_player] call TRGM_GLOBAL_fnc_isLeaderOrAdmin && ([_target] call TRGM_GLOBAL_fnc_helicopterIsFlying);
                    };
                    ([_target] call TRGM_GLOBAL_fnc_helicopterIsFlying);
                }
            ]
        ] apply { _x call ACE_interact_menu_fnc_createAction};

        _actions apply { [_x, [], _target] };
    };

    private _vehicleActionCondition = {
        params ["_target", "_player", "_actionParams"];
        if !(_player in (crew _target)) exitWith { false; };
        if (call TRGM_GETTER_fnc_bTransportLeaderOnly) exitWith {
            [_player] call TRGM_GLOBAL_fnc_isLeaderOrAdmin;
        };
        true;
    };

    private _name = [_vehicle] call TRGM_GLOBAL_fnc_getTransportName;
    private _vehicleAction = [
        'SelectDestChopper',
        _name,
        '',
        {},
        _vehicleActionCondition,
        _generateChildActions
    ] call ACE_interact_menu_fnc_createAction;

    [_vehicleAction, _vehicle] call TRGM_GLOBAL_fnc_addAceActionToObject;

} else {
    private _actionAdapter = {
        params ["_target", "_caller", "_id", "_arguments"];
        [_target] spawn TRGM_GLOBAL_fnc_selectLz;
    };

    // add in vehicle Actions
    private _actions = [

        // Select Destination when in chopper on ground
        [
            localize "STR_TRGM2_transport_fnaddTransportAction_SelectDest",
            _actionAdapter,
            nil,
            -20, //priority
            false,
            true,
            "",
            ["_this in (crew _target) && !([_target] call TRGM_GLOBAL_fnc_helicopterIsFlying)", "[_this] call TRGM_GLOBAL_fnc_isLeaderOrAdmin && _this in (crew _target) && !([_target] call TRGM_GLOBAL_fnc_helicopterIsFlying)"] select (call TRGM_GETTER_fnc_bTransportLeaderOnly),
            -1,
            false,
            ""
        ],

        // Select Destination when in chopper and flying
        [
            localize "STR_TRGM2_transport_fnaddTransportAction_DivertLZ",
            _actionAdapter,
            nil,
            -20, //priority
            false,
            true,
            "",
            ["_this in (crew _target) && ([_target] call TRGM_GLOBAL_fnc_helicopterIsFlying)", "[_this] call TRGM_GLOBAL_fnc_isLeaderOrAdmin && _this in (crew _target) && ([_target] call TRGM_GLOBAL_fnc_helicopterIsFlying)"] select (call TRGM_GETTER_fnc_bTransportLeaderOnly),
            -1,
            false,
            ""
        ]
    ];

    private _existingActions = _vehicle getVariable ["TRGM_addedActions", []];
    if (_existingActions isEqualTo []) then {
        // add actions on vehicle
        {
            [_vehicle, _x] remoteExec ["addAction",0,true];
            // TODO: ACE alternative
        } foreach _actions;
        _vehicle setVariable ["TRGM_addedActions", _actions, true];
    };
};

true;