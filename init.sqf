"Init.sqf" call TRGM_GLOBAL_fnc_log;

if (isNil "TRGM_VAR_LoadingPercent") then {TRGM_VAR_LoadingPercent = 10; publicVariable "TRGM_VAR_LoadingPercent";};
if (isNil "TRGM_VAR_LoadingText") then {TRGM_VAR_LoadingText = "Loading..."; publicVariable "TRGM_VAR_LoadingText";};
if (isNil "TRGM_VAR_serverFinishedInitGlobal")  then {TRGM_VAR_serverFinishedInitGlobal = false; publicVariable "TRGM_VAR_serverFinishedInitGlobal";};

private _initVarsHandle = [] spawn TRGM_GLOBAL_fnc_initGlobalVars;
waitUntil {
   sleep 0.1;
   [TRGM_VAR_LoadingPercent, false, TRGM_VAR_LoadingText] call TRGM_GLOBAL_fnc_populateLoadingWait;
   TRGM_VAR_serverFinishedInitGlobal && scriptDone _initVarsHandle;
};

[80, false, "Finding admin player..."] call TRGM_GLOBAL_fnc_populateLoadingWait;

if (isServer) then {
   [] spawn {
      while {isNil "TRGM_VAR_AdminPlayer" || isNull TRGM_VAR_AdminPlayer} do {
         call TRGM_SERVER_fnc_setAdmin;
         sleep 30;
      };
   };
};

[90, false, "Finishing up..."] call TRGM_GLOBAL_fnc_populateLoadingWait;

TRGM_VAR_iTimeMultiplier call BIS_fnc_paramTimeAcceleration;

tf_give_personal_radio_to_regular_soldier = true; publicVariable "tf_give_personal_radio_to_regular_soldier";
tf_no_auto_long_range_radio = true; publicVariable "tf_no_auto_long_range_radio";

call FHQ_fnc_ttiInit;
call FHQ_fnc_ttiPostInit;

[
   west,
      [(localize "STR_TRGM2_Init_Mission"), ""],
      ["", ""],
   east,
      ["", ""],
      ["", ""],
   {true},
      [(localize "STR_TRGM2_Init_TRGM2Engine"), (localize "STR_TRGM2_Init_Credits"), localize "STR_TRGM2_Description_Author"],
      [(localize "STR_TRGM2_Init_TRGM2Engine"), (localize "STR_TRGM2_Init_ScriptsUsed"), localize "STR_TRGM2_TRGMSetUnitGlobalVars_ScriptsUsed"]
] call FHQ_fnc_ttAddBriefing;

[] spawn {
    uiSleep 1;
    [100, false, "Done"] call TRGM_GLOBAL_fnc_populateLoadingWait;
    uiSleep 2;
    TRGM_VAR_PopulateLoadingWait_percentage = 0; publicVariable "TRGM_VAR_PopulateLoadingWait_percentage";
};

waitUntil { TRGM_VAR_playerIsChoosingHQpos || TRGM_VAR_NeededObjectsAvailable; };

