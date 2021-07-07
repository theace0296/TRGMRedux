format["%1 called by %2 on %3", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if !(hasInterface) exitWith {};

waitUntil {!isNull player};
waitUntil {player isEqualTo player};

player createDiarySubject ["supportMe","Support Me"];
player createDiaryRecord ["supportMe", ["-", "<br /><font color='#5555FF'>www.trgm2.com</font><br /><br />Thank you for taking the time to read this : )
<br />
<br />
I love creating these missions and over the past few years have dedicated way too many hours to Arma 3 lol... nearly at the cost of my marriage!!! : S  

<br /><br />
<font color='#FFFF00'>Follow Me</font>
<br />If you want to support my work, there are quite a few ways to do so... if you visit my steam workshop page and give a thumbs up and comment, it really means a lot... these thumbs up ratings, and adding to fav help move my work up the workshop pages,
Follow me on steam, or my YouTube account, its nice to know my videos are being watched.
<br />
<br /><font color='#FFFF00'>
Donations : www.trgm2.com</font>
<br />
If you really want to, you can make a donation via my site www.trgm2.com (paypal link at top right of site).  I would also love to dedicate more time to the TRGM2 engine, making updates, fixes and new features, so would love to take some time off work to spend full days on my engine : )"]];

waitUntil {time > 0};

[] spawn {
    _unit = player;
    while {true} do {
        waitUntil {sleep 2; _unit != player };
        group player selectLeader player;
        //hintSilent " Player has changed";
        [_unit] call TRGM_CLIENT_fnc_transferProviders;
        _unit = player;
    };
};

if ((call TRGM_CLIENT_fnc_isAdmin) && (isNil "TRGM_VAR_AdminPlayer" || isNull TRGM_VAR_AdminPlayer)) then {
    TRGM_VAR_AdminPlayer = player; publicVariable "TRGM_VAR_AdminPlayer";
};

if (!TRGM_VAR_NeededObjectsAvailable) then {
    player allowDamage false;
    [player] spawn TRGM_CLIENT_fnc_findValidHQPosition;

    waitUntil { sleep 10; TRGM_VAR_NeededObjectsAvailable; };
};

call TRGM_CLIENT_fnc_missionSetupCamera;

[] spawn TRGM_CLIENT_fnc_missionSelectLoop;

waitUntil { TRGM_VAR_bOptionsSet };

txt5Layer = "txt5" call BIS_fnc_rscLayer;
_texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.8' color='#Ffffff'>TRGM Redux</t>";
[_texta, -0, 0.150, 7, 1,0,txt5Layer] spawn BIS_fnc_dynamicText;


txt51Layer = "txt51" call BIS_fnc_rscLayer;
_texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.5' color='#ffffff'>" + localize "STR_TRGM2_TRGMInitPlayerLocal_CantHearMusic" + "</t>";
[_texta, 0, 0.280, 7, 1,0,txt51Layer] spawn BIS_fnc_dynamicText;

call TRGM_CLIENT_fnc_endCamera;

sleep 3;

if (TRGM_VAR_AdminPlayer isEqualTo player) then {
    if !(call TRGM_GETTER_fnc_bIsCampaign) then {    //if isCampaign, dont allow to select AO

        if (call TRGM_GETTER_fnc_bManualAOPlacement) then {
            [player] spawn TRGM_CLIENT_fnc_selectAOLocation;
            waitUntil { TRGM_VAR_ManualAOPosFound };
            TRGM_VAR_Mission1Loc = TRGM_VAR_foundManualAOPos;
            publicVariable "TRGM_VAR_Mission1Loc";
            TRGM_VAR_foundManualAOPos = [0,0,0]; publicVariable "TRGM_VAR_foundManualAOPos";
            TRGM_VAR_ManualAOPosFound = false; publicVariable "TRGM_VAR_ManualAOPosFound";
            if (call TRGM_GETTER_fnc_bHasThreeChoosableAOLocations) then {
                [player] spawn TRGM_CLIENT_fnc_selectAOLocation;
                waitUntil { TRGM_VAR_ManualAOPosFound };
                TRGM_VAR_Mission2Loc = TRGM_VAR_foundManualAOPos;
                publicVariable "TRGM_VAR_Mission2Loc";
                TRGM_VAR_foundManualAOPos = [0,0,0]; publicVariable "TRGM_VAR_foundManualAOPos";
                TRGM_VAR_ManualAOPosFound = false; publicVariable "TRGM_VAR_ManualAOPosFound";
                [player] spawn TRGM_CLIENT_fnc_selectAOLocation;
                waitUntil { TRGM_VAR_ManualAOPosFound };
                TRGM_VAR_Mission3Loc = TRGM_VAR_foundManualAOPos;
                publicVariable "TRGM_VAR_Mission3Loc";
                TRGM_VAR_foundManualAOPos = [0,0,0]; publicVariable "TRGM_VAR_foundManualAOPos";
                TRGM_VAR_ManualAOPosFound = false; publicVariable "TRGM_VAR_ManualAOPosFound";
            };
        };

        if (call TRGM_GETTER_fnc_bManualCampPlacement) then {
            titleText[localize "STR_TRGM2_tele_SelectPosition_AO_Camp", "PLAIN"];
            openMap true;
            onMapSingleClick "TRGM_VAR_AOCampLocation = _pos; publicVariable 'TRGM_VAR_AOCampLocation'; openMap false; onMapSingleClick ''; true;";
            sleep 1;
            waitUntil {!visibleMap};
        };


    };
    TRGM_VAR_bAndSoItBegins = true; publicVariable "TRGM_VAR_bAndSoItBegins";
};

// _fnc_basicInitAndRespawn = {
//     "_fnc_basicInitAndRespawn called" call TRGM_GLOBAL_fnc_log;

//     if (isMultiplayer) then
//     {
//         waitUntil {!(isNull (findDisplay 46))};

//         player setspeaker "NoVoice";
//         //ShowRad = showRadio false;
//         //EnabRad = enableRadio false;
//         player disableConversation true;

//         player addEventHandler
//         [
//         "respawn",
//             {
//             player setspeaker "NoVoice";
//             //ShowRad = showRadio false;
//             //EnabRad = enableRadio false;
//             player disableConversation true
//             }
//         ];
//     };

//     TRGM_VAR_iAllowGPS = ("OUT_par_AllowGPS" call BIS_fnc_getParamValue);
//     if (TRGM_VAR_iAllowGPS isEqualTo 0) then {
//         showGPS false;
//     };

// };
// [] spawn _fnc_basicInitAndRespawn;
// player addEventHandler ["Respawn", { [] spawn _fnc_basicInitAndRespawn; }];

waitUntil { TRGM_VAR_bAndSoItBegins && TRGM_VAR_CustomObjectsSet };

[player] spawn TRGM_GLOBAL_fnc_setLoadout;

_isAceRespawnWithGear = false;
if (call TRGM_GLOBAL_fnc_isCbaLoaded) then {
    // check for ACE respawn with gear setting
    _isAceRespawnWithGear = "ace_respawn_savePreDeathGear" call CBA_settings_fnc_get;
};
if (!isNil("_isAceRespawnWithGear")) then {
    if (!_isAceRespawnWithGear) then {
        player addEventHandler ["Respawn", { [player] spawn TRGM_GLOBAL_fnc_setLoadout; }];
    };
};

[] spawn {
    5 fadeMusic 0;
    sleep 5;
    ace_hearing_disableVolumeUpdate = false;
    playMusic "";
};

_iEnableGroupManagement = TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_GROUP_MANAGE_IDX;
if (_iEnableGroupManagement isEqualTo 1) then {
    ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;//Exec on client
};

[] spawn TRGM_CLIENT_fnc_playerScripts;
player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_playerScripts; }];

