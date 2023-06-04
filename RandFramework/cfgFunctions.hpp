class TRGM_SERVER {
    class init {
        file = "RandFramework\Server\init";
        class checkAnyPlayersAlive {};
        class createNeededObjects {};
        class initUnitVars {};
        class main {};
        class playBaseRadioEffect {};
        class sandStormEffect {};
        class serverSave {};
        class setAdmin {};
        class setTimeAndWeather {};
        class weatherAffectsAI {};
    };

    class campaign {
        file = "RandFramework\Server\campaign";
        class initCampaign {};
        class exitCampaign {};
        class setMissionBoardOptions {};
        class turnInMission {};
    };

    class mission {
        file = "RandFramework\Server\mission";
        class attemptEndMission {};
        class finalSetupCleaner {};
        class generateObjective {};
        class initMissionVars {};
        class populateSideMission {};
        class postStartMission {};
        class quitMission {};
        class startInfMission {};
        class startMission {};
        class startMissionPreCheck {};
        class endMission {};
    };

    class objectives {
        file = "RandFramework\Server\objectives";
        class aoCampCreator {};
        class bugRadio {};
        class commsBlocked {};
        class hackIntel {};
        class occupyHouses {};
        class setATMineEvent {};
        class setCheckpoint {};
        class setDownCivCarEvent {};
        class setDownConvoyEvent {};
        class setDownedChopperEvent {};
        class setFireFightEvent {};
        class setIEDEvent {};
        class setMedicalEvent {};
        class setOtherAreaStuff {};
        class setTargetEvent {};
        class speakToFriendlyCheckpoint {};
        class updateTask {};
    };

    class units {
        file = "RandFramework\Server\units";
        class alertNearbyUnits {};
        class backForthPatrol {};
        class badCiv {};
        class badCivAddSearchAction {};
        class badCivApplyAssingnedArmament {};
        class badCivInitialize {};
        class badCivLoop {};
        class badCivRemoveSearchAction {};
        class badCivSearch {};
        class badCivTurnHostile {};
        class badReb {};
        class buildingPatrol {};
        class civKilled {};
        class createEnemySniper {};
        class createWaitingAmbush {};
        class createWaitingSuicideBomber {};
        class findOverwatchOverride {};
        class hvtWalkAround {};
        class insKilled {};
        class interrogateOfficer {};
        class paramedicKilled {};
        class radiusPatrol {};
        class searchGoodCiv {};
        class spawnCivs {};
        class spawnPatrolUnit {};
        class speakInformant {};
        class talkRebLead {};
        class zenOccupyHouse {};
    };
};

class TRGM_GLOBAL {
    class init {
        file = "RandFramework\Global\init";
        class initGlobalVars {};
    };

    class logging {
        file = "RandFramework\Global\logging";
        class log {};
        class notify {};
        class notifyGlobal {};
        class populateLoadingWait {};
        class timerGlobal {};
    };

    class loadbalancer {
        file = "RandFramework\Global\loadbalancer";
        class loadbalancer_aggregate {};
        class loadbalancer_fpsLoop {};
        class loadbalancer_getHost {};
        class loadbalancer_init {};
        class loadbalancer_setFps {};
        class loadbalancer_setGroupOwner {};
    };

    class ace {
        file = "RandFramework\Global\ace";
        class addAceActionToObject {};
        class addAceActionToPlayer {};
        class removeAceActionFromObject {};
        class removeAceActionFromPlayer {};
    };

    class common {
        file = "RandFramework\Global\common";
        class addPlayerActionPersistent {};
        class animateAnimals {};
        class callbackWhenPlayersNearby {};
        class callNearbyPatrol {};
        class callUAVFindObjective {};
        class carryAndJoinWounded {};
        class convoy {};
        class createConvoy {};
        class createUnit {};
        class createVehicleCrew {};
        class debugDotMarker {};
        class deleteTrash {};
        class dynamicShowHide {};
        class enemyAirSupport {};
        class fireAOFlares {};
        class fireIllumFlares {};
        class fisherYatesShuffleArray {};
        class getUnitType {};
        class getVehicleType {};
        class getRealPos {};
        class hideTerrainObjects {};
        class initAmmoBox {};
        class isAceLoaded {};
        class isCbaLoaded {};
        class makeNPC {};
        class nvScript {};
        class para {};
        class paraDrop {};
        class pushObject {};
        class reinforcements {};
        class setLoadout {};
        class setCustomLoadout {};
        class setMilitiaSkill {};
        class setVehicleUpright {};
        class showIntel {};
        class supplyHelicopter {};
        class unloadDingy {};
    };

