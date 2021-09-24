// private _fnc_scriptName = "TRGM_GLOBAL_fnc_createConvoy";
params [
    "_side",
    "_vehicles",
    "_startPos",
    "_endPos",
    ["_hvtUnitClass", ""],
    ["_hvtVehClass", ""],
    ["_guardUnitClasses", []],
    ["_wpPosArray", []],
    ["_convoySpeed", 50],
    ["_convoySeparation", 50],
    ["_pushThrough", true],
    ["_cycleMode", false],
    ["_noWaypoints", false],
    ["_disableAIMods", true],
    ["_allowCaching", false]
];

if (isNil "_side" || isNil "_vehicles" || isNil "_startPos" || isNil "_endPos") exitWith {};

private _finalGroup = [];
private _group = creategroup _side;
_group setFormation "FILE";
_group setSpeedMode "LIMITED";

private _dir = [_startPos, _endPos] call BIS_fnc_dirTo;
private _pos = _startPos;
{
    private _vehicleClass = _x;
    if (!isNil "_vehicleClass") then {
        _pos = [_pos, 0, 50, 10, 0, 0.5, 0, [], [_pos,_pos], _vehicleClass] call TRGM_GLOBAL_fnc_findSafePos;
        private _vehicle = _vehicleClass createvehicle _pos;
        _vehicle allowDamage false;
        _vehicle setDir _dir;
        [_side, _vehicle, _allowCaching] call TRGM_GLOBAL_fnc_createVehicleCrew;
        private _crew = crew _vehicle;
        _crew joinSilent _group;
        _group addVehicle _vehicle;
        if (!_allowCaching) then {
            {
                _x setVariable ["zbe_cacheDisabled", true, true];
            } forEach crew _vehicle;
        };
        if (_forEachIndex isEqualTo 0) then {
            _group selectLeader (commander _vehicle);
        };
        _group setFormation "FILE";
        _vehicle lockdriver true;
        _pos = _vehicle modelToWorld [0,-25,0];
        _finalGroup pushBack _vehicle;
    };
} forEach _vehicles;

private _hvtVehicle = _finalGroup select floor ((count _finalGroup)/2); // Middle vehicle works for an HVT, additional options later?
private _hvtUnit = driver _hvtVehicle;
if !(_hvtUnitClass isEqualTo "") then {

    if !(_hvtVehClass isEqualTo "") then { // Does HVT get a special vehicle?
        private _index = _finalGroup find _hvtVehicle;
        _pos = [_hvtVehicle] call TRGM_GLOBAL_fnc_getRealPos;
        _dir = getdir _hvtVehicle;
        private _driverClass = typeOf(driver _hvtVehicle);

        {deleteVehicle _x} forEach (crew _hvtVehicle) + [_hvtVehicle];

        private _hvtVehicleNew = _hvtVehClass createVehicle ([_startPos, 0, 50, 10, 0, 0.5, 0, [], [_startPos,_startPos], _hvtVehClass] call TRGM_GLOBAL_fnc_findSafePos);
        _hvtVehicleNew allowDamage false;
        _group addVehicle _hvtVehicleNew;
        _hvtVehicle = _hvtVehicleNew;
        _hvtVehicle setpos _pos;
        _hvtVehicle setdir _dir;
        _finalGroup set [_index,_hvtVehicle];

        private _driver = [_group, _driverClass, [_startPos select 0, _startPos select 1, 0], [], 0, "NONE", _allowCaching] call TRGM_GLOBAL_fnc_createUnit;
        if (!_allowCaching) then {
            _driver setVariable ["zbe_cacheDisabled", true, true];
        };
        _driver assignAsDriver _hvtVehicle;
        _driver moveInDriver _hvtVehicle;
    };

    _group = group driver _hvtVehicle;

    if !(_guardUnitClasses isEqualTo []) then {
        {
            if ((_hvtVehicle emptyPositions "Cargo") > 1) then {
                private _guardUnit = [_group, _x, [_startPos select 0, _startPos select 1, 0], [], 0, "NONE", _allowCaching] call TRGM_GLOBAL_fnc_createUnit;
                if (!_allowCaching) then {
                    _guardUnit setVariable ["zbe_cacheDisabled", true, true];
                };
                _guardUnit assignAsCargo _hvtVehicle;
                _guardUnit moveInCargo _hvtVehicle;
            } else {
                if ((_hvtVehicle emptyPositions "Cargo") isEqualTo 1) exitWith {};
            };
        } forEach _guardUnitClasses;
    };

    _hvtUnit = [_group, _hvtUnitClass, [_startPos select 0, _startPos select 1, 0], [], 0, "NONE", _allowCaching] call TRGM_GLOBAL_fnc_createUnit;
    if (!_allowCaching) then {
        _hvtUnit setVariable ["zbe_cacheDisabled", true, true];
    };
    _hvtUnit assignAsCargo _hvtVehicle;
    _hvtUnit moveInCargo _hvtVehicle;
};