if (TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_VIRTUAL_ARSENAL_IDX isEqualTo 1) then {
    box1 addAction [localize "STR_TRGM2_startInfMission_VirtualArsenal", {["Open",true] spawn BIS_fnc_arsenal}];
};

TRGM_VAR_bCirclesOfDeath = false;
TRGM_VAR_iCirclesOfDeath = 0; //("TRGM_VAR_par_CirclesOfDeath" call BIS_fnc_getParamValue);
if (TRGM_VAR_iCirclesOfDeath isEqualTo 1) then {
    TRGM_VAR_bCirclesOfDeath = true;
};

TRGM_VAR_iMissionSetup = TRGM_VAR_iMissionParamType;
if (TRGM_VAR_iMissionSetup isEqualTo 12 || TRGM_VAR_iMissionSetup isEqualTo 20) then {
    //training
    [player, 100] call BIS_fnc_respawnTickets;

    if (call TRGM_GLOBAL_fnc_isAceLoaded) then {
        myaction = ['TraceBulletAction',localize 'STR_TRGM2_TRGMInitPlayerLocal_TraceBullets','',{},{true}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions"], myaction] call ace_interact_menu_fnc_addActionToObject;

        myaction = ['TraceBulletEnable',localize 'STR_TRGM2_TRGMInitPlayerLocal_Enable','',{[player, 5] spawn BIS_fnc_traceBullets;},{true}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions", "TraceBulletAction"], myaction] call ace_interact_menu_fnc_addActionToObject;

        myaction = ['TraceBulletDisable',localize 'STR_TRGM2_TRGMInitPlayerLocal_Disable','',{[player, 0] spawn BIS_fnc_traceBullets;},{true}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions", "TraceBulletAction"], myaction] call ace_interact_menu_fnc_addActionToObject;
    };

}
else {
    _iTicketCount = TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_RESPAWN_TICKET_COUNT_IDX;
    [player, _iTicketCount] call BIS_fnc_respawnTickets;

    _iRespawnTimer = TRGM_VAR_AdvancedSettings select TRGM_VAR_ADVSET_RESPAWN_TIMER_IDX;
    setPlayerRespawnTime _iRespawnTimer;

    //if (TRGM_VAR_iMissionSetup isEqualTo 5 && !isMultiplayer) then {
    //    [player, 999] call BIS_fnc_respawnTickets;
    //    TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + "\n" + "999 respawn tickets"
    //}
    //else {
    //    [player, 1] call BIS_fnc_respawnTickets;
    //};
};


[] spawn TRGM_GLOBAL_fnc_animateAnimals;
player addEventHandler ["Respawn", { [] spawn TRGM_GLOBAL_fnc_animateAnimals; }];

[] spawn TRGM_CLIENT_fnc_generalPlayerLoop;
player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_generalPlayerLoop; }];

[] spawn TRGM_CLIENT_fnc_onlyAllowDirectMapDraw;
player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_onlyAllowDirectMapDraw; }];

