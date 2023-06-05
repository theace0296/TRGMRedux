// private _fnc_scriptName = "CUSTOM_MISSION_fnc_LoadTest";
if (TRGM_VAR_bLoadTest) then {
    TRGM_VAR_ForceMissionSetup = true;
    TRGM_VAR_UseCustomMission = false;
    TRGM_VAR_MainMissionTitle = "LOAD TEST";
};

if (isServer && {TRGM_VAR_bLoadTest}) then {
    TRGM_VAR_iMissionIsCampaign = false;
    TRGM_VAR_IsFullMap = true;
    TRGM_VAR_iMissionParamObjectives = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16] apply { [_x, false, false, false]; };

    TRGM_VAR_iStartLocation = 0;
    TRGM_VAR_AOCampOnlyAmmoBox = true;
    TRGM_VAR_AOCampLocation = [1674.52,1846.55,0];

    TRGM_VAR_iMissionParamLocations = [];
    TRGM_VAR_iMissionParamSubLocations = [];

    TRGM_VAR_ForceWarZoneLoc = nil;

    TRGM_VAR_UseEditorWeather = false;
    TRGM_VAR_DateTimeWeather = [2055,12,16,09,30,0,[0,0,0]];

    TRGM_VAR_iAllowNVG = 1;
    TRGM_VAR_iMissionParamRepOption =  0;
    TRGM_VAR_iUseRevive = 1;

    TRGM_VAR_HideAoMarker = false;

    TRGM_VAR_CustomAdvancedSettings = [1,"THE LOAD TESTERS",0,999,0,5,"OPF_F","IND_G_F","BLU_F",2,0,0,0,0,0,0,0,0,0,0,1,1,1];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Do not change anything under here!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    publicVariable "TRGM_VAR_ForceMissionSetup";
    publicVariable "TRGM_VAR_UseCustomMission";
    publicVariable "TRGM_VAR_MainMissionTitle";
    publicVariable "TRGM_VAR_iMissionIsCampaign";
    publicVariable "TRGM_VAR_IsFullMap";
    publicVariable "TRGM_VAR_iMissionParamObjectives";
    publicVariable "TRGM_VAR_iStartLocation";
    publicVariable "TRGM_VAR_AOCampOnlyAmmoBox";
    publicVariable "TRGM_VAR_AOCampLocation";
    publicVariable "TRGM_VAR_iMissionParamLocations";
    publicVariable "TRGM_VAR_iMissionParamSubLocations";
    publicVariable "TRGM_VAR_Mission1Title";
    publicVariable "TRGM_VAR_Mission1Desc";
    publicVariable "TRGM_VAR_ForceWarZoneLoc";
    publicVariable "TRGM_VAR_UseEditorWeather";
    publicVariable "TRGM_VAR_DateTimeWeather";
    publicVariable "TRGM_VAR_iAllowNVG";
    publicVariable "TRGM_VAR_iMissionParamRepOption";
    publicVariable "TRGM_VAR_iUseRevive";
    publicVariable "TRGM_VAR_NewMissionMusic";
    publicVariable "TRGM_VAR_PatrolType";
    publicVariable "TRGM_VAR_AllowAOFires";
    publicVariable "TRGM_VAR_HideAoMarker";

    // Convert string to index:
    TRGM_VAR_AdvancedSettings = [];
    {
        switch (_forEachIndex) do {
            case 6: { //TRGM_VAR_ADVSET_ENEMY_FACTIONS_IDX
                for "_i" from 0 to (count TRGM_VAR_AvailableFactions - 1) do {
                    (TRGM_VAR_AvailableFactions select _i) params ["_className", "_displayName"];
                    if (_className isEqualTo _x) then {
                        TRGM_VAR_AdvancedSettings pushBack _i;
                    };
                };
            };
            case 7: { //TRGM_VAR_ADVSET_MILITIA_FACTIONS_IDX
                for "_i" from 0 to (count TRGM_VAR_AvailableFactions - 1) do {
                    (TRGM_VAR_AvailableFactions select _i) params ["_className", "_displayName"];
                    if (_className isEqualTo _x) then {
                        TRGM_VAR_AdvancedSettings pushBack _i;
                    };
                };
            };
            case 8: { //TRGM_VAR_ADVSET_FRIENDLY_FACTIONS_IDX
                for "_i" from 0 to (count TRGM_VAR_AvailableFactions - 1) do {
                    (TRGM_VAR_AvailableFactions select _i) params ["_className", "_displayName"];
                    if (_className isEqualTo _x) then {
                        TRGM_VAR_AdvancedSettings pushBack _i;
                    };
                };
            };
            default { TRGM_VAR_AdvancedSettings pushBack _x;};
        };
    } forEach TRGM_VAR_CustomAdvancedSettings;
    publicVariable "TRGM_VAR_AdvancedSettings";
};