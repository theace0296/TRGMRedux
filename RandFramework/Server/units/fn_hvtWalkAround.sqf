params ["_objManName","_thisInitPos","_objMan","_walkRadius"];
if (_fnc_scriptName != _fnc_scriptNameParent) then { //Reduce RPT Spam for this looping function...
    format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};

};

private _currentManPos = ([_objMan] call TRGM_GLOBAL_fnc_getRealPos);
private _MoveType = selectRandom ["Man","OpenArea"];
private _WalkToPos = ([_objMan] call TRGM_GLOBAL_fnc_getRealPos);

if (_MoveType isEqualTo "OpenArea") then {
    private _flatPos = [_thisInitPos , 10, _walkRadius, 7, 0, 0.5, 0,[[_currentManPos,10]],[_thisInitPos,_thisInitPos]] call BIS_fnc_findSafePos;
    _WalkToPos = _flatPos;
};
if (_MoveType isEqualTo "Man") then {
    private _nearMen = nearestObjects [_thisInitPos, ["man"], _walkRadius];
    if (count _nearMen > 1) then { //more than one, because we dont want to count our target guy!
        //HERE set array then remove our guy from the array
        private _tempMenArray = _nearMen;
        private _ItemsToRemove = [_objMan];
        private _tempArrayToUse = _tempMenArray - _ItemsToRemove;
        _WalkToPos = getPos (selectRandom _tempArrayToUse);
    };
};

_objMan doMove (_WalkToPos);
sleep 2;

waitUntil {sleep 1; speed _objMan isEqualTo 0};
private _nearMen = (nearestObjects [_thisInitPos, ["man"], 7]) select {side _x isEqualTo side _objMan};
private _animType = selectRandom [2,3,4];
if (count _nearMen > 1) then {
    _animType = selectRandom [1,2,3,4];
};

if (alive(_objMan) && {behaviour _objMan isEqualTo "SAFE"}) then {
    switch (_animType) do {
        case 1: { //SALUTE
            private _nearMan = _nearMen select 0;
            private _azimuth = _objMan getDir _nearMan;
            _objMan setDir _azimuth;
            private _azimuth2 = _nearMan getDir _objMan;
            _nearMan setDir _azimuth;
            _objMan playActionNow "Salute";
            _nearMan playActionNow "Salute";
            sleep selectRandom [30,60,120];
            if (!(_objMan getVariable ["StopWalkScript", false])) then {
                _objMan switchMove "";
                _nearMan switchMove "";
            };
        };
        case 2: { //Relax
            _objMan playActionNow "Relax";
            sleep selectRandom [30,60,120];
            if (!(_objMan getVariable ["StopWalkScript", false])) then {
                _objMan switchMove "";
            };
        };
        case 3: { //Binoculars
            _objMan playActionNow "Binoculars";
            sleep selectRandom [30,60,120];
            if (!(_objMan getVariable ["StopWalkScript", false])) then {
                _objMan switchMove "";
            };
        };
        case 4: { //reloadMagazine
            _objMan playActionNow "reloadMagazine";
            sleep selectRandom [30,60,120];
            if (!(_objMan getVariable ["StopWalkScript", false])) then {
                _objMan switchMove "";
            };
        };
        default { };
    };
};

true;