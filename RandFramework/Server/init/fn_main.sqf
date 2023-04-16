// private _fnc_scriptName = "TRGM_SERVER_fnc_main";
format[localize "STR_TRGM2_debugFunctionString", _fnc_scriptName, _fnc_scriptNameParent, (["Client", "Server"] select isServer)] call TRGM_GLOBAL_fnc_log;



if !(isServer) exitWith {};

createCenter west;
createCenter east;
createCenter independent;
createCenter civilian;
createCenter sideLogic;

// Set relationships
west setFriend [east, 0];
west setFriend [independent, 0];
east setFriend [west, 0];
east setFriend [independent, 1];
independent setFriend [west, 0];
independent setFriend [east, 1];
civilian setFriend [west, 1];
civilian setFriend [east, 1];

TRGM_VAR_SniperCount = 0; publicVariable "TRGM_VAR_SniperCount";
TRGM_VAR_SniperAttemptCount = 0; publicVariable "TRGM_VAR_SniperAttemptCount";
TRGM_VAR_SpotterCount = 0; publicVariable "TRGM_VAR_SpotterCount";
TRGM_VAR_SpotterAttemptCount = 0; publicVariable "TRGM_VAR_SpotterAttemptCount";
TRGM_VAR_friendlySentryCheckpointPos = []; publicVariable "TRGM_VAR_friendlySentryCheckpointPos";

private _tracers = ["tracer1", "tracer2", "tracer3", "tracer4"];
{
    private _name = _x;
    if (isNil _name) then {
        private _tracer = (group (missionNamespace getvariable ["BIS_functions_mainscope",objnull])) createUnit ["ModuleTracers_F",[0,0,0],[],0,"CAN_COLLIDE"];
        _tracer setVehicleVarName _name;
        _tracer setVariable ['Side', '0', true];
        _tracer setVariable ['Min', 10, true];
        _tracer setVariable ['Max', 20, true];
        _tracer setVariable ['Weapon', '', true];
        _tracer setVariable ['Magazine', '', true];
        _tracer setVariable ['Target', '', true];
        _tracer setVariable ["BIS_fnc_initModules_disableAutoActivation", true];
        _tracer setPos [99999,99999];
        missionNamespace setVariable [_name, _tracer];
    };
} forEach _tracers;

[true] call TRGM_SERVER_fnc_setTimeAndWeather;

waitUntil {time > 0};

private _trgRatingAdjust = createTrigger ["EmptyDetector", [0,0]];
_trgRatingAdjust setTriggerArea [0, 0, 0, false];
_trgRatingAdjust setTriggerStatements ["((rating player) < 0)", "player addRating -(rating player)", ""];

// Instead of only doing this in SP, check if the HCs are empty and delete the unused ones.
{
    if (!isNil {_x}) then {
        deleteVehicle _x;
    };
} forEach [vs1, vs2, vs3, vs4, vs5, vs6, vs7, vs8, vs9, vs10];

waitUntil { TRGM_VAR_bAndSoItBegins };

TRGM_VAR_PopulateLoadingWait_percentage = 0; publicVariable "TRGM_VAR_PopulateLoadingWait_percentage";

[format["Mission Core: %1", "Init"], true] call TRGM_GLOBAL_fnc_log;
[5] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

if (call TRGM_GETTER_fnc_bEnableGroupManagement) then {
    ["Initialize"] call BIS_fnc_dynamicGroups;//Exec on Server
};

format["Mission Core: %1", "GroupManagementSet"] call TRGM_GLOBAL_fnc_log;

[format["Mission Core: %1", "GlobalVarsSet"], true] call TRGM_GLOBAL_fnc_log;

call TRGM_GLOBAL_fnc_buildEnemyFaction;
[format["Mission Core: %1", "EnemyGlobalVarsSet"], true] call TRGM_GLOBAL_fnc_log;

call TRGM_GLOBAL_fnc_buildFriendlyFaction;
[format["Mission Core: %1", "FriendlyGlobalVarsSet"], true] call TRGM_GLOBAL_fnc_log;

call CUSTOM_MISSION_fnc_SetEnemyFaction; //if TRGM_VAR_useCustomEnemyFaction set to true within this sqf, will overright the above enemy faction data
call CUSTOM_MISSION_fnc_SetMilitiaFaction; //if TRGM_VAR_useCustomMilitiaFaction set to true within this sqf, will overright the above enemy faction data
[format["Mission Core: %1", "EnemyFactionSet"], true] call TRGM_GLOBAL_fnc_log;

