// private _fnc_scriptName = "TRGM_GLOBAL_fnc_createVehicleCrew";
params [["_sideOrGroup", WEST, [WEST, grpNull]], ["_vehicle", objNull, [objNull]], ["_disableDynamicShowHide", false, [false]]];

if (isNull _vehicle) exitWith {[]};

private _vehicleType = typeof _vehicle;
private _vehicleConfig = configFile >> "CfgVehicles" >> _vehicleType;

private ["_group", "_side"];

if (_sideOrGroup isEqualType WEST) then {
    _side = _sideOrGroup;
    _group = (createGroup [_side, true]);
} else {
    _side = side _sideOrGroup;
    _group = _sideOrGroup;
};

private _crew = [];
private _crewType = getText (_vehicleConfig >> "crew");
if (_crewType isEqualTo "") then {
    switch (_side) do {
        case WEST: {
            _crewType = [(call fRifleman), (call fPilot)] select (_vehicle isKindOf "Air");
        };
        case EAST: {
            _crewType = [(call sRifleman), (call sEnemyHeliPilot)] select (_vehicle isKindOf "Air");
        };
        case INDEPENDENT: {
            _crewType = [(call sRiflemanMilitia), (call sEnemyHeliPilotMilitia)] select (_vehicle isKindOf "Air");
        };
        default {
            _crewType = sCivilian;
            if (typeName _crewType isEqualTo "ARRAY") then {
                _crewType = selectRandom sCivilian;
            };
        };
    };
};

private _hasDriver = (getNumber (_vehicleConfig >> "hasDriver")) isEqualTo 1;
if (_hasDriver && {isNull driver _vehicle}) then {
    private _driver = [_group, _crewType, getPos _vehicle, [], 0, "NONE", _disableDynamicShowHide] call TRGM_GLOBAL_fnc_createUnit;
    _crew = _crew + [_driver];
    _driver assignAsDriver _vehicle;
    _driver moveInDriver _vehicle;
};

private _hasCommander = (getNumber (_vehicleConfig >> "hasCommander")) isEqualTo 1;
if (_hasCommander && {isNull driver _vehicle}) then {
    private _commander = [_group, _crewType, getPos _vehicle, [], 0, "NONE", _disableDynamicShowHide] call TRGM_GLOBAL_fnc_createUnit;
    if (!(isNil "_commander") && {!(isNull _commander)}) then {
        _crew = _crew + [_commander];
        _commander assignAsCommander _vehicle;
        _commander moveInCommander _vehicle;
    };
};

private _hasGunner = (getNumber (_vehicleConfig >> "hasGunner")) isEqualTo 1;
if (_hasGunner && {isNull gunner _vehicle}) then {
    private _gunner = [_group, _crewType, getPos _vehicle, [], 0, "NONE", _disableDynamicShowHide] call TRGM_GLOBAL_fnc_createUnit;
    if (!(isNil "_gunner") && {!(isNull _gunner)}) then {
        _crew = _crew + [_gunner];
        _gunner assignAsGunner _vehicle;
        _gunner moveInGunner _vehicle;
    };
};

private _turrets = [_vehicleType, false] call BIS_fnc_allTurrets;
{
    if (isNull (_vehicle turretUnit _x)) then {
        private _turretUnit = [_group, _crewType, getPos _vehicle, [], 0, "NONE", _disableDynamicShowHide] call TRGM_GLOBAL_fnc_createUnit;
        try {
            if (!(isNil "_turretUnit") && {!(isNull _turretUnit)}) then {
                _crew = _crew + [_turretUnit];
                _turretUnit assignAsTurret [_vehicle, _x];
                _turretUnit moveInTurret [_vehicle, _x];
            };
        } catch {
            if (isNull (_vehicle turretUnit _x)) then {
                deleteVehicle _turretUnit;
            } else {
                _vehicle deleteVehicleCrew _turretUnit;
            };
        };
    };
} forEach _turrets;

[_vehicle, "LIEUTENANT"] call BIS_fnc_setRank;

if (_sideOrGroup isEqualType WEST && {!((driver _vehicle) isEqualTo (leader _group))}) then {
    [_group, driver _vehicle] remoteExec ["selectLeader", groupOwner _group];
};

[_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;

_crew;