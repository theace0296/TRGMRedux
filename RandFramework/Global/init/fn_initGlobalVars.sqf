// private _fnc_scriptName = "TRGM_GLOBAL_fnc_initGlobalVars";
/////// Debug Mode ///////
TRGM_VAR_bDebugMode = [false, true] select ((["DebugMode", 0] call BIS_fnc_getParamValue) isEqualTo 1);
publicVariable "TRGM_VAR_bDebugMode";
/////// Load Test ///////
TRGM_VAR_bLoadTest = [false, true] select ((["LoadTest", 0] call BIS_fnc_getParamValue) isEqualTo 1);
publicVariable "TRGM_VAR_bLoadTest";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if (isNil "TRGM_VAR_serverFinishedInitGlobal")  then {TRGM_VAR_serverFinishedInitGlobal = false; publicVariable "TRGM_VAR_serverFinishedInitGlobal";};
if (isNil "TRGM_VAR_clientsFinishedInitGlobal") then {TRGM_VAR_clientsFinishedInitGlobal = []; publicVariable "TRGM_VAR_clientsFinishedInitGlobal";};

if (isServer) then {
    if (TRGM_VAR_serverFinishedInitGlobal) exitWith {};
    TRGM_VAR_serverFinishedInitGlobal = false; publicVariable "TRGM_VAR_serverFinishedInitGlobal";
    TRGM_VAR_clientsFinishedInitGlobal = []; publicVariable "TRGM_VAR_clientsFinishedInitGlobal";
} else {
    waitUntil {TRGM_VAR_serverFinishedInitGlobal;};
    if (clientOwner in TRGM_VAR_clientsFinishedInitGlobal) exitWith {};
};

if (isNil "TRGM_VAR_debugMessages") then {TRGM_VAR_debugMessages = ""; publicVariable "TRGM_VAR_debugMessages";};

if (isNil "TRGM_VAR_NeededObjectsAvailable") then { TRGM_VAR_NeededObjectsAvailable = false; publicVariable "TRGM_VAR_NeededObjectsAvailable"; };
if (isNil "TRGM_VAR_playerIsChoosingHQpos")  then { TRGM_VAR_playerIsChoosingHQpos  = false; publicVariable "TRGM_VAR_playerIsChoosingHQpos"; };
if (isNil "TRGM_VAR_HQPosFound")             then { TRGM_VAR_HQPosFound             = false; publicVariable "TRGM_VAR_HQPosFound"; };
if (isNil "TRGM_VAR_ManualAOPosFound")       then { TRGM_VAR_ManualAOPosFound       = false; publicVariable "TRGM_VAR_ManualAOPosFound"; };
if (isNil "TRGM_VAR_FactionSetupCompleted")  then { TRGM_VAR_FactionSetupCompleted  = false; publicVariable "TRGM_VAR_FactionSetupCompleted";};
if (!isNil "laptop1")                        then { TRGM_VAR_NeededObjectsAvailable = true;  publicVariable "TRGM_VAR_NeededObjectsAvailable"; };
TRGM_VAR_iMissionParamLocations    = []; publicVariable "TRGM_VAR_iMissionParamLocations";
TRGM_VAR_iMissionParamSubLocations = []; publicVariable "TRGM_VAR_iMissionParamSubLocations";

TRGM_VAR_iTimeMultiplier = ["TimeMultiplier", 0] call BIS_fnc_getParamValue;
if (TRGM_Var_iTimeMultiplier isEqualTo 50) then {
   TRGM_VAR_iTimeMultiplier = 0.5;
};
publicVariable "TRGM_VAR_iTimeMultiplier";

if (isNil "TRGM_VAR_SaveDataVersion") then { TRGM_VAR_SaveDataVersion = 3;  publicVariable "TRGM_VAR_SaveDataVersion"; };
if (isNil "TRGM_VAR_FactionVersion")  then { TRGM_VAR_FactionVersion  = 9;  publicVariable "TRGM_VAR_FactionVersion"; };
if (isNil "TRGM_VAR_LocationVersion") then { TRGM_VAR_LocationVersion = 4;  publicVariable "TRGM_VAR_LocationVersion"; };