if (isServer && !TRGM_VAR_NeededObjectsAvailable) then {
   waitUntil { TRGM_VAR_HQPosFound };
   private _handle = [TRGM_VAR_foundHQPos] spawn TRGM_SERVER_fnc_createNeededObjects;
   waitUntil {scriptDone _handle};

   { [[_x], {(_this select 0) allowDamage false}] remoteExec ["call", _x]; } forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});

   waitUntil { sleep 10; TRGM_VAR_NeededObjectsAvailable; };

   {
      if (!isPlayer _x) then {
         private _safePos = [TRGM_VAR_foundHQPos, 0,25,15,0,0.15,0,[],[[TRGM_VAR_foundHQPos select 0, TRGM_VAR_foundHQPos select 1],[TRGM_VAR_foundHQPos select 0, TRGM_VAR_foundHQPos select 1]]] call TRGM_GLOBAL_fnc_findSafePos;
         [[_x, _safePos], {
            (_this select 0) setpos (_this select 1);
            (_this select 0) setdamage 0;
            (_this select 0) allowDamage true;
         }] remoteExec ["call", _x];
      } else {
            [[_x], {
               titleCut ["", "BLACK OUT", 5];
               (_this select 0) setpos [(TRGM_VAR_foundHQPos select 0) - 10, (TRGM_VAR_foundHQPos select 1)];
               (_this select 0) setdamage 0;
               (_this select 0) allowDamage true;
               titleCut ["", "BLACK IN", 5];
            }] remoteExec ["call", _x];
            [_x, [localize "STR_TRGM2_spawnCrewInVehicle", {
               private _vehicle = cursorObject;
               if (isNull _vehicle || _vehicle isKindOf "Helicopter") exitWith {
                  player setVariable ["TRGM_VAR_SpawningCrew", false];
                  hint localize "STR_TRGM2_spawnCrewInVehicle_notAHelicopter";
               };
               [_vehicle] call TRGM_GLOBAL_fnc_spawnCrew;
            }, [], 0, true, true, "", "_this isEqualTo player && (player distance laptop1) < 100 && player getVariable ['TRGM_VAR_SpawningCrew', false]"]] remoteExec ["addAction", 0, true];
      };
   } forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
};

if (isServer) then {
    TRGM_VAR_FirstSpottedHasHappend = false; publicVariable "TRGM_VAR_FirstSpottedHasHappend";
};

"Marker1" setMarkerTextLocal (localize "STR_TRGM2_Init_MarkerText_HQ"); //Head Quarters marker localize
"transportChopper" setMarkerTextLocal (localize "STR_TRGM2_Init_MarkerText_TransportChopper"); //Transport Chopper marker localize

if (isServer) then {
   [] spawn TRGM_GLOBAL_fnc_loadbalancer_init;
   [laptop1, [localize "STR_TRGM2_openDialogRequests_RequestUnitsVehicles", {player call TRGM_GUI_fnc_openDialogRequests;}, [], 0, true, true, "", "_this isEqualTo player"]] remoteExec ["addAction", 0, true];
   // [laptop1, [localize "STR_TRGM2_openDialogRequests_RequestUnitsVehicles", {
   //    player setVariable ["TRGM_VAR_SpawningCrew", true];
   //    hint format [localize "STR_TRGM2_spawnCrewInVehicle_lookAtAHelicopter", localize "STR_TRGM2_spawnCrewInVehicle"];
   //    [] spawn {
   //       waitUntil {!(player getVariable ["TRGM_VAR_SpawningCrew", false]) || (player distance laptop1) > 100};
   //       player setVariable ["TRGM_VAR_SpawningCrew", false];
   //    };
   // }, [], 0, true, true, "", "_this isEqualTo player"]] remoteExec ["addAction", 0, true];
   // [laptop1, [localize "STR_TRGM2_logMissionInfo", {player call TRGM_GLOBAL_fnc_copyMissionInfo;}, [], 0, true, true, "", "_this isEqualTo player"]] remoteExec ["addAction", 0, true];
   [laptop1, [localize "STR_TRGM2_debugOption_ReAddTransportActions", {if !(isNil "TRGM_VAR_transportHelosToGetActions") then {[TRGM_VAR_transportHelosToGetActions] call TRGM_GLOBAL_fnc_addTransportActions;};}, [], 0, true, true, "", "_this isEqualTo player"]] remoteExec ["addAction", 0, true];
   [laptop1, [localize "STR_TRGM2_adminOption_openObjectiveStatusManager", {player call TRGM_GUI_fnc_openDialogObjectiveManager;}, [], 0, true, true, "", "_this isEqualTo player && [player] call TRGM_CLIENT_fnc_isAdmin"]] remoteExec ["addAction", 0, true];
   [] spawn TRGM_SERVER_fnc_main;
};

true;