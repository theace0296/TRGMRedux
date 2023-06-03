// private _fnc_scriptName = "TRGM_SERVER_fnc_populateSideMission";
params [
    "_sidePos",
    "_sideType",
    "_sideMainBuilding",
    "_bIsMainObjective",
    "_iTaskIndex",
    ["_allowFriendlyIns", false],
    ["_ForceCivsOnly", false]
];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

[format ["Mission Setup: Task: %1 - Populating Side Mission", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, 50]; };

call TRGM_SERVER_fnc_initMissionVars;

// percent range is 50-95
private _fnc_setPopulateSideMissionCompletionPercent = {
    private _percent = _this # 0;
    private _message = _this # 1;
    [format ["Mission Setup: Task: %1 - Populating Side Mission - %2", _iTaskIndex, _message], true] call TRGM_GLOBAL_fnc_log;
    if (!(isNil "TRGM_VAR_GenerateMissionPercentCompletions") && TRGM_VAR_GenerateMissionPercentCompletions isEqualType []) then { TRGM_VAR_GenerateMissionPercentCompletions set [_iTaskIndex, _percent]; };
};

private _dAngleAdustPerLoop = 0;
private _bHasVehicle = false;

TRGM_VAR_AODetails pushBack [_iTaskIndex,0,0,0,false,0,0];
publicVariable "TRGM_VAR_AODetails";

private _bFriendlyInsurgents = selectRandom TRGM_VAR_bFriendlyInsurgents;
private _bThisMissionCivsOnly = false;
private _InsurgentSide = TRGM_VAR_EnemySide;
if (_bFriendlyInsurgents) then {
    _InsurgentSide = TRGM_VAR_FriendlySide;
    TRGM_VAR_ClearedPositions pushBack [_sidePos];
    publicVariable "TRGM_VAR_ClearedPositions";
};
if (_bIsMainObjective) then {
    _InsurgentSide = TRGM_VAR_EnemySide;
    _bFriendlyInsurgents = false; //if main need to make sure not friendly insurgents
    _bThisMissionCivsOnly = false;
};

_bThisMissionCivsOnly = selectRandom TRGM_VAR_bCivsOnly;
private _bTownBigenoughForFriendlyInsurgants = true;
private _allBuildingsNearAO = nearestObjects [_sidePos, TRGM_VAR_BasicBuildings, 100];
private _allBuildingsNearAOCount = count _allBuildingsNearAO;
if (_allBuildingsNearAOCount <= TRGM_VAR_iBuildingCountToAllowCivsAndFriendlyInformants) then {
    _bThisMissionCivsOnly = false;
    _bTownBigenoughForFriendlyInsurgants = false;
};
if (!_bTownBigenoughForFriendlyInsurgants && _bFriendlyInsurgents) then {
    _InsurgentSide = TRGM_VAR_EnemySide;
    _bFriendlyInsurgents = false;
};
if (!_allowFriendlyIns) then {
    _InsurgentSide = TRGM_VAR_EnemySide;
    _bFriendlyInsurgents = false;
};

if (_ForceCivsOnly) then {
    _bThisMissionCivsOnly = true;
};

private _randomChance = {random 1 > .80};
if (call TRGM_GETTER_fnc_bMoreEnemies) then {
    _randomChance = {random 1 > .65};
    _bThisMissionCivsOnly = false;
    _InsurgentSide = TRGM_VAR_EnemySide;
    _bFriendlyInsurgents = false;
};

if ((_sideType isEqualTo 7 || _sideType isEqualTo 5) && _bFriendlyInsurgents) then { //if mission is kill officer or kill officer and in fridnldy area then make him prisoner
    private _sOfficerName = format["objInformant%1",_iTaskIndex];
    private _officerObject = missionNamespace getVariable [_sOfficerName , objNull];
    _officerObject disableAI "anim";
    _officerObject switchMove "Acts_ExecutionVictim_Loop";
    _officerObject disableAI "anim";
    _officerObject setCaptive true;
    _officerObject setVariable ["StopWalkScript", true];
    private _allpositionsMainBuiding = _sideMainBuilding buildingPos -1;
    _officerObject setPosATL (selectRandom _allpositionsMainBuiding);
    removeAllWeapons _officerObject;
};
if (_sideType isEqualTo 4) then { //if mission is informant, then dont be walkig around
    private _sInformantName = format["objInformant%1",_iTaskIndex];
    private _InformantObject = missionNamespace getVariable [_sInformantName , objNull];
    _InformantObject setVariable ["StopWalkScript", true];
    private _allpositionsMainBuiding = _sideMainBuilding buildingPos -1;
    _InformantObject setPosATL (selectRandom _allpositionsMainBuiding);
};

