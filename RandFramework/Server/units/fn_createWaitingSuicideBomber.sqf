//Must be set on a road!
params ["_triggerArea"];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
if (isClass(configFile >> "CfgPatches" >> "dedmen_arma_script_profiler")) then {private _scope = createProfileScope _fnc_scriptName;};


if (isNil "_triggerArea") exitWith {};

private _triggerSize = 100;
private _nearestHidingPlaces = nearestTerrainObjects [_triggerArea, ["HIDE","BUSH"], 200];
private _HidingPlacesTooClose = nearestTerrainObjects [_triggerArea, ["HIDE","BUSH"], 75];
private _nearestHidingPlaces = _nearestHidingPlaces - _HidingPlacesTooClose;

if (count _nearestHidingPlaces > 5) then {
    private _ambushGroup = createGroup TRGM_VAR_EnemySide;
    private _objMilUnit = [_ambushGroup, selectRandom sCivilian,getPos (selectRandom _nearestHidingPlaces),[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
    doStop _objMilUnit;
    _ambushGroup setCombatMode "BLUE";
    _ambushGroup setBehaviour "SAFE";
    _objMilUnit setUnitPos selectRandom ["MIDDLE","DOWN"];
    private _direction = ([_objMilUnit, _triggerArea] call BIS_fnc_DirTo);
    _objMilUnit setDir _direction;
    _objMilUnit setFormDir _direction;

    private _expl1 = "DemoCharge_Remote_Ammo" createVehicle position _objMilUnit;
    _expl1 attachTo [_objMilUnit, [-0.1, 0.1, 0.15], "Pelvis"];
    _expl1 setVectorDirAndUp [ [0.5, 0.5, 0], [-0.5, 0.5, 0] ];
    private _expl2 = "DemoCharge_Remote_Ammo" createVehicle position _objMilUnit;
    _expl2 attachTo [_objMilUnit, [0, 0.15, 0.15], "Pelvis"];
    _expl2 setVectorDirAndUp [ [1, 0, 0], [0, 1, 0] ];
    private _expl3 = "DemoCharge_Remote_Ammo" createVehicle position _objMilUnit;
    _expl3 attachTo [_objMilUnit, [0.1, 0.1, 0.15], "Pelvis"];
    _expl3 setVectorDirAndUp [ [0.5, -0.5, 0], [0.5, 0.5, 0] ];

    private _bWaiting = true;
    private _unitPos = _triggerArea;
    while {_bWaiting} do {
        if (floor(damage _objMilUnit) > 0) then {
            _bWaiting = false;
        };
        private _nearUnits = nearestObjects [([_objMilUnit] call TRGM_GLOBAL_fnc_getRealPos), ["Man"], 10];
        {
            if (_x in switchableUnits || _x in playableUnits) then {
                _bWaiting = false;
                _unitPos = ([_x] call TRGM_GLOBAL_fnc_getRealPos);
            };
        } forEach _nearUnits;
        _nearUnits = nearestObjects [_triggerArea, ["Man"], _triggerSize];
        {
            if (_x in switchableUnits || _x in playableUnits) then {
                _bWaiting = false;
                _unitPos = ([_x] call TRGM_GLOBAL_fnc_getRealPos);
            };
        } forEach _nearUnits;
        if (_bWaiting) then {
            sleep 2;
        } else {
            sleep (30 + (random 120));
        };
    };

    //after the wait, get the units pos again and move to it
    private _nearUnits = nearestObjects [([_objMilUnit] call TRGM_GLOBAL_fnc_getRealPos), ["Man"], 10];
    {
        if (_x in switchableUnits || _x in playableUnits) then {
            _unitPos = ([_x] call TRGM_GLOBAL_fnc_getRealPos);
        };
    } forEach _nearUnits;

    _nearUnits = nearestObjects [_triggerArea, ["Man"], _triggerSize];
    {
        if (_x in switchableUnits || _x in playableUnits) then {
            _unitPos = ([_x] call TRGM_GLOBAL_fnc_getRealPos);
        };
    } forEach _nearUnits;

    _objMilUnit setBehaviour "CARELESS";
    _objMilUnit doMove _unitPos;
    _ambushGroup setSpeedMode "FULL";
    _objMilUnit setUnitPos "UP";

    private _BombSet = false;
    while {!_BombSet} do {
        if ((_objMilUnit distance _unitPos) < 10 || !alive _objMilUnit) then {
            if (!alive _objMilUnit) then {sleep 2.5};
            _BombSet = true;
            _expl1 setDamage 1;
            _expl2 setDamage 1;
            _expl3 setDamage 1;
            sleep 0.1;
            deleteVehicle _objMilUnit;
        };
    };

};

true;