//// These must be declared BEFORE either initUnitVars or CUSTOM_MISSION_fnc_SetDefaultMissionSetupVars!!!
if (isNil "TRGM_VAR_AllFactionData" || {isNil "TRGM_VAR_AllFactionMap" || {isNil "TRGM_VAR_AvailableFactions"}}) then {
    format["Get all faction data, called on %1", (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

    if (isServer) then {
        TRGM_VAR_LoadingText = "Gathering available factions..."; publicVariable "TRGM_VAR_LoadingText";
        TRGM_VAR_LoadingPercent = 15; publicVariable "TRGM_VAR_LoadingPercent";
    };

    private _WestFactionData =  [WEST] call TRGM_GLOBAL_fnc_getFactionDataBySide;
    private _EastFactionData =  [EAST] call TRGM_GLOBAL_fnc_getFactionDataBySide;
    private _GuerFactionData =  [INDEPENDENT] call TRGM_GLOBAL_fnc_getFactionDataBySide;
    TRGM_VAR_AvailableFactions = _WestFactionData + _EastFactionData + _GuerFactionData;
    TRGM_VAR_AvailableFactions = [TRGM_VAR_AvailableFactions, [], { _x select 1 }, "ASCEND"] call BIS_fnc_sortBy;
    private _FactionVersion = profileNamespace getVariable ["TRGM_VAR_FactionVersion", 0];

    TRGM_VAR_AllFactions = profileNamespace getVariable ["TRGM_VAR_AllFactions", []];
    TRGM_VAR_AllFactionData = profileNamespace getVariable ["TRGM_VAR_AllFactionData", []];
    TRGM_VAR_AllFactionMap = profileNamespace getVariable ["TRGM_VAR_AllFactionMap", createHashMap];

    TRGM_VAR_bRecalculateFactionData = [false, true] select ((["RecalculateFactionData", 0] call BIS_fnc_getParamValue) isEqualTo 1);
    TRGM_VAR_bRecalculateFactionData = [TRGM_VAR_bRecalculateFactionData, true] select !(TRGM_VAR_FactionVersion isEqualTo _FactionVersion);

    if (TRGM_VAR_bRecalculateFactionData) then {
        TRGM_VAR_AllFactions = [];
        TRGM_VAR_AllFactionData = [];
        TRGM_VAR_AllFactionMap = createHashMap;
    };

    publicVariable "TRGM_VAR_AvailableFactions";
    publicVariable "TRGM_VAR_AllFactions";
    publicVariable "TRGM_VAR_AllFactionData";
    publicVariable "TRGM_VAR_AllFactionMap";

    if (TRGM_VAR_bRecalculateFactionData || {count TRGM_VAR_AllFactions isEqualTo 0 || {{!(_x in TRGM_VAR_AllFactions)} count TRGM_VAR_AvailableFactions > 0}}) then {
        format["Update saved faction data, called on %1", (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
        private _factionDataHandles = [];

        call TRGM_GLOBAL_fnc_prePopulateUnitAndVehicleData;

        {
            if !((_x select 0) in TRGM_VAR_AllFactions) then {
                private _handle = [_x select 0, _x select 1] spawn {
                    try
                    {
                        params ["_className", "_displayName"];
                        format["Faction data for %1 (%2) not found, recalculating!", _className, _displayName] call TRGM_GLOBAL_fnc_log;
                        private _baseUnitData = [_className, _displayName] call TRGM_GLOBAL_fnc_getUnitDataByFaction;
                        private _baseVehData = [_className, _displayName] call TRGM_GLOBAL_fnc_getVehicleDataByFaction;

                        private _appendedData = [_baseUnitData, _baseVehData, _className, _displayName] call TRGM_GLOBAL_fnc_appendAdditonalFactionData;
                        _appendedData params ["_unitData", "_vehData"];

                        private _unitArray = [_unitData] call TRGM_GLOBAL_fnc_getUnitArraysFromUnitData;
                        private _vehArray = [_vehData] call TRGM_GLOBAL_fnc_getVehicleArraysFromVehData;

                        if (!(isNil "_unitArray") && !(isNil "_vehArray") && {{count _x > 0} count _unitArray > 0 && {count _x > 0} count _vehArray > 0}) then {
                            TRGM_VAR_AllFactionData pushBackUnique [_className, _displayName];
                            TRGM_VAR_AllFactionMap set [_className, [_unitArray, _vehArray]];
                            publicVariable "TRGM_VAR_AllFactionData";
                            publicVariable "TRGM_VAR_AllFactionMap";
                        } else {
                            if !((TRGM_VAR_AvailableFactions find [_className, _displayName]) isEqualTo -1) then {
                                TRGM_VAR_AvailableFactions deleteAt (TRGM_VAR_AvailableFactions find [_className, _displayName]);
                                publicVariable "TRGM_VAR_AvailableFactions";
                            };
                        };
                    }
                    catch
                    {
                        ["Exception caught while updating faction data:"] call TRGM_GLOBAL_fnc_log;
                        format["%1", _exception] call TRGM_GLOBAL_fnc_log;
                    };
                };
                _factionDataHandles pushBack [_x select 0, _x select 1, _handle];
            };
        } forEach TRGM_VAR_AvailableFactions;

        waitUntil {
            sleep 0.1;
            private _completedHandles = _factionDataHandles select { scriptDone (_x select 2); };
            if (isServer && count _factionDataHandles > 0) then {
                private _activeHandles = _factionDataHandles select { !(_x in _completedHandles); };
                private _content = ["Loading data for: "] + (flatten (_activeHandles apply { [lineBreak, format["  %1", _x select 1]] }));
                TRGM_VAR_LoadingText = composeText _content; publicVariable "TRGM_VAR_LoadingText";
                if (TRGM_VAR_LoadingPercent < 60) then {
                    TRGM_VAR_LoadingPercent = ceil(15 + ((count _completedHandles / count _factionDataHandles) * 45)); publicVariable "TRGM_VAR_LoadingPercent";
                };
            };
            count _completedHandles isEqualTo count _factionDataHandles;
        };

        if !(isNil "TRGM_TEMPVAR_allManUnits") then { TRGM_TEMPVAR_allManUnits = nil; publicVariable "TRGM_TEMPVAR_allManUnits"; };
        if !(isNil "TRGM_TEMPVAR_allVehicleUnits") then { TRGM_TEMPVAR_allVehicleUnits = nil; publicVariable "TRGM_TEMPVAR_allVehicleUnits"; };

        TRGM_VAR_AllFactionData = [TRGM_VAR_AllFactionData, [], { _x select 1 }, "ASCEND"] call BIS_fnc_sortBy;
        TRGM_VAR_AllFactions = (_WestFactionData + _EastFactionData + _GuerFactionData) apply { _x select 0 };
        profileNamespace setVariable ["TRGM_VAR_FactionVersion", TRGM_VAR_FactionVersion];
        profileNamespace setVariable ["TRGM_VAR_AllFactions", TRGM_VAR_AllFactions];
        profileNamespace setVariable ["TRGM_VAR_AllFactionData", TRGM_VAR_AllFactionData];
        profileNamespace setVariable ["TRGM_VAR_AllFactionMap", TRGM_VAR_AllFactionMap];
        saveProfileNamespace;
    } else {
        if (isServer) then {
            TRGM_VAR_LoadingText = "Loading Faction Data..."; publicVariable "TRGM_VAR_LoadingText";
            TRGM_VAR_LoadingPercent = 60; publicVariable "TRGM_VAR_LoadingPercent";
        };
        format["Using saved faction data, called on %1", (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
    };

    TRGM_VAR_AvailableFactions = [TRGM_VAR_AvailableFactions, [], { _x select 1 }, "ASCEND"] call BIS_fnc_sortBy;
    publicVariable "TRGM_VAR_AvailableFactions";
    publicVariable "TRGM_VAR_AllFactions";
    publicVariable "TRGM_VAR_AllFactionData";
    publicVariable "TRGM_VAR_AllFactionMap";
    format["Faction data calculated, called on %1", (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;
};

if (isServer) then {
    TRGM_VAR_LoadingText = "Loading variables..."; publicVariable "TRGM_VAR_LoadingText";
    TRGM_VAR_LoadingPercent = 70; publicVariable "TRGM_VAR_LoadingPercent";
};

// Custom Mission
TRGM_VAR_UseCustomMission = (["CustomMission", 0] call BIS_fnc_getParamValue) isEqualTo 1;
publicVariable "TRGM_VAR_UseCustomMission";

// Mission Setup Override
TRGM_VAR_OverrideMissionSetup = (["OverrideMissionSetup", 0] call BIS_fnc_getParamValue) isEqualTo 1;
publicVariable "TRGM_VAR_OverrideMissionSetup";

if (TRGM_VAR_OverrideMissionSetup) then {
    call CUSTOM_MISSION_fnc_SetDefaultMissionSetupVars;
};

if (TRGM_VAR_bLoadTest) then {
    call CUSTOM_MISSION_fnc_LoadTest;
};

// if (isNil "TRGM_VAR_TopLeftPos") then { TRGM_VAR_TopLeftPos = [25.4257,8173.69,0]; publicVariable "TRGM_VAR_TopLeftPos"; };
// if (isNil "TRGM_VAR_BotRightPos") then { TRGM_VAR_BotRightPos = [8188.86,9.91748,0]; publicVariable "TRGM_VAR_BotRightPos"; };

call TRGM_SERVER_fnc_initUnitVars;

TRGM_VAR_ThemeAndIntroMusic = ["LeadTrack01_F_Curator","Fallout","Wasteland","AmbientTrack01_F","AmbientTrack01b_F","Track02_SolarPower","Track03_OnTheRoad","Track04_Underwater1","Track05_Underwater2","Track06_CarnHeli","Track07_ActionDark","Track08_Night_ambient","Track09_Night_percussions","Track10_StageB_action","Track11_StageB_stealth","Track12_StageC_action","Track13_StageC_negative","Track14_MainMenu","Track15_MainTheme","LeadTrack01_F_EPA","LeadTrack02_F_EPA","LeadTrack02a_F_EPA","LeadTrack02b_F_EPA","LeadTrack03_F_EPA","LeadTrack03a_F_EPA","EventTrack01_F_EPA","EventTrack01a_F_EPA","EventTrack02_F_EPA","EventTrack02a_F_EPA","EventTrack03_F_EPA","EventTrack03a_F_EPA","LeadTrack01_F_EPB","LeadTrack01a_F_EPB","LeadTrack02_F_EPB","LeadTrack02a_F_EPB","LeadTrack02b_F_EPB","LeadTrack03_F_EPB","LeadTrack03a_F_EPB","LeadTrack04_F_EPB","EventTrack01_F_EPB","EventTrack01a_F_EPB","EventTrack02_F_EPB","EventTrack02a_F_EPB","EventTrack03_F_EPB","EventTrack04_F_EPB","EventTrack04a_F_EPB","EventTrack03a_F_EPB","AmbientTrack01_F_EPB","BackgroundTrack01_F_EPB","LeadTrack01_F_EPC","LeadTrack02_F_EPC","LeadTrack03_F_EPC","LeadTrack04_F_EPC","LeadTrack05_F_EPC","LeadTrack06_F_EPC","LeadTrack06b_F_EPC","EventTrack01_F_EPC","EventTrack02_F_EPC","EventTrack02b_F_EPC","EventTrack03_F_EPC","BackgroundTrack01_F_EPC","BackgroundTrack02_F_EPC","BackgroundTrack03_F_EPC","BackgroundTrack04_F_EPC","LeadTrack01_F_Bootcamp","LeadTrack01b_F_Bootcamp","LeadTrack02_F_Bootcamp","LeadTrack03_F_Bootcamp","LeadTrack01_F_Heli","LeadTrack01_F_Mark","LeadTrack02_F_Mark","LeadTrack03_F_Mark","LeadTrack01_F_EXP","LeadTrack01a_F_EXP","LeadTrack01b_F_EXP","LeadTrack01c_F_EXP","LeadTrack02_F_EXP","LeadTrack03_F_EXP","LeadTrack04_F_EXP","AmbientTrack01_F_EXP","AmbientTrack01a_F_EXP","AmbientTrack01b_F_EXP","AmbientTrack02_F_EXP","AmbientTrack02a_F_EXP","AmbientTrack02b_F_EXP","AmbientTrack02c_F_EXP","AmbientTrack02d_F_EXP","LeadTrack01_F_Jets","LeadTrack02_F_Jets","EventTrack01_F_Jets","LeadTrack01_F_Malden","LeadTrack02_F_Malden","LeadTrack01_F_Orange","AmbientTrack02_F_Orange","EventTrack01_F_Orange","EventTrack02_F_Orange","AmbientTrack01_F_Orange","LeadTrack01_F_Tacops","LeadTrack02_F_Tacops","LeadTrack03_F_Tacops","LeadTrack04_F_Tacops","AmbientTrack01a_F_Tacops","AmbientTrack01b_F_Tacops","AmbientTrack02a_F_Tacops","AmbientTrack02b_F_Tacops","AmbientTrack03a_F_Tacops","AmbientTrack03b_F_Tacops","AmbientTrack04a_F_Tacops","AmbientTrack04b_F_Tacops","EventTrack01a_F_Tacops","EventTrack01b_F_Tacops","EventTrack02a_F_Tacops","EventTrack02b_F_Tacops","EventTrack03a_F_Tacops","EventTrack03b_F_Tacops","Defcon","SkyNet","MAD","AmbientTrack03_F","BackgroundTrack01_F","Track01_Proteus","MainTheme_F_Tank","LeadTrack01_F_Tank","LeadTrack02_F_Tank","LeadTrack03_F_Tank","LeadTrack04_F_Tank","LeadTrack05_F_Tank","LeadTrack06_F_Tank","AmbientTrack01_F_Tank"];
if (1227700 in (getDLCs 1)) then {
    TRGM_VAR_ThemeAndIntroMusic = TRGM_VAR_ThemeAndIntroMusic + ["vn_blues_for_suzy", "vn_dont_cry_baby", "vn_drafted", "vn_fire_in_the_sky_demo", "vn_freedom_bird", "vn_jungle_boots", "vn_kitty_bar_blues", "vn_route9", "vn_tequila_highway", "vn_there_it_is", "vn_trippin", "vn_unsung_heroes", "vn_up_here_looking_down", "vn_voodoo_girl"];
    if (getNumber(configfile >> "CfgPatches" >> "theace" >> "appId") isEqualTo 1161041) then {
        TRGM_VAR_ThemeAndIntroMusic = TRGM_VAR_ThemeAndIntroMusic + ["fortunate_son", "ride_of_the_valkyries"];
    };
};
publicVariable "TRGM_VAR_ThemeAndIntroMusic";

if (isNil "TRGM_VAR_aNVClassNames")      then { TRGM_VAR_aNVClassNames = ["NVGoggles","NVGoggles_tna_F"]; publicVariable "TRGM_VAR_aNVClassNames"; };
if (isNil "TRGM_VAR_FriendlySide")       then { TRGM_VAR_FriendlySide = West;                             publicVariable "TRGM_VAR_FriendlySide"; };
if (isNil "TRGM_VAR_EnemySide")          then { TRGM_VAR_EnemySide = East;                                publicVariable "TRGM_VAR_EnemySide"; };
if (isNil "TRGM_VAR_InsSide")            then { TRGM_VAR_InsSide = Independent;                           publicVariable "TRGM_VAR_InsSide"; };
if (isNil "TRGM_VAR_FriendlySideString") then { TRGM_VAR_FriendlySideString = "West";                     publicVariable "TRGM_VAR_FriendlySideString"; };
if (isNil "TRGM_VAR_EnemySideString")    then { TRGM_VAR_EnemySideString = "East";                        publicVariable "TRGM_VAR_EnemySideString"; };
if (isNil "TRGM_VAR_InsSideString")      then { TRGM_VAR_InsSideString = "Independent";                   publicVariable "TRGM_VAR_InsSideString"; };
if (isNil "TRGM_VAR_sArmaGroup")         then { TRGM_VAR_sArmaGroup = "TCF";                              publicVariable "TRGM_VAR_sArmaGroup"; }; //use this to customise code for specific group requiments
if (isNil "TRGM_VAR_bNoVNChance")        then { TRGM_VAR_bNoVNChance = [false];                           publicVariable "TRGM_VAR_bNoVNChance"; };
if (isNil "TRGM_VAR_aPhoneticNames")   then { TRGM_VAR_aPhoneticNames = (["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"] apply { localize (format ["str_a3_radio_%1", _x])}); publicVariable "TRGM_VAR_aPhoneticNames"; };

TRGM_GETTER_fnc_sGetPhoneticName = { _index = _this select 0; _name = format ["%1", _index]; if (_index < 26) then { _name = TRGM_VAR_aPhoneticNames select _index; }; _name; }; publicVariable "TRGM_GETTER_fnc_sGetPhoneticName";

TRGM_GETTER_fnc_aGetReinforceStartPos = { [random 500, random 500, 0]; }; publicVariable "TRGM_GETTER_fnc_aGetReinforceStartPos";

if (isNil "TRGM_VAR_SideMissionMinDistFromBase") then { TRGM_VAR_SideMissionMinDistFromBase = 3000; publicVariable "TRGM_VAR_SideMissionMinDistFromBase"; }; //for min distached to have AO from base... TRGM_VAR_BaseAreaRange is more for patrols and events (thees need to be seperate variables, because if we had main HQ on an island and an AO spawned on the small island away from main land... hen will cause issues spawning in everything else)
if (isNil "TRGM_VAR_BaseAreaRange")              then { TRGM_VAR_BaseAreaRange = 1500;              publicVariable "TRGM_VAR_BaseAreaRange"; }; //used to make sure enemy events, patrols etc... doesnt spawn too close to base
if (isNil "TRGM_VAR_KilledZoneRadius")           then { TRGM_VAR_KilledZoneRadius = 1500;           publicVariable "TRGM_VAR_KilledZoneRadius"; };
if (isNil "TRGM_VAR_KilledZoneInnerRadius")      then { TRGM_VAR_KilledZoneInnerRadius = 1450;      publicVariable "TRGM_VAR_KilledZoneInnerRadius"; };
if (isNil "TRGM_VAR_SaveZoneRadius")             then { TRGM_VAR_SaveZoneRadius = 1000;             publicVariable "TRGM_VAR_SaveZoneRadius"; }; //if 0 will be no safezone

//remove radios etc... for nam mission or other era
if (isNil "TRGM_VAR_InitialBoxItems")        then { TRGM_VAR_InitialBoxItems = [[[[],[]],[["SmokeShellBlue","SmokeShellGreen","SmokeShellOrange","SmokeShellRed","SmokeShell"],[20,20,20,20,20]],[["ItemCompass","ItemMap","ItemWatch"],[5,5,5]],[[],[]]],false]; publicVariable "TRGM_VAR_InitialBoxItems"; };
if (isNil "TRGM_VAR_InitialBoxItemsWithAce") then { TRGM_VAR_InitialBoxItemsWithAce = [[[["ACE_VMH3","ACE_VMM3"],[5,5]],[["DemoCharge_Remote_Mag","SatchelCharge_Remote_Mag","SmokeShellGreen","SmokeShellOrange","SmokeShellRed","SmokeShell"],[5,5,20,20,20,20,20]],[["ACE_RangeTable_82mm","ACE_adenosine","ACE_ATragMX","ACE_atropine","ACE_Banana","ACE_fieldDressing","ACE_elasticBandage","ACE_quikclot","ACE_bloodIV","ACE_bloodIV_250","ACE_bloodIV_500","ACE_bodyBag","ACE_CableTie","ItemCompass","ACE_DAGR","ACE_DefusalKit","ACE_EarPlugs","ACE_EntrenchingTool","ACE_epinephrine","ACE_Flashlight_MX991","ACE_Kestrel4500","ACE_Flashlight_KSF1","ACE_M26_Clacker","ACE_Clacker","ACE_Flashlight_XL50","ItemMap","ACE_MapTools","ACE_microDAGR","ACE_morphine","ACE_packingBandage","ACE_personalAidKit","ACE_plasmaIV","ACE_plasmaIV_250","ACE_plasmaIV_500","ACE_RangeCard","ACE_salineIV","ACE_salineIV_250","ACE_salineIV_500","ACE_Sandbag_empty","ACE_Tripod","ACE_surgicalKit","ACE_tourniquet","ACE_VectorDay","ItemWatch","ACE_wirecutter","tf_anprc152","tf_anprc154"],[50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50]],[["tf_rt1523g","tf_rt1523g_big"],[3,3]]],false]; publicVariable "TRGM_VAR_InitialBoxItemsWithAce"; };


if (isNil "TRGM_VAR_CampaignRecruitUnitRifleman")            then { TRGM_VAR_CampaignRecruitUnitRifleman = "B_Soldier_F";                publicVariable "TRGM_VAR_CampaignRecruitUnitRifleman"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitAT")                  then { TRGM_VAR_CampaignRecruitUnitAT = "B_soldier_AT_F";                   publicVariable "TRGM_VAR_CampaignRecruitUnitAT"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitAA")                  then { TRGM_VAR_CampaignRecruitUnitAA = "B_soldier_AA_F";                   publicVariable "TRGM_VAR_CampaignRecruitUnitAA"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitExplosiveSpecialist") then { TRGM_VAR_CampaignRecruitUnitExplosiveSpecialist = "B_soldier_exp_F"; publicVariable "TRGM_VAR_CampaignRecruitUnitExplosiveSpecialist"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitMedic")               then { TRGM_VAR_CampaignRecruitUnitMedic = "B_medic_F";                     publicVariable "TRGM_VAR_CampaignRecruitUnitMedic"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitEngineer")            then { TRGM_VAR_CampaignRecruitUnitEngineer = "B_engineer_F";               publicVariable "TRGM_VAR_CampaignRecruitUnitEngineer"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitAuto")                then { TRGM_VAR_CampaignRecruitUnitAuto = "B_soldier_AR_F";                 publicVariable "TRGM_VAR_CampaignRecruitUnitAuto"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitSniper")              then { TRGM_VAR_CampaignRecruitUnitSniper = "B_sniper_F";                   publicVariable "TRGM_VAR_CampaignRecruitUnitSniper"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitSpotter")             then { TRGM_VAR_CampaignRecruitUnitSpotter = "B_spotter_F";                 publicVariable "TRGM_VAR_CampaignRecruitUnitSpotter"; };
if (isNil "TRGM_VAR_CampaignRecruitUnitUAV")                 then { TRGM_VAR_CampaignRecruitUnitUAV = "B_soldier_UAV_F";                 publicVariable "TRGM_VAR_CampaignRecruitUnitUAV"; };

if (isNil "TRGM_VAR_GraveYardPos")       then { TRGM_VAR_GraveYardPos = [5028.07,1424.47,0]; publicVariable "TRGM_VAR_GraveYardPos"; };
if (isNil "TRGM_VAR_GraveYardDirection") then { TRGM_VAR_GraveYardDirection = 90;            publicVariable "TRGM_VAR_GraveYardDirection"; };

if (isNil "TRGM_VAR_FriendlyFastResponseDingy") then { TRGM_VAR_FriendlyFastResponseDingy = ["B_Boat_Transport_01_F"]; publicVariable "TRGM_VAR_FriendlyFastResponseDingy"; };
if (isNil "TRGM_VAR_SmallTransportVehicle")     then { TRGM_VAR_SmallTransportVehicle = ["B_Quadbike_01_F"];           publicVariable "TRGM_VAR_SmallTransportVehicle"; }; //used for AO camp, just incase no vehicles near, or too built up in jungle for cars


if (isNil "TRGM_VAR_EnemyRadioSounds")    then { TRGM_VAR_EnemyRadioSounds = ["ambient_radio2","ambient_radio8","ambient_radio10","ambient_radio11","ambient_radio12","ambient_radio13","ambient_radio15","ambient_radio16","ambient_radio18","ambient_radio20","ambient_radio24"]; publicVariable "TRGM_VAR_EnemyRadioSounds"; };
if (isNil "TRGM_VAR_FriendlyRadioSounds") then { TRGM_VAR_FriendlyRadioSounds = ["ambient_radio3","ambient_radio4","ambient_radio5","ambient_radio6","ambient_radio7","ambient_radio9","ambient_radio14","ambient_radio17","ambient_radio19","ambient_radio21","ambient_radio22","ambient_radio23","ambient_radio25","ambient_radio26","ambient_radio27","ambient_radio28","ambient_radio29","ambient_radio30"]; publicVariable "TRGM_VAR_FriendlyRadioSounds"; };
if (isNil "TRGM_VAR_IEDClassNames")       then { TRGM_VAR_IEDClassNames = ["IEDUrbanBig_F","IEDLandBig_F","IEDUrbanSmall_F"]; publicVariable "TRGM_VAR_IEDClassNames"; };
if (isNil "TRGM_VAR_IEDFakeClassNames")   then { TRGM_VAR_IEDFakeClassNames = ["Land_GarbagePallet_F","Land_JunkPile_F"]; publicVariable "TRGM_VAR_IEDFakeClassNames"; };
if (isNil "TRGM_VAR_ATMinesClassNames")   then { TRGM_VAR_ATMinesClassNames = ["ATMine"]; publicVariable "TRGM_VAR_ATMinesClassNames"; };
if (isNil "TRGM_VAR_WreckCarClasses")     then { TRGM_VAR_WreckCarClasses = ["Land_Wreck_Slammer_F","Land_Wreck_Truck_dropside_F","Land_Wreck_Offroad2_F","Land_Wreck_Car3_F","Land_Wreck_Truck_F"]; publicVariable "TRGM_VAR_WreckCarClasses"; };
if (isNil "TRGM_VAR_ChopperWrecks")       then { TRGM_VAR_ChopperWrecks = ["Land_Wreck_Heli_Attack_01_F"]; publicVariable "TRGM_VAR_ChopperWrecks"; };


if (isNil "TRGM_VAR_MedicalMessItems") then { TRGM_VAR_MedicalMessItems = ["MedicalGarbage_01_1x1_v1_F","MedicalGarbage_01_1x1_v2_F","MedicalGarbage_01_1x1_v3_F","MedicalGarbage_01_3x3_v1_F","MedicalGarbage_01_3x3_v2_F","MedicalGarbage_01_5x5_v1_F"]; publicVariable "TRGM_VAR_MedicalMessItems"; };
if (isNil "TRGM_VAR_MedicalBoxes")     then { TRGM_VAR_MedicalBoxes = ["Land_PaperBox_01_small_closed_white_med_F","Land_FirstAidKit_01_open_F"]; publicVariable "TRGM_VAR_MedicalBoxes"; };
if (isNil "TRGM_VAR_ConesWithLight")   then { TRGM_VAR_ConesWithLight = ["RoadCone_L_F"]; publicVariable "TRGM_VAR_ConesWithLight"; };
if (isNil "TRGM_VAR_Cones")            then { TRGM_VAR_Cones = ["RoadCone_F"]; publicVariable "TRGM_VAR_Cones"; };

if (isNil "TRGM_VAR_TombStones")        then { TRGM_VAR_TombStones = ["Land_Tombstone_01_F","Land_Tombstone_03_F","Land_Tombstone_02_F"]; publicVariable "TRGM_VAR_TombStones"; };
if (isNil "TRGM_VAR_InformantImage")    then { TRGM_VAR_InformantImage = "<img image='RandFramework\Media\Informants2.jpg' size='1' />"; publicVariable "TRGM_VAR_InformantImage"; };
if (isNil "TRGM_VAR_OfficerImage")      then { TRGM_VAR_OfficerImage = "<img image='RandFramework\Media\Officer2.jpg' size='1' />"; publicVariable "TRGM_VAR_OfficerImage"; };
if (isNil "TRGM_VAR_WeaponDealerImage") then { TRGM_VAR_WeaponDealerImage = "<img image='RandFramework\Media\WeaponDealers2.jpg' size='1' />"; publicVariable "TRGM_VAR_WeaponDealerImage"; };


if (isNil "TRGM_VAR_transportHelosToGetActions")              then {TRGM_VAR_transportHelosToGetActions = [];                         publicVariable "TRGM_VAR_transportHelosToGetActions";};
if (isNil "TRGM_VAR_AllInitScriptsFinished")                  then {TRGM_VAR_AllInitScriptsFinished = false;                          publicVariable "TRGM_VAR_AllInitScriptsFinished";};
if (isNil "TRGM_VAR_AOCampOnlyAmmoBox")                       then {TRGM_VAR_AOCampOnlyAmmoBox = false;                               publicVariable "TRGM_VAR_AOCampOnlyAmmoBox";};
//TRGM_VAR_AODetails = [[AOIndex,InfSpottedCount,VehSpottedCount,AirSpottedCount,bScoutCalled,patrolMoveCounter]]
//example TRGM_VAR_AODetails [[1,0,0,0,False,0],[2,0,0,0,True,0]]
if (isNil "TRGM_VAR_AODetails")                               then {TRGM_VAR_AODetails = [];                                          publicVariable "TRGM_VAR_AODetails";};
if (isNil "TRGM_VAR_ATFieldPos")                              then {TRGM_VAR_ATFieldPos = [];                                         publicVariable "TRGM_VAR_ATFieldPos";};
if (isNil "TRGM_VAR_ActiveTasks")                             then {TRGM_VAR_ActiveTasks = [];                                        publicVariable "TRGM_VAR_ActiveTasks";};
if (isNil "TRGM_VAR_AdminPlayer")                             then {TRGM_VAR_AdminPlayer = objNull;                                   publicVariable "TRGM_VAR_AdminPlayer";};
if (isNil "TRGM_VAR_AllowAOFires")                            then {TRGM_VAR_AllowAOFires =   true;                                   publicVariable "TRGM_VAR_AllowAOFires";};
if (isNil "TRGM_VAR_AllowUAVLocateHelp")                      then {TRGM_VAR_AllowUAVLocateHelp = false;                              publicVariable "TRGM_VAR_AllowUAVLocateHelp";};
if (isNil "TRGM_VAR_BadPoints")                               then {TRGM_VAR_BadPoints = 0;                                           publicVariable "TRGM_VAR_BadPoints";};
if (isNil "TRGM_VAR_BadPointsReason")                         then {TRGM_VAR_BadPointsReason = "";                                    publicVariable "TRGM_VAR_BadPointsReason";};
if (isNil "TRGM_VAR_CalledAirsupportIndex")                   then {TRGM_VAR_CalledAirsupportIndex = 1;                               publicVariable "TRGM_VAR_CalledAirsupportIndex";};
if (isNil "TRGM_VAR_CampaignInitiated")                       then {TRGM_VAR_CampaignInitiated = false;                               publicVariable "TRGM_VAR_CampaignInitiated"; };
if (isNil "TRGM_VAR_CheckPointAreas")                         then {TRGM_VAR_CheckPointAreas = [];                                    publicVariable "TRGM_VAR_CheckPointAreas";};
if (isNil "TRGM_VAR_CivDeathCount")                           then {TRGM_VAR_CivDeathCount = 0;                                       publicVariable "TRGM_VAR_CivDeathCount";};
if (isNil "TRGM_VAR_ClearedPositions")                        then {TRGM_VAR_ClearedPositions = [];                                   publicVariable "TRGM_VAR_ClearedPositions";};
if (isNil "TRGM_VAR_CoreCompleted")                           then { TRGM_VAR_CoreCompleted = false;                                  publicVariable "TRGM_VAR_CoreCompleted";};
if (isNil "TRGM_VAR_CurrentZeroMissionTitle")                 then {TRGM_VAR_CurrentZeroMissionTitle = "";                            publicVariable "TRGM_VAR_CurrentZeroMissionTitle";};
if (isNil "TRGM_VAR_CustomObjectsSet")                        then {TRGM_VAR_CustomObjectsSet = false;                                publicVariable "TRGM_VAR_CustomObjectsSet";};
if (isNil "TRGM_VAR_EnemyID")                                 then {TRGM_VAR_EnemyID = 1;                                             publicVariable "TRGM_VAR_EnemyID";};
if (isNil "TRGM_VAR_FinalMissionStarted")                     then {TRGM_VAR_FinalMissionStarted = false;                             publicVariable "TRGM_VAR_FinalMissionStarted";};
if (isNil "TRGM_VAR_FlareCounter")                            then {TRGM_VAR_FlareCounter = 15;                                       publicVariable "TRGM_VAR_FlareCounter";};
if (isNil "TRGM_VAR_FireFlares")                              then {TRGM_VAR_FireFlares = random 1 < .50;                             publicVariable "TRGM_VAR_FireFlares";};
if (isNil "TRGM_VAR_ForceEndSandStorm")                       then {TRGM_VAR_ForceEndSandStorm = false;                               publicVariable "TRGM_VAR_ForceEndSandStorm";};
if (isNil "TRGM_VAR_ForceMissionSetup")                       then {TRGM_VAR_ForceMissionSetup = false;                               publicVariable "TRGM_VAR_ForceMissionSetup";};
if (isNil "TRGM_VAR_HiddenPositions")                         then {TRGM_VAR_HiddenPositions = [];                                    publicVariable "TRGM_VAR_HiddenPositions";};
if (isNil "TRGM_VAR_ISUNSUNG")                                then {TRGM_VAR_ISUNSUNG = false;                                        publicVariable "TRGM_VAR_ISUNSUNG";};
if (isNil "TRGM_VAR_IntroMusic")                              then {TRGM_VAR_IntroMusic = selectRandom TRGM_VAR_ThemeAndIntroMusic;   publicVariable "TRGM_VAR_IntroMusic";};
if (isNil "TRGM_VAR_IsFullMap")                               then {TRGM_VAR_IsFullMap = false;                                       publicVariable "TRGM_VAR_IsFullMap";};
if (isNil "TRGM_VAR_IsSnowMap")                               then {TRGM_VAR_IsSnowMap = false;                                       publicVariable "TRGM_VAR_IsSnowMap";};
if (isNil "TRGM_VAR_KilledPlayers")                           then {TRGM_VAR_KilledPlayers = [];                                      publicVariable "TRGM_VAR_KilledPlayers";};
if (isNil "TRGM_VAR_KilledPositions")                         then {TRGM_VAR_KilledPositions = [];                                    publicVariable "TRGM_VAR_KilledPositions";};
if (isNil "TRGM_VAR_MainMissionTitle")                        then {TRGM_VAR_MainMissionTitle = "";                                   publicVariable "TRGM_VAR_MainMissionTitle";};
if (isNil "TRGM_VAR_MaxBadPoints")                            then {TRGM_VAR_MaxBadPoints = 1;                                        publicVariable "TRGM_VAR_MaxBadPoints";};
if (isNil "TRGM_VAR_MissionLoaded")                           then {TRGM_VAR_MissionLoaded = false;                                   publicVariable "TRGM_VAR_MissionLoaded";};
if (isNil "TRGM_VAR_MissionParamsSet")                        then {TRGM_VAR_MissionParamsSet = false;                                publicVariable "TRGM_VAR_MissionParamsSet";};
if (isNil "TRGM_VAR_NewMissionMusic")                         then {TRGM_VAR_NewMissionMusic = selectRandom TRGM_VAR_ThemeAndIntroMusic; publicVariable "TRGM_VAR_NewMissionMusic";};
if (isNil "TRGM_VAR_ObjectivePositions")                      then {TRGM_VAR_ObjectivePositions = [];                                 publicVariable "TRGM_VAR_ObjectivePositions";};
if (isNil "TRGM_VAR_OccupiedHousesPos")                       then {TRGM_VAR_OccupiedHousesPos =   [];                                publicVariable "TRGM_VAR_OccupiedHousesPos"; };
if (isNil "TRGM_VAR_ParaDropped")                             then {TRGM_VAR_ParaDropped = false;                                     publicVariable "TRGM_VAR_ParaDropped";};
if (isNil "TRGM_VAR_PatrolType")                              then {TRGM_VAR_PatrolType =   0;                                        publicVariable "TRGM_VAR_PatrolType";};
if (isNil "TRGM_VAR_PlayersHaveLeftStartingArea")             then {TRGM_VAR_PlayersHaveLeftStartingArea = false;                     publicVariable "TRGM_VAR_PlayersHaveLeftStartingArea";};
if (isNil "TRGM_VAR_ReinforcementsCalled")                    then {TRGM_VAR_ReinforcementsCalled = 0;                                publicVariable "TRGM_VAR_ReinforcementsCalled";};
if (isNil "TRGM_VAR_SaveType")                                then {TRGM_VAR_SaveType = 0;                                            publicVariable "TRGM_VAR_SaveType";};
if (isNil "TRGM_VAR_SentryAreas")                             then {TRGM_VAR_SentryAreas = [];                                        publicVariable "TRGM_VAR_SentryAreas";};
if (isNil "TRGM_VAR_TimeLastReinforcementsCalled")            then {TRGM_VAR_TimeLastReinforcementsCalled = time;                     publicVariable "TRGM_VAR_TimeLastReinforcementsCalled";};
if (isNil "TRGM_VAR_TimeSinceAdditionalReinforcementsCalled") then {TRGM_VAR_TimeSinceAdditionalReinforcementsCalled = time;          publicVariable "TRGM_VAR_TimeSinceAdditionalReinforcementsCalled";};
if (isNil "TRGM_VAR_TimeSinceLastSpottedAction")              then {TRGM_VAR_TimeSinceLastSpottedAction = time;                       publicVariable "TRGM_VAR_TimeSinceLastSpottedAction";};
if (isNil "TRGM_VAR_ToUseMilitia_Side")                       then {TRGM_VAR_ToUseMilitia_Side = false;                               publicVariable "TRGM_VAR_ToUseMilitia_Side";};
if (isNil "TRGM_VAR_bAndSoItBegins")                          then {TRGM_VAR_bAndSoItBegins = false;                                  publicVariable "TRGM_VAR_bAndSoItBegins";};
if (isNil "TRGM_VAR_bBaseHasChopper")                         then {TRGM_VAR_bBaseHasChopper = false;                                 publicVariable "TRGM_VAR_bBaseHasChopper";};
if (isNil "TRGM_VAR_bBreifingPrepped")                        then {TRGM_VAR_bBreifingPrepped = false;                                publicVariable "TRGM_VAR_bBreifingPrepped";};
if (isNil "TRGM_VAR_bCommsBlocked")                           then {TRGM_VAR_bCommsBlocked = [false];                                 publicVariable "TRGM_VAR_bCommsBlocked";};
if (isNil "TRGM_VAR_bHasCommsTower")                          then {TRGM_VAR_bHasCommsTower = [false];                                publicVariable "TRGM_VAR_bHasCommsTower";};
if (isNil "TRGM_VAR_bMortarFiring")                           then {TRGM_VAR_bMortarFiring = false;                                   publicVariable "TRGM_VAR_bMortarFiring";};
if (isNil "TRGM_VAR_bOptionsSet")                             then {TRGM_VAR_bOptionsSet = false;                                     publicVariable "TRGM_VAR_bOptionsSet";};
if (isNil "TRGM_VAR_bOptionsSet")                             then {TRGM_VAR_bOptionsSet = false;                                     publicVariable "TRGM_VAR_bOptionsSet";};
if (isNil "TRGM_VAR_iAllowNVG")                               then {TRGM_VAR_iAllowNVG = 2;                                           publicVariable "TRGM_VAR_iAllowNVG";};
if (isNil "TRGM_VAR_iCampaignDay")                            then {TRGM_VAR_iCampaignDay = 0;                                        publicVariable "TRGM_VAR_iCampaignDay";};
if (isNil "TRGM_VAR_iMissionParamObjectives")                 then {TRGM_VAR_iMissionParamObjectives = [[0, false, false, false]];    publicVariable "TRGM_VAR_iMissionParamObjectives";};
if (isNil "TRGM_VAR_iMissionParamRepOption")                  then {TRGM_VAR_iMissionParamRepOption = 0;                              publicVariable "TRGM_VAR_iMissionParamRepOption";};
if (isNil "TRGM_VAR_iMissionIsCampaign")                      then {TRGM_VAR_iMissionIsCampaign = false;                              publicVariable "TRGM_VAR_iMissionIsCampaign";};
if (isNil "TRGM_VAR_iStartLocation")                          then {TRGM_VAR_iStartLocation = 2;                                      publicVariable "TRGM_VAR_iStartLocation";};
if (isNil "TRGM_VAR_iUseRevive")                              then {TRGM_VAR_iUseRevive = 0;                                          publicVariable "TRGM_VAR_iUseRevive";};
if (isNil "TRGM_VAR_iWeather")                                then {TRGM_VAR_iWeather = 1;                                            publicVariable "TRGM_VAR_iWeather";};
if (isNil "TRGM_VAR_OverrideTimer")                           then {TRGM_VAR_OverrideTimer = false;                                   publicVariable "TRGM_VAR_OverrideTimer"; };

if (isServer) then {
    TRGM_VAR_serverFinishedInitGlobal = true; publicVariable "TRGM_VAR_serverFinishedInitGlobal";
} else {
    TRGM_VAR_clientsFinishedInitGlobal = TRGM_VAR_clientsFinishedInitGlobal + [clientOwner]; publicVariable "TRGM_VAR_clientsFinishedInitGlobal";
};

true;