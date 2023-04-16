// private _fnc_scriptName = "TRGM_GLOBAL_fnc_getFactionDataBySide";
params[["_side", WEST]];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



// _factionData = [WEST] call TRGM_GLOBAL_fnc_getFactionDataBySide;
// Return format: [[faction1_className, faction1_displayName], [faction2_className, faction2_displayName], ... , [factionN_className, factionN_displayName]]

private _sideNum = [_side] call BIS_fnc_sideID;
private _configPath = configFile >> "CfgFactionClasses";
private _vehiclesConfigPath = configFile >> "CfgVehicles";
private _factions = [];
private _men = [];
private _vehicles = [];

for "_i" from 0 to (count _vehiclesConfigPath - 1) do {
    private _element = _vehiclesConfigPath select _i;
    if !(isClass _element) then { continue; };
    if (getNumber(_element >> "side") isNotEqualTo _sideNum) then { continue; };
    if (configName(_element) isKindOf 'Man') then { _men pushBackUnique (getText(_element >> "faction")) };
    if (configName(_element) isKindOf 'Car') then { _vehicles pushBackUnique (getText(_element >> "faction")) };
};

for "_i" from 0 to (count _configPath - 1) do {
    private _element = _configPath select _i;
    if !(isClass _element) then { continue; };
    if (getNumber(_element >> "side") isNotEqualTo _sideNum) then { continue; };

    private _faction = (configName _element);
    private _hasMan = _faction in _men;
    private _hasCar = _faction in _vehicles;
    if (_hasMan && _hasCar) then {
        _factions pushBack [_faction, getText(_element >> "displayName")];
    };
};

_factions;

/* Example return for side WEST:
[
    ["BLU_F","NATO"],
    ["BLU_G_F","FIA"],
    ["BLU_T_F","NATO (Pacific)"],
    ["BLU_CTRG_F","CTRG"],
    ["BLU_GEN_F","Gendarmerie"],
    ["gm_fc_DK","Denmark"],
    ["gm_fc_GE","West Germany"],
    ["gm_fc_GE_bgs","West Germany (Borderguards)"],
    ["rhs_faction_usarmy_wd","USA (Army - W)"],
    ["rhs_faction_usarmy_d","USA (Army - D)"],
    ["rhs_faction_usmc_wd","USA (USMC - W)"],
    ["rhs_faction_usmc_d","USA (USMC - D)"],
    ["rhs_faction_usaf","USA (USAF)"],
    ["rhs_faction_socom","USA (SOCOM)"],
    ["rhsgref_faction_cdf_ground_b","CDF (Ground Forces)"],
    ["rhsgref_faction_hidf","Horizon Islands Defence Force"]
]
*/

/* Example return for side EAST:
[
    ["OPF_F","CSAT"],
    ["OPF_G_F","FIA"],
    ["OPF_T_F","CSAT (Pacific)"],
    ["TEC_CSAT","CSAT (Iran, Arid)"],
    ["TEC_CSAT_Pacific","CSAT (Iran, Woodland)"],
    ["TEC_CSAT_SOF","CSAT (Iran, Special Forces)"],
    ["gm_fc_GC","East Germany"],
    ["gm_fc_GC_bgs","East Germany (Borderguards)"],
    ["gm_fc_PL","Poland"],
    ["rhs_faction_msv","Russia (MSV)"],
    ["rhs_faction_vdv","Russia (VDV)"],
    ["rhs_faction_vmf","Russia (VMF)"],
    ["rhs_faction_vv","Russia (VV)"],
    ["rhs_faction_rva","Russia (RVA)"],
    ["rhsgref_faction_chdkz","ChDKZ"],
    ["rhsgref_faction_tla","Tanoan Liberation Army"],
    ["rhssaf_faction_army_opfor","SAF (KOV)"]
]
*/

/* Example return for side Independent:
[
    ["IND_F","AAF"],
    ["IND_G_F","FIA"],
    ["IND_C_F","Syndikat"],
    ["IND_E_F","LDF"],
    ["rhsgref_faction_cdf_ground","CDF (Ground Forces)"],
    ["rhsgref_faction_un","CDF (UN)"],
    ["rhsgref_faction_nationalist","NAPA"],
    ["rhsgref_faction_chdkz_g","ChDKZ"],
    ["rhsgref_faction_tla_g","Tanoan Liberation Army"],
    ["rhssaf_faction_army","SAF (KOV)"],
    ["rhssaf_faction_un","SAF (UN Peacekeepers)"]
]
*/
