// private _fnc_scriptName = "TRGM_SERVER_fnc_setMedicalEvent";
params ["_posOfAO"];
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;

if (!isServer || isNil "_posOfAO") exitWith {};

call TRGM_SERVER_fnc_initMissionVars;
private _requiredItemIndex = selectRandom [0,1,2];
requiredItemsCount = [10,5,2] select _requiredItemIndex;
RequestedMedicalItem = ["FirstAidKit","FirstAidKit","Medikit"] select _requiredItemIndex;
RequestedMedicalItemName = [localize "STR_TRGM2_First_Aid_Kits", localize "STR_TRGM2_First_Aid_Kits",localize "STR_TRGM2_Medikit"] select _requiredItemIndex;

if (isClass(configFile >> "CfgPatches" >> "ace_medical")) then {
    RequestedMedicalItem = ["ACE_bloodIV","ACE_quikclot","ACE_surgicalKit"] select _requiredItemIndex;
    requiredItemsCount = [5,5,2] select _requiredItemIndex;
    RequestedMedicalItemName = [localize "STR_TRGM2_Blood_IV",localize "STR_TRGM2_Basic_Field_Dressing",localize "STR_TRGM2_Surgical_Kits"] select _requiredItemIndex;
};
publicVariable "requiredItemsCount";
publicVariable "RequestedMedicalItem";
publicVariable "RequestedMedicalItemName";

private _bloodPools = ["BloodPool_01_Large_New_F","BloodSplatter_01_Large_New_F"];
private _nearLocations = nearestLocations [_posOfAO, ["NameCity","NameCityCapital","NameVillage"], 2500];
if (TRGM_VAR_MainIsHidden) then {
    _nearLocations = nearestLocations [_posOfAO, ["NameCity","NameCityCapital","NameVillage"], 30000];
};

private _eventLocationPos = nil;
{
    private _xLocPos = locationPosition selectRandom _nearLocations;
    if (_xLocPos distance _posOfAO > 1000) then {
        private _nearestRoads = _xLocPos nearRoads 150;
        _eventLocationPos = getPos (selectRandom _nearestRoads);
    };
} forEach _nearLocations;

if (isNil "_eventLocationPos") then {
    private _nearestRoads = _posOfAO nearRoads 5000;
    if (TRGM_VAR_MainIsHidden) then {
        _nearestRoads = _posOfAO nearRoads 30000;
    };
    _eventLocationPos = getPos (selectRandom _nearestRoads);
};

