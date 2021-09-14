
TRGM_VAR_useCustomCampaignObjectives = (["CustomCampaignObjectives", 0] call BIS_fnc_getParamValue) isEqualTo 1;
publicVariable "TRGM_VAR_useCustomCampaignObjectives";
TRGM_VAR_useCustomCampaignSideObjectives = (["CustomCampaignSideObjectives", 0] call BIS_fnc_getParamValue) isEqualTo 1;
publicVariable "TRGM_VAR_useCustomCampaignSideObjectives";

TRGM_VAR_MainObjectivesToExcludeFromCampaign = [];
TRGM_VAR_SideObjectivesToExcludeFromCampaign = [];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Do not change anything above here!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if (isServer && TRGM_VAR_useCustomCampaignObjectives) then {

    // Uncomment the line with the mission you want to EXCLUDE from campaign.
    // For example, the meeting assassination and destroy cache missions will
    // not appear in the campaign mode.

    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 1;  // Hack Data
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 2;  // Steal data from research vehicle
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 3;  // Destroy Ammo Trucks
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 6;  // Bug Radio
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 7;  // Eliminate Officer
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 8;  // Assasinate weapon dealer
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 9;  // Destroy AAA vehicles
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 10; // Destroy Artillery vehicles
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 11; // Resue POW
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 12; // Resue Reporter
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 13; // Defuse IEDs
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 14; // Bomb Disposal
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 15; // Search and Destroy
    TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 16; // Destroy Cache
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 17; // Secure and Resupply
    TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 18; // Meeting Assassination
    // TRGM_VAR_MainObjectivesToExcludeFromCampaign pushBack 19; // Convoy Ambush

};

if (isServer && TRGM_VAR_useCustomCampaignSideObjectives) then {

    // Uncomment the line with the mission you want to EXCLUDE from campaign.
    // For example, the HVT-style missions will not appear as a side mission
    // in the campaign mode.

    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 1;  // Hack Data
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 2;  // Steal data from research vehicle
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 3;  // Destroy Ammo Trucks
    TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 4;  // Speak with informant
    TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 5;  // Interrogate officer
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 6;  // Bug Radio
    TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 7;  // Eliminate Officer
    TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 8;  // Assasinate weapon dealer
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 9;  // Destroy AAA vehicles
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 10; // Destroy Artillery vehicles
    TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 11; // Resue POW
    TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 12; // Resue Reporter
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 13; // Defuse IEDs
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 14; // Bomb Disposal
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 15; // Search and Destroy
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 16; // Destroy Cache
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 17; // Secure and Resupply
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 18; // Meeting Assassination
    // TRGM_VAR_SideObjectivesToExcludeFromCampaign pushBack 19; // Convoy Ambush

};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Do not change anything under here!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
publicVariable "TRGM_VAR_MainObjectivesToExcludeFromCampaign";
publicVariable "TRGM_VAR_SideObjectivesToExcludeFromCampaign";