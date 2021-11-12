// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getVehicleArraysFromVehData";
params["_vehData"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

private _unarmedcars = [];
private _armedcars = [];
private _trucks = [];
private _apcs = [];
private _tanks = [];
private _artillery = [];
private _antiair = [];
private _turrets = [];
private _unarmedhelicopters = [];
private _armedhelicopters = [];
private _planes = [];
private _boats = [];
private _mortars = [];
{
    _x params ["_vehClassName", "_vehType"];
    switch (_vehType) do {
        case "UnarmedCars": { _unarmedcars pushBackUnique _vehClassName; };
        case "ArmedCars": { _armedcars pushBackUnique _vehClassName; };
        case "Mortars": { _mortars pushBackUnique _vehClassName; };
        case "Turrets": { _turrets pushBackUnique _vehClassName; };
        case "Boats": { _boats pushBackUnique _vehClassName; };
        case "Artillery": { _artillery pushBackUnique _vehClassName; };
        case "AntiAir": { _antiair pushBackUnique _vehClassName; };
        case "Planes": { _planes pushBackUnique _vehClassName; };
        case "APCs": { _apcs pushBackUnique _vehClassName; };
        case "Tanks": { _tanks pushBackUnique _vehClassName; };
        case "ArmedHelos": { _armedhelicopters pushBackUnique _vehClassName; };
        case "UnarmedHelos": { _unarmedhelicopters pushBackUnique _vehClassName; };
        default { _unarmedcars pushBackUnique _vehClassName; };
    };
} forEach _vehData;

private _combinedWheeled = _unarmedcars + _armedcars + _trucks;
if (_unarmedcars isEqualTo [] && count _combinedWheeled > 0) then {
    _unarmedcars = _combinedWheeled;
};
if (_armedcars isEqualTo [] && count _combinedWheeled > 0) then {
    _armedcars = _combinedWheeled;
};
if (_trucks isEqualTo [] && count _combinedWheeled > 0) then {
    _trucks = _combinedWheeled;
};

private _combinedArmored = _apcs + _tanks;
if (_apcs isEqualTo [] && count _combinedArmored > 0) then {
    _apcs = _combinedArmored;
};
if (_tanks isEqualTo [] && count _combinedArmored > 0) then {
    _tanks = _combinedArmored;
};

private _combinedAntiAir = _antiair + _turrets;
if (_antiair isEqualTo [] && count _combinedAntiAir > 0) then {
    _antiair = _combinedAntiAir;
};
if (_turrets isEqualTo [] && count _combinedAntiAir > 0) then {
    _turrets = _combinedAntiAir;
};

private _combinedHelicopters = _unarmedhelicopters + _armedhelicopters;
if (_unarmedhelicopters isEqualTo [] && count _combinedHelicopters > 0) then {
    _unarmedhelicopters = _combinedHelicopters;
};
if (_armedhelicopters isEqualTo [] && count _combinedHelicopters > 0) then {
    _armedhelicopters = _combinedHelicopters;
};
if (_planes isEqualTo [] && count _armedhelicopters > 0) then {
    _planes = _armedhelicopters;
};

if (_boats isEqualTo []) then {
    private _arbitraryVeh = _vehData select 0;
    switch ((configFile >> "CfgVehicles" >> (_arbitraryVeh select 0) >> "side")) do {
        case 0: {
            _boats = ["O_G_Boat_Transport_01_F"];
        };
        case 1: {
            _boats = ["B_G_Boat_Transport_01_F"];
        };
        case 2: {
            _boats = ["I_G_Boat_Transport_01_F"];
        };
        default {
            _boats = ["B_G_Boat_Transport_01_F"];
        };
    };
};

if (_mortars isEqualTo [] && _artillery isEqualTo []) then {
    private _arbitraryVeh = _vehData select 0;
    switch ((configFile >> "CfgVehicles" >> (_arbitraryVeh select 0) >> "side")) do {
        case 0: {
            _mortars = ["O_G_Mortar_01_F"];
        };
        case 1: {
            _mortars = ["B_G_Mortar_01_F"];
        };
        case 2: {
            _mortars = ["I_G_Mortar_01_F"];
        };
        default {
            _mortars = ["B_G_Mortar_01_F"];
        };
    };
};

private _combinedArty = _artillery + _mortars;
if (_artillery isEqualTo [] && count _combinedArty > 0) then {
    _artillery = _combinedArty;
};
if (_mortars isEqualTo [] && count _combinedArty > 0) then {
    _mortars = _combinedArty;
};

private _vehArray = [_unarmedcars, _armedcars, _trucks, _apcs, _tanks, _artillery, _antiair, _turrets, _unarmedhelicopters, _armedhelicopters, _planes, _boats, _mortars];
_vehArray;