    class factions {
        file = "RandFramework\Global\factions";
        class appendAdditonalFactionData {};
        class buildEnemyFaction {};
        class buildFriendlyFaction {};
        class getFactionDataBySide {};
        class getFactionVehicle {};
        class getUnitArraysFromUnitData {};
        class getUnitData {};
        class getUnitDataByFaction {};
        class getVehicleArraysFromVehData {};
        class getVehicleData {};
        class getVehicleDataByFaction {};
        class ignoreUnit {};
        class ignoreVehicle {};
        class isAmmo {};
        class isArmed {};
        class isFuel {};
        class isMedical {};
        class isRepair {};
        class isTransport {};
        class prePopulateUnitAndVehicleData {};
    };

    class location {
        file = "RandFramework\Global\location";
        class addToDirection {}; //Can add degrees to direction to calcuate final direction
        class directionToText {};
        class findSafePos {};
        class getLocationName {};
        class randomPosIntersection {};
    };

    class reputation {
        file = "RandFramework\Global\reputation";
        class adjustBadPoints {};
        class adjustMaxBadPoints {};
        class checkBadPoints {};
        class countSpentPoints {};
        class showRepReport {};
    };

    class transport {
        file = "RandFramework\Global\transport";
        class addTransportActions {};
        class addTransportActionsPlayer {};
        class addTransportActionsVehicle {};
        class checkMissionIdActive {};
        class commsHQ {};
        class commsPilotToVehicle {};
        class commsSide {};
        class flyToBase {};
        class flyToLz {};
        class getTransportName {};
        class helicopterIsFlying {};
        class helocastLanding {};
        class isLeaderOrAdmin {};
        class isOnlyBoardCrewOnboard {};
        class selectLz {};
        class selectLzCreateBolckedAreaMarker {};
        class selectLzOnMapClick {};
        class spawnCrew {};
    };
};

class TRGM_GUI {
    class gui {
        file = "RandFramework\GUI";
        class addObjective {};
        class codeCompare {};
        class createNotification {};
        class deleteNotification {};
        class downloadData {};
        class handleNotification {};
        class initNotifications {};
        class missionSetupControlsOnChange {};
        class missionSetupControlsOnLoad {};
        class missionTypeSelection {};
        class openDialogAdvancedMissionSettings {};
        class openDialogMissionSelection {};
        class openDialogObjectiveManager {};
        class openDialogRequests {};
        class openVehicleCustomizationDialog {};
        class removeObjective {};
        class setParamsAndBegin {};
        class timeSliderOnChange {};
        class wireCompare {};
    };
};

class TRGM_CLIENT {
    class init {
        file = "RandFramework\Client\init";
        class checkKilledRange {};
        class drawKilledRanges {};
        class generalPlayerLoop {};
        class inSafeZone {};
        class isAdmin {};
        class findValidHQPosition {};
        class main {};
        class missionSelectLoop {};
        class onlyAllowDirectMapDraw {};
        class playerScripts {};
        class selectAOLocation {};
        class setNVG {};
        class startingMove {};
    };

    class camera {
        file = "RandFramework\Client\camera";
        class endCamera {};
        class introCamera {};
        class missionOverAnimation {};
        class missionSetupCamera {};
        class postStartMissionCamera {};
    };

    class supports {
        file = "RandFramework\Client\supports";
        class airSupportRequested {};
        class supplyDropCrateInit {};
        class supplyDropVehInit {};
        class supportArtiRequested {};
        class transferProviders {};
    };
};

class MISSIONS {
    class main {
        class ambushConvoyMission {
            file = "RandFramework\Missions\ambushConvoyMission.sqf";
        };
        class bombDisposalMission {
            file = "RandFramework\Missions\bombDisposalMission.sqf";
        };
        class bugRadioMission {
            file = "RandFramework\Missions\bugRadioMission.sqf";
        };
        class defuseIEDsMission {
            file = "RandFramework\Missions\defuseIEDsMission.sqf";
        };
        class destroyCacheMission {
            file = "RandFramework\Missions\destroyCacheMission.sqf";
        };
        class destroyVehiclesMission {
            file = "RandFramework\Missions\destroyVehiclesMission.sqf";
        };
        class hackDataMission {
            file = "RandFramework\Missions\hackDataMission.sqf";
        };
        class hvtMission {
            file = "RandFramework\Missions\hvtMission.sqf";
        };
        class meetingAssassinationMission {
            file = "RandFramework\Missions\meetingAssassinationMission.sqf";
        };
        class searchAndDestroyMission {
            file = "RandFramework\Missions\searchAndDestroyMission.sqf";
        };
        class secureAndResupplyMission {
            file = "RandFramework\Missions\secureAndResupplyMission.sqf";
        };
        class stealDataFromResearchVehMission {
            file = "RandFramework\Missions\stealDataFromResearchVehMission.sqf";
        };
    };
};