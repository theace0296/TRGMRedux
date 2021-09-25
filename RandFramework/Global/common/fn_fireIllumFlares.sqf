// private _fnc_scriptName = "TRGM_GLOBAL_fnc_fireIllumFlares";
params ["_player"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (isNil "_player") exitWith {};

titleText[localize "STR_TRGM2_select_flare_location", "PLAIN"];
openMap true;
onMapSingleClick "FlarePos = _pos; openMap false; onMapSingleClick '';true;";
sleep 1;
waitUntil {sleep 2; !visibleMap};

private _countSec = 300; //300 = 5 mins

private _pos = FlarePos;
while {_countSec > 0} do {
    private _xPos = (_pos select 0)-200;
    private _yPos = (_pos select 1)-200;

    private _randomPos = [_xPos+(random 400),_yPos+(random 400),0];
    [_randomPos] spawn TRGM_GLOBAL_fnc_fireAOFlares;
    private _delaySec = selectRandom[2,3,4,5];
    _countSec = _countSec - _delaySec;
    sleep _delaySec;

    _randomPos = [_xPos+(random 400),_yPos+(random 400),0];
    [_randomPos] spawn TRGM_GLOBAL_fnc_fireAOFlares;
    _delaySec = selectRandom[2,3,4,5];
    _countSec = _countSec - _delaySec;
    sleep _delaySec;

    _randomPos = [_xPos+(random 400),_yPos+(random 400),0];
    [_randomPos] spawn TRGM_GLOBAL_fnc_fireAOFlares;
    _delaySec = selectRandom[20,25];
    _countSec = _countSec - _delaySec;
    sleep _delaySec;
};

true;