[] spawn TRGM_CLIENT_fnc_inSafeZone;
player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_inSafeZone; }];

[] spawn TRGM_CLIENT_fnc_setNVG;
player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_setNVG; }];

if (TRGM_VAR_bCirclesOfDeath) then {

    [] spawn TRGM_CLIENT_fnc_checkKilledRange;
    player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_checkKilledRange; }];

    [] spawn TRGM_CLIENT_fnc_drawKilledRanges;
    player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_drawKilledRanges; }];

};

// if (TRGM_VAR_sArmaGroup isEqualTo "TCF" && isMultiplayer) then {
//     //_handle=createdialog "DialogMessAround";
//     //titleText ["!!!WARNING!!!\n\nPoint system in place\n\nDO NOT mess around at base\n\nONLY fly if you know AFM, or are being trained.\n\nDestroying vehicles will mark points and ruin the experience for others!!!", "PLAIN"];
// };

[] spawn TRGM_CLIENT_fnc_missionOverAnimation;
player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_missionOverAnimation; }];

player doFollow player;

waitUntil { TRGM_VAR_CoreCompleted; };

[] spawn TRGM_GLOBAL_fnc_checkBadPoints;
player addEventHandler ["Respawn", { [] spawn TRGM_GLOBAL_fnc_checkBadPoints; }];
