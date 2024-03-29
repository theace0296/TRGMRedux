// private _fnc_scriptName = "CUSTOM_MISSION_fnc_SetEnemyFaction";

TRGM_VAR_useCustomEnemyFactionVehicles = (["CustomEnemyFactionVehicles", 0] call BIS_fnc_getParamValue) isEqualTo 1;
publicVariable "TRGM_VAR_useCustomEnemyFactionVehicles";
TRGM_VAR_useCustomEnemyFactionLoadouts = (["CustomEnemyFactionLoadouts", 0] call BIS_fnc_getParamValue) isEqualTo 1;
publicVariable "TRGM_VAR_useCustomEnemyFactionLoadouts";

if (isServer && TRGM_VAR_useCustomEnemyFactionVehicles) then {
    TRGM_VAR_EastUnarmedCars  =  ["O_MRAP_02_F", "O_G_Offroad_01_F", "O_Truck_02_transport_F"]; publicVariable "TRGM_VAR_EastUnarmedCars";
    TRGM_VAR_EastArmedCars    =  ["O_MRAP_02_hmg_F", "O_G_Offroad_01_armed_F"]; publicVariable "TRGM_VAR_EastArmedCars";
    TRGM_VAR_EastAPCs         =  ["O_APC_Tracked_02_cannon_F"]; publicVariable "TRGM_VAR_EastAPCs";
    TRGM_VAR_EastTanks        =  ["O_MBT_02_cannon_F"]; publicVariable "TRGM_VAR_EastTanks";
    TRGM_VAR_EastArtillery    =  ["O_T_MBT_02_arty_ghex_F"]; publicVariable "TRGM_VAR_EastArtillery";
    TRGM_VAR_EastAntiAir      =  ["O_APC_Tracked_02_AA_F"]; publicVariable "TRGM_VAR_EastAntiAir";
    TRGM_VAR_EastTurrets      =  ["O_HMG_01_F", "O_HMG_01_high_F"]; publicVariable "TRGM_VAR_EastTurrets";
    TRGM_VAR_EastUnarmedHelos =  ["O_Heli_Light_02_unarmed_F", "O_Heli_Transport_04_bench_F"]; publicVariable "TRGM_VAR_EastUnarmedHelos";
    TRGM_VAR_EastArmedHelos   =  ["O_Heli_Attack_02_dynamicLoadout_F"]; publicVariable "TRGM_VAR_EastArmedHelos";
    TRGM_VAR_EastPlanes       =  ["O_Plane_CAS_02_dynamicLoadout_F", "O_Plane_Fighter_02_F"]; publicVariable "TRGM_VAR_EastPlanes";
    TRGM_VAR_EastBoats        =  ["O_T_Boat_Armed_01_hmg_F"]; publicVariable "TRGM_VAR_EastBoats";
    TRGM_VAR_EastMortars      =  ["O_Mortar_01_F"]; publicVariable "TRGM_VAR_EastMortars";

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Do not change anything under here!
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    TRGM_VAR_EastHelos = (TRGM_VAR_EastUnarmedHelos + TRGM_VAR_EastArmedHelos); publicVariable "TRGM_VAR_EastHelos";
};