if ((call TRGM_GETTER_fnc_bAllowAOFires) && (call _randomChance) && !_bThisMissionCivsOnly) then {
    private _fireRootx = ([_sideMainBuilding] call TRGM_GLOBAL_fnc_getRealPos) select 0;
    private _fireRooty = ([_sideMainBuilding] call TRGM_GLOBAL_fnc_getRealPos) select 1;

    private _firePos1 = [_fireRootx+5+(floor random 15),_fireRooty+5+(floor random 15)];
    private _objFlame1 = "test_EmptyObjectForFireBig" createVehicle _firePos1;
    if (isOnRoad _firePos1) then {selectRandom TRGM_VAR_WreckCarClasses createVehicle ([_objFlame1] call TRGM_GLOBAL_fnc_getRealPos);};

    if (call _randomChance) then {
        private _firePos2 = [_fireRootx-5-(floor random 15),_fireRooty-5-(floor random 15)];
        private _objFlame2 = "test_EmptyObjectForFireBig" createVehicle _firePos2;
        if (isOnRoad _firePos2) then {selectRandom TRGM_VAR_WreckCarClasses createVehicle ([_objFlame2] call TRGM_GLOBAL_fnc_getRealPos);};
    };

    if (call _randomChance) then {
        private _firePos3 = [_fireRootx+5+(floor random 15),_fireRooty-5-(floor random 15)];
        private _objFlame3 = "test_EmptyObjectForFireBig" createVehicle _firePos3;
        if (isOnRoad _firePos3) then {selectRandom TRGM_VAR_WreckCarClasses createVehicle ([_objFlame3] call TRGM_GLOBAL_fnc_getRealPos);};

    };
    if (call _randomChance) then {
        private _firePos4 = [_fireRootx-5-(floor random 15),_fireRooty+5+(floor random 15)];
        private _objFlame4 = "test_EmptyObjectForFireBig" createVehicle _firePos4;
        if (isOnRoad _firePos4) then {selectRandom TRGM_VAR_WreckCarClasses createVehicle ([_objFlame4] call TRGM_GLOBAL_fnc_getRealPos);};
    };
};

//if main var to set friendly insurg and also, if our random selction above plus 25/75 chance is true, then the units will be dressed as insurgents (player will not know if friendly of enemy)
TRGM_VAR_ToUseMilitia_Side = false; publicVariable "TRGM_VAR_ToUseMilitia_Side";
if ((_bThisMissionCivsOnly || (!_bIsMainObjective && random 1 < .25))) then {
    TRGM_VAR_ToUseMilitia_Side = true; publicVariable "TRGM_VAR_ToUseMilitia_Side";
};

TRGM_VAR_sideAllBuildingPos = _sideMainBuilding buildingPos -1;
private _inf1X = _sidePos select 0;
private _inf1Y = _sidePos select 1;

private _trgCustomAIScript = createTrigger ["EmptyDetector", _sidePos];
_trgCustomAIScript setVariable ["DelMeOnNewCampaignDay",true];
_trgCustomAIScript setTriggerArea [1250, 1250, 0, false];
_trgCustomAIScript setTriggerActivation [TRGM_VAR_FriendlySideString, format["%1 D", TRGM_VAR_EnemySideString], true];
_trgCustomAIScript setTriggerStatements ["this && {(time - TRGM_VAR_TimeSinceLastSpottedAction) > (call TRGM_GETTER_fnc_iGetSpottedDelay)}", format["nul = [%1, %2, %3, thisTrigger, thisList] spawn TRGM_GLOBAL_fnc_callNearbyPatrol;",str(_sidePos),_iTaskIndex, _bIsMainObjective], ""];

//Create extra detected trigger for more reinforcements
if (call TRGM_GETTER_fnc_bMoreReinforcements) then {
    private _trgCustomAIScript2 = createTrigger ["EmptyDetector", _sidePos];
    _trgCustomAIScript2 setVariable ["DelMeOnNewCampaignDay",true];
    _trgCustomAIScript2 setTriggerArea [1250, 1250, 0, false];
    _trgCustomAIScript2 setTriggerActivation [TRGM_VAR_FriendlySideString, format["%1 D", TRGM_VAR_EnemySideString], true];
    _trgCustomAIScript2 setTriggerStatements ["this && {(time - TRGM_VAR_TimeSinceLastSpottedAction) > (call TRGM_GETTER_fnc_iGetSpottedDelay * 1.5)}", format["nul = [%1, %2, %3, thisTrigger, thisList] spawn TRGM_GLOBAL_fnc_callNearbyPatrol; nul = [true, %1] spawn TRGM_SERVER_fnc_alertNearbyUnits;",str(_sidePos),_iTaskIndex, _bIsMainObjective], ""];
};

TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n\ntrendFunctions.sqf : _bFriendlyInsurgents: %1 - _bThisMissionCivsOnly: %2 ",str(_bFriendlyInsurgents),str(_bThisMissionCivsOnly)];