{
    private _thisVehicle = _x;
    for [{private _i = 0}, {_i < (_thisVehicle emptyPositions "Cargo")}, {_i = _i + 1}] do {
        private _unitTypeIndex = [_i, 8] select (_i > 8);
        private _convoyUnit = [_group, [call sTeamleader, call sMachineGunMan, call sATMan, call sMedic, call sAAMan, call sEngineer, call sGrenadier, call sSniper, call sRifleman] select _unitTypeIndex, [([_thisVehicle] call TRGM_GLOBAL_fnc_getRealPos) select 0, (([_thisVehicle] call TRGM_GLOBAL_fnc_getRealPos) select 1) + 5, 0], [], 0, "NONE", _allowCaching] call TRGM_GLOBAL_fnc_createUnit;
        _convoyUnit assignAsCargo _thisVehicle;
        _convoyUnit moveInCargo _thisVehicle;
    };
} forEach (_finalGroup - [_hvtVehicle]);

private _finalwp = [0,0,0];
if (!_noWaypoints) then {
    if !(_wpPosArray isEqualTo []) then {
        {
            private _aslPos = [_x select 0, _x select 1, getTerrainHeightASL [_x select 0, _x select 1]];
            private _aglPos = ASLToAGL _aslPos;
            private _wp = _group addWaypoint [_aglPos, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointCompletionRadius 25;
            _wp setwaypointCombatMode "GREEN";
            _wp setWaypointFormation "FILE";
            _wp setWaypointBehaviour "SAFE";
        } forEach _wpPosArray;
    };

    private _aslPos = [_endPos select 0, _endPos select 1, getTerrainHeightASL [_endPos select 0, _endPos select 1]];
    private _aglPos = ASLToAGL _aslPos;
    private _finalwp = _group addWaypoint [_aglPos, 0];
    _finalwp setWaypointType (["GETOUT", "MOVE"] select (_cycleMode));
    _finalwp setWaypointCompletionRadius 25;
    _finalwp setwaypointCombatMode "GREEN";
    _finalwp setWaypointFormation "FILE";
    _finalwp setWaypointBehaviour "SAFE";

    if (_cycleMode) then {
        _aslPos = [_startPos select 0, _startPos select 1, getTerrainHeightASL [_startPos select 0, _startPos select 1]];
        _aglPos = ASLToAGL _aslPos;
        private _startwp = _group addWaypoint [_aglPos, 0];
        _startwp setWaypointType "MOVE";
        _startwp setWaypointCompletionRadius 25;
        _startwp setwaypointCombatMode "GREEN";
        _startwp setWaypointFormation "FILE";
        _startwp setWaypointBehaviour "SAFE";
        _aslPos = [_startPos select 0, _startPos select 1, getTerrainHeightASL [_startPos select 0, _startPos select 1]];
        _aglPos = ASLToAGL _aslPos;
        private _cyclewp = _group addWaypoint [_aglPos, 0];
        _cyclewp setWaypointType "CYCLE";
        _cyclewp setWaypointCompletionRadius 25;
        _cyclewp setwaypointCombatMode "GREEN";
        _cyclewp setWaypointFormation "FILE";
        _cyclewp setWaypointBehaviour "SAFE";
    };
};

{
    private _unit = _x;
    if (_disableAIMods) then {
        // Disable ASR
        _unit setVariable ["asr_ai_exclude", true, true];
        // Disable VCOM
        _unit setVariable ["NOAI", 1, true];
        // Disable LAMBS
        _unit setVariable ["lambs_danger_disableAI", true, true];
    };
    if (!_allowCaching) then {
        // Disable ZBE Caching
        _unit setVariable ["zbe_cacheDisabled", true, true];
    };
    if (vehicle _unit isEqualTo _unit) then {
        {
            if (_x emptyPositions "CARGO" > 0) exitWith {
                _unit assignAsCargo _x;
                _unit moveInCargo _x;
            };
        } forEach (_finalGroup - [_hvtVehicle]);
    };
} forEach units _group;

if (_disableAIMods) then {
    // Disable LAMBS
    _group setVariable ["lambs_danger_disableGroupAI", true, true];
    _group setVariable ["lambs_danger_dangerFormation", true, true];
};

{
    _x allowDamage true;
} forEach _finalGroup;

if (!_noWaypoints) then {
    [_group, _convoySpeed, _convoySeparation, _pushThrough] spawn TRGM_GLOBAL_fnc_convoy;
};

[_group, _finalGroup, _hvtVehicle, _hvtUnit, _finalwp];