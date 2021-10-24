// private _fnc_scriptName = "TRGM_GLOBAL_fnc_helocastLanding";
params ["_vehicle"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (isNil "_vehicle") exitWith {};

if !(isServer) exitWith {};

waitUntil { _vehicle getVariable ["landingInProgress", false]; };

[[_vehicle], {
    params ["_thisVehicle"];
    private _actionId = _thisVehicle addAction [
        localize "STR_TRGM2_jumpIntoWater",
        {
            {
                [[_x], {
                    sleep (floor(random 5) max 1);
                    unassignVehicle (_this select 0);
                    moveOut (_this select 0);
                }] remoteExec ["spawn", _x];
            } forEach units group (_this select 1);
        },
        nil,
        -20, //priority
        false,
        true,
        "",
        "_this in (crew _target) && (speed _target) < 1",
        -1,
        false,
        ""
    ];
    waitUntil {([_thisVehicle] call TRGM_GLOBAL_fnc_isOnlyBoardCrewOnboard);};
    _thisVehicle removeAction _actionId;
}] remoteExec ["spawn", 0, true];

waitUntil { getPos _vehicle select 2 >= 0 && getPos _vehicle select 2 <= 6; };

private _numBoats = ceil((count ((crew _vehicle) - (units group driver _vehicle))) / 5);
for [{private _i = 0}, {_i < _numBoats}, {_i = _i + 1}] do {
    private _boundingBoxHelo = boundingBoxReal _vehicle;
    _boundingBoxHelo params ["_mins", "_maxes", "_diam"];
    private _maxLength = abs ((_maxes select 1) - (_mins select 1));
    private _maxHeight = abs ((_maxes select 2) - (_mins select 2));
    private _boatPos = _vehicle modelToWorld [_i * (sizeOf "B_Boat_Transport_01_F"), -(_maxLength /2 + sizeOf "B_Boat_Transport_01_F"), -(_maxHeight/2)];
    private _boat = "B_Boat_Transport_01_F" createVehicle _boatPos;
    _boat setPos _boatPos;
    sleep 1;
};

{_x disableAI "MOVE";} forEach units group driver _vehicle;

waitUntil {([_vehicle] call TRGM_GLOBAL_fnc_isOnlyBoardCrewOnboard);};

{_x enableAI "MOVE";} forEach units group driver _vehicle;
_vehicle flyInHeight 20;

true;