// private _fnc_scriptName = "MISSIONS_fnc_hvtMission";
//These are only ever called by the server!

//useful variables
//base location
//mission task locations
//friendly AO camp location
//checkpoint locations and sentry postions
//cleared locations (i.e. AOs that had a task completed)

private _MISSION_LOCAL_fnc_CustomRequired = { //used to set any required details for the AO (example, a wide open space or factory nearby)... if this is not found in AO, the engine will scrap the area and loop around again with a different location
//be careful about using this, some maps may not have what you require, so the engine will never satisfy the requirements here (example, if no airports are on a map and that is what you require)
    private ["_objectiveMainBuilding", "_centralAO_x", "_centralAO_y", "_result", "_flatPos"];
    _objectiveMainBuilding = _this select 0;
    _centralAO_x = _this select 1;
    _centralAO_y = _this select 2;

    _result = false;

    _flatPos = nil;
    _flatPos = [[_centralAO_x,_centralAO_y,0] , 10, 150, 10, 0, 0.3, 0,[],[[_centralAO_x,_centralAO_y],[_centralAO_x,_centralAO_y]]] call TRGM_GLOBAL_fnc_findSafePos;

    if ((_flatPos select 0) > 0) then {_result = true};
    //flatPosDebug = _flatPos;
    _result; //return value
};

private _MISSION_LOCAL_fnc_CustomVars = { //This is called before the mission function is called below, and the variables below can be adjusted for your mission
    _RequiresNearbyRoad = true;
    _roadSearchRange = 100; //this is how far out the engine will check to make sure a road is within range (if your objective requires a nearby road)
    _MissionTitle = _this select 0; // The destroy X vehicle mission takes the mission title as a parameter to allow all the destory X vehicle missions to use the same function
    _allowFriendlyIns = false;
};

