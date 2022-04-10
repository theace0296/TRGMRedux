// private _fnc_scriptName = "TRGM_GLOBAL_fnc_carryAndJoinWounded";
params ["_civ", "_player"];



if (isNil "_civ" || isNil "_player") exitWith {};

//Add other params here so can pass in rep reward reason (so can use for other events, or for bringing back dead players)

if (alive _civ) then {
    {
      [_x, "Acts_CivilListening_2"] remoteExec ["switchMove", 0];
      detach _x;
    } forEach attachedObjects _civ;

    _civ disableAI "anim";
    _civ disableAI "MOVE";

    disableUserInput true;
    private _pos = _player ModelToWorld [0,1.8,0];
    _civ setPos _pos;
    _civ attachTo [_player, [0.5,0,0]];
    [_civ, 180] remoteExec ["setDir", 0, false];

    [_civ] spawn {_this select 0 switchMove ""; [_this select 0, "grabCarried"] remoteExec ["playActionNow", 0, false]};
    sleep 4;
    [_player] spawn {_this select 0 switchMove "AcinPknlMstpSnonWnonDnon_AcinPercMrunSnonWnonDnon"; };

    disableUserInput false;
    disableUserInput true;
    disableUserInput false;

    [_civ,_player] spawn {
        private _civP = _this select 0;
        private _playerP = _this select 1;
        private _doLoop = true;
        waitUntil {
            sleep 0.1;
            if (!(alive _playerP)) then {
                _doLoop = false;
                [_playerP, ""] remoteExec ["switchMove", 0, false];
                {
                    if ( _x isKindOf "Man") then {
                          [_x, "Acts_CivilInjuredGeneral_1"] remoteExec ["switchMove", 0];
                          detach _x;
                    };
                } forEach attachedObjects _playerP;
            };
            if (!(alive _civP)) then {
                _doLoop = false;
            };
            !_doLoop;
        };
    };

    private _iDropActionIndex = _player addAction ["drop", {
        private _playerP = _this select 0;
        {
            if ( _x isKindOf "Man") then {
                  [_x, "Acts_CivilInjuredGeneral_1"] remoteExec ["switchMove", 0];
                  detach _x;
            };
        } forEach attachedObjects _playerP;
        _playerP switchMove "";
        private _dropIndex = _playerP getVariable ["dropActionIndex",-1];
        _playerP removeAction _dropIndex;
        private _loadIndex = _playerP getVariable ["loadActionIndex",-1];
        _playerP removeAction _loadIndex;
    },nil,10];
    _player setVariable ["dropActionIndex",_iDropActionIndex];

    private _iLoadActionIndex = player addAction ["load wounded in vehicle", {
        private _playerP = _this select 0;
        private _nearestVeh = nearestObjects [_playerP, ["Car","Tank","Truck","Helicopter"], 10];
        if (count _nearestVeh > 0) then {
            {
                if ( _x isKindOf "Man") then {
                      detach _x;
                      _x enableAI "anim";
                      _x setHitPointDamage ["hitLegs", 1];
                      [_x] join (group _playerP);
                    _x enableAI "MOVE";
                    [_x, ""] remoteExec ["switchMove", 0, false];
                    sleep 1;
                    [_x, (_nearestVeh select 0)] remoteExec ["moveInCargo", 0, false];
                      [_x, (_nearestVeh select 0)] remoteExec ["assignAsCargo", 0, false];
                    [_x, (_nearestVeh select 0)] remoteExec ["moveInCargo", 0, false];
                      [_x, (_nearestVeh select 0)] remoteExec ["assignAsCargo", 0, false];
                };
            } forEach attachedObjects _playerP;
            _playerP switchMove "";
            private _dropIndex = _playerP getVariable ["dropActionIndex",-1];
            _playerP removeAction _dropIndex;
            private _loadIndex = _playerP getVariable ["loadActionIndex",-1];
            _playerP removeAction _loadIndex;
        }
        else {
            ["No vehicle near"] call TRGM_GLOBAL_fnc_notify;
        };
    },nil,9];
    _player setVariable ["loadActionIndex",_iLoadActionIndex];
}
else {
    ["It's too late. this guy is dead"] call TRGM_GLOBAL_fnc_notify;
};

true;