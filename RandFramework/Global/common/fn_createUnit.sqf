// private _fnc_scriptName = "TRGM_GLOBAL_fnc_createUnit";
params [["_group", grpNull, [grpNull]], ["_type", nil, [""]], ["_position", nil, [nil, objNull, grpNull, []]], ["_markers", [], [[]]], ["_placement", 0, [0]], ["_special", "NONE", [""]], ["_disableDynamicShowHide", false, [false]]];
format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (isNull _group || _type isEqualTo "" || isNil "_position") exitWith {objNull};

if !(_markers isEqualType []) then {
    _markers = [];
};

if !(_placement isEqualType 0) then {
    _placement = 0;
};

if !(_special in ["NONE", "FORM", "CAN_COLLIDE", "CARGO"]) then {
    _special = "NONE";
};

private _side = side _group;
private _unitType = [_type, _side] call TRGM_GLOBAL_fnc_getUnitType;
private _tempUnitType = _type;

if !(_unitType isEqualTo "") then {
    private _configPath = (configFile >> "CfgVehicles" >> _type);

    private _riflemen       = _type;
    private _leaders        = _riflemen;
    private _atsoldiers     = _riflemen;
    private _aasoldiers     = _riflemen;
    private _engineers      = _riflemen;
    private _grenadiers     = _riflemen;
    private _medics         = _riflemen;
    private _autoriflemen   = _riflemen;
    private _snipers        = _riflemen;
    private _explosiveSpecs = _riflemen;
    private _pilots         = _riflemen;
    private _uavOps         = _riflemen;

    switch (_side) do {
        case WEST: {
            _riflemen       = "B_Soldier_F";
            _leaders        = "B_Soldier_TL_F";
            _atsoldiers     = "B_Soldier_LAT_F";
            _aasoldiers     = "B_Soldier_AA_F";
            _engineers      = "B_Engineer_F";
            _grenadiers     = "B_Soldier_GL_F";
            _medics         = "B_Medic_F";
            _autoriflemen   = "B_Soldier_AR_F";
            _snipers        = "B_Sniper_F";
            _explosiveSpecs = "B_Soldier_Exp_F";
            _pilots         = "B_Helipilot_F";
            _uavOps         = "B_soldier_UAV_F";
        };
        case EAST: {
            _riflemen       = "O_T_Soldier_F";
            _leaders        = "O_T_Soldier_TL_F";
            _atsoldiers     = "O_T_Soldier_LAT_F";
            _aasoldiers     = "O_T_Soldier_AA_F";
            _engineers      = "O_T_Engineer_F";
            _grenadiers     = "O_T_Soldier_GL_F";
            _medics         = "O_T_Medic_F";
            _autoriflemen   = "O_T_Soldier_AR_F";
            _snipers        = "O_T_Sniper_F";
            _explosiveSpecs = "O_T_Soldier_Exp_F";
            _pilots         = "O_T_Helipilot_F";
            _uavOps         = "O_T_Soldier_UAV_F";
        };
        case INDEPENDENT: {
            _riflemen       = "I_G_Soldier_F";
            _leaders        = "I_G_Soldier_SL_F";
            _atsoldiers     = "I_G_Soldier_LAT_F";
            _aasoldiers     = "I_G_Soldier_LAT_F";
            _engineers      = "I_G_Engineer_F";
            _grenadiers     = "I_G_Soldier_GL_F";
            _medics         = "I_G_Medic_F";
            _autoriflemen   = "I_G_Soldier_AR_F";
            _snipers        = "I_G_Soldier_M_F";
            _explosiveSpecs = "I_G_Soldier_Exp_F";
            _pilots         = "I_helipilot_F";
            _uavOps         = "I_soldier_UAV_F";
        };
    };

    switch (_unitType) do {
        case "riflemen": {
            _tempUnitType = _riflemen;
        };
        case "leaders": {
            _tempUnitType = _leaders;
        };
        case "atsoldiers": {
            _tempUnitType = _atsoldiers;
        };
        case "aasoldiers": {
            _tempUnitType = _aasoldiers;
        };
        case "engineers": {
            _tempUnitType = _engineers;
        };
        case "grenadiers": {
            _tempUnitType = _grenadiers;
        };
        case "medics": {
            _tempUnitType = _medics;
        };
        case "autoriflemen": {
            _tempUnitType = _autoriflemen;
        };
        case "snipers": {
            _tempUnitType = _snipers;
        };
        case "explosivespecs": {
            _tempUnitType = _explosiveSpecs;
        };
        case "pilots": {
            _tempUnitType = _pilots;
        };
        case "uavops": {
            _tempUnitType = _uavOps;
        };
    };
};

private _unit = _group createUnit [_tempUnitType, _position, _markers, _placement, _special];
if !(_type isEqualTo _tempUnitType) then {
    [_unit, _type] call TRGM_GLOBAL_fnc_setLoadout;
    private _tempUnit = (createGroup CIVILIAN) createUnit [_type, [0,0,0], [], 0, 'NONE'];
    private _speaker = speaker _tempUnit;
    private _face = face _tempUnit;
    private _pitch = pitch _tempUnit;
    private _nameSound = nameSound _tempUnit;
    private _name = name _tempUnit;
    deleteVehicle _tempUnit;
    [_unit, _face, _speaker, _pitch, _nameSound, _name] call BIS_fnc_setIdentity;
};

if (_unit isEqualTo leader _group && !_disableDynamicShowHide) then {
    [_unit] spawn TRGM_GLOBAL_fnc_dynamicShowHide;
};

_unit;
