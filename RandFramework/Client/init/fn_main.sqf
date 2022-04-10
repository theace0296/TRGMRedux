// private _fnc_scriptName = "TRGM_CLIENT_fnc_main";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



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
    private _unit = player;
    waitUntil {
        waitUntil {sleep 5; _unit != player };
        group player selectLeader player;
        //hintSilent " Player has changed";
        [_unit] call TRGM_CLIENT_fnc_transferProviders;
        _unit = player;
        sleep 10;
        false;
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

private _txt5Layer = "txt5" call BIS_fnc_rscLayer;
private _texta = format ["<t font ='EtelkaMonospaceProBold' align = 'center' size='0.8' color='#Ffffff'>%1</t>", localize "STR_TRGM2_Description_Name"];
[_texta, -0, 0.150, 7, 1,0,_txt5Layer] spawn BIS_fnc_dynamicText;


private _txt51Layer = "txt51" call BIS_fnc_rscLayer;
_texta = "<t font ='EtelkaMonospaceProBold' align = 'center' size='0.5' color='#ffffff'>" + localize "STR_TRGM2_TRGMInitPlayerLocal_CantHearMusic" + "</t>";
[_texta, 0, 0.280, 7, 1,0,_txt51Layer] spawn BIS_fnc_dynamicText;

call TRGM_CLIENT_fnc_endCamera;

sleep 3;

if (TRGM_VAR_AdminPlayer isEqualTo player) then {
    if !(TRGM_VAR_iMissionIsCampaign) then {    //if isCampaign, dont allow to select AO

        if (call TRGM_GETTER_fnc_bManualAOPlacement) then {
            TRGM_VAR_iMissionParamLocations    = []; publicVariable "TRGM_VAR_iMissionParamLocations";
            TRGM_VAR_iMissionParamSubLocations = []; publicVariable "TRGM_VAR_iMissionParamSubLocations";
            for [{private _i = 0;}, {_i < count TRGM_VAR_iMissionParamObjectives}, {_i = _i + 1}] do {
                TRGM_VAR_iMissionParamLocations pushBack [0,0,0]; publicVariable "TRGM_VAR_iMissionParamLocations";
                TRGM_VAR_iMissionParamSubLocations pushBack [0,0,0]; publicVariable "TRGM_VAR_iMissionParamSubLocations";
                [player] spawn TRGM_CLIENT_fnc_selectAOLocation;
                waitUntil { TRGM_VAR_ManualAOPosFound };
                TRGM_VAR_iMissionParamLocations set [_i, TRGM_VAR_foundManualAOPos];
                publicVariable "TRGM_VAR_iMissionParamLocations";
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

waitUntil { TRGM_VAR_bAndSoItBegins && TRGM_VAR_CustomObjectsSet };

[player] spawn TRGM_GLOBAL_fnc_setLoadout;

if (call TRGM_GLOBAL_fnc_isCbaLoaded && call TRGM_GLOBAL_fnc_isAceLoaded) then {
    // check for ACE respawn with gear setting
    private _isAceRespawnWithGear = "ace_respawn_savePreDeathGear" call CBA_settings_fnc_get;
    if (!(isNil "_isAceRespawnWithGear") && {!_isAceRespawnWithGear}) then {
        player addEventHandler ["Respawn", { [player] spawn TRGM_GLOBAL_fnc_setLoadout; }];
    };
};

[] spawn {
    5 fadeMusic 0;
    sleep 5;
    ace_hearing_disableVolumeUpdate = false;
    playMusic "";
};

if (call TRGM_GETTER_fnc_bEnableGroupManagement) then {
    ["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;//Exec on client
};

[] spawn TRGM_CLIENT_fnc_playerScripts;
player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_playerScripts; }];

if (call TRGM_GETTER_fnc_bEnableVirtualArsenal) then {
    box1 addAction [localize "STR_TRGM2_startInfMission_VirtualArsenal", {["Open",true] spawn BIS_fnc_arsenal}];
};

TRGM_VAR_bCirclesOfDeath = false;
TRGM_VAR_iCirclesOfDeath = 0; //("TRGM_VAR_par_CirclesOfDeath" call BIS_fnc_getParamValue);
if (TRGM_VAR_iCirclesOfDeath isEqualTo 1) then {
    TRGM_VAR_bCirclesOfDeath = true;
};

private _isTraining = false;
if (_isTraining) then {
    //training
    [player, 100] call BIS_fnc_respawnTickets;

    private _useAceInteractionForTransport = [false, true] select ((["EnableAceActions", 0] call BIS_fnc_getParamValue) isEqualTo 1);
    if (_useAceInteractionForTransport && call TRGM_GLOBAL_fnc_isAceLoaded) then {
        myaction = ['TraceBulletAction',localize 'STR_TRGM2_TRGMInitPlayerLocal_TraceBullets','',{},{true}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions"], myaction] call ace_interact_menu_fnc_addActionToObject;

        myaction = ['TraceBulletEnable',localize 'STR_TRGM2_TRGMInitPlayerLocal_Enable','',{[player, 5] spawn BIS_fnc_traceBullets;},{true}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions", "TraceBulletAction"], myaction] call ace_interact_menu_fnc_addActionToObject;

        myaction = ['TraceBulletDisable',localize 'STR_TRGM2_TRGMInitPlayerLocal_Disable','',{[player, 0] spawn BIS_fnc_traceBullets;},{true}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions", "TraceBulletAction"], myaction] call ace_interact_menu_fnc_addActionToObject;
    };

}
else {
    [player, call TRGM_GETTER_fnc_iTicketCount] call BIS_fnc_respawnTickets;
    setPlayerRespawnTime (call TRGM_GETTER_fnc_iRespawnTimer);
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

[] spawn TRGM_CLIENT_fnc_missionOverAnimation;
player addEventHandler ["Respawn", { [] spawn TRGM_CLIENT_fnc_missionOverAnimation; }];

player doFollow player;

waitUntil { TRGM_VAR_CoreCompleted; };

[] spawn TRGM_GLOBAL_fnc_checkBadPoints;
player addEventHandler ["Respawn", { [] spawn TRGM_GLOBAL_fnc_checkBadPoints; }];
