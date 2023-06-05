if (!isServer) exitWith {};
private ["_grp", "_rdCount", "_n", "_tempUnit", "_tempVeh"];
_mkr= (_this select 0);
_pos = (_this select 1);

// Hint format["TESTTEST2: %1", _pos];
// sleep 3;

waitUntil {
    sleep 2;
    TRGM_VAR_bAndSoItBegins && TRGM_VAR_CustomObjectsSet
};

if (!TRGM_VAR_MissionLoaded) exitWith {};

// hint "test";

_mainObjPos = TRGM_VAR_ObjectivePositions select 0;
_mrkHQPos = getMarkerPos "mrkHQ";
if (_pos distance _mainObjPos < 1500) exitWith {};
if (_pos distance _mrkHQPos < 1500) exitWith {};

// get trigger status
_trigID=format["trig%1", _mkr];
_isActive=server getVariable _trigID;

// get stored town variables
_popVar=format["population%1", _mkr];
_information=server getVariable _popVar;
_civilians=(_information select 0);
_vehicles=(_information select 1);
_parked=(_information select 2);
_roadPosArray=(_information select 3);

if (debugCOS) then {
    COSGlobalSideChat=[_civilians, _vehicles, _parked, _mkr];
    publicvariable "COSGlobalSideChat";
        player groupChat (format ["Town:%4 .Civilians:%1 .Vehicles:%2 .Parked:%3", _civilians, _vehicles, _parked, _mkr])// for singleplayer
};

_showRoads=false;
if (_showRoads) then {
    {
        _txt=format["roadMkr%1", _x];
        _debugMkr=createMarker [_txt, getPos _x];
        _debugMkr setMarkerShape "ICON";
        _debugMkr setMarkerType "hd_dot";
    }forEach _roadPosArray;
};

_glbGrps=server getvariable "cosGrpCount";
_townGrp=createGroup DefaultSide;
_localGrps=1;

waitUntil {
    !populating_COS
};
populating_COS=true;
_glbGrps=server getvariable "cosGrpCount";

// spawn CIVILIANS NOW
_civilianArray=[];
_vehicleArray=[];
_PatrolVehArray=[];
_ParkedArray=[];

_roadPosArray=_roadPosArray call BIS_fnc_arrayShuffle;
_UnitList=COScivPool call BIS_fnc_arrayShuffle;
_vehList=COSmotPool call BIS_fnc_arrayShuffle;
_countVehPool=count _vehList;
_countPool=count _UnitList;
_v=0;
_n=0;
_rdCount=0;

