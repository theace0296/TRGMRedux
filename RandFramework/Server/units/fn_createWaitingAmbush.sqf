params ["_triggerArea",["_nearestAmbush", 50],["_furthestAmbush",150]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};

call TRGM_SERVER_fnc_initMissionVars;

private _bAllowAmbush = true;
if (!isNil "TRGM_VAR_AOCampPos") then {
    if (_triggerArea distance TRGM_VAR_AOCampPos < 300) then {
        _bAllowAmbush = false;
    };
};

if !(_bAllowAmbush) exitWith {};

private _triggerSize = 100;
private _nearestHidingPlaces = nearestTerrainObjects [_triggerArea, ["HIDE","BUSH"], _furthestAmbush];
private _HidingPlacesTooClose = nearestTerrainObjects [_triggerArea, ["HIDE","BUSH"], _nearestAmbush];
private _nearestHidingPlaces = _nearestHidingPlaces - _HidingPlacesTooClose;

if (count _nearestHidingPlaces > 5) then {
    private _ambushGroup = createGroup TRGM_VAR_EnemySide;

    private _groupSize = selectRandom [5,6,7];
    private _iCount = 0;
    while {_iCount < _groupSize} do {
        _iCount = _iCount + 1;
        private _objMilUnit = [_ambushGroup, selectRandom[(call sRiflemanToUse),(call sRiflemanToUse),(call sRiflemanToUse),(call sRiflemanToUse),(call sRiflemanToUse),(call sRiflemanToUse),(call sATManToUse),(call sMachineGunManToUse)],getPos (selectRandom _nearestHidingPlaces),[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
        doStop _objMilUnit;
        _ambushGroup setCombatMode "BLUE";
        _ambushGroup setBehaviour "SAFE";
        _objMilUnit setUnitPos selectRandom ["MIDDLE","DOWN","DOWN","DOWN"];
        _objMilUnit setDir ([_objMilUnit, _triggerArea] call BIS_fnc_DirTo);
        _objMilUnit setVariable ["ambushUnit", true];
    };

    private _bWaiting = true;
    while {_bWaiting} do {
        //loop _ambushGroup members, if player near then set _bWaiting to false
        {
            if (floor(damage _x) > 0) then {
                _bWaiting = false;
            };
            private _nearUnits = nearestObjects [(getPos _x), ["Man"], 10];
            {
                if (_x in switchableUnits || _x in playableUnits) then {
                    _bWaiting = false;
                };
            } forEach _nearUnits;
        } forEach units _ambushGroup;

        private _nearUnits = nearestObjects [_triggerArea, ["Man"], _triggerSize];
        {
            if (_x in switchableUnits || _x in playableUnits) then {
                _bWaiting = false;
            };
        } forEach _nearUnits;
        if (_bWaiting) then {
            sleep 2;
        } else {
            sleep (30 + (random 120));
        };
    };

    {
        _x setCombatMode "RED";
        _x setBehaviour "AWARE";
        _x setUnitPos "AUTO";
        _x doMove _triggerArea;
        _ambushGroup setSpeedMode "FULL";
    } forEach units _ambushGroup;

};


true;