private _MISSION_LOCAL_fnc_CustomMission = { //This function is the main script for your mission, some if the parameters passed in must not be changed!!!
    /*
     * Parameter Descriptions
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     * _markerType                 : The marker type to be used, you can set the type of marker below, but if the player has selected to hide mission locations, then your marker will not show.
     * _objectiveMainBuilding      : DO NOT EDIT THIS VALUE (this is the main building location selected within your AO)
     * _centralAO_x                : DO NOT EDIT THIS VALUE (this is the X coord of the AO)
     * _centralAO_y                : DO NOT EDIT THIS VALUE (this is the Y coord of the AO)
     * _roadSearchRange            : DO NOT EDIT THIS VALUE (this is the search range for a valid road, set previously in _MISSION_LOCAL_fnc_CustomVars)
     * _bCreateTask                : DO NOT EDIT THIS VALUE (this is determined by the player, if the player selected to play a hidden mission, the task is not created!)
     * _iTaskIndex                 : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the index of the task used to determine mission/task completion!)
     * _bIsMainObjective           : DO NOT EDIT THIS VALUE (this is determined by the engine, and is the boolean if the mission is a Heavy or Standard mission!)
     * _args                       : These are additional arguments that might be required for the mission, for an example, see the Destroy Vehicles Mission.
     * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    params ["_markerType","_objectiveMainBuilding","_centralAO_x","_centralAO_y","_roadSearchRange", "_bCreateTask", "_iTaskIndex", "_bIsMainObjective", ["_args", []]];
    if (_markerType != "empty") then { _markerType = "hd_unknown"; }; // Set marker type here...

    _args params ["_repReasonOnComplete", "_repAmountOnComplete", "_hintStrOnComplete", "_infClassToUse", "_sideToUse", "_hvtType", "_searchText", "_getIntelText", "_missionDescriptions"];

    // HVT Types: "RESCUE", "KILL", "INTERROGATE", or "SPEAK"
    //###################################### HVT(s) ######################################
    ["Mission Setup: 8-4", true] call TRGM_GLOBAL_fnc_log;
    _allpositions = _objectiveMainBuilding buildingPos -1;
    if (_iTaskIndex isEqualTo 0) then {
        TRGM_VAR_AllowUAVLocateHelp =  true; publicVariable "TRGM_VAR_AllowUAVLocateHelp";
    };

    _sInformant1Name = format["objInformant%1",_iTaskIndex];

    _objInformant = [(createGroup [_sideToUse, true]), _infClassToUse, [0,0,500], [], 0, "NONE", true] call TRGM_GLOBAL_fnc_createUnit;
    if (isNil "_objInformant" || {isNull _objInformant}) exitWith {};

    _objInformant allowDamage false;
    _objInformant setVariable [_sInformant1Name, _objInformant, true];
    _objInformant setVariable ["taskIndex",_iTaskIndex, true];
    _objInformant setVariable ["HVTType",_hvtType,true];
    _objInformant setVariable ["createTask",_bCreateTask,true];
    _objInformant setVariable ["ObjectiveParams", [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
    missionNamespace setVariable [format ["missionObjectiveParams%1", _iTaskIndex], [_markerType,_objectiveMainBuilding,_centralAO_x,_centralAO_y,_roadSearchRange,_bCreateTask,_iTaskIndex,_bIsMainObjective,_args]];
    missionNamespace setVariable [_sInformant1Name, _objInformant];
    sleep 0.2;
    _MissionTitle = _MissionTitle + ": " + name _objInformant;

    _initPos = selectRandom _allpositions;
    _flatPosInform = nil;
    _flatPosInform = [_initPos, 10, 75, 7, 0, 0.5, 0, [], [_initPos,_initPos], _objInformant] call TRGM_GLOBAL_fnc_findSafePos;
    if (count _flatPosInform isEqualTo 3) then { //if pos is [x,y] instead of [x,y,z] then dont setPosATL!
        _objInformant setPosATL (_flatPosInform);
    } else {
        _objInformant setPos (_flatPosInform);
    };

    if (_hvtType isNotEqualTo "RESCUE") then {
        [_objInformant, _initPos] spawn {
            params ["_objInformantInner", "_initPosInner"];
            waitUntil {
                sleep 10;
                if (alive _objInformantInner && (_objInformantInner distance _initPosInner) > 100) then {
                    _objInformantInner setPos _initPosInner;
                };
                !(alive _objInformantInner);
            };
        };
    };

    [_objInformant, ["HitPart", {
        (_this select 0) params ["_thisInformant", "_thisShooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"];
        _hitLocation = _selection select 0;
        if (side (_thisShooter) isEqualTo TRGM_VAR_FriendlySide && alive(_thisInformant)) then {
            _thisInformant allowDamage true;
            _bDone = false;
            (group _thisInformant) setBehaviour "ALERT";
            _thisInformant switchMove "";
            _ThisHVTType = _thisInformant getVariable ["HVTType","SPEAK"];
            if (!isPlayer _thisShooter && {_ThisHVTType isEqualTo "INTERROGATE" || _ThisHVTType isEqualTo "SPEAK"}) then {
                _thisInformant disableAI "anim";
                _thisInformant switchMove "Acts_CivilInjuredLegs_1";
                _thisInformant disableAI "anim";
                _thisInformant setHit ['legs',1];
                _thisInformant setCaptive true;
            } else {
                switch (_hitLocation) do {
                    case "head";
                    case "neck";
                    case "spine1";
                    case "spine2";
                    case "spine3";
                    case "body": {
                        _thisInformant setDamage 1;
                        _bDone = true;
                    };
                    default {
                        if (_ThisHVTType isEqualTo "INTERROGATE") then {
                            _thisInformant disableAI "anim";
                            _thisInformant switchMove "Acts_CivilInjuredLegs_1";
                            _thisInformant disableAI "anim";
                            _thisInformant setHit ['legs',1];
                            _thisInformant setVariable ["StopWalkScript", true, true];
                            _thisInformant setCaptive true;
                            removeAllWeapons _thisInformant;
                        } else {
                            _thisInformant setHit ['legs',1];
                        };
                        _bDone = true;
                    };
                };

                if (!_bDone) then {
                    _thisInformant setDamage 0.8;
                };
            };
            _objInformant allowDamage false;
        };
    }]] remoteExec ["addEventHandler", 0, true];

    if (!(_hvtType isEqualTo "INTERROGATE")) then {
        //pass in false so we know to just hint if this was our guy or not (just in case player wants to be sure before moving to next objective)
        //only need to search if its a kill objective... if for example its "interogate officer", there will already be an action to get intel
        [_objInformant, [_searchText, {[_this select 0] spawn TRGM_SERVER_fnc_updateTask;}, [], 10, true, true, "", "_this distance _target < 3"]] remoteExec ["addAction", 0, true];
    };

    if (_hvtType isEqualTo "INTERROGATE" || _hvtType isEqualTo "KILL") then { //if interrogate or kill task
        if (_sideToUse isEqualTo TRGM_VAR_EnemySide) then {  //only give weapon if enemy side unit
            _grpName = (createGroup [TRGM_VAR_EnemySide, true]);
            [_objInformant] joinSilent _grpName;
            _objInformant addMagazine "30Rnd_9x21_Mag_SMG_02";
            _objInformant addMagazine "30Rnd_9x21_Mag_SMG_02";
            _objInformant addWeapon "SMG_02_F";
        };
        if (_hvtType isEqualTo "INTERROGATE") then {
            [_objInformant, [_getIntelText, {_this spawn TRGM_SERVER_fnc_interrogateOfficer;}, [], 10, true, true, "", "_this distance _target < 3"]] remoteExec ["addAction", 0, true];
        };

        TRGM_LOCAL_fnc_walkingGuyLoop = {
            _objManName = _this select 0;
            _thisInitPos = _this select 1;
            _objMan = missionNamespace getVariable _objManName;

            group _objMan setSpeedMode "LIMITED";
            group _objMan setBehaviour "SAFE";
            sleep 5; //allow five seconds for any scripts to be run on officer before he moves e.g. if set as hostage when friendly rebels)

            waitUntil {
                private _walkAroundHandle = [_objManName,_thisInitPos,_objMan,75] spawn TRGM_SERVER_fnc_hvtWalkAround;
                sleep 2;
                waitUntil {sleep 1; speed _objMan < 0.5};
                sleep 10;
                waitUntil { sleep 1; scriptDone _walkAroundHandle; };
                sleep 2;
                !(alive _objMan) || behaviour _objMan isNotEqualTo "SAFE";
            };
        };
        [_sInformant1Name,_initPos] spawn TRGM_LOCAL_fnc_walkingGuyLoop;

        if (_bIsMainObjective) then {
            //if interrogate or kill, and is a main objective, then complete task when searched
            //its only the main objective that we require the player to get to the body... otherwise, can kill him from a distance
            [_objInformant, [_searchText, {[_this select 0] spawn TRGM_SERVER_fnc_updateTask;}, [], 10, true, true, "", "_this distance _target < 3"]] remoteExec ["addAction", 0, true];
        };

        if (!_bIsMainObjective && _hvtType isEqualTo "KILL") then {
            [_objInformant] spawn {
                private _objInformant = _this select 0;
                waitUntil { !alive(_objInformant) };
                _objInformant spawn TRGM_SERVER_fnc_updateTask;
            };
        };
    }
    else {
        if (_hvtType isEqualTo "SPEAK") then {
            _objInformant setCaptive true;
            [_objInformant, [_getIntelText,{_this spawn TRGM_SERVER_fnc_speakInformant;},[],1,false,true,"","_this distance _target < 3"]] remoteExec ["addAction", 0, true];
        };
        if (_hvtType isEqualTo "RESCUE") then { //pow or reporter
            _allowFriendlyIns = false;
            [_objInformant, "Acts_ExecutionVictim_Loop"] remoteExec ["switchMove", 0];
            _objInformant setCaptive true;
            _objInformant setDamage 0.8;
            _objInformant setHitPointDamage ["hitLegs", 1];

            _allpositionsMainBuiding = _objectiveMainBuilding buildingPos -1;
            _objInformant setPosATL (selectRandom _allpositionsMainBuiding);
            removeAllWeapons _objInformant;

            [_objInformant,[localize "STR_TRGM2_fnpostinit_Carry",{
                _civ = _this select 0;
                _player = _this select 1;
                [_civ, _player] spawn TRGM_GLOBAL_fnc_carryAndJoinWounded;
            }]] remoteExecCall ["addAction", 0];

            [_objInformant,[localize "STR_TRGM2_fnpostinit_JoinGroup",{
                _civ=_this select 0;
                _player=_this select 1;
                [_civ] join (group _player);
                _civ enableAI "MOVE";
                _civ switchMove "Acts_ExecutionVictim_Unbow";
                _civ enableAI "anim";
                _civ setCaptive false;
                addSwitchableUnit _civ;
            }]] remoteExecCall ["addAction", 0];

            TRGM_LOCAL_fnc_powCheck = {
                _objMan = _this select 0;
                _doLoop = true;
                waitUntil {
                    if (!alive(_objMan)) then {
                        _doLoop = false;
                        [_objMan, "failed"] call TRGM_SERVER_fnc_updateTask;
                    };
                    if (_objMan distance (getMarkerPos "mrkHQ") < 500 || vehicle _objMan distance (getMarkerPos "mrkHQ") < 500) then {
                        _doLoop = false;
                        _objMan call TRGM_SERVER_fnc_updateTask;
                        [_objMan] join grpNull;
                        deleteVehicle _objMan;

                    };
                    !_doLoop;
                };
            };
            [_objInformant] spawn TRGM_LOCAL_fnc_powCheck;
        };
    };
    _sTaskDescription = selectRandom _missionDescriptions;
};

[_MISSION_LOCAL_fnc_CustomRequired, _MISSION_LOCAL_fnc_CustomVars, _MISSION_LOCAL_fnc_CustomMission];