// spawn PEDESTRIANS
for "_i" from 1 to _civilians do {
    if (!(server getVariable _trigID)) exitWith {
        _isActive=false;
    };

    if (_i >= _countPool) then {
        if (_n >= _countPool) then {
            _n=0;
        };
        _tempUnit=_UnitList select _n;
        _n=_n+1;
    };
    if (_i < _countPool) then {
        _tempUnit=_UnitList select _i;
    };

    _tempPos=_roadPosArray select _rdCount;
    _rdCount=_rdCount+1;

    if (COSmaxGrps < (_glbGrps+_localGrps+1)) then {
        _grp=_townGrp;
    } else {
        _grp=createGroup DefaultSide;
        _localGrps=_localGrps+1;
    };

    _unit = [_grp, _tempUnit, _tempPos, [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;

    if !(isNil "_unit" || {isNull _unit}) then {
        _civilianArray set [count _civilianArray, _grp];
        null =[_unit] execVM "RandFramework\cos\addScript_Unit.sqf";
        if (debugCOS) then {
            _txt=format["INF%1, MKR%2", _i, _mkr];
            _debugMkr=createMarker [_txt, getPos _unit];
            _debugMkr setMarkerShape "ICON";
            _debugMkr setMarkerType "hd_dot";
            _debugMkr setMarkerText "Civ Spawn";
        };
    };

};

// spawn vehicles
for "_i" from 1 to _vehicles do {
    if (!(server getVariable _trigID)) exitWith {
        _isActive=false;
    };

    if (_i >= _countVehPool) then {
        if (_v >= _countVehPool) then {
            _v=0;
        };
        _tempVeh=_vehList select _v;
        _v=_v+1;
    };
    if (_i < _countVehPool) then {
        _tempVeh=_vehList select _i;
    };

    if (_i >= _countPool) then {
        if (_n >= _countPool) then {
            _n=0;
        };
        _tempUnit=_UnitList select _n;
        _n=_n+1;
    };
    if (_i < _countPool) then {
        _tempUnit=_UnitList select _i;
    };

    _tempPos=_roadPosArray select _rdCount;
    _rdCount=_rdCount+1;
    _roadConnectedTo = roadsConnectedTo _tempPos;
    _connectedRoad = _roadConnectedTo select 0;
    _direction = [_tempPos, _connectedRoad] call BIS_fnc_dirTo;

    if (COSmaxGrps < (_glbGrps+_localGrps+1)) then {
        _grp=_townGrp;
    } else {
        _grp=createGroup DefaultSide;
        _localGrps=_localGrps+1;
    };

    _veh = createVehicle [_tempVeh, _tempPos, [], 0, "NONE"];
    _unit = [_grp, _tempUnit, getpos _veh, [], 0, "CAN_COLLIDE"] call TRGM_GLOBAL_fnc_createUnit;
    if !(isNil "_unit" || {isNull _unit}) then {
        _veh setDir _direction;

        _unit assignAsDriver _veh;
        _unit moveInDriver _veh;

        _vehPack=[_veh, _unit, _grp];
        _PatrolVehArray set [count _PatrolVehArray, _grp];
        _vehicleArray set [count _vehicleArray, _vehPack];

        null =[_veh] execVM "RandFramework\cos\addScript_Vehicle.sqf";
        null =[_unit] execVM "RandFramework\cos\addScript_Unit.sqf";

        if (debugCOS) then {
            _txt=format["veh%1, mkr%2", _i, _mkr];
            _debugMkr=createMarker [_txt, getPos _unit];
            _debugMkr setMarkerShape "ICON";
            _debugMkr setMarkerType "hd_dot";
            _debugMkr setMarkerText "VEH Spawn";
        };
    };
};

// spawn PARKED vehicles
for "_i" from 1 to _parked do {
    if (!(server getVariable _trigID)) exitWith {
        _isActive=false;
    };

    if (_i >= _countVehPool) then {
        if (_v >= _countVehPool) then {
            _v=0;
        };
        _tempVeh=_vehList select _v;
        _v=_v+1;
    };
    if (_i < _countVehPool) then {
        _tempVeh=_vehList select _i;
    };

    _tempPos=_roadPosArray select _rdCount;
    _rdCount=_rdCount+1;
    _roadConnectedTo = roadsConnectedTo _tempPos;
    _connectedRoad = _roadConnectedTo select 0;
    _direction = [_tempPos, _connectedRoad] call BIS_fnc_dirTo;

    _veh = createVehicle [_tempVeh, _tempPos, [], 0, "NONE"];
    _veh setDir _direction;
    _veh setPos [(getPos _veh select 0)-6, getPos _veh select 1, getPos _veh select 2];

    _ParkedArray set [count _ParkedArray, _veh];

    null =[_veh] execVM "RandFramework\cos\addScript_Vehicle.sqf";

    if (debugCOS) then {
        _txt=format["Park%1, mkr%2", _i, _mkr];
        _debugMkr=createMarker [_txt, getPos _veh];
        _debugMkr setMarkerShape "ICON";
        _debugMkr setMarkerType "hd_dot";
        _debugMkr setMarkerText "Park Spawn";
    };
};

// apply Patrol script to all units
null =[_civilianArray, _PatrolVehArray, _roadPosArray] execVM "RandFramework\cos\CosPatrol.sqf";

if (debugCOS) then {
    player sidechat (format ["Roads used:%1. Roads Stored %2", _rdCount, count _roadPosArray])
};

// count groups
_glbGrps=server getvariable "cosGrpCount";
_glbGrps=_glbGrps+_localGrps;
server setvariable ["cosGrpCount", _glbGrps];
populating_COS=false;

// Show town label if town still active
if (showTownLabel and (server getVariable _trigID)) then {
    COSTownLabel=[(_civilians+_vehicles), _mkr];
    PUBLICVARIABLE "COSTownLabel";
    _population=format ["Population: %1", _civilians+_vehicles];
            [markerText _mkr, _population] spawn BIS_fnc_infoText;// for USE in SINGLEPLAYER
};

// Check every second until trigger is deactivated
while { _isActive } do {
    _isActive=server getVariable _trigID;
    if (!_isActive) exitWith {};
    sleep 1;
};

// if another town is populating wait until it has finished before deleting population
waitUntil {
    !populating_COS
};

// Delete all pedestrians
_counter=0;
{
    _grp=_x;
    _counter=_counter+1;
    if (debugCOS) then {
        deletemarker (format["INF%1, MKR%2", _counter, _mkr]);
    };
    {
        deleteVehicle _x
    } forEach units _grp;
    deleteGroup _grp;
}forEach _civilianArray;

// Delete all vehicles and crew
_counter=0;
{
    _veh=_x select 0;
    _unit=_x select 1;
    _grp=_x select 2;
    _counter=_counter+1;
    if (debugCOS) then {
        deletemarker (format["veh%1, mkr%2", _counter, _mkr]);
    };

    // CHECK vehicle IS not TAKEN BY player
    if ({
        isPlayer _veh
    } count (crew _veh) == 0)
    then {
        {
            deleteVehicle _x
        } forEach (crew _veh);
        deleteVehicle _veh;
    };
    deleteVehicle _unit;
    deleteGroup _grp;
}forEach _vehicleArray;

// Delete all parked vehicles
_counter=0;
{
    _counter=_counter+1;
    if (debugCOS) then {
        deletemarker (format["Park%1, mkr%2", _counter, _mkr]);
    };

      // CHECK vehicle IS not TAKEN BY player
    if ({
        isPlayer _x
    } count (crew _x) == 0)
    then {
        deleteVehicle _x;
    };
}forEach _ParkedArray;

deleteGroup _townGrp;

// Update global groups
_glbGrps=server getvariable "cosGrpCount";
_glbGrps=_glbGrps-_localGrps;
server setvariable ["cosGrpCount", _glbGrps];