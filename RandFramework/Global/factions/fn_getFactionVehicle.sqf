// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getFactionVehicle";
params [["_vehClassName", "", [objNull, ""]], ["_side", WEST]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

switch (typeName _vehClassName) do {
    case ("OBJECT") : {_vehClassName = typeOf _vehClassName};
};

private _configPath = (configFile >> "CfgVehicles" >> _vehClassName);

private _returnVeh = [_vehClassName];

private _UnarmedCars = ["B_Truck_01_covered_F"];
private _ArmedCars = ["B_MRAP_01_hmg_F"];
private _APCs = ["B_T_LSV_01_unarmed_F"];
private _Tanks = ["B_MBT_01_cannon_F"];
private _Artillery = ["B_MBT_01_arty_F"];
private _AntiAir = ["B_APC_Tracked_01_AA_F"];
private _Turrets = ["B_G_HMG_02_high_F"];
private _UnarmedHelos = ["B_Heli_Transport_03_unarmed_F"];
private _ArmedHelos = ["B_Heli_Transport_01_camo_F"];
private _Planes = ["B_Plane_Fighter_01_Stealth_F"];
private _Boats = ["B_Boat_Transport_01_F"];
private _Mortars = ["B_Mortar_01_F"];
// [count _UnarmedCars, count _ArmedCars, count _APCs, count _Tanks, count _Artillery, count _AntiAir, count _Turrets, count _UnarmedHelos, count _ArmedHelos, count _Planes, count _Boats, count _Mortars];

switch (_side) do {
    case WEST: {
        if (count TRGM_VAR_WestUnarmedCars > 0) then { _UnarmedCars = TRGM_VAR_WestUnarmedCars; } else { _UnarmedCars = ["B_Truck_01_covered_F"]; };
        if (count TRGM_VAR_WestArmedCars > 0) then { _ArmedCars = TRGM_VAR_WestArmedCars; } else { _ArmedCars = ["B_MRAP_01_hmg_F"]; };
        if (count TRGM_VAR_WestAPCs > 0) then { _APCs = TRGM_VAR_WestAPCs; } else { _APCs = ["B_T_LSV_01_unarmed_F"]; };
        if (count TRGM_VAR_WestTanks > 0) then { _Tanks = TRGM_VAR_WestTanks; } else { _Tanks = ["B_MBT_01_cannon_F"]; };
        if (count TRGM_VAR_WestArtillery > 0) then { _Artillery = TRGM_VAR_WestArtillery; } else { _Artillery = ["B_MBT_01_arty_F"]; };
        if (count TRGM_VAR_WestAntiAir > 0) then { _AntiAir = TRGM_VAR_WestAntiAir; } else { _AntiAir = ["B_APC_Tracked_01_AA_F"]; };
        if (count TRGM_VAR_WestTurrets > 0) then { _Turrets = TRGM_VAR_WestTurrets; } else { _Turrets = ["B_G_HMG_02_high_F"]; };
        if (count TRGM_VAR_WestUnarmedHelos > 0) then { _UnarmedHelos = TRGM_VAR_WestUnarmedHelos; } else { _UnarmedHelos = ["B_Heli_Transport_03_unarmed_F"]; };
        if (count TRGM_VAR_WestArmedHelos > 0) then { _ArmedHelos = TRGM_VAR_WestArmedHelos; } else { _ArmedHelos = ["B_Heli_Transport_01_camo_F"]; };
        if (count TRGM_VAR_WestPlanes > 0) then { _Planes = TRGM_VAR_WestPlanes; } else { _Planes = ["B_Plane_Fighter_01_Stealth_F"]; };
        if (count TRGM_VAR_WestBoats > 0) then { _Boats = TRGM_VAR_WestBoats; } else { _Boats = ["B_Boat_Transport_01_F"]; };
        if (count TRGM_VAR_WestMortars > 0) then { _Mortars = TRGM_VAR_WestMortars; } else { _Mortars = ["B_Mortar_01_F"]; };
    };
    case EAST: {
        if (count TRGM_VAR_EastUnarmedCars > 0) then { _UnarmedCars = TRGM_VAR_EastUnarmedCars; } else { _UnarmedCars = ["O_Truck_02_covered_F"]; };
        if (count TRGM_VAR_EastArmedCars > 0) then { _ArmedCars = TRGM_VAR_EastArmedCars; } else { _ArmedCars = ["O_T_LSV_02_armed_F"]; };
        if (count TRGM_VAR_EastAPCs > 0) then { _APCs = TRGM_VAR_EastAPCs; } else { _APCs = ["O_APC_Wheeled_02_rcws_v2_F"]; };
        if (count TRGM_VAR_EastTanks > 0) then { _Tanks = TRGM_VAR_EastTanks; } else { _Tanks = ["O_MBT_02_cannon_F"]; };
        if (count TRGM_VAR_EastArtillery > 0) then { _Artillery = TRGM_VAR_EastArtillery; } else { _Artillery = ["O_MBT_02_arty_F"]; };
        if (count TRGM_VAR_EastAntiAir > 0) then { _AntiAir = TRGM_VAR_EastAntiAir; } else { _AntiAir = ["O_APC_Tracked_02_AA_F"]; };
        if (count TRGM_VAR_EastTurrets > 0) then { _Turrets = TRGM_VAR_EastTurrets; } else { _Turrets = ["O_G_HMG_02_high_F"]; };
        if (count TRGM_VAR_EastUnarmedHelos > 0) then { _UnarmedHelos = TRGM_VAR_EastUnarmedHelos; } else { _UnarmedHelos = ["O_Heli_Light_02_unarmed_F"]; };
        if (count TRGM_VAR_EastArmedHelos > 0) then { _ArmedHelos = TRGM_VAR_EastArmedHelos; } else { _ArmedHelos = ["O_Heli_Light_02_dynamicLoadout_F"]; };
        if (count TRGM_VAR_EastPlanes > 0) then { _Planes = TRGM_VAR_EastPlanes; } else { _Planes = ["O_Plane_Fighter_02_F"]; };
        if (count TRGM_VAR_EastBoats > 0) then { _Boats = TRGM_VAR_EastBoats; } else { _Boats = ["O_Boat_Armed_01_hmg_F"]; };
        if (count TRGM_VAR_EastMortars > 0) then { _Mortars = TRGM_VAR_EastMortars; } else { _Mortars = ["O_Mortar_01_F"]; };
    };
    case INDEPENDENT: {
        if (count TRGM_VAR_GuerUnarmedCars > 0) then { _UnarmedCars = TRGM_VAR_GuerUnarmedCars; } else { _UnarmedCars = ["I_C_Offroad_02_unarmed_F"]; };
        if (count TRGM_VAR_GuerArmedCars > 0) then { _ArmedCars = TRGM_VAR_GuerArmedCars; } else { _ArmedCars = ["I_C_Offroad_02_LMG_F"]; };
        if (count TRGM_VAR_GuerAPCs > 0) then { _APCs = TRGM_VAR_GuerAPCs; } else { _APCs = ["I_E_APC_tracked_03_cannon_F"]; };
        if (count TRGM_VAR_GuerTanks > 0) then { _Tanks = TRGM_VAR_GuerTanks; } else { _Tanks = ["I_LT_01_AT_F"]; };
        if (count TRGM_VAR_GuerArtillery > 0) then { _Artillery = TRGM_VAR_GuerArtillery; } else { _Artillery = ["I_Truck_02_MRL_F"]; };
        if (count TRGM_VAR_GuerAntiAir > 0) then { _AntiAir = TRGM_VAR_GuerAntiAir; } else { _AntiAir = ["I_LT_01_AA_F"]; };
        if (count TRGM_VAR_GuerTurrets > 0) then { _Turrets = TRGM_VAR_GuerTurrets; } else { _Turrets = ["I_E_HMG_02_high_F"]; };
        if (count TRGM_VAR_GuerUnarmedHelos > 0) then { _UnarmedHelos = TRGM_VAR_GuerUnarmedHelos; } else { _UnarmedHelos = ["I_E_Heli_light_03_unarmed_F"]; };
        if (count TRGM_VAR_GuerArmedHelos > 0) then { _ArmedHelos = TRGM_VAR_GuerArmedHelos; } else { _ArmedHelos = ["I_E_Heli_light_03_dynamicLoadout_F"]; };
        if (count TRGM_VAR_GuerPlanes > 0) then { _Planes = TRGM_VAR_GuerPlanes; } else { _Planes = ["I_Plane_Fighter_04_F"]; };
        if (count TRGM_VAR_GuerBoats > 0) then { _Boats = TRGM_VAR_GuerBoats; } else { _Boats = ["I_Boat_Transport_01_F"]; };
        if (count TRGM_VAR_GuerMortars > 0) then { _Mortars = TRGM_VAR_GuerMortars; } else { _Mortars = ["I_Mortar_01_F"]; };
    };
};

private _vehType = [_vehClassName] call TRGM_GLOBAL_fnc_getVehicleType;
switch (_vehType) do {
    case "UnarmedCars": { _returnVeh = _UnarmedCars; };
    case "ArmedCars": { _returnVeh = _ArmedCars; };
    case "Mortars": { _returnVeh = _Mortars; };
    case "Turrets": { _returnVeh = _Turrets; };
    case "Boats": { _returnVeh = _Boats; };
    case "Artillery": { _returnVeh = _Artillery; };
    case "AntiAir": { _returnVeh = _AntiAir; };
    case "Planes": { _returnVeh = _Planes; };
    case "APCs": { _returnVeh = _APCs; };
    case "Tanks": { _returnVeh = _Tanks; };
    case "ArmedHelos": { _returnVeh = _ArmedHelos; };
    case "UnarmedHelos": { _returnVeh = _UnarmedHelos; };
    default { _returnVeh = _UnarmedCars; };
};

private _fallbackReturnVeh = _returnVeh;

if (_vehClassName call TRGM_GLOBAL_fnc_isMedical && ({_x call TRGM_GLOBAL_fnc_isMedical} count _returnVeh) > 0) then {
    _returnVeh = _returnVeh select {_x call TRGM_GLOBAL_fnc_isMedical};
    if (isNil "_returnVeh" || { _returnVeh isEqualTo []}) exitWith {_vehClassName};
} else {
    if (_vehClassName call TRGM_GLOBAL_fnc_isFuel && ({_x call TRGM_GLOBAL_fnc_isFuel} count _returnVeh) > 0) then {
        _returnVeh = _returnVeh select {_x call TRGM_GLOBAL_fnc_isFuel};
        if (isNil "_returnVeh" || { _returnVeh isEqualTo []}) exitWith {_vehClassName};
    } else {
        if (_vehClassName call TRGM_GLOBAL_fnc_isRepair && ({_x call TRGM_GLOBAL_fnc_isRepair} count _returnVeh) > 0) then {
            _returnVeh = _returnVeh select {_x call TRGM_GLOBAL_fnc_isRepair};
            if (isNil "_returnVeh" || { _returnVeh isEqualTo []}) exitWith {_vehClassName};
        } else {
            if (_vehClassName call TRGM_GLOBAL_fnc_isAmmo && ({_x call TRGM_GLOBAL_fnc_isAmmo} count _returnVeh) > 0) then {
                _returnVeh = _returnVeh select {_x call TRGM_GLOBAL_fnc_isAmmo};
                if (isNil "_returnVeh" || { _returnVeh isEqualTo []}) exitWith {_vehClassName};
            } else {
                if (_vehClassName call TRGM_GLOBAL_fnc_isArmed && ({_x call TRGM_GLOBAL_fnc_isArmed} count _returnVeh) > 0) then {
                    _returnVeh = _returnVeh select {_x call TRGM_GLOBAL_fnc_isArmed};
                    if (isNil "_returnVeh" || { _returnVeh isEqualTo []}) exitWith {_vehClassName};
                } else {
                    if (_vehClassName call TRGM_GLOBAL_fnc_isTransport && ({_x call TRGM_GLOBAL_fnc_isTransport} count _returnVeh) > 0) then {
                        _returnVeh = _returnVeh select {_x call TRGM_GLOBAL_fnc_isTransport};
                        if (isNil "_returnVeh" || { _returnVeh isEqualTo []}) exitWith {_vehClassName};
                    };
                };
            };
        };
    };
};

_returnVeh = if (count _returnVeh > 0) then {selectRandom _returnVeh;} else {if (count _fallbackReturnVeh > 0) then {selectRandom _fallbackReturnVeh;} else {_vehClassName;};};

// Final fail safe:
if (isNil "_returnVeh" || { _returnVeh isEqualTo [] }) exitWith {_vehClassName};
_returnVeh;