if (!_bFriendlyInsurgents) then {
    if (!_bThisMissionCivsOnly) then {

        private _minimission = call TRGM_GETTER_fnc_bMiniMissions;
        TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n\ntrendFunctions.sqf : inside populate enemy -  _bFriendlyInsurgents: %1 - _bThisMissionCivsOnly: %2 ",str(_bFriendlyInsurgents),str(_bThisMissionCivsOnly)];
        //Spawn patrol
        //if main need a couple of these and always have 2 or 3

        if (call _randomChance) then {
            [52, "Adding sniper positions"] call _fnc_setPopulateSideMissionCompletionPercent;
            [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_createEnemySniper; }, [_sidePos]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
        };
        private _bHasPatrols = false;
        if (_bIsMainObjective) then {_bHasPatrols = true};

        _bSmallerAllOverPatrols = random 1 < .50 || TRGM_VAR_PatrolType isEqualTo 1 || TRGM_VAR_PatrolType isEqualTo 2; //if single mission and random 50/50, or if forced by custom mission

        if (_minimission) then {
            if (random 1 < .50) then {
                if (random 1 < .50) then {
                    [53, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_buildingPatrol; }, [_sidePos,250 + (floor random 100),[2,3],true,TRGM_VAR_EnemySide, 10]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                }
                else {
                    [53, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [300,0],180 + (floor random 20),[2,3],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
            };
        }
        else {
            if (_bSmallerAllOverPatrols) then {
                _bHasPatrols = true;
                private _patrolUnitCounts = [2,3];
                if (TRGM_VAR_PatrolType isEqualTo 2) then {
                    _patrolUnitCounts = [4,4,4,4,4,4,5,5,5,5,5,5];
                };

                if (_bIsMainObjective) then {
                    [54, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_buildingPatrol; }, [_sidePos,250 + (floor random 400),_patrolUnitCounts,true,TRGM_VAR_EnemySide, 10]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [55, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_buildingPatrol; }, [_sidePos,250 + (floor random 100),_patrolUnitCounts,true,TRGM_VAR_EnemySide, 10]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [56, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [300,0],180 + (floor random 20),_patrolUnitCounts,true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [57, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [300,90],180 + (floor random 20),_patrolUnitCounts,true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [58, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [300,180],180 + (floor random 20),_patrolUnitCounts,true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [59, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [300,270],180 + (floor random 20),_patrolUnitCounts,true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [60, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [600,45],200 + (floor random 50),_patrolUnitCounts,true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [61, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [600,135],200 + (floor random 50),_patrolUnitCounts,true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [62, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [600,225],200 + (floor random 50),_patrolUnitCounts,true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [63, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [600,315],200 + (floor random 50),_patrolUnitCounts,true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                }
                else {
                    [54, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_buildingPatrol; }, [_sidePos,250 + (floor random 100),[2,3],true,TRGM_VAR_EnemySide, 10]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [56, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_buildingPatrol; }, [_sidePos,800 + (floor random 100),[2,3],true,TRGM_VAR_EnemySide, 200]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [58, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [400,0],250 + (floor random 20),[2,3],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [60, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [400,90],250 + (floor random 20),[2,3],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [61, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [400,180],250 + (floor random 20),[2,3],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;

                    [63, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos getPos [400,270],250 + (floor random 20),[2,3],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };


            }
            else {
                if (_bIsMainObjective) then {
                    [64, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos,15 + (floor random 150),[2,3],false,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                    if ((call TRGM_GETTER_fnc_bAllowLargerPatrols && _bIsMainObjective)) then {
                        [64, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                        [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos,15 + (floor random 150),[2,3],false,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                    };
                };
                if (call _randomChance) then {
                    //not adding a teamleader to small patrol as we need long dist to have teamleader for CallNearbyPatrols (3rd param for RadiusPatrol is false)
                    [64, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos,15 + (floor random 50),[2,3],false,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                    _bHasPatrols = true
                };


                //Spawn wide patrol
                //if main, need a couple of these and always have 2 or 3
                if (_bIsMainObjective) then {
                    [65, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos,500 + (floor random 250),[7,8,9],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                }
                else {
                    if (call _randomChance) then {
                        [65, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                        [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos,500 + (floor random 250),[4,5,6],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                        _bHasPatrols = true
                    };
                };

                if ((_bIsMainObjective && (call _randomChance))) then {
                    if (call TRGM_GETTER_fnc_bAllowLargerPatrols && _bIsMainObjective) then {
                        [66, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                        [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_radiusPatrol; }, [_sidePos,900 + (floor random 250),[7,8,9,10],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                    };
                };



                //Spawn patrol to move from building to building
                if (_bIsMainObjective || (call _randomChance)) then {
                    [67, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_buildingPatrol; }, [_sidePos,1000 + (floor random 500),[3,4,5],true,TRGM_VAR_EnemySide, 10]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                    _bHasPatrols = true
                };
                if (_bIsMainObjective && call TRGM_GETTER_fnc_bAllowLargerPatrols) then {
                    [68, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_buildingPatrol; }, [_sidePos,1000 + (floor random 500),[3,4,5],true,TRGM_VAR_EnemySide, 10]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };

                //Spawn distant patrol ready to move in (will need to spawn trigger)
                if (_bIsMainObjective || (call _randomChance) ) then {
                    [69, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_backForthPatrol; }, [_sidePos,1000 + (floor random 500),[5,6],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                    _bHasPatrols = true
                };
                if (_bIsMainObjective && call TRGM_GETTER_fnc_bAllowLargerPatrols) then {
                    [70, "Adding patrol"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_backForthPatrol; }, [_sidePos,1000 + (floor random 500),[5,6,7],true,TRGM_VAR_EnemySide]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
            };
        };

        private _chanceOfMortorTeam = .50;
        if (_bIsMainObjective) then {_chanceOfMortorTeam = 1};
        if (_minimission) then {_chanceOfMortorTeam = .15;};
        //Spawn Mortar team
        if (random 1 < _chanceOfMortorTeam || (call _randomChance)) then {
            private _flatPos = _sidePos;
            _flatPos = [_sidePos , 10, 200, 8, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[_sidePos,_sidePos]] call TRGM_GLOBAL_fnc_findSafePos;
            private _vehicle = createVehicle [selectRandom (call sMortarToUse), _flatPos, [], 0, "NONE"];
            private _group = createGroup [TRGM_VAR_EnemySide, true];
            [_group, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
            [_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
        };

        //Spawn vehicle
        private _chanceOfVeh = .50;
        if (_bIsMainObjective) then {_chanceOfVeh = 1};
        if (_minimission) then {_chanceOfVeh = .15;};
        //if main, spawn 1 or two, and also, spawn 2 or three in larger radius
        if (random 1 < _chanceOfVeh || (call _randomChance)) then {
            if (_minimission) then {
                private _flatPos = [_sidePos , 10, 200, 8, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],(call sTank1ArmedCarToUse)] call TRGM_GLOBAL_fnc_findSafePos;
                private _vehicle = createVehicle [(call sTank1ArmedCarToUse), _flatPos, [], 0, "NONE"];
                private _group = createGroup [TRGM_VAR_EnemySide, true];
                [_group, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                [_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
            } else {
                private _vehiclesToUse = [(call sTank1ArmedCarToUse),(call sTank2APCToUse),(call sTank3TankToUse)];
                if (_bIsMainObjective && (call _randomChance)) then {
                    private _flatPos = [_sidePos , 10, 200, 8, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom _vehiclesToUse] call TRGM_GLOBAL_fnc_findSafePos;
                    private _vehicle = createVehicle [selectRandom _vehiclesToUse, _flatPos, [], 0, "NONE"];
                    private _group = createGroup [TRGM_VAR_EnemySide, true];
                    [_group, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                    [_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
                };
                if (call TRGM_GETTER_fnc_bAllowLargerPatrols && _bIsMainObjective && (call _randomChance)) then {
                    private _flatPos = [_sidePos , 300, 1000, 8, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom _vehiclesToUse] call TRGM_GLOBAL_fnc_findSafePos;
                    private _vehicle = createVehicle [selectRandom _vehiclesToUse, _flatPos, [], 0, "NONE"];
                    private _group = createGroup [TRGM_VAR_EnemySide, true];
                    [_group, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                    [_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
                };
                if (call TRGM_GETTER_fnc_bAllowLargerPatrols && _bIsMainObjective) then {
                    private _flatPos = [_sidePos , 300, 1000, 8, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom _vehiclesToUse] call TRGM_GLOBAL_fnc_findSafePos;
                    private _vehicle = createVehicle [selectRandom _vehiclesToUse, _flatPos, [], 0, "NONE"];
                    private _group = createGroup [TRGM_VAR_EnemySide, true];
                    [_group, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                    [_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;

                    private _flatPos = [_sidePos , 300, 1000, 8, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom _vehiclesToUse] call TRGM_GLOBAL_fnc_findSafePos;
                    private _vehicle = createVehicle [selectRandom _vehiclesToUse, _flatPos, [], 0, "NONE"];
                    private _group = createGroup [TRGM_VAR_EnemySide, true];
                    [_group, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                    [_group] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;

                };
            };
            _bHasVehicle = true;
        };
        if (!_minimission) then {
            if (_bIsMainObjective || (call _randomChance)) then {
                private _vehiclesToUse = [(call sTank1ArmedCarToUse),(call sTank2APCToUse),(call sTank3TankToUse)];
                private _flatPos = [_sidePos , 10, 200, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom _vehiclesToUse] call TRGM_GLOBAL_fnc_findSafePos;
                private _vehOneGroup = createGroup [TRGM_VAR_EnemySide, true];
                private _vehicle = createVehicle [selectRandom _vehiclesToUse, _flatPos, [], 0, "NONE"];
                [_vehOneGroup, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                [_vehOneGroup, _sidePos, 2000 ] call bis_fnc_taskPatrol;
                _vehOneGroup setSpeedMode "LIMITED";
                [_vehOneGroup] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;

                if (_bIsMainObjective && (call _randomChance)) then {
                    private _flatPos = [_sidePos , 10, 200, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom _vehiclesToUse] call TRGM_GLOBAL_fnc_findSafePos;
                    private _vehTwoGroup = createGroup [TRGM_VAR_EnemySide, true];
                    private _vehicle = createVehicle [selectRandom _vehiclesToUse, _flatPos, [], 0, "NONE"];
                    [_vehTwoGroup, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                    [_vehTwoGroup, _sidePos, 2000 ] call bis_fnc_taskPatrol;
                    _vehTwoGroup setSpeedMode "LIMITED";
                    [_vehTwoGroup] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
                };
                _bHasVehicle = true;
            };
        };

        if (_bIsMainObjective || (call _randomChance)) then {
            if (!_minimission || (_minimission && (call _randomChance))) then {
                private _flatPos = [_sidePos , 10, 500, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom (call UnarmedScoutVehicles)] call TRGM_GLOBAL_fnc_findSafePos;
                private _vehScountOneGroup = createGroup [TRGM_VAR_EnemySide, true];
                private _vehicle = createVehicle [selectRandom (call UnarmedScoutVehicles), _flatPos, [], 0, "NONE"];
                [_vehScountOneGroup, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                [_vehScountOneGroup, _sidePos, 3000 ] call bis_fnc_taskPatrol;
                _vehScountOneGroup setSpeedMode "LIMITED";
                [_vehScountOneGroup] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
            };
            if (_bIsMainObjective && (call _randomChance)) then {
                private _flatPos = [_sidePos , 10, 500, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom (call UnarmedScoutVehicles)] call TRGM_GLOBAL_fnc_findSafePos;
                private _vehScoutTwoGroup = createGroup [TRGM_VAR_EnemySide, true];
                private _vehicle = createVehicle [selectRandom (call UnarmedScoutVehicles), _flatPos, [], 0, "NONE"];
                [_vehScoutTwoGroup, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                [_vehScoutTwoGroup, _sidePos, 2000 ] call bis_fnc_taskPatrol;
                _vehScoutTwoGroup setSpeedMode "LIMITED";
                [_vehScoutTwoGroup] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
            };
            _bHasVehicle = true;

        };

        if (_minimission) then {
            if (call _randomChance) then {
                [74, "Occupying buildings with units"] call _fnc_setPopulateSideMissionCompletionPercent;
                [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_occupyHouses; }, [_sidePos,100,[1,2,3],TRGM_VAR_EnemySide,_bThisMissionCivsOnly]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
            };
        } else {
            //if main then 100% occupie houses, and increase number and range
            [71, "Occupying buildings with units"] call _fnc_setPopulateSideMissionCompletionPercent;
            [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_occupyHouses; }, [_sidePos,10,[1],TRGM_VAR_EnemySide,_bThisMissionCivsOnly]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
            if (_bIsMainObjective || (call _randomChance)) then {
                [72, "Occupying buildings with units"] call _fnc_setPopulateSideMissionCompletionPercent;
                [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_occupyHouses; }, [_sidePos,200,[1,2,3],TRGM_VAR_EnemySide,_bThisMissionCivsOnly]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                [73, "Occupying buildings with units"] call _fnc_setPopulateSideMissionCompletionPercent;
                [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_occupyHouses; }, [_sidePos,500,[4,5,6],TRGM_VAR_EnemySide,_bThisMissionCivsOnly]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                if (call TRGM_GETTER_fnc_bAllowLargerPatrols && _bIsMainObjective) then {
                    [74, "Occupying buildings with units"] call _fnc_setPopulateSideMissionCompletionPercent;
                    [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_occupyHouses; }, [_sidePos,1000,[4,5,6],TRGM_VAR_EnemySide,_bThisMissionCivsOnly]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
            }
            else {
                [72, "Occupying buildings with units"] call _fnc_setPopulateSideMissionCompletionPercent;
                [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_occupyHouses; }, [_sidePos,100,[1,2],TRGM_VAR_EnemySide,_bThisMissionCivsOnly]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                [74, "Occupying buildings with units"] call _fnc_setPopulateSideMissionCompletionPercent;
                [_sidePos, 2500, { _this spawn TRGM_SERVER_fnc_occupyHouses; }, [_sidePos,1000,[1,2,3,4],TRGM_VAR_EnemySide,_bThisMissionCivsOnly]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
            };
        };


        if (!_minimission || (call _randomChance)) then {
            //Spawn nasty surprise (AAA, IEDs, wider patrol)
            if ((_bIsMainObjective && (call _randomChance)) || (!_bIsMainObjective && (call _randomChance))) then {
                if ((call sAAAVehMilitia) != "") then {
                    private _flatPos = [_sidePos , 10, 200, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],(call sAAAVehToUse)] call TRGM_GLOBAL_fnc_findSafePos;
                    private _AAAGroup = createGroup [TRGM_VAR_EnemySide, true];
                    private _vehicle = createVehicle [(call sAAAVehToUse), _flatPos, [], 0, "NONE"];
                    [_AAAGroup, _vehicle] call TRGM_GLOBAL_fnc_createVehicleCrew;
                    {
                        _x setskill ["aimingAccuracy",1];
                        _x setskill ["aimingShake",1];
                        _x setskill ["aimingSpeed",1];
                        _x setskill ["spotDistance",1];
                        _x setskill ["spotTime",0.7];
                        _x setskill ["courage",1];
                        _x setskill ["commanding",0.9];
                        _x setskill ["general",1];
                        _x setskill ["endurance",1.0];
                        _x setskill ["reloadSpeed",0.5];
                    } forEach units _AAAGroup;
                    [_AAAGroup] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
                };
            };
        };


        if (TRGM_VAR_MainIsHidden || _minimission) then {
            //spawn wide map checkpoints
            private _iCount = ([10] call TRGM_GETTER_fnc_iMoreEnemies);
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _checkPointGuidePos = _sidePos;
                private _thisAreaRange = 20000;
                private _flatPos = [_checkPointGuidePos , 400, _thisAreaRange, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = false;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = (call _randomChance);
                    private _thisIsDirectionAwayFromAO = true;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,false,(call UnarmedScoutVehicles),50]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [76, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;
        };

        if (_minimission) then {
            //spawn inner random sentrys
            private _iCount = ([30] call TRGM_GETTER_fnc_iMoreEnemies);
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _thisAreaRange = 50;
                private _checkPointGuidePos = _sidePos;
                private _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;

                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = false;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = false;
                    private _thisIsDirectionAwayFromAO = true;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,false,(call UnarmedScoutVehicles),50]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [78, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;

            _iCount = 1;
            if (!_bIsMainObjective) then {_iCount = 2;};
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _thisAreaRange = 500;
                private _checkPointGuidePos = _sidePos getPos [1250, floor(random 360)];
                private _flatPos = [_checkPointGuidePos , 0, 500, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = true;
                    private _thisSide = TRGM_VAR_FriendlySide;
                    private _thisUnitTypes = (call FriendlyCheckpointUnits);
                    private _thisAllowBarakade = true;
                    private _thisIsDirectionAwayFromAO = false;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call FriendlyScoutVehicles),500]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [80, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;
        } else {
            //spawn inner random sentrys
            private _iCount = ([25] call TRGM_GETTER_fnc_iMoreEnemies);
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _thisAreaRange = 50;
                private _checkPointGuidePos = _sidePos;
                private _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;

                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = false;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = false;
                    private _thisIsDirectionAwayFromAO = true;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,false,(call UnarmedScoutVehicles),50]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [76, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;

            //spawn inner checkpoints
            _iCount = ([25] call TRGM_GETTER_fnc_iMoreEnemies);
            if (!_bIsMainObjective) then {_iCount = ([35] call TRGM_GETTER_fnc_iMoreEnemies);};
            if ((!_bIsMainObjective && !_bHasPatrols) || (call _randomChance)) then {_iCount = ([45] call TRGM_GETTER_fnc_iMoreEnemies);};
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _thisAreaRange = 50;
                private _checkPointGuidePos = _sidePos;
                private _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = true;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = true;
                    private _thisIsDirectionAwayFromAO = true;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [78, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;

            //spawn outer but close surrunding checkpoints
            _iCount = ([15] call TRGM_GETTER_fnc_iMoreEnemies);
            if (!_bIsMainObjective) then {_iCount = ([30] call TRGM_GETTER_fnc_iMoreEnemies);};
            if ((!_bIsMainObjective && !_bHasPatrols) || (call _randomChance)) then {_iCount = ([40] call TRGM_GETTER_fnc_iMoreEnemies);};
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _thisAreaRange = 75;
                private _checkPointGuidePos = _sidePos getPos [250, floor(random 360)];
                private _flatPos = [_checkPointGuidePos , 0, 75, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = true;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = true;
                    private _thisIsDirectionAwayFromAO = true;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),300]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [80, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;

            //spawn outer far checkpoints
            _iCount = ([35] call TRGM_GETTER_fnc_iMoreEnemies);
            if (!_bIsMainObjective) then {_iCount = ([45] call TRGM_GETTER_fnc_iMoreEnemies);};
            if ((!_bIsMainObjective && !_bHasPatrols) || (call _randomChance)) then {_iCount = ([55] call TRGM_GETTER_fnc_iMoreEnemies);};
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _thisAreaRange = 250;
                private _checkPointGuidePos = _sidePos getPos [1000, floor(random 360)];
                private _flatPos = [_checkPointGuidePos , 0, 250, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = true;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = true;
                    private _thisIsDirectionAwayFromAO = true;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),500]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [82, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;

            //spawn outer far sentrys
            _iCount = ([45] call TRGM_GETTER_fnc_iMoreEnemies);
            if (!_bIsMainObjective) then {_iCount = ([55] call TRGM_GETTER_fnc_iMoreEnemies);};
            if ((!_bIsMainObjective && !_bHasPatrols) || (call _randomChance)) then {_iCount = ([65] call TRGM_GETTER_fnc_iMoreEnemies);};
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _thisAreaRange = 250;
                private _checkPointGuidePos = _sidePos getPos [1200, floor(random 360)];
                private _flatPos = [_checkPointGuidePos , 0, 250, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = false;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = false;
                    private _thisIsDirectionAwayFromAO = true;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,false,(call UnarmedScoutVehicles),500]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [84, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;


            //future update... player faction here, or frienly rebels
            //spawn outer nearish friendly checkpoint
            _iCount = 1;
            if (!_bIsMainObjective || (call _randomChance)) then {_iCount = 2;};
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            waitUntil {
                _iCount = _iCount - 1;
                private _thisAreaRange = 500;
                private _checkPointGuidePos = _sidePos getPos [1250, floor(random 360)];
                private _flatPos = [_checkPointGuidePos , 0, 500, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = true;
                    private _thisSide = TRGM_VAR_FriendlySide;
                    private _thisUnitTypes = (call FriendlyCheckpointUnits);
                    private _thisAllowBarakade = true;
                    private _thisIsDirectionAwayFromAO = false;
                    [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call FriendlyScoutVehicles),500]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
                };
                sleep 0.1;
                _iCount <= 0;
            };
            [86, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;
        };

        //Spawn Mil occupy units
        private _MilSearchDistFromCent = 3000;
        //occupy miletary building
        private _allMilBuildings = nearestObjects [_sidePos, TRGM_VAR_MilBuildings, _MilSearchDistFromCent];
        private _iCount = 0;
        private _milOccupyOdds = [true,false,false];
        if (_bIsMainObjective) then {
            _milOccupyOdds = [true,false];
        };
        if (call _randomChance) then {
            _milOccupyOdds = [true];
        };
        if (!(isNil "_allMilBuildings") && count _allMilBuildings > 0) then {
            {
                private _thisMilBuilPos = getPos _x;
                private _distanceFromBase = getMarkerPos "mrkHQ" distance getPos _x;
                if (SelectRandom _milOccupyOdds && _distanceFromBase > TRGM_VAR_BaseAreaRange && !(_thisMilBuilPos in TRGM_VAR_OccupiedHousesPos)) then {
                    _iCount = _iCount + 1;
                    private _MilGroup1 = createGroup [TRGM_VAR_EnemySide, true];
                    private _objMilUnit1 = [_MilGroup1, selectRandom[(call sRiflemanToUse),(call sMachineGunManToUse)],[-1000,0,0],[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    private _objMilUnit2 = [_MilGroup1, selectRandom[(call sRiflemanToUse),(call sMachineGunManToUse)],[-1002,0,0],[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    private _objMilUnit3 = [_MilGroup1, selectRandom[(call sRiflemanToUse),(call sMachineGunManToUse)],[-1003,0,0],[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    [_MilGroup1] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
                    TRGM_VAR_OccupiedHousesPos = TRGM_VAR_OccupiedHousesPos + [_thisMilBuilPos];
                    [getPos _x, [_objMilUnit1,_objMilUnit2,_objMilUnit3], -1, true, false,true] spawn TRGM_SERVER_fnc_zenOccupyHouse;
                    sleep 0.1;
                    _objMilUnit1 setUnitPos "up";
                    _objMilUnit2 setUnitPos "up";
                    _objMilUnit3 setUnitPos "up";
                    {deleteVehicle _x} forEach nearestObjects [[-1000,0,0], ["all"], 100];

                    private _ParkedCar = nil;
                    if (call _randomChance) then {
                        private _flatPos = [getpos _x , 0, 20, 10, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[getpos _x,getpos _x],selectRandom (call UnarmedScoutVehicles)] call TRGM_GLOBAL_fnc_findSafePos;
                        _ParkedCar = selectRandom (call UnarmedScoutVehicles) createVehicle _flatPos;
                        _ParkedCar setDir (floor(random 360));
                    };

                    if (call _randomChance) then {
                        private _MilGroup4 = createGroup [TRGM_VAR_EnemySide, true];
                        private _sCheckpointGuyName = format["objMilGuyName%1",(floor(random 999999))];
                        private _pos5 = [getpos _x , 0, 30, 5, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[getpos _x,getpos _x]] call TRGM_GLOBAL_fnc_findSafePos;
                        private _guardUnit5 = [_MilGroup4, (call sRiflemanToUse),_pos5,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                        [_MilGroup4] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;
                        _guardUnit5 setVariable [_sCheckpointGuyName, _guardUnit5, true];
                        missionNamespace setVariable [_sCheckpointGuyName, _guardUnit5];
                        TRGM_LOCAL_fnc_walkingGuyLoop = {
                            private _objManName = _this select 0;
                            private _thisInitPos = _this select 1;
                            private _objMan = missionNamespace getVariable _objManName;

                            group _objMan setSpeedMode "LIMITED";
                            group _objMan setBehaviour "SAFE";

                            waitUntil {
                                private _walkAroundHandle = [_objManName,_thisInitPos,_objMan,35] spawn TRGM_SERVER_fnc_hvtWalkAround;
                                sleep 2;
                                waitUntil {sleep 1; speed _objMan < 0.5};
                                sleep 10;
                                waitUntil { sleep 1; scriptDone _walkAroundHandle; };
                                sleep 5;
                                !(alive(_objMan)) || behaviour _objMan isNotEqualTo "SAFE";
                            };
                        };
                        [_sCheckpointGuyName,_pos5] spawn TRGM_LOCAL_fnc_walkingGuyLoop;
                    };
                    //because we have a base, we see if a helipad is aviable for an attack chopper
                    private _HeliPads = nearestObjects [getPos _x, ["Land_HelipadCircle_F","Land_HelipadSquare_F"], 200];
                    if (count _HeliPads > 0 && !TRGM_VAR_bBaseHasChopper && (call _randomChance)) then {
                        TRGM_VAR_baseHeliPad =  selectRandom _HeliPads; publicVariable "TRGM_VAR_baseHeliPad";
                        TRGM_VAR_bBaseHasChopper =  true; publicVariable "TRGM_VAR_bBaseHasChopper";
                        private _BaseChopperGroup = createGroup [TRGM_VAR_EnemySide, true];
                        private _EnemyBaseChopper = selectRandom (call EnemyBaseChoppers) createVehicle getPosATL TRGM_VAR_baseHeliPad;
                        _EnemyBaseChopper setDir direction TRGM_VAR_baseHeliPad;
                        [_BaseChopperGroup, call sEnemyHeliPilotToUse, [(getPos TRGM_VAR_baseHeliPad select 0)+10,(getPos TRGM_VAR_baseHeliPad select 1)+10], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                        [_BaseChopperGroup, call sEnemyHeliPilotToUse, [(getPos TRGM_VAR_baseHeliPad select 0)+11,(getPos TRGM_VAR_baseHeliPad select 1)+10], [], 0, "NONE"] call TRGM_GLOBAL_fnc_createUnit;
                        {
                            [_x,"STAND","ASIS"] call BIS_fnc_ambientAnimCombat;
                        } forEach units _BaseChopperGroup;
                        [_BaseChopperGroup] call TRGM_GLOBAL_fnc_loadbalancer_setGroupOwner;

                        //EnemyBaseChopperPilot = getNEAREST (call sEnemyHeliPilot) to chopper
                        private _EnemyBaseChopperPilots = nearestObjects [getPos TRGM_VAR_baseHeliPad, [(call sEnemyHeliPilotToUse)], 250];
                        TRGM_VAR_EnemyBaseChopperPilot =  _EnemyBaseChopperPilots select 0; publicVariable "TRGM_VAR_EnemyBaseChopperPilot";
                        // _BaseChopperGroup

                    };
                };
                if (_iCount > 10) exitWith {};
            } forEach _allMilBuildings;
        };

        [88, "Occupying buildings with units"] call _fnc_setPopulateSideMissionCompletionPercent;
    } else { //else if _bThisMissionCivsOnly
        //spawn inner checkpoints
        private _iCount = ([50] call TRGM_GETTER_fnc_iMoreEnemies);
        if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
        waitUntil {
            _iCount = _iCount - 1;
            private _thisAreaRange = 50;
            private _checkPointGuidePos = _sidePos;
            private _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
            if !(_flatPos isEqualTo _checkPointGuidePos) then {
                private _thisPosAreaOfCheckpoint = _flatPos;
                private _thisRoadOnly = true;
                private _thisSide = TRGM_VAR_EnemySide;
                private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                private _thisAllowBarakade = true;
                private _thisIsDirectionAwayFromAO = true;
                [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
            };
            sleep 0.1;
            _iCount <= 0;
        };
        [58, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;

        //spawn inner sentry
        _iCount = ([50] call TRGM_GETTER_fnc_iMoreEnemies);
        if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
        waitUntil {
            _iCount = _iCount - 1;
            private _thisAreaRange = 50;
            private _checkPointGuidePos = _sidePos;
            private _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
            if !(_flatPos isEqualTo _checkPointGuidePos) then {
                private _thisPosAreaOfCheckpoint = _flatPos;
                private _thisRoadOnly = false;
                private _thisSide = TRGM_VAR_EnemySide;
                private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                private _thisAllowBarakade = false;
                private _thisIsDirectionAwayFromAO = true;
                [_thisPosAreaOfCheckpoint, 2500, { _this spawn TRGM_SERVER_fnc_setCheckpoint; }, [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100]] spawn TRGM_GLOBAL_fnc_callbackWhenPlayersNearby;
            };
            sleep 0.1;
            _iCount <= 0;
        };
        [76, "Adding checkpoints"] call _fnc_setPopulateSideMissionCompletionPercent;
    };
} else {
    [86, "Spawning civilians"] call _fnc_setPopulateSideMissionCompletionPercent;
    [_sidePos,200,true] spawn TRGM_SERVER_fnc_spawnCivs; //3rd param of true says these are rebels and function will set rebels instead of civs
    private _lapPos = _sidePos getPos [50, 180];
    private _markerFriendlyRebs = createMarker [format["mrkFriendlyRebs%1",_iTaskIndex], _lapPos];
    _markerFriendlyRebs setMarkerShape "ICON";
    _markerFriendlyRebs setMarkerType "hd_dot";
    _markerFriendlyRebs setMarkerText (localize "STR_TRGM2_trendFunctions_OccupiedByFriendRebel");
};

[92, "Finishing up"] call _fnc_setPopulateSideMissionCompletionPercent;

if (call _randomChance) then {
    private _iAnimalCount = 0;
    private _flatPosInside = [_sidePos , 0, 100, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[_sidePos,[0,0,0]]] call BIS_fnc_findSafePos;
    waitUntil {
        _iAnimalCount = _iAnimalCount + 1;
        private _myDog1 = createAgent ["Fin_random_F", _flatPosInside, [], 50, "NONE"];
        sleep 0.1;
        _myDog1 playMove "Dog_Sit";
        sleep 1;
        _iAnimalCount >= 4;
    };
};

if (call _randomChance) then {
    private _iAnimalCount = 0;
    private _flatPosInside2 = [_sidePos , 0, 100, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[_sidePos,[0,0,0]]] call BIS_fnc_findSafePos;
    waitUntil {
        _iAnimalCount = _iAnimalCount + 1;
        private _myGoat1 = createAgent ["Goat_random_F", _flatPosInside2, [], 5, "NONE"];
        sleep 0.1;
        _myGoat1 playMove "Goat_Walk";
        sleep 1;
        _iAnimalCount >= 8;
    };
};

if (call _randomChance) then {
    private _iAnimalCount = 0;
    private _flatPosInside2 = [_sidePos , 500, 1500, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[_sidePos,[0,0,0]]] call BIS_fnc_findSafePos;
    waitUntil {
        _iAnimalCount = _iAnimalCount + 1;
        private _myGoat2 = createAgent ["Goat_random_F", _flatPosInside2, [], 5, "NONE"];
        sleep 0.1;
        _myGoat2 playMove "Goat_Stop";
        sleep 1;
        _iAnimalCount >= 8;
    };
};



//Spawn IED
if (call _randomChance) then {
    private _iCount = 0;
    private _low = 2;
    private _high = 9;
    private _LoopMax = selectRandom [_low,_low,_low,_high]; //zero based
    private _IEDCount = 0;
    private _bHightlightIEDTests = false;
    //will only ever be three IEDs but if 10 is loop then we will have random rubble to confuse player
    waitUntil {
        private _flatPos = [_sidePos , 10, 80, 4, 0, 0.5, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]],[[0,0,0],[0,0,0]],selectRandom TRGM_VAR_IEDClassNames] call TRGM_GLOBAL_fnc_findSafePos;
        if (_IEDCount <= 2) then {
            private _objIED1 = selectRandom TRGM_VAR_IEDClassNames createVehicle _flatPos;
            _IEDCount = _IEDCount + 1;
        };
        if (_bHightlightIEDTests) then {
            private _test = createMarker [format["IEDMrk%1%2%3",_inf1X,_inf1Y,_iCount], _flatPos];
            _test setMarkerShape "ICON";
            _test setMarkerType "hd_dot";
            _test setMarkerText "IED";
        };
        _iCount = _iCount + 1;
        sleep 0.1;
        _iCount > _LoopMax;
    };
};


if ((call _randomChance) || _bThisMissionCivsOnly) then {
    TRGM_VAR_debugMessages = TRGM_VAR_debugMessages + format["\n\ntrendFunctions.sqf - Populate Civs : _bFriendlyInsurgents: %1 - _bThisMissionCivsOnly: %2 ",str(_bFriendlyInsurgents),str(_bThisMissionCivsOnly)];
    [format ["Mission Setup: Task: %1 - Populating Side Mission - Spawning civilians", _iTaskIndex], true] call TRGM_GLOBAL_fnc_log;
    [_sidePos,200,false] spawn TRGM_SERVER_fnc_spawnCivs;
};

[95, "Population complete"] call _fnc_setPopulateSideMissionCompletionPercent;

//Spawn AT Mine on road if not vehicles and hack data mission
if (_sideType isEqualTo 1 && random 1 < .50) then {
    private _nearestRoad = [[_inf1X,_inf1Y], 100, []] call BIS_fnc_nearestRoad;
    if !(isNil "_nearestRoad") then {
        private _roadConnectedTo = roadsConnectedTo _nearestRoad;
        if (count _roadConnectedTo > 0) then {
            private _objAT = selectRandom TRGM_VAR_ATMinesClassNames createVehicle getPosATL _nearestRoad;
        };
    };
};

true;