call CUSTOM_MISSION_fnc_SetFriendlyFaction; //if TRGM_VAR_useCustomFriendlyFaction set to true within this sqf, will overright the above enemy faction data
[format["Mission Core: %1", "FriendlyLoadoutSet"], true] call TRGM_GLOBAL_fnc_log;
[10] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

// Fix any changed types
if (typeName sCivilian != "ARRAY") then {sCivilian = [sCivilian]};
// end

TRGM_VAR_FactionSetupCompleted = true; publicVariable "TRGM_VAR_FactionSetupCompleted";

[HQMan] call TRGM_GLOBAL_fnc_setLoadout;

private _bReplaceFriendlyVehicles = [false, true] select ((["ReplaceFriendlyVehicles", 1] call BIS_fnc_getParamValue) isEqualTo 1);

if (_bReplaceFriendlyVehicles) then {
    try {
        private _airTransClassName = [chopper1, TRGM_VAR_FriendlySide] call TRGM_GLOBAL_fnc_getFactionVehicle;
        if (!isNil "chopper1" && {!(isNil "_airTransClassName") && {_airTransClassName != typeOf chopper1}}) then {
            {deleteVehicle _x;} forEach crew chopper1 + [chopper1];
            private _helipadPos = [heliPad1] call TRGM_GLOBAL_fnc_getRealPos;
            private _safePos = _helipadPos findEmptyPosition [0, 20, _airTransClassName];
            if !(count _safePos isEqualTo 3) then {
                if (count _safePos isEqualTo 2) then {
                    _safePos = [_safePos # 0, _safePos # 1, _helipadPos # 2];
                } else {
                    _safePos = _helipadPos;
                };
            };
            chopper1 = createVehicle [_airTransClassName, _safePos, [], 0, "NONE"];
            [TRGM_VAR_FriendlySide, chopper1, true] call TRGM_GLOBAL_fnc_createVehicleCrew;
            chopper1 setVehicleVarName "chopper1";
            publicVariable "chopper1";
            chopper1 allowDamage false;
            heliPad1 setPos ([chopper1] call TRGM_GLOBAL_fnc_getRealPos);
            chopper1 setVelocity [0, 0, 0];
            chopper1 setdamage 0;
            chopper1 engineOn false;
            chopper1 lockDriver true;
            chopper1D = driver chopper1;
            chopper1D setVehicleVarName "chopper1D";
            {_x allowDamage false;} forEach crew chopper1;
            chopper1D allowDamage false;
            chopper1D setCaptive true;
            chopper1D disableAI "AUTOTARGET";
            chopper1D disableAI "TARGET";
            chopper1D disableAI "SUPPRESSION";
            chopper1D disableAI "AUTOCOMBAT";
            chopper1D setBehaviour "CARELESS";
            publicVariable "chopper1D";
            private _totalTurrets = [_airTransClassName, true] call BIS_fnc_allTurrets;
            {chopper1 lockTurret [_x, true]} forEach _totalTurrets;
            { _x disableAI "MOVE"; } forEach crew chopper1;
            [] spawn {
                waitUntil { !([chopper1] call TRGM_GLOBAL_fnc_helicopterIsFlying); };
                { _x enableAI "MOVE"; } forEach crew chopper1;
            };
        };
    } catch {};

    try {
        private _airSupClassName = [chopper2, TRGM_VAR_FriendlySide] call TRGM_GLOBAL_fnc_getFactionVehicle;
        if (!isNil "chopper2" && {!(isNil "_airSupClassName") && {_airSupClassName != typeOf chopper2}}) then {
            {deleteVehicle _x;} forEach crew chopper2 + [chopper2];
            private _helipadPos = [airSupportHeliPad] call TRGM_GLOBAL_fnc_getRealPos;
            private _safePos = _helipadPos findEmptyPosition [0, 20, _airSupClassName];
            if !(count _safePos isEqualTo 3) then {
                if (count _safePos isEqualTo 2) then {
                    _safePos = [_safePos # 0, _safePos # 1, _helipadPos # 2];
                } else {
                    _safePos = _helipadPos;
                };
            };
            chopper2 = createVehicle [_airSupClassName, _safePos, [], 0, "NONE"];
            [TRGM_VAR_FriendlySide, chopper2, true] call TRGM_GLOBAL_fnc_createVehicleCrew;
            chopper2 setVehicleVarName "chopper2";
            publicVariable "chopper2";
            chopper2 allowDamage false;
            airSupportHeliPad setPos ([chopper2] call TRGM_GLOBAL_fnc_getRealPos);
            chopper2 setVelocity [0, 0, 0];
            chopper2 setdamage 0;
            chopper2 engineOn false;
            chopper2 lockDriver true;
            chopper2D = driver chopper2;
            chopper2D setVehicleVarName "chopper2D";
            publicVariable "chopper2D";
            {_x allowDamage false;} forEach crew chopper2;
            private _totalTurrets = [_airSupClassName, true] call BIS_fnc_allTurrets;
            {chopper2 lockTurret [_x, true]} forEach _totalTurrets;
            { _x disableAI "MOVE"; } forEach crew chopper2;
            [] spawn {
                waitUntil { !([chopper2] call TRGM_GLOBAL_fnc_helicopterIsFlying); };
                { _x enableAI "MOVE"; } forEach crew chopper2;
            };
        };
    } catch {};
};

TRGM_VAR_transportHelosToGetActions = [chopper1];
{
    try {
        if (_bReplaceFriendlyVehicles && {isClass(configFile >> "CfgVehicles" >> typeOf _x) && {_x isKindOf "LandVehicle" || _x isKindOf "Air" || _x isKindOf "Ship"}}) then {
            private _faction = getText(configFile >> "CfgVehicles" >> typeOf _x >> "faction");
            private _friendlyFactionIndex = call TRGM_GETTER_fnc_friendlyFactionIndex;
            private _westFaction = (TRGM_VAR_AvailableFactions select _friendlyFactionIndex) select 0;
            if (getNumber(configFile >> "CfgFactionClasses" >> _faction >> "side") isEqualTo 1 && {_faction != _westFaction}) then {
                private _newVehClass = [_x, TRGM_VAR_FriendlySide] call TRGM_GLOBAL_fnc_getFactionVehicle;
                if (!isNil "_newVehClass") then {
                    private _pos = getPosATL _x;
                    private _dir = getDir _x;
                    if ((crew _x) isEqualTo []) then {
                        deleteVehicle _x;
                        sleep 0.01;
                        private _safePos = _pos findEmptyPosition [0, 20, _newVehClass];
                        private _newVeh = createVehicle [_newVehClass, _safePos, [], 0, "NONE"];
                        _newVeh setDir _dir;
                        _newVeh allowDamage false;
                        _newVeh setPos _pos;
                        _newVeh allowDamage true;
                    } else {
                        if (({isPlayer _x || _x in playableUnits || _x in switchableUnits || !(side _x isEqualTo TRGM_VAR_FriendlySide)} count (crew _x)) isEqualTo 0) then {
                            {deleteVehicle _x;} forEach crew _x + [_x];
                            sleep 0.01;
                            private _safePos = _pos findEmptyPosition [0, 20, _newVehClass];
                            private _newVeh = createVehicle [_newVehClass, _safePos, [], 0, "NONE"];
                            [TRGM_VAR_FriendlySide, _newVeh, true] call TRGM_GLOBAL_fnc_createVehicleCrew;
                            _newVeh setDir _dir;
                            _newVeh allowDamage false;
                            _newVeh setPos _pos;
                            _newVeh allowDamage true;
                        };
                    };
                };

            };
        };

        if ((count crew _x) > 0 && {isClass(configFile >> "CfgVehicles" >> typeOf _x) && {_x isKindOf "Air" && {_x call TRGM_GLOBAL_fnc_isTransport}}}) then {
            TRGM_VAR_transportHelosToGetActions pushBackUnique _x;
        };
    } catch {};
} forEach (vehicles - [chopper1, chopper2]);
publicVariable "TRGM_VAR_transportHelosToGetActions";

[chopper1] call TRGM_GLOBAL_fnc_setVehicleUpright;
[chopper2] call TRGM_GLOBAL_fnc_setVehicleUpright;
{_x setDamage 0;} forEach (crew chopper2 + crew chopper1 + [chopper1, chopper2]);
{_x allowDamage true;} forEach crew chopper2 + [chopper2];

[TRGM_VAR_transportHelosToGetActions] call TRGM_GLOBAL_fnc_addTransportActions;
[format["Mission Core: %1", "TransportScriptRun"], true] call TRGM_GLOBAL_fnc_log;
[15] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

TRGM_VAR_CustomObjectsSet = true; publicVariable "TRGM_VAR_CustomObjectsSet";

try {
    if !(isNil "SupProArti") then {
        SupProArti setVariable ['BIS_SUPP_vehicles',TRGM_VAR_WestArtillery,true];
    };
    if !(isNil "supReqAirSup") then {
        supReqAirSup setVariable ['BIS_SUPP_vehicles',(TRGM_VAR_WestPlanes + TRGM_VAR_WestArmedHelos),true];
    };
    if !(isNil "supReqSupDrop") then {
        supReqSupDrop setVariable ['BIS_SUPP_vehicles',TRGM_VAR_WestUnarmedHelos,true];
    };
} catch {};

[format["Mission Core: %1", "FriendlyObjectsSet"], true] call TRGM_GLOBAL_fnc_log;

[format["Mission Core: %1", "EnemyFactionDataProcessed"], true] call TRGM_GLOBAL_fnc_log;

private _isAceRespawnWithGear = false;
if (call TRGM_GLOBAL_fnc_isCbaLoaded && call TRGM_GLOBAL_fnc_isAceLoaded) then {
    // check for ACE respawn with gear setting
    _isAceRespawnWithGear = "ace_respawn_savePreDeathGear" call CBA_settings_fnc_get;
};

[format["Mission Core: %1", "savePreDeathGear"], true] call TRGM_GLOBAL_fnc_log;
{
    if (!isPlayer _x) then {
        [_x] call TRGM_GLOBAL_fnc_setLoadout;
        if (!isNil("_isAceRespawnWithGear") && {!_isAceRespawnWithGear}) then {
            _x addEventHandler ["Respawn", { [_this select 0] call TRGM_GLOBAL_fnc_setLoadout; }];
        };
    };
} forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
[format["Mission Core: %1", "setLoadout ran"], true] call TRGM_GLOBAL_fnc_log;

box1 allowDamage false;
[box1, (if (isMultiplayer) then {playableUnits} else {switchableUnits})] call TRGM_GLOBAL_fnc_initAmmoBox;

[format["Mission Core: %1", "boxCargo set"], true] call TRGM_GLOBAL_fnc_log;
[format["Mission Core: %1", "PreCustomObjectSet"], true] call TRGM_GLOBAL_fnc_log;

waitUntil { TRGM_VAR_CustomObjectsSet };

[20] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

[endMissionBoard] remoteExec ["removeAllActions"];
[endMissionBoard2] remoteExec ["removeAllActions"];

if (TRGM_VAR_iMissionIsCampaign && isMultiplayer && isServer) then {
    if (TRGM_VAR_SaveType isEqualTo 0) then {
        [laptop1, [localize "STR_TRGM2_TRGMInitPlayerLocal_SaveLocal",{[1,true] spawn TRGM_SERVER_fnc_serverSave;}]] remoteExec ["addaction"];
        [laptop1, [localize "STR_TRGM2_TRGMInitPlayerLocal_SaveGlobal",{[2,true] spawn TRGM_SERVER_fnc_serverSave;}]] remoteExec ["addaction"];
    };
    if (TRGM_VAR_SaveType isEqualTo 1) then {
        [(localize "STR_TRGM2_ServerSave_Save1")] call TRGM_GLOBAL_fnc_notify;
        [laptop1, [localize "STR_TRGM2_ServerSave_SaveLocal",{[(localize "STR_TRGM2_ServerSave_SaveHint")] call TRGM_GLOBAL_fnc_notify}]] remoteExec ["addaction"];
    };
    if (TRGM_VAR_SaveType isEqualTo 2) then {
        [(localize "STR_TRGM2_ServerSave_Save2")] call TRGM_GLOBAL_fnc_notify;
        [laptop1, [localize "STR_TRGM2_ServerSave_SaveGlobal",{[(localize "STR_TRGM2_ServerSave_SaveHint2")] call TRGM_GLOBAL_fnc_notify}]] remoteExec ["addaction"];
    };
};

[endMissionBoard, [localize "STR_TRGM2_SetMissionBoardOptions_ShowRepLong", {[true] spawn TRGM_GLOBAL_fnc_showRepReport;}]] remoteExec ["addAction"];
[endMissionBoard, [localize "STR_TRGM2_SetMissionBoardOptions_EndMission",{_this spawn TRGM_SERVER_fnc_attemptEndMission;}]] remoteExec ["addAction", 0];

[format["Mission Core: %1", "PostCustomObjectSet"], true] call TRGM_GLOBAL_fnc_log;

if (TRGM_VAR_iUseRevive > 0 && {isNil "AIS_MOD_ENABLED"}) then {
    call AIS_Core_fnc_preInit;
    call AIS_Core_fnc_postInit;
    call AIS_System_fnc_postInit;
};

[format["Mission Core: %1", "AIS Script Run"], true] call TRGM_GLOBAL_fnc_log;


// Place in unit init to have them deleted in MP: this setVariable ["MP_ONLY", true, true];
if (!isMultiplayer) then {
    {
        if (_x getVariable ["MP_ONLY",false] && !isNil "_x") then {
            deleteVehicle _x;
        };
    } forEach allUnits;
};

[format["Mission Core: %1", "DeleteMpOnlyVehicles"], true] call TRGM_GLOBAL_fnc_log;

[format["Mission Core: %1", "DoFollowRun"], true] call TRGM_GLOBAL_fnc_log;

[format["Mission Core: %1", "CoreFinished"], true] call TRGM_GLOBAL_fnc_log;
[25] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

TRGM_VAR_CoreCompleted = true; publicVariable "TRGM_VAR_CoreCompleted";
TRGM_VAR_BadPoints = 0; publicVariable "TRGM_VAR_BadPoints";
TRGM_VAR_BadPointsReason = ""; publicVariable "TRGM_VAR_BadPointsReason";
TRGM_VAR_MaxBadPoints = 1; publicVariable "TRGM_VAR_MaxBadPoints";
[format["Mission Core: %1", "BadPointsSet"], true] call TRGM_GLOBAL_fnc_log;

[30] spawn TRGM_GLOBAL_fnc_populateLoadingWait;

if (TRGM_VAR_iMissionIsCampaign) then {
    if (isServer) then {
        [] spawn TRGM_SERVER_fnc_initCampaign;
        [] spawn {
            [100] spawn TRGM_GLOBAL_fnc_populateLoadingWait;
            sleep 10;
            TRGM_VAR_PopulateLoadingWait_percentage = 0; publicVariable "TRGM_VAR_PopulateLoadingWait_percentage";
            waitUntil { TRGM_VAR_MissionLoaded; };
            [30] spawn TRGM_GLOBAL_fnc_populateLoadingWait;
        };
    };
} else {
    [] spawn TRGM_SERVER_fnc_startMission;
};
[format["Mission Core: %1", "InitCampaign/StartMission ran"], true] call TRGM_GLOBAL_fnc_log;

waitUntil { TRGM_VAR_MissionLoaded; };

[format["Mission Core: %1", "TRGM_VAR_MissionLoaded true"], true] call TRGM_GLOBAL_fnc_log;

{
    _x setVariable ["DontDelete",true];
} forEach nearestObjects [getMarkerPos "mrkHQ", ["all"], 2000];
[format["Mission Core: %1", "DontDeleteSet"], true] call TRGM_GLOBAL_fnc_log;

if (isMultiplayer && {!(TRGM_VAR_iMissionIsCampaign)}) then {
    [] spawn TRGM_SERVER_fnc_checkAnyPlayersAlive;
};

[format["Mission Core: %1", "NonAliveEndCheckRunning"], true] call TRGM_GLOBAL_fnc_log;

if (TRGM_VAR_iAllowNVG isEqualTo 0) then {
    {
        private _unit = _x;
        _unit addPrimaryWeaponItem "acc_flashlight";
        _unit enableGunLights "forceOn";
        {_unit unassignItem _x; _unit removeItem _x;} forEach TRGM_VAR_aNVClassNames;
    } forEach allUnits;
};
[format["Mission Core: %1", "NVGStateSet"], true] call TRGM_GLOBAL_fnc_log;

[] spawn TRGM_SERVER_fnc_playBaseRadioEffect;
[format["Mission Core: %1", "PlayBaseRadioEffect"], true] call TRGM_GLOBAL_fnc_log;

[] spawn TRGM_SERVER_fnc_weatherAffectsAI;
[] spawn TRGM_SERVER_fnc_sandStormEffect;


if (TRGM_VAR_iMissionIsCampaign) then {
    [] remoteExec ["TRGM_SERVER_fnc_postStartMission"];
};

[format["Mission Core: %1", "RunFlashLightState"], true] call TRGM_GLOBAL_fnc_log;

if (call TRGM_GETTER_fnc_bEnemyFlashlight) then {
    {
        if ((side _x) isEqualTo TRGM_VAR_EnemySide) then
        {
            if (isNil { _x getVariable "ambushUnit" }) then {
                private _unit = _x;
                _unit addPrimaryWeaponItem "acc_flashlight";
                _unit enableGunLights "forceOn";
                {_unit unassignItem _x; _unit removeItem _x;} forEach TRGM_VAR_aNVClassNames;
            };
        };
    } forEach allUnits;
};

waitUntil { TRGM_VAR_AllInitScriptsFinished; };
[format["Mission Core: %1", "Main Init Complete"], true] call TRGM_GLOBAL_fnc_log;
[100] spawn TRGM_GLOBAL_fnc_populateLoadingWait;
if !(TRGM_VAR_iMissionIsCampaign) then {
    [(localize "STR_TRGM2_startInfMission_SoItBegin")] call TRGM_GLOBAL_fnc_notifyGlobal;
};

true;