if (random 1 < .20) then {
    [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingAmbush;
    if (random 1 < .33) then {
        [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
    };
};
if (random 1 < .20) then {
    [_eventLocationPos] spawn TRGM_SERVER_fnc_createWaitingSuicideBomber;
};
if (random 1 < .33) then {
    [_eventLocationPos] spawn TRGM_SERVER_fnc_createEnemySniper;
};


private _thisAreaRange = 50;
private _iteration = 1;

while {_iteration <= 2} do {
    private _nearestRoads = _eventLocationPos nearRoads _thisAreaRange;
    private _nearestRoad = nil;
    private _roadConnectedTo = nil;
    private _connectedRoad = nil;
    private _direction = nil;
    private _PosFound = false;
    private _iAttemptLimit = 5;

    while {!_PosFound && _iAttemptLimit > 0 && count _nearestRoads > 0} do {
        _nearestRoad = selectRandom _nearestRoads;
        _roadConnectedTo = roadsConnectedTo _nearestRoad;
        if (count _roadConnectedTo > 0) then {
            _connectedRoad = _roadConnectedTo select 0;
            _direction = [_nearestRoad, _connectedRoad] call BIS_fnc_DirTo;
            _PosFound = true;
        } else {
            _iAttemptLimit = _iAttemptLimit - 1;
        };
    };

    if (_PosFound) then {
        private _roadBlockPos =  getPos _nearestRoad;
        private _roadBlockSidePos = _nearestRoad getPos [10, ([_direction,90] call TRGM_GLOBAL_fnc_addToDirection)];

        private _mainVeh = createVehicle [selectRandom Ambulances,_roadBlockPos,[],0,"NONE"];
        _mainVeh setVehicleLock "LOCKED";
        private _mainVehDirection =  ([_direction,(selectRandom[0,-10,10,170,180,190])] call TRGM_GLOBAL_fnc_addToDirection);
        _mainVeh setDir _mainVehDirection;
        clearItemCargoGlobal _mainVeh;
        [
            _mainVeh,
            ["CivAmbulance",1],
            ["Door_1_source",1,"Door_2_source",0,"Door_3_source",0,"Door_4_source",1,"Hide_Door_1_source",0,"Hide_Door_2_source",0,"Hide_Door_3_source",0,"Hide_Door_4_source",0,"lights_em_hide",1,"ladder_hide",1,"spare_tyre_holder_hide",1,"spare_tyre_hide",1,"reflective_tape_hide",0,"roof_rack_hide",0,"LED_lights_hide",0,"sidesteps_hide",0,"rearsteps_hide",0,"side_protective_frame_hide",1,"front_protective_frame_hide",1,"beacon_front_hide",0,"beacon_rear_hide",0]
        ] call BIS_fnc_initVehicle;

        if (_iteration isEqualTo 1) then {
            [_mainVeh] spawn {
                private _mainVeh = _this select 0;
                while{ (alive _mainVeh)} do {
                    playSound3D ["A3\Sounds_F\sfx\radio\" + selectRandom TRGM_VAR_FriendlyRadioSounds + ".wss",_mainVeh,false,getPosASL _mainVeh,0.5,1,0];
                    sleep selectRandom [10,15,20,30];
                };
            };

            if (TRGM_VAR_MainIsHidden) then {
                //Here... store location and type, so can learn this from intel
            };

            private _markerEventMedi = createMarker [format["_markerEventMedi%1",(floor(random 360))], ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos)];
            _markerEventMedi setMarkerShape "ICON";
            _markerEventMedi setMarkerType "hd_dot";
            _markerEventMedi setMarkerText (localize "STR_TRGM2_distressSignal_civilian");
        };

        if (random 1 < .50) then {
            [_mainVeh] spawn {
                private _mainVeh = _this select 0;
                while{ (alive _mainVeh)} do {
                    private _flareposX = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos) select 0;
                    private _flareposY = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos) select 1;
                    private _flare1 = "F_40mm_red" createvehicle [_flareposX+20,_flareposY+20, 250]; _flare1 setVelocity [0,0,-10];
                    sleep selectRandom [600];
                };
            };
        };

        if (isNil "fncMedicalFlashLights") then {
            fncMedicalFlashLights = {
                params ["_mainVeh"];
                [_mainVeh] spawn {
                    private _mainVeh = _this select 0;
                    private _lightleft = "#lightpoint" createVehicle ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
                    _lightleft setLightColor [255, 0, 0]; //red
                    _lightleft setLightBrightness 0.03;
                    _lightleft setLightAmbient [0.5,0.5,0.8];
                    _lightleft lightAttachObject [_mainVeh, [0, 1, 1]];
                    private _leftRed = true;
                    while{alive _mainVeh} do {
                        if (_leftRed) then {
                            _leftRed = false;
                            _lightleft setLightColor [0, 0, 255];
                        } else {
                            _leftRed = true;
                            _lightleft setLightColor [255, 0, 0];
                        };
                    sleep 0.1;
                    };
                };
            };
            publicVariable "fncMedicalFlashLights";
        };

        if (isNil "fncMedicalParamedicLight") then {
            fncMedicalParamedicLight = {
                params ["_downedCivMedic"];
                private _medicLight = "#lightpoint" createVehicle ([_downedCivMedic] call TRGM_GLOBAL_fnc_getRealPos);
                _medicLight setLightColor [255, 255, 255]; //red
                _medicLight setLightBrightness 0.03;
                _medicLight setLightAmbient [0.5,0.5,0.8];
                _medicLight lightAttachObject [_downedCivMedic, [0, 1, 1]];

            };
            publicVariable "fncMedicalParamedicLight";
        };

        [_mainVeh] remoteExec ["fncMedicalFlashLights", 0, true];
        private _vehPos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
        private _backOfVehArea = _vehPos getPos [5,([_mainVehDirection,(selectRandom[170,180,190])] call TRGM_GLOBAL_fnc_addToDirection)];
        //_direction is direction of road
        //_mainVehDirection is direction of first veh
        //use these to lay down guys, cones, rubbish, barriers, lights etc...
        private _group = createGroup civilian;
        private _downedCiv = [_group, selectRandom sCivilian,_backOfVehArea,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
        private _iterations = 0;
        while {isNil "_downedCiv" || {isNull _downedCiv}} do {
            _downedCiv = [_group, selectRandom sCivilian,_backOfVehArea,[],0,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
            if (_iterations > 5) exitWith {};
            _iterations = _iterations + 1;
        };
        if (isNil "_downedCiv") exitWith {};
        _downedCiv setDamage 0.8;
        [_downedCiv, "Acts_CivilInjuredGeneral_1"] remoteExec ["switchMove", 0];

        _downedCiv disableAI "anim";
        private _downedCivDirection = (floor(random 360));
        _downedCiv setDir (_downedCivDirection);
        _downedCiv addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}];
        private _bloodPool1 = createVehicle [selectRandom _bloodPools, ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), [], 0, "CAN_COLLIDE"];
        _bloodPool1 setDir (floor(random 360));

        private _trialDir = (floor(random 360));
        private _trialPos = (getPos _bloodPool1) getPos [3,_trialDir];
        private _bloodTrail1 = createVehicle ["BloodTrail_01_New_F", _trialPos, [], 0, "CAN_COLLIDE"];
        _bloodTrail1 setDir _trialDir;

        [_downedCiv] spawn {
            private _downedCiv = _this select 0;
            if (isNil "_downedCiv") exitWith {};
            while{!(isNil "_downedCiv") && (alive _downedCiv)} do {
                _downedCiv say3D selectRandom WoundedSounds;
                sleep selectRandom [2,2.5,3];
            };
        };

        //Paramedics object1 attachTo [object2, offset, memPoint]
        private _downedCivMedic = [_group, selectRandom Paramedics,_backOfVehArea,[],0,"CAN_COLLIDE"] call TRGM_GLOBAL_fnc_createUnit;
        _iterations = 0;
        while {isNil "_downedCivMedic" || {isNull _downedCivMedic}} do {
            _downedCivMedic = [_group, selectRandom Paramedics,_backOfVehArea,[],0,"CAN_COLLIDE"] call TRGM_GLOBAL_fnc_createUnit;
            if (_iterations > 5) exitWith {};
            _iterations = _iterations + 1;
        };
        if !(isNil "_downedCivMedic") then {
            _downedCivMedic playmove "Acts_TreatingWounded02";
            _downedCivMedic disableAI "anim";
            _downedCivMedic attachTo [_downedCiv, [0.5,-0.3,-0.1]];
            _downedCivMedic setDir 270;
            _downedCivMedic addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_paramedicKilled;}]; //ParamedicKilled


            [_downedCivMedic] remoteExec ["fncMedicalParamedicLight", 0, true];

            if (_iteration isEqualTo 1) then {
                [_downedCivMedic, [localize "STR_TRGM2_AskNeedsAssistanceAction",{[format[localize "STR_TRGM2_MedSupplysNeededString",requiredItemsCount,RequestedMedicalItemName]] call TRGM_GLOBAL_fnc_notify;},[_downedCivMedic]]] remoteExec ["addAction", 0, true];
                [_mainVeh,_downedCivMedic] spawn {
                    private _mainVeh = _this select 0;
                    private _downedCivMedic = _this select 1;
                    private _completed = false;
                    while{(alive _mainVeh && !_completed)} do {
                        private _VanillaItemCount = {RequestedMedicalItem isEqualTo _x} count (itemcargo _mainVeh);
                        private _AceItemCount = {RequestedMedicalItem isEqualTo _x} count (itemcargo _mainVeh);
                        if (_VanillaItemCount >= requiredItemsCount || _AceItemCount >= requiredItemsCount) then {
                            [localize "STR_TRGM2_MedEventThankYouString"] call TRGM_GLOBAL_fnc_notifyGlobal;
                            private _completed = true;
                            removeAllActions _downedCivMedic;
                            [0.3, localize "STR_TRGM2_MedEventTaskString"] spawn TRGM_GLOBAL_fnc_adjustMaxBadPoints;
                        };
                        sleep selectRandom [2];
                    };
                };

                private _Crater = createVehicle ["Crater", _backOfVehArea, [], 20, "CAN_COLLIDE"];

                private _downedCivMedic2 = [_group, selectRandom sCivilian,_backOfVehArea,[],8,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                _iterations = 0;
                while {isNil "_downedCivMedic2" || {isNull _downedCivMedic2}} do {
                    _downedCivMedic2 = [_group, selectRandom sCivilian,_backOfVehArea,[],8,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    if (_iterations > 5) exitWith {};
                    _iterations = _iterations + 1;
                };
                if !(isNil "_downedCivMedic2") then {
                    _downedCivMedic2 playmove "Acts_CivilListening_2";
                    _downedCivMedic2 disableAI "anim";
                    _downedCivMedic2 addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_paramedicKilled;}]; //ParamedicKilled
                    private _downedCiv2 = [_group, selectRandom Paramedics,([_downedCivMedic2] call TRGM_GLOBAL_fnc_getRealPos),[],2,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    _iterations = 0;
                    while {isNil "_downedCiv2" || {isNull _downedCiv2}} do {
                        _downedCiv2 = [_group, selectRandom Paramedics,([_downedCivMedic2] call TRGM_GLOBAL_fnc_getRealPos),[],2,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                        if (_iterations > 5) exitWith {};
                        _iterations = _iterations + 1;
                    };
                    if !(isNil "_downedCiv2") then {
                        _downedCiv2 playmove "Acts_CivilTalking_2";
                        _downedCiv2 disableAI "anim";
                        _downedCiv2 addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}]; //ParamedicKilled
                        private _directionFromMed2ToCiv2 = [_downedCivMedic2, _downedCiv2] call BIS_fnc_DirTo;
                        _downedCivMedic2 setDir _directionFromMed2ToCiv2;
                        private _directionFromCiv2ToMed2 = [_downedCiv2, _downedCivMedic2] call BIS_fnc_DirTo;
                        _downedCiv2 setDir _directionFromCiv2ToMed2;
                    };
                };
            };
            if (_iteration isEqualTo 2) then {
                _downedCiv2 = [_group, selectRandom sCivilian,_backOfVehArea,[],8,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                _iterations = 0;
                while {isNil "_downedCiv2" || {isNull _downedCiv2}} do {
                    _downedCiv2 = [_group, selectRandom sCivilian,_backOfVehArea,[],8,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    if (_iterations > 5) exitWith {};
                    _iterations = _iterations + 1;
                };
                if !(isNil "_downedCiv2") then {
                    _downedCiv2 playmove "Acts_CivilHiding_2";
                    _downedCiv2 disableAI "anim";
                    _downedCiv2 addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}]; //ParamedicKilled
                    _directionFromCiv2ToMed2 = [_downedCiv2, _downedCiv] call BIS_fnc_DirTo;
                    _downedCiv2 setDir _directionFromCiv2ToMed2;
                };

                private _downedCiv3 = [_group, selectRandom sCivilian,_backOfVehArea,[],25,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                _iterations = 0;
                while {isNil "_downedCiv3" || {isNull _downedCiv3}} do {
                    _downedCiv3 = [_group, selectRandom sCivilian,_backOfVehArea,[],25,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                    if (_iterations > 5) exitWith {};
                    _iterations = _iterations + 1;
                };
                if !(isNil "_downedCiv3") then {
                    _downedCiv3 playmove "Acts_CivilShocked_1";
                    _downedCiv3 disableAI "anim";
                    _downedCiv3 setDir (floor(random 360));
                    _downedCiv3 addEventHandler ["killed", {_this spawn TRGM_SERVER_fnc_civKilled;}]; //ParamedicKilled
                };
            };
        };

        private _rubbish1 = createVehicle [selectRandom TRGM_VAR_MedicalMessItems, ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), [], 1.5, "CAN_COLLIDE"];
        _rubbish1 setDir (floor(random 360));

        private _rubbish2 = createVehicle [selectRandom TRGM_VAR_MedicalMessItems, ([_downedCiv] call TRGM_GLOBAL_fnc_getRealPos), [], 1.5, "CAN_COLLIDE"];
        _rubbish2 setDir (floor(random 360));

        private _medicalBox1 = createVehicle [selectRandom TRGM_VAR_MedicalBoxes, (_downedCiv getpos [2,(floor(random 360))]), [], 0, "CAN_COLLIDE"];
        _medicalBox1 setDir (floor(random 360));
        clearItemCargoGlobal _medicalBox1;

        private _nearestRoadsPoint2 = _vehPos nearRoads 25;
        private _maxRoads2 = count _nearestRoadsPoint2;
        private _selIndex = selectRandom [0,(_maxRoads2-1)];
        private _nearestRoad2 = _nearestRoadsPoint2 select 0;
        private _roadConnectedTo2 = roadsConnectedTo _nearestRoad2;
        if (count _roadConnectedTo > 0) then {
            private _connectedRoad2 = _roadConnectedTo2 select 0;
            private _direction2 = [_nearestRoad2, _connectedRoad2] call BIS_fnc_DirTo;

            private _conelight1 = createVehicle [selectRandom TRGM_VAR_ConesWithLight, (_nearestRoad2 getpos [3,[_direction2,90] call TRGM_GLOBAL_fnc_addToDirection]), [], 0, "CAN_COLLIDE"];
            _conelight1 enableSimulation false;
            _conelight1 setDir (floor(random 360));
            private _conelight2 = createVehicle [selectRandom TRGM_VAR_ConesWithLight, (_nearestRoad2 getpos [3,[_direction2,270] call TRGM_GLOBAL_fnc_addToDirection]), [], 0, "CAN_COLLIDE"];
            _conelight2 enableSimulation false;
            _conelight2 setDir (floor(random 360));
        };

        private _flatPos = [_vehPos , 10, 15, 10, 0, 0.3, 0,[],[[0,0,0],[0,0,0]],selectRandom CivCars] call TRGM_GLOBAL_fnc_findSafePos;
        private _buildings = nearestObjects [_vehPos, TRGM_VAR_BasicBuildings, 100];

        if (count _buildings < 5 && _iteration isEqualTo 1) then {
            private _car1 = createVehicle [selectRandom CivCars, _flatPos, [], 0, "CAN_COLLIDE"];
            _car1 setDamage [1,false];
            _car1 setDir (floor(random 360));
            if (call TRGM_GETTER_fnc_bAllowAOFires) then {
                private _objFlame1 = createVehicle ["test_EmptyObjectForFireBig", _flatPos, [], 0, "CAN_COLLIDE"];
            };
        };

        // Police
        if (_iteration isEqualTo 1 && random 1 < .50) then {
            private _flatPosPolice1 = [_vehPos , 30, 50, 10, 0, 0.5, 0,[],[[0,0,0],[0,0,0]],selectRandom PoliceVehicles] call TRGM_GLOBAL_fnc_findSafePos;
            private _carPolice = createVehicle [selectRandom PoliceVehicles, _flatPosPolice1, [], 0, "NONE"];
            private _manPolice = [createGroup civilian, selectRandom Police,([_carPolice] call TRGM_GLOBAL_fnc_getRealPos),[],15,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
            _iterations = 0;
            while {isNil "_manPolice" || {isNull _manPolice}} do {
                _manPolice = [createGroup civilian, selectRandom Police,([_carPolice] call TRGM_GLOBAL_fnc_getRealPos),[],15,"NONE"] call TRGM_GLOBAL_fnc_createUnit;
                if (_iterations > 5) exitWith {};
                _iterations = _iterations + 1;
            };
            if !(isNil "_manPolice") then {
                _manPolice setDir (floor(random 360));
                [_manPolice] call TRGM_GLOBAL_fnc_makeNPC;
            };
        };

        // CivCars

        //TRGM_VAR_ConesWithLight
        //TRGM_VAR_Cones
        //Paramedics
        //"MedicalGarbage_01_Bandage_F" createVehicle ([player] call TRGM_GLOBAL_fnc_getRealPos);
        if (_iteration isEqualTo 1) then {
            private _sidePos = ([_mainVeh] call TRGM_GLOBAL_fnc_getRealPos);
            private _iCount = selectRandom[0,0,0,1,2];
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            while {_iCount > 0} do {
                private _thisAreaRange = 100;
                private _checkPointGuidePos = _sidePos;
                _iCount = _iCount - 1;
                private _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = true;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = true;
                    private _thisIsDirectionAwayFromAO = true;
                    [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100] spawn TRGM_SERVER_fnc_setCheckpoint;
                };
            };

            //spawn inner sentry
            _iCount = selectRandom[0,0,0,0,1];
            if (_iCount > 0) then {_dAngleAdustPerLoop = 360 / _iCount;};
            while {_iCount > 0} do {
                private _thisAreaRange = 100;
                private _checkPointGuidePos = _sidePos;
                _iCount = _iCount - 1;
                private _flatPos = [_checkPointGuidePos , 0, 50, 10, 0, 0.2, 0,[[getMarkerPos "mrkHQ", TRGM_VAR_BaseAreaRange]] + TRGM_VAR_CheckPointAreas + TRGM_VAR_SentryAreas,[_checkPointGuidePos,_checkPointGuidePos]] call TRGM_GLOBAL_fnc_findSafePos;
                if !(_flatPos isEqualTo _checkPointGuidePos) then {
                    private _thisPosAreaOfCheckpoint = _flatPos;
                    private _thisRoadOnly = false;
                    private _thisSide = TRGM_VAR_EnemySide;
                    private _thisUnitTypes = [(call sRiflemanToUse), (call sRiflemanToUse),(call sRiflemanToUse),(call sMachineGunManToUse), (call sEngineerToUse), (call sGrenadierToUse), (call sMedicToUse),(call sAAManToUse),(call sATManToUse)];
                    private _thisAllowBarakade = false;
                    private _thisIsDirectionAwayFromAO = true;
                    [_sidePos,_thisPosAreaOfCheckpoint,_thisAreaRange,_thisRoadOnly,_thisSide,_thisUnitTypes,_thisAllowBarakade,_thisIsDirectionAwayFromAO,true,(call UnarmedScoutVehicles),100] spawn TRGM_SERVER_fnc_setCheckpoint;
                };
            };
        };
    };
    _iteration = _iteration + 